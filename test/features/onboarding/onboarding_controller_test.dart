import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mylarium/app/theme/theme_controller.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/storage/secure_store.dart';
import 'package:mylarium/data/komga/komga_api.dart';
import 'package:mylarium/data/komga/komga_providers.dart';
import 'package:mylarium/data/source/source_providers.dart';
import 'package:mylarium/features/onboarding/connection_result.dart';
import 'package:mylarium/features/onboarding/onboarding_controller.dart';

/// In-memory [SecureStore] so credentials never touch the platform Keychain.
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
  late AppDatabase db;
  late Dio dio;
  late DioAdapter adapter;
  late _InMemorySecureStore secure;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.getOrCreateSettings();
    dio = Dio(BaseOptions(baseUrl: 'https://komga.test'));
    adapter = DioAdapter(dio: dio);
    secure = _InMemorySecureStore();
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      secureStoreProvider.overrideWithValue(secure),
      komgaApiFactoryProvider.overrideWithValue(
        ({required String baseUrl, required auth}) => KomgaApi(dio),
      ),
    ]);
    // Keep the auto-dispose controller alive across reads within a test.
    container.listen(onboardingControllerProvider, (_, _) {},
        fireImmediately: true);
  });
  tearDown(() {
    container.dispose();
    db.close();
  });

  OnboardingController controller() =>
      container.read(onboardingControllerProvider.notifier);
  ConnectionResult? result() =>
      container.read(onboardingControllerProvider).valueOrNull;

  void mockVersion(String v) => adapter.onGet(
        '/api/v1/actuator/info',
        (s) => s.reply(200, {
          'build': {'version': v}
        }),
      );

  void mockRoles(List<String> roles) => adapter.onGet(
        '/api/v2/users/me',
        (s) => s.reply(200, {'roles': roles}),
      );

  test('an empty URL is rejected before any request', () async {
    await controller().connect(url: '', method: AuthMethod.basic);
    expect(result(), isA<ConnInvalidUrl>());
  });

  test('a valid connection persists the source and credential', () async {
    mockVersion('1.21.0');
    mockRoles(['PAGE_STREAMING', 'FILE_DOWNLOAD']);

    await controller().connect(
      url: 'komga.test',
      method: AuthMethod.apiKey,
      apiKey: 'sek',
    );

    final r = result();
    expect(r, isA<ConnSuccess>());
    expect(await db.hasAnySource(), isTrue);
    final sourceId = (r! as ConnSuccess).sourceId;
    final cred =
        await container.read(komgaCredentialStoreProvider).read(sourceId);
    expect(cred, isNotNull);
  });

  test('a successful connection becomes the active source without a restart',
      () async {
    mockVersion('1.21.0');
    mockRoles(['PAGE_STREAMING', 'FILE_DOWNLOAD']);

    // Mirror the running app: the home screen reads the active source before
    // onboarding completes, so the keepAlive provider has already resolved to
    // null (no sources yet). Force that cached null here.
    final before = await container.read(activeSourceIdProvider.future);
    expect(before, isNull);

    await controller().connect(
      url: 'komga.test',
      method: AuthMethod.apiKey,
      apiKey: 'sek',
    );

    final r = result();
    expect(r, isA<ConnSuccess>());
    final sourceId = (r! as ConnSuccess).sourceId;

    // The freshly connected source must be active immediately, with no restart
    // or manual invalidation. Without the fix this stays null until rebuild.
    expect(container.read(activeSourceIdProvider).valueOrNull, sourceId);
  });

  test('an API key on a pre-1.20.0 server steers to password', () async {
    mockVersion('1.19.0');

    await controller().connect(
      url: 'komga.test',
      method: AuthMethod.apiKey,
      apiKey: 'sek',
    );

    expect(result(), isA<ConnVersionTooOldForApiKey>());
    expect(await db.hasAnySource(), isFalse);
  });

  test('a missing role names which role is missing', () async {
    mockVersion('1.21.0');
    mockRoles(['PAGE_STREAMING']);

    await controller().connect(
      url: 'komga.test',
      method: AuthMethod.basic,
      username: 'a',
      password: 'b',
    );

    final r = result();
    expect(r, isA<ConnMissingRoles>());
    expect((r! as ConnMissingRoles).missing, {'FILE_DOWNLOAD'});
    expect(await db.hasAnySource(), isFalse);
  });

  test('bad credentials surface as unauthorized', () async {
    mockVersion('1.21.0');
    adapter.onGet('/api/v2/users/me', (s) => s.reply(401, {'error': 'no'}));

    await controller().connect(
      url: 'komga.test',
      method: AuthMethod.basic,
      username: 'a',
      password: 'b',
    );

    expect(result(), isA<ConnUnauthorized>());
  });

  test('an unreachable server is reported as such', () async {
    mockVersion('1.21.0');
    adapter.onGet(
      '/api/v2/users/me',
      (s) => s.throws(
        503,
        DioException(
          requestOptions: RequestOptions(path: '/api/v2/users/me'),
          type: DioExceptionType.connectionError,
        ),
      ),
    );

    await controller().connect(
      url: 'komga.test',
      method: AuthMethod.basic,
      username: 'a',
      password: 'b',
    );

    expect(result(), isA<ConnUnreachable>());
  });

  test('a certificate failure is reported distinctly', () async {
    mockVersion('1.21.0');
    adapter.onGet(
      '/api/v2/users/me',
      (s) => s.throws(
        495,
        DioException(
          requestOptions: RequestOptions(path: '/api/v2/users/me'),
          type: DioExceptionType.badCertificate,
        ),
      ),
    );

    await controller().connect(
      url: 'komga.test',
      method: AuthMethod.basic,
      username: 'a',
      password: 'b',
    );

    expect(result(), isA<ConnTlsError>());
  });
}
