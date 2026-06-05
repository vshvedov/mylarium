import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/app/app.dart';
import 'package:mylarium/app/router.dart';
import 'package:mylarium/app/theme/theme_controller.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/storage/secure_store.dart';
import 'package:mylarium/data/komga/komga_api.dart';
import 'package:mylarium/data/komga/komga_providers.dart';

class _InMemorySecureStore extends SecureStore {
  final Map<String, String> _values = {};
  @override
  Future<void> write(String key, String value) async => _values[key] = value;
  @override
  Future<String?> read(String key) async => _values[key];
  @override
  Future<void> delete(String key) async => _values.remove(key);
}

void main() {
  testWidgets('boots to onboarding, connects, lands on the library home',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final settings = await db.getOrCreateSettings();
    addTearDown(db.close);

    final dio = Dio(BaseOptions(baseUrl: 'https://komga.test'));
    final adapter = DioAdapter(dio: dio);
    adapter.onGet('/api/v1/actuator/info', (s) => s.reply(200, {
          'build': {'version': '1.21.0'}
        }));
    adapter.onGet('/api/v2/users/me', (s) => s.reply(200, {
          'roles': ['PAGE_STREAMING', 'FILE_DOWNLOAD']
        }));
    adapter.onGet(
      '/api/v1/series',
      (s) => s.reply(200, {
        'content': [
          {
            'id': 's1',
            'libraryId': 'lib1',
            'name': 'Akira',
            'metadata': {'title': 'Akira', 'titleSort': 'Akira'},
          },
        ],
        'totalElements': 1,
        'number': 0,
        'last': true,
      }),
      queryParameters: {'page': 0, 'size': 50},
    );
    // Home rails fetch these on landing.
    Map<String, Object?> page(List<Map<String, Object?>> content) => {
          'content': content,
          'totalElements': content.length,
          'number': 0,
          'last': true,
        };
    const akira = {
      'id': 's1',
      'libraryId': 'lib1',
      'name': 'Akira',
      'metadata': {'title': 'Akira', 'titleSort': 'Akira'},
    };
    adapter.onGet('/api/v1/books/ondeck', (s) => s.reply(200, page(const [])),
        queryParameters: {'page': 0, 'size': 20});
    adapter.onGet('/api/v1/series/new', (s) => s.reply(200, page(const [akira])),
        queryParameters: {'page': 0, 'size': 20});
    adapter.onGet('/api/v1/series/updated', (s) => s.reply(200, page(const [])),
        queryParameters: {'page': 0, 'size': 20});

    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        initialSettingsProvider.overrideWithValue(settings),
        // No source yet -> boot to onboarding.
        initialLocationProvider.overrideWithValue('/onboarding'),
        secureStoreProvider.overrideWithValue(_InMemorySecureStore()),
        komgaApiFactoryProvider.overrideWithValue(
          ({required String baseUrl, required auth}) => KomgaApi(dio),
        ),
      ],
      child: const MylariumApp(),
    ));
    await tester.pumpAndSettle();

    // Onboarding opens on the source picker.
    expect(find.text('Mylarium'), findsOneWidget);
    expect(find.text('Komga'), findsOneWidget);

    // Choose Komga -> the connect form.
    await tester.tap(find.text('Komga'));
    await tester.pumpAndSettle();
    expect(find.text('Connect to Komga'), findsOneWidget);

    // Fill the form (default method is API key: url field + key field).
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'komga.test');
    await tester.enterText(fields.at(1), 'sek');

    await tester.tap(find.widgetWithText(FilledButton, 'Connect'));
    await tester.pumpAndSettle();

    // Navigated to the library home (NOT the debug source list), with the
    // recently-added rail showing the fetched series.
    expect(find.text('Mylarium'), findsOneWidget);
    expect(find.text('Sources (debug)'), findsNothing);
    expect(find.text('Recently added'), findsOneWidget);
    expect(find.text('Akira'), findsOneWidget);

    // Tear down the widget tree inside the test so stream subscriptions and any
    // mock-adapter timers are disposed before the pending-timer invariant runs.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
