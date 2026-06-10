import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/fs/app_paths.dart';
import 'package:mylarium/data/local/local_path_resolver.dart';
import 'package:mylarium/data/local/tree_fs.dart';
import 'package:mylarium/data/local/tree_scanner.dart';

/// A [TreeFs] over a real local directory; "uris" are absolute paths. Counts
/// stage-out copies so tests can assert scratch reuse.
class _FakeTreeFs implements TreeFs {
  int copies = 0;

  @override
  Future<List<TreeEntry>> list(String dirUri) async {
    final dir = Directory(dirUri);
    return [
      for (final e in dir.listSync())
        TreeEntry(
          uri: e.path,
          name: e.path.split('/').last,
          isDir: e is Directory,
          length: e is File ? e.lengthSync() : 0,
          lastModified: e is File
              ? e.statSync().modified.millisecondsSinceEpoch
              : 0,
        ),
    ];
  }

  @override
  Future<Uint8List> readBytes(String fileUri, {int? start, int? count}) async {
    final raf = File(fileUri).openSync();
    try {
      if (start != null) raf.setPositionSync(start);
      return raf.readSync(count ?? raf.lengthSync());
    } finally {
      raf.closeSync();
    }
  }

  @override
  Future<void> copyToLocal(String fileUri, String destPath) async {
    copies++;
    await File(fileUri).copy(destPath);
  }

  @override
  Future<bool> exists(String uri, {required bool isDir}) async =>
      isDir ? Directory(uri).existsSync() : File(uri).existsSync();
}

