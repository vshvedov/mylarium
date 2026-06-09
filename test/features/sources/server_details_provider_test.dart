import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/network/content_exception.dart';
import 'package:mylarium/data/source/content_api.dart';
import 'package:mylarium/data/source/models/server_details.dart';
import 'package:mylarium/data/source/source_providers.dart';
import 'package:mylarium/features/sources/server_details.dart';

import '../../support/test_scope.dart';

/// Minimal ContentApi that only answers fetchServerFacts; every other member
/// throws via noSuchMethod (the provider never calls them).
class _FakeApi implements ContentApi {
  _FakeApi({this.facts, this.throwUnreachable = false});
  final ServerFacts? facts;
  final bool throwUnreachable;

  @override
  Future<ServerFacts> fetchServerFacts() async {
    if (throwUnreachable) {
      throw const ContentException(ContentErrorKind.unreachable, 'down');
    }
    return facts ?? ServerFacts.empty;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  Future<ProviderContainer> containerWith(
    TestScope scope,
    Override apiOverride,
  ) async {
    final container = ProviderContainer(
      overrides: [...scope.overrides, apiOverride],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('online: merges connection fields with fetched facts', () async {
    final scope = await TestScope.create();
    addTearDown(scope.db.close);
    await scope.db.upsertSource(const SourcesCompanion(
      id: Value('s1'),
      kind: Value('komga'),
      label: Value('My Server'),
      baseUrl: Value('https://komga.test'),
    ));

    final container = await containerWith(
      scope,
      contentApiForProvider('s1').overrideWith(
        (ref) async => _FakeApi(
          facts: const ServerFacts(version: '1.21.0', account: 'me'),
        ),
      ),
    );

    final d = await container.read(serverDetailsProvider('s1').future);
    expect(d.online, isTrue);
    expect(d.label, 'My Server');
    expect(d.baseUrl, 'https://komga.test');
    expect(d.facts.version, '1.21.0');
    expect(d.facts.account, 'me');
  });

  test('offline: ContentException yields online:false, empty facts', () async {
    final scope = await TestScope.create();
    addTearDown(scope.db.close);
    await scope.db.upsertSource(const SourcesCompanion(
      id: Value('s1'),
      kind: Value('komga'),
      label: Value('My Server'),
      baseUrl: Value('https://komga.test'),
    ));

    final container = await containerWith(
      scope,
      contentApiForProvider('s1')
          .overrideWith((ref) async => _FakeApi(throwUnreachable: true)),
    );

    final d = await container.read(serverDetailsProvider('s1').future);
    expect(d.online, isFalse);
    expect(d.label, 'My Server');
    expect(d.facts.version, isNull);
  });

  test('no client: online:false', () async {
    final scope = await TestScope.create();
    addTearDown(scope.db.close);
    await scope.db.upsertSource(const SourcesCompanion(
      id: Value('s1'),
      kind: Value('komga'),
      label: Value('My Server'),
    ));

    final container = await containerWith(
      scope,
      contentApiForProvider('s1').overrideWith((ref) async => null),
    );

    final d = await container.read(serverDetailsProvider('s1').future);
    expect(d.online, isFalse);
  });
}
