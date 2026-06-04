import 'dart:io';

import 'package:flutter/services.dart';

/// Excludes downloaded media from iCloud/iTunes backup (CLAUDE.md: exclude the
/// media store from iCloud backup). On iOS this sets
/// `NSURLIsExcludedFromBackupKey` via a platform channel; on every other
/// platform (and in host unit tests) it is a no-op. Failures are swallowed:
/// backup exclusion is best-effort and must never block a media write.
class BackupExclusion {
  const BackupExclusion._();

  static const _channel = MethodChannel('mylarium/fs');

  static Future<void> exclude(String absolutePath) async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod<void>(
        'excludeFromBackup',
        {'path': absolutePath},
      );
    } on PlatformException {
      // Best-effort; never throw on the media-write path.
    } on MissingPluginException {
      // Channel not wired in a test/headless context.
    }
  }
}
