import 'package:flutter/widgets.dart';

import '../core/network/content_exception.dart';
import 'l10n.dart';

/// Localized counterpart to [friendlyError] (which lives in the network layer
/// and stays English-only for logs). Maps a transport error to a short,
/// human-friendly, localized hint for display in the UI. Mirrors the
/// English copy of [friendlyError] exactly.
String localizedFriendlyError(BuildContext context, Object error) {
  final l10n = context.l10n;
  if (error is ContentException) {
    return switch (error.kind) {
      ContentErrorKind.notFound => l10n.errorNotFound,
      ContentErrorKind.unauthorized ||
      ContentErrorKind.forbidden =>
        l10n.errorSessionExpired,
      ContentErrorKind.unreachable => l10n.errorUnreachable,
      ContentErrorKind.tls => l10n.errorTls,
      _ => l10n.errorServerGeneric,
    };
  }
  return l10n.errorGeneric;
}
