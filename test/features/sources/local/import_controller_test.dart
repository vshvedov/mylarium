import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/app/theme/theme_controller.dart'
    show appDatabaseProvider;
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/core/fs/app_paths.dart';
import 'package:mylarium/data/local/import_service.dart';
import 'package:mylarium/features/sources/local/import_controller.dart';

void main() {
  late AppDatabase db;
  late Directory tmp;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tmp = await Directory.systemTemp.createTemp('import_ctrl');
    AppPaths.debugOverrideRoot = tmp.path;
  });

  tearDown(() async {
    AppPaths.debugOverrideRoot = null;
    await db.close();
    if (tmp.existsSync()) await tmp.delete(recursive: true);
  });

  String writeCbz(String name) {
    final archive = Archive()..add(ArchiveFile.bytes('p1.jpg', [1]));
    final path = '${tmp.path}/$name';
    File(path).writeAsBytesSync(ZipEncoder().encodeBytes(archive));
    return path;
  }

  test('importFiles walks active states and ends done with the batch result',
      () async {
    final c = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)]);
    addTearDown(c.dispose);

    final seen = <ImportRunState>[];
    c.listen(importControllerProvider, (_, next) => seen.add(next));

    final files = [
      PickedFile(path: writeCbz('a.cbz'), name: 'a.cbz'),
      PickedFile(path: '${tmp.path}/junk.cbz', name: 'junk.cbz'),
    ];
    File(files[1].path).writeAsBytesSync([1, 2, 3]);

    final result =
        await c.read(importControllerProvider.notifier).importFiles(files);

    expect(result.files, hasLength(2));
    expect(result.importedCount, 1);
    expect(seen.whereType<ImportRunActive>(), hasLength(2));
    expect(seen.last, isA<ImportRunDone>());
    expect(c.read(importControllerProvider), isA<ImportRunDone>());

    // The local source row exists and is discoverable for the active-source
    // provider re-read.
    expect(await db.localFilesSource(), isNotNull);
  });
}
