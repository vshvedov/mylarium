import 'dart:io';

import 'package:archive/archive.dart' hide ArchiveException;
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/archive/archive_extractor.dart' show ArchiveException;
import 'package:mylarium/core/archive/archive_reader.dart';

void main() {
  late Directory tmp;

  setUp(() async => tmp = await Directory.systemTemp.createTemp('reader_test'));
  tearDown(() async => tmp.existsSync()
      ? await tmp.delete(recursive: true)
      : null);

  String writeCbz(Map<String, List<int>> entries) {
    final archive = Archive();
    entries.forEach((name, data) => archive.add(ArchiveFile.bytes(name, data)));
    final bytes = ZipEncoder().encodeBytes(archive);
    final path = '${tmp.path}/book.cbz';
    File(path).writeAsBytesSync(bytes);
    return path;
  }

  test('serves each entry byte-for-byte', () async {
    final reader = ArchiveReader(writeCbz({
      '001.jpg': [1, 2, 3],
      '002.jpg': [4, 5, 6],
      '003.jpg': [7, 8, 9, 10],
    }));
    addTearDown(reader.dispose);

    expect(await reader.page('001.jpg'), [1, 2, 3]);
    expect(await reader.page('002.jpg'), [4, 5, 6]);
    expect(await reader.page('003.jpg'), [7, 8, 9, 10]);
  });

  test('interleaved and repeated reads stay correct (cache + worker)', () async {
    final reader = ArchiveReader(writeCbz({
      'a.jpg': [10, 20],
      'b.jpg': [30, 40, 50],
    }));
    addTearDown(reader.dispose);

    // Read a, then b, then a again (a second time should hit the in-memory LRU).
    expect(await reader.page('a.jpg'), [10, 20]);
    expect(await reader.page('b.jpg'), [30, 40, 50]);
    expect(await reader.page('a.jpg'), [10, 20]);
    expect(await reader.page('b.jpg'), [30, 40, 50]);
  });

  test('concurrent reads of distinct entries all resolve', () async {
    final reader = ArchiveReader(writeCbz({
      '1.jpg': [1],
      '2.jpg': [2],
      '3.jpg': [3],
      '4.jpg': [4],
    }));
    addTearDown(reader.dispose);

    final results = await Future.wait([
      reader.page('1.jpg'),
      reader.page('2.jpg'),
      reader.page('3.jpg'),
      reader.page('4.jpg'),
    ]);
    expect(results.map((b) => b.first).toList(), [1, 2, 3, 4]);
  });

  test('a missing entry throws ArchiveException', () async {
    final reader = ArchiveReader(writeCbz({'only.jpg': [1]}));
    addTearDown(reader.dispose);

    await expectLater(
      reader.page('missing.jpg'),
      throwsA(isA<ArchiveException>()),
    );
    // The reader stays usable after a missing-entry error.
    expect(await reader.page('only.jpg'), [1]);
  });

  test('an unknown container throws on read', () async {
    final path = '${tmp.path}/junk.cbz';
    File(path).writeAsBytesSync([1, 2, 3, 4, 5, 6, 7, 8]);
    final reader = ArchiveReader(path);
    addTearDown(reader.dispose);

    await expectLater(
      reader.page('whatever.jpg'),
      throwsA(isA<ArchiveException>()),
    );
  });

  test('a disposed reader rejects further reads', () async {
    final reader = ArchiveReader(writeCbz({'a.jpg': [1]}));
    expect(await reader.page('a.jpg'), [1]);
    await reader.dispose();
    await expectLater(reader.page('a.jpg'), throwsStateError);
  });
}
