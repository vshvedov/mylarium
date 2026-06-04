import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/archive/magic_bytes.dart';

void main() {
  Uint8List u(List<int> b) => Uint8List.fromList(b);

  test('sniffs zip and rar signatures', () {
    expect(sniffArchiveFormat(u([0x50, 0x4B, 0x03, 0x04, 0, 0, 0, 0])),
        ArchiveFormat.zip);
    expect(
        sniffArchiveFormat(u([0x52, 0x61, 0x72, 0x21, 0x1A, 0x07, 0x00, 0x00])),
        ArchiveFormat.rar);
    expect(sniffArchiveFormat(u([1, 2, 3, 4])), ArchiveFormat.unknown);
    expect(sniffArchiveFormat(u([])), ArchiveFormat.unknown);
  });

  test('isImageEntry accepts images, rejects junk', () {
    expect(isImageEntry('001.jpg'), isTrue);
    expect(isImageEntry('a/b/page.PNG'), isTrue);
    expect(isImageEntry('cover.webp'), isTrue);
    expect(isImageEntry('dir/'), isFalse);
    expect(isImageEntry('ComicInfo.xml'), isFalse);
    expect(isImageEntry('__MACOSX/._001.jpg'), isFalse);
    expect(isImageEntry('.hidden.jpg'), isFalse);
    expect(isImageEntry('noext'), isFalse);
  });
}
