import 'package:flutter/widgets.dart';

import '../../../app/l10n.dart';

/// Maps a data-layer import skip/failure reason (produced English-only by
/// `ImportService` in `lib/data/local/import_service.dart`) to a localized
/// string for display.
///
/// The import service keeps its reasons as plain English internals (they double
/// as log/diagnostic text and some are arbitrary archive/exception messages).
/// We translate only the known, fixed reasons here at the rendering boundary
/// and fall back to the raw reason for anything else (a malformed-archive
/// message, an unexpected exception string), so output never regresses to a
/// blank or a key.
String localizedImportReason(BuildContext context, String reason) {
  final l10n = context.l10n;
  // The oversize reason embeds the configured size limit (e.g. "... 200 MB"),
  // so match by prefix and re-emit the localized form with the same number.
  const oversizePrefix = 'File is larger than ';
  if (reason.startsWith(oversizePrefix) && reason.endsWith(' MB')) {
    final mb = reason.substring(oversizePrefix.length, reason.length - 3);
    return l10n.importReasonOversize(mb);
  }
  return switch (reason) {
    'Only https URLs are supported' => l10n.importReasonHttpsOnly,
    'Could not reach the URL' => l10n.importReasonUrlUnreachable,
    'Not a comic archive URL' => l10n.importReasonNotArchiveUrl,
    'Download failed' => l10n.importReasonDownloadFailed,
    'File not found' => l10n.importReasonFileNotFound,
    'Not a comic archive' => l10n.importReasonNotArchive,
    'Already imported' => l10n.importReasonAlreadyImported,
    _ => reason,
  };
}
