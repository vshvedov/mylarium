import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/theme_controller.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/fs/app_paths.dart';
import 'package:mylarium/core/security/app_lock.dart';
import 'package:mylarium/features/gallery/gallery_controller.dart';

Uint8List _png() => Uint8List.fromList(const [1, 2, 3, 4, 5]);

void main() {
  late AppDatabase db;
  late Directory tmp;
  late CapturesRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tmp = await Directory.systemTemp.createTemp('captures_test');
    AppPaths.debugOverrideRoot = tmp.path;
    repo = CapturesRepository(db);
  });
  tearDown(() async {
    AppPaths.debugOverrideRoot = null;
    await db.close();
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  test('save writes the PNG and inserts one row; watch returns it', () async {
    final capture = await repo.save(
      sourceId: 's',
      seriesId: 'se',
      bookId: 'b',
      bookTitle: 'Book',
      pageNumber: 4,
      pngBytes: _png(),
      width: 120,
      height: 240,
    );

    expect(File(capture.absolutePath).existsSync(), isTrue);
    expect(capture.pageNumber, 4);
    expect(capture.bookTitle, 'Book');

    final rows = await db.watchCaptures().first;
    expect(rows, hasLength(1));
    expect(rows.single.relativePath, capture.relativePath);

    final list = await repo.watch().first;
    expect(list, hasLength(1));
    expect(list.single.absolutePath, capture.absolutePath);
  });

  test('save stamps libraryId + seriesTitle from the cache', () async {
    await db.upsertBook(BooksCompanion.insert(
      sourceId: 's',
      id: 'b',
      seriesId: 'se',
      libraryId: 'lib1',
      title: 'Book',
      number: '1',
    ));
    await db.upsertSeries(SeriesCompanion.insert(
      sourceId: 's',
      id: 'se',
      libraryId: 'lib1',
      title: 'My Series',
      titleSort: 'My Series',
    ));
    final capture = await repo.save(
      sourceId: 's',
      seriesId: 'se',
      bookId: 'b',
      pageNumber: 0,
      pngBytes: _png(),
      width: 10,
      height: 10,
    );
    expect(capture.libraryId, 'lib1');
    expect(capture.seriesTitle, 'My Series');
  });

  test('delete removes both the row and the file', () async {
    final capture = await repo.save(
      sourceId: 's',
      seriesId: 'se',
      bookId: 'b',
      pageNumber: 0,
      pngBytes: _png(),
      width: 10,
      height: 10,
    );
    expect(File(capture.absolutePath).existsSync(), isTrue);

    await repo.delete(capture.id);

    expect(await db.getCapture(capture.id), isNull);
    expect(File(capture.absolutePath).existsSync(), isFalse);
  });

  test('watch returns captures newest first', () async {
    await db.insertCapture(CapturesCompanion.insert(
      id: 'old',
      sourceId: 's',
      seriesId: 'se',
      bookId: 'b',
      pageNumber: 0,
      relativePath: 'media/captures/s/b/old.png',
      width: 1,
      height: 1,
      capturedAt: 1000,
    ));
    await db.insertCapture(CapturesCompanion.insert(
      id: 'new',
      sourceId: 's',
      seriesId: 'se',
      bookId: 'b',
      pageNumber: 1,
      relativePath: 'media/captures/s/b/new.png',
      width: 1,
      height: 1,
      capturedAt: 2000,
    ));
    final list = await repo.watch().first;
    expect(list.map((c) => c.id).toList(), ['new', 'old']);
  });

  test('captures provider hides captures whose library is locked', () async {
    await db.upsertSource(const SourcesCompanion(
      id: Value('s'),
      kind: Value('komga'),
      label: Value('Test'),
    ));
    await db.insertCapture(CapturesCompanion.insert(
      id: 'open',
      sourceId: 's',
      seriesId: 'se',
      bookId: 'b1',
      libraryId: const Value('openLib'),
      pageNumber: 0,
      relativePath: 'media/captures/s/b1/open.png',
      width: 1,
      height: 1,
      capturedAt: 2000,
    ));
    await db.insertCapture(CapturesCompanion.insert(
      id: 'hidden',
      sourceId: 's',
      seriesId: 'se',
      bookId: 'b2',
      libraryId: const Value('lockedLib'),
      pageNumber: 0,
      relativePath: 'media/captures/s/b2/hidden.png',
      width: 1,
      height: 1,
      capturedAt: 1000,
    ));

    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ]);
    addTearDown(container.dispose);

    await container.read(appLockProvider.notifier).lock('lockedLib');

    final list = await container.read(capturesProvider.future);
    expect(list.map((c) => c.id).toList(), ['open']);
  });

  test('captureChapterAvailable: false when the chapter is gone, true when the '
      'book still exists', () async {
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
    ]);
    addTearDown(container.dispose);

    // No book row and no cached archive -> chapter is gone -> hide "Go to page".
    expect(
      await container.read(captureChapterAvailableProvider('s', 'gone').future),
      isFalse,
    );

    // Book still in the catalog -> chapter openable -> offer "Go to page".
    await db.upsertBook(BooksCompanion.insert(
      sourceId: 's',
      id: 'b',
      seriesId: 'se',
      libraryId: 'lib1',
      title: 'Book',
      number: '1',
    ));
    expect(
      await container.read(captureChapterAvailableProvider('s', 'b').future),
      isTrue,
    );
  });
}
