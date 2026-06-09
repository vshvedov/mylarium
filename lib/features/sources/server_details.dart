import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/theme/theme_controller.dart' show appDatabaseProvider;
import '../../core/network/content_exception.dart';
import '../../data/source/content_source.dart';
import '../../data/source/models/server_details.dart';
import '../../data/source/source_providers.dart';

part 'server_details.g.dart';

/// Fetches [ServerDetails] for one source when the details popup opens. Reads the
/// local `Source` row for connection metadata, resolves the `ContentApi`, and
/// merges best-effort [ServerFacts]. An unreachable server or expired session is
/// a rendered offline state (online:false), not an AsyncError, so the dialog can
/// show connection info plus a Retry. Refresh by invalidating this provider.
@riverpod
Future<ServerDetails> serverDetails(Ref ref, String sourceId) async {
  final db = ref.watch(appDatabaseProvider);
  final source = await db.getSource(sourceId);
  final kind = _kindFromName(source?.kind);
  final label = source?.label ?? '';
  final baseUrl = source?.baseUrl ?? '';

  ServerDetails offline() => ServerDetails(
        kind: kind,
        label: label,
        baseUrl: baseUrl,
        online: false,
        facts: ServerFacts.empty,
      );

  final api = await ref.watch(contentApiForProvider(sourceId).future);
  if (api == null) return offline();

  try {
    final facts = await api.fetchServerFacts();
    return ServerDetails(
      kind: kind,
      label: label,
      baseUrl: baseUrl,
      online: true,
      facts: facts,
    );
  } on ContentException {
    return offline();
  }
}

SourceKind _kindFromName(String? name) =>
    SourceKind.values.asNameMap()[name] ?? SourceKind.komga;
