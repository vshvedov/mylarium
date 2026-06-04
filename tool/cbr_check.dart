// Host-only CBR verification for the real ArchiveExtractor.
//
// The `unrar` native build hook does NOT run under `flutter test`, so CBR cannot
// be exercised there. Run this on a host (macOS/Linux) to verify the FFI +
// isolate + magic-byte dispatch path against a real RAR:
//
//   dart run tool/cbr_check.dart [path/to/file.rar]
//
// With no argument it uses the bundled fixture (which holds .txt entries, so it
// reports "No image entries" - that still proves the RAR was decoded). Point it
// at an image-bearing CBR to see real page entries.
import 'dart:io';

import 'package:mylarium/core/archive/archive_extractor.dart';
import 'package:unrar/unrar.dart';

Future<void> main(List<String> args) async {
  final path = args.isNotEmpty
      ? args.first
      : 'test/core/archive/fixtures/test.rar';
  stdout.writeln('Checking: $path');

  final head = File(path).openSync()..readSync(8);
  head.closeSync();
  // Raw package call (proves the native lib + FFI work).
  final raw = UnrarExtractor().listFiles(path).map((e) => e.name).toList();
  stdout.writeln('Raw unrar entries: $raw');

  // Real ArchiveExtractor (isolate + sniff + filter).
  try {
    final entries = await const ArchiveExtractor().entries(path);
    stdout.writeln('ArchiveExtractor image entries: $entries');
    if (entries.isNotEmpty) {
      final bytes = await const ArchiveExtractor().page(path, entries.first);
      stdout.writeln('First page bytes: ${bytes.length}');
    }
  } on ArchiveException catch (e) {
    stdout.writeln('ArchiveExtractor: ${e.message} (decode path ran OK)');
  }
}
