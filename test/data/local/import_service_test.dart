import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/fs/app_paths.dart';
import 'package:mylarium/data/local/import_service.dart';

void main() {
  late AppDatabase db;
  late Directory tmp;
  late ImportService service;
  var idCounter = 0;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tmp = await Directory.systemTemp.createTemp('import_test');
    AppPaths.debugOverrideRoot = tmp.path;
    idCounter = 0;
    service = ImportService(
      db,
      newId: () => 'id-${idCounter++}',
      nowMs: () => 1700000000000,
    );
  });

  tearDown(() async {
    AppPaths.debugOverrideRoot = null;
    await db.close();
    if (tmp.existsSync()) await tmp.delete(recursive: true);
  });

  String writeCbz(String name, Map<String, List<int>> entries) {
    final archive = Archive();
    entries.forEach((n, data) => archive.add(ArchiveFile.bytes(n, data)));
    final path = '${tmp.path}/$name';
    File(path).writeAsBytesSync(ZipEncoder().encodeBytes(archive));
    return path;
  }

  PickedFile pick(String path) =>
      PickedFile(path: path, name: path.split('/').last);

  const comicInfo = '''
<ComicInfo>
  <Series>Berserk</Series>
  <Number>3</Number>
  <Title>The Fall</Title>
  <AgeRating>Mature 17+</AgeRating>
  <Manga>YesAndRightToLeft</Manga>
</ComicInfo>''';

  test('imports a ComicInfo-tagged CBZ with RTL and natural page order',
      () async {
    final path = writeCbz('Berserk_003.cbz', {
      'page10.jpg': [10],
      'page2.jpg': [2],
      'page1.jpg': [1],
      'ComicInfo.xml': utf8.encode(comicInfo),
    });

    final result = await service.importFiles([pick(path)]);
    expect(result.files.single.outcome, ImportOutcome.imported);

    final sourceId = (await db.localFilesSource())!.id;
    final comic =
        (await db.watchLocalBooks(sourceId, 'Berserk').first).single;
    expect(comic.series, 'Berserk');
    expect(comic.number, '3');
    expect(comic.title, 'The Fall');
    expect(comic.readingDirection, 'rtl');
    expect(comic.ageRating, 17);
    expect(comic.pagesCount, 3);
    expect(jsonDecode(comic.pageOrder),
        ['page1.jpg', 'page2.jpg', 'page10.jpg']);
    expect(comic.kind, 'localCopy');

    // The copy exists in the media store at the recorded relative path.
    final abs = await AppPaths.resolve(comic.managedPath!);
    expect(File(abs).existsSync(), isTrue);

    // A cover thumbnail row was written for the book.
    final thumb =
        await db.getThumbnail(comic.sourceId, 'book', comic.id);
    expect(thumb, isNotNull);
    expect(thumb!.bytes, [1]); // first page inline (small)
  });

  test('falls back to filename heuristics without ComicInfo', () async {
    final path = writeCbz('One Piece v12 c100.cbz', {
      'a.jpg': [1],
    });
    await service.importFiles([pick(path)]);
    final sourceId = (await db.localFilesSource())!.id;
    final books = await db.watchLocalBooks(sourceId, 'One Piece').first;
    expect(books.single.number, '100');
    expect(books.single.volume, 12);
    expect(books.single.readingDirection, 'ltr');
    expect(books.single.numberSort, 100);
  });

  test('rejects a renamed non-archive by magic bytes', () async {
    final path = '${tmp.path}/fake.cbz';
    File(path).writeAsBytesSync(utf8.encode('plain text, not a zip'));
    final result = await service.importFiles([pick(path)]);
    expect(result.files.single.outcome, ImportOutcome.notAnArchive);
    expect(await db.localFilesSource(), isNotNull); // source row still created
  });

  test('quarantines a malformed archive and continues the batch', () async {
    final bad = writeCbz('bad.cbz', {'notes.txt': [1]}); // zip, no images
    final good = writeCbz('good.cbz', {'p1.jpg': [1]});
    final result = await service.importFiles([pick(bad), pick(good)]);
    expect(result.files[0].outcome, ImportOutcome.malformed);
    expect(result.files[1].outcome, ImportOutcome.imported);
    expect(result.importedCount, 1);
  });

  test('detects a duplicate import by size and hash', () async {
    final path = writeCbz('dup.cbz', {'p1.jpg': [1, 2, 3]});
    final first = await service.importFiles([pick(path)]);
    expect(first.files.single.outcome, ImportOutcome.imported);
    final second = await service.importFiles([pick(path)]);
    expect(second.files.single.outcome, ImportOutcome.duplicate);
    final sourceId = (await db.localFilesSource())!.id;
    final groups = await db.watchLocalSeries(sourceId).first;
    expect(groups.single.booksCount, 1);
  });

  test('ensureLocalSource is idempotent', () async {
    final a = await service.ensureLocalSource();
    final b = await service.ensureLocalSource();
    expect(a, b);
    final sources = await db.allSources();
    expect(sources, hasLength(1));
    expect(sources.single.kind, 'local');
  });

  test('a missing file reports failed, not a crash', () async {
    final result = await service
        .importFiles([const PickedFile(path: '/nope/x.cbz', name: 'x.cbz')]);
    expect(result.files.single.outcome, ImportOutcome.failed);
  });

  test('deleteImported removes file, thumbnail, and row but keeps BookState',
      () async {
    final path = writeCbz('gone.cbz', {'p1.jpg': [1]});
    final result = await service.importFiles([pick(path)]);
    final comicId = result.files.single.comicId!;
    final sourceId = (await db.localFilesSource())!.id;
    await db.upsertBookState(BookStateCompanion.insert(
      sourceId: sourceId,
      bookId: comicId,
      status: const Value('completed'),
      updatedAt: 1,
    ));

    final comic = (await db.getLocalComic(comicId))!;
    final abs = await AppPaths.resolve(comic.managedPath!);
    expect(File(abs).existsSync(), isTrue);

    await service.deleteImported(comic);

    expect(File(abs).existsSync(), isFalse);
    expect(await db.getLocalComic(comicId), isNull);
    expect(await db.getThumbnail(sourceId, 'book', comicId), isNull);
    // Read history survives for stats.
    expect(await db.getBookState(sourceId, comicId), isNotNull);
  });
}
