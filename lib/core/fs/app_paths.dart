import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Filesystem layout helpers. All persistent media lives under the application
/// support directory (never temp/cache), and only RELATIVE paths are stored in
/// the database (CLAUDE.md: the iOS sandbox container path changes between
/// installs, so absolute paths must never be persisted).
class AppPaths {
  const AppPaths._();

  /// The thumbnails root, relative to applicationSupport.
  static const thumbnailsDir = 'thumbnails';

  /// Resolves a stored RELATIVE path to an absolute path for this install.
  static Future<String> resolve(String relativePath) async {
    final dir = await getApplicationSupportDirectory();
    return p.join(dir.path, relativePath);
  }

  /// Relative path for a cached thumbnail. Keeping `<ownerType>/<sourceId>/...`
  /// segments avoids id collisions across sources. Ids are sanitized so a hostile
  /// or unusual source id (containing `/` or `..`) cannot escape the media root.
  static String thumbnailRelativePath(
    String sourceId,
    String ownerType,
    String ownerId,
  ) =>
      p.join(thumbnailsDir, _safe(ownerType), _safe(sourceId), '${_safe(ownerId)}.img');

  static String _safe(String segment) =>
      segment.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');

  /// Ensures the parent directory of [relativePath] exists and returns the
  /// absolute file path. The caller writes the bytes.
  static Future<File> prepareFile(String relativePath) async {
    final abs = await resolve(relativePath);
    final file = File(abs);
    await file.parent.create(recursive: true);
    return file;
  }
}
