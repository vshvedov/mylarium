import 'dart:typed_data';

import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';

/// One entry of a folder tree listing.
class TreeEntry {
  const TreeEntry({
    required this.uri,
    required this.name,
    required this.isDir,
    required this.length,
    required this.lastModified,
  });

  final String uri;
  final String name;
  final bool isDir;
  final int length;

  /// Epoch ms; 0 when the provider does not report one.
  final int lastModified;
}

/// The minimal folder-tree filesystem the scanner and resolver need. The
/// production implementation is [SafTreeFs] (Android SAF); tests provide a
/// fixture over a local directory. Kept deliberately tiny: list, sniff-read,
/// stage-out, existence.
abstract class TreeFs {
  Future<List<TreeEntry>> list(String dirUri);

  /// Reads up to [count] bytes from [start] (both null = the whole file).
  Future<Uint8List> readBytes(String fileUri, {int? start, int? count});

  /// Copies the document at [fileUri] to [destPath] on local disk.
  Future<void> copyToLocal(String fileUri, String destPath);

  /// Whether the document/directory at [uri] currently exists and is readable
  /// (false when the card was ejected or the permission was revoked).
  Future<bool> exists(String uri, {required bool isDir});
}

/// Android SAF implementation over saf_util + saf_stream.
class SafTreeFs implements TreeFs {
  SafTreeFs({SafUtil? util, SafStream? stream})
      : _util = util ?? SafUtil(),
        _stream = stream ?? SafStream();

  final SafUtil _util;
  final SafStream _stream;

  @override
  Future<List<TreeEntry>> list(String dirUri) async => [
        for (final f in await _util.list(dirUri))
          TreeEntry(
            uri: f.uri,
            name: f.name,
            isDir: f.isDir,
            length: f.length,
            lastModified: f.lastModified,
          ),
      ];

  @override
  Future<Uint8List> readBytes(String fileUri, {int? start, int? count}) =>
      _stream.readFileBytes(fileUri, start: start, count: count);

  @override
  Future<void> copyToLocal(String fileUri, String destPath) =>
      _stream.copyToLocalFile(fileUri, destPath);

  @override
  Future<bool> exists(String uri, {required bool isDir}) async {
    try {
      return await _util.exists(uri, isDir);
    } catch (_) {
      // A revoked permission throws rather than returning false.
      return false;
    }
  }
}
