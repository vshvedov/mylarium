import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;
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

  /// Downloaded comic archives root, relative to applicationSupport.
  static const archivesDir = 'media/archives';

  /// Test seam: when set, [resolve] joins against this root instead of the
  /// platform applicationSupport directory (lets tests simulate the cross-install
  /// container-path change that the relative-path promise guards).
  @visibleForTesting
  static String? debugOverrideRoot;

  /// Resolves a stored RELATIVE path to an absolute path for this install.
  static Future<String> resolve(String relativePath) async {
    final root = debugOverrideRoot ??
        (await getApplicationSupportDirectory()).path;
    return p.join(root, relativePath);
  }

  /// Relative path for a downloaded archive. Ids are sanitized so a hostile id
  /// cannot escape the media root. Extension is irrelevant (decode sniffs magic
  /// bytes), so a generic suffix is used.
  static String archiveRelativePath(String sourceId, String bookId) =>
      p.join(archivesDir, _safe(sourceId), '${_safe(bookId)}.archive');

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