void main() {
  late AppDatabase db;
  late Directory tmp;
  late Directory tree;
  late _FakeTreeFs fs;
  late TreeScanner scanner;
  var idCounter = 0;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tmp = await Directory.systemTemp.createTemp('tree_test');
    tree = await Directory('${tmp.path}/card').create();
    AppPaths.debugOverrideRoot = '${tmp.path}/support';
    fs = _FakeTreeFs();
    idCounter = 0;
    scanner = TreeScanner(
      db,
      fs,
      newId: () => 'id-${idCounter++}',
      nowMs: () => 1700000000000,
    );
    await db.upsertSource(SourcesCompanion(
      id: const Value('tree1'),
      kind: const Value('safTree'),
      handle: Value(tree.path),
      label: const Value('card'),
    ));
  });

  tearDown(() async {
    AppPaths.debugOverrideRoot = null;
    await db.close();
    if (tmp.existsSync()) await tmp.delete(recursive: true);
  });

  Future<Source> source() async => (await db.getSource('tree1'))!;

  File writeCbz(String relPath, Map<String, List<int>> entries) {
    final archive = Archive();
    entries.forEach((n, data) => archive.add(ArchiveFile.bytes(n, data)));
    final file = File('${tree.path}/$relPath')..createSync(recursive: true);
    file.writeAsBytesSync(ZipEncoder().encodeBytes(archive));
    return file;
  }

  const comicInfo = '''
<ComicInfo>
  <Series>Berserk Deluxe</Series>
  <Number>1</Number>
  <Manga>YesAndRightToLeft</Manga>
</ComicInfo>''';

  test('initial scan maps subfolders to series, ComicInfo overrides, '
      'non-archives and malformed archives are skipped', () async {
    writeCbz('Berserk/v01.cbz', {
      'p2.jpg': [2],
      'p1.jpg': [1],
      'ComicInfo.xml': utf8.encode(comicInfo),
    });
    writeCbz('Berserk/v02.cbz', {
      'p1.jpg': [1],
    });
    writeCbz('One Piece v3.cbz', {
      'p1.jpg': [1],
    }); // loose root file -> filename heuristics
    File('${tree.path}/notes.txt').writeAsStringSync('not an archive');
    writeCbz('Berserk/broken.cbz', {'readme.txt': [0]}); // no page images

    final result = await scanner.rescan(await source());

    expect(result.added, 3);
    expect(result.updated, 0);
    expect(result.removed, 0);
    expect(result.cancelled, isFalse);

    final rows = await db.localComicsForSource('tree1');
    expect(rows, hasLength(3));
    final v01 = rows.singleWhere((r) => r.treeDocPath!.endsWith('v01.cbz'));
    expect(v01.series, 'Berserk Deluxe'); // ComicInfo wins over the folder
    expect(v01.readingDirection, 'rtl');
    expect(v01.kind, 'safTree');
    expect(v01.managedPath, isNull);
    expect(jsonDecode(v01.pageOrder), ['p1.jpg', 'p2.jpg']);
    final v02 = rows.singleWhere((r) => r.treeDocPath!.endsWith('v02.cbz'));
    expect(v02.series, 'Berserk'); // the subfolder names the series
    final loose =
        rows.singleWhere((r) => r.treeDocPath!.endsWith('One Piece v3.cbz'));
    expect(loose.series, 'One Piece'); // filename heuristics for root files

    // Covers were written.
    expect(await db.getThumbnail('tree1', 'book', v01.id), isNotNull);

    // The scan staged nothing permanently: scratch holds no archives.
    final scratch = Directory('${tmp.path}/support/media/scratch');
    final leftovers = scratch.existsSync()
        ? scratch.listSync().where((e) => !e.path.endsWith('.src')).toList()
        : const <FileSystemEntity>[];
    expect(leftovers, isEmpty);
  });

  test('rescan reconciles added, modified, and removed files; an updated row '
      'keeps its id and a removed row keeps its BookState', () async {
    final v1 = writeCbz('Berserk/v01.cbz', {
      'p1.jpg': [1],
    });
    writeCbz('Berserk/v02.cbz', {
      'p1.jpg': [1],
    });
    await scanner.rescan(await source());
    final before = await db.localComicsForSource('tree1');
    final v1Row =
        before.singleWhere((r) => r.treeDocPath!.endsWith('v01.cbz'));
    final v2Row =
        before.singleWhere((r) => r.treeDocPath!.endsWith('v02.cbz'));
    await db.upsertBookState(BookStateCompanion.insert(
      sourceId: 'tree1',
      bookId: v2Row.id,
      status: const Value('completed'),
      updatedAt: 1,
    ));

    // Modify v01 (more pages + a newer mtime), delete v02, add v03.
    writeCbz('Berserk/v01.cbz', {
      'p1.jpg': [1],
      'p2.jpg': [2],
    });
    v1.setLastModifiedSync(DateTime.now().add(const Duration(minutes: 2)));
    File('${tree.path}/Berserk/v02.cbz').deleteSync();
    writeCbz('Berserk/v03.cbz', {
      'p1.jpg': [1],
    });

    final result = await scanner.rescan(await source());
    expect(result.added, 1);
    expect(result.updated, 1);
    expect(result.removed, 1);

    final after = await db.localComicsForSource('tree1');
    expect(after, hasLength(2));
    final v1After =
        after.singleWhere((r) => r.treeDocPath!.endsWith('v01.cbz'));
    expect(v1After.id, v1Row.id); // same row id: reading state stays attached
    expect(v1After.pagesCount, 2);
    expect(after.any((r) => r.treeDocPath!.endsWith('v02.cbz')), isFalse);
    // Reading history of the removed book survives (stats promise).
    expect(await db.getBookState('tree1', v2Row.id), isNotNull);
    expect(await db.getThumbnail('tree1', 'book', v2Row.id), isNull);
  });

  test('a cancelled pass never runs the removal sweep', () async {
    writeCbz('Berserk/v01.cbz', {
      'p1.jpg': [1],
    });
    writeCbz('Berserk/v02.cbz', {
      'p1.jpg': [1],
    });
    await scanner.rescan(await source());
    expect(await db.localComicsForSource('tree1'), hasLength(2));

    // Delete a file on the card, then cancel immediately: the walk is
    // incomplete, so the missing file's row must NOT be purged.
    File('${tree.path}/Berserk/v02.cbz').deleteSync();
    final result =
        await scanner.rescan(await source(), isCancelled: () => true);
    expect(result.cancelled, isTrue);
    expect(result.removed, 0);
    expect(await db.localComicsForSource('tree1'), hasLength(2));
  });

  test('an unchanged file is not re-imported on rescan', () async {
    writeCbz('Berserk/v01.cbz', {
      'p1.jpg': [1],
    });
    await scanner.rescan(await source());
    final result = await scanner.rescan(await source());
    expect(result.added, 0);
    expect(result.updated, 0);
    expect(result.removed, 0);
  });

  group('in-place reading via the resolver', () {
    test('stages a tree book to scratch once and reuses it', () async {
      writeCbz('Berserk/v01.cbz', {
        'p1.jpg': [1],
      });
      await scanner.rescan(await source());
      final row = (await db.localComicsForSource('tree1')).single;
      final copiesAfterScan = fs.copies;

      final resolver = LocalPathResolver(treeFs: fs);
      final path1 = await resolver.archivePath(row);
      expect(File(path1).existsSync(), isTrue);
      expect(fs.copies, copiesAfterScan + 1);

      // Second open: served from scratch, no new copy off the card.
      final path2 = await resolver.archivePath(row);
      expect(path2, path1);
      expect(fs.copies, copiesAfterScan + 1);
    });

    test('a changed source file invalidates the staged copy', () async {
      final f = writeCbz('Berserk/v01.cbz', {
        'p1.jpg': [1],
      });
      await scanner.rescan(await source());
      var row = (await db.localComicsForSource('tree1')).single;
      final resolver = LocalPathResolver(treeFs: fs);
      await resolver.archivePath(row);
      final copies = fs.copies;

      // The file changes on the card and a rescan refreshes the row.
      writeCbz('Berserk/v01.cbz', {
        'p1.jpg': [1],
        'p2.jpg': [2],
      });
      f.setLastModifiedSync(DateTime.now().add(const Duration(minutes: 2)));
      await scanner.rescan(await source());
      row = (await db.localComicsForSource('tree1')).single;

      await resolver.archivePath(row);
      expect(fs.copies, greaterThan(copies)); // stale staging was re-copied
    });
  });
}
