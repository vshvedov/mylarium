import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/archive/archive_extractor.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/fs/app_paths.dart';
import 'package:mylarium/features/offline/offline_cache.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory installA;
  late Directory installB;

  setUp(() async {
    installA = await Directory.systemTemp.createTemp('install_a');
    installB = await Directory.systemTemp.createTemp('install_b');
  });
  tearDown(() async {
    AppPaths.debugOverrideRoot = null;
    if (installA.existsSync()) await installA.delete(recursive: true);
    if (installB.existsSync()) await installB.delete(recursive: true);
  });

  test('a downloaded CBZ reads offline after restart + reinstall', () async {
    // --- First install: download lands, record a RELATIVE path. ---
    AppPaths.debugOverrideRoot = installA.path;
    final rel = AppPaths.archiveRelativePath('s1', 'b1');

    final archive = Archive()
      ..add(ArchiveFile.bytes('002.jpg', [4, 5, 6]))
      ..add(ArchiveFile.bytes('001.jpg', [1, 2, 3]));
    final cbz = ZipEncoder().encodeBytes(archive);
    final fileA = await AppPaths.prepareFile(rel);
    await fileA.writeAsBytes(cbz);

    final dbPath = p.join(installA.path, 'app.sqlite');
    final db1 = AppDatabase(NativeDatabase(File(dbPath)));
    await db1.upsertBook(const BooksCompanion(
      sourceId: Value('s1'),
      id: Value('b1'),
      seriesId: Value('ser1'),
      libraryId: Value('lib1'),
      title: Value('Vol 1'),
      number: Value('1'),
    ));
    await db1.upsertCachedAsset(CachedAssetsCompanion(
      sourceId: const Value('s1'),
      bookId: const Value('b1'),
      relativePath: Value(rel),
      sizeBytes: Value(cbz.length),
      lastAccessedAt: const Value(1),
    ));
    await db1.close();

    // --- Reinstall: the container path changes; media + db move with it, but
    // the stored path is RELATIVE so it must still resolve. ---
    final dbPathB = p.join(installB.path, 'app.sqlite');
    await File(dbPath).copy(dbPathB);
    final relAbsB = p.join(installB.path, rel);
    Directory(p.dirname(relAbsB)).createSync(recursive: true);
    File(relAbsB).writeAsBytesSync(cbz);
    AppPaths.debugOverrideRoot = installB.path;

    final db2 = AppDatabase(NativeDatabase(File(dbPathB)));
    addTearDown(db2.close);
    final cache = OfflineCacheManager(db2);

    expect(await cache.isAvailable('s1', 'b1'), isTrue);
    final resolved = await cache.archivePath('s1', 'b1');
    expect(resolved, relAbsB, reason: 'relative path re-resolves to new install');

    // The book metadata survived (offline open can resolve seriesId).
    expect((await db2.getBook('s1', 'b1'))?.seriesId, 'ser1');

    // The archive reads offline, natural-sorted, from the new install path.
    const extractor = ArchiveExtractor();
    final entries = await extractor.entries(resolved!);
    expect(entries, ['001.jpg', '002.jpg']);
    expect(await extractor.page(resolved, '001.jpg'), [1, 2, 3]);
  });
}
