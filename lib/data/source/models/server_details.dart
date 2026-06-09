import '../content_source.dart' show SourceKind;

/// One labelled row of source-specific detail (disk, OS, install id, health,
/// age restriction, ...). A record so callers build them inline.
typedef ServerDetailRow = ({String label, String value});

/// Source-neutral facts a backend can fetch about itself for the details popup.
/// Every field is best-effort: a piece that fails to load is simply null/empty,
/// so a partial response still renders. The connection fields (kind, label,
/// baseUrl, online) live on [ServerDetails], not here, because the client does
/// not know them.
class ServerFacts {
  const ServerFacts({
    this.version,
    this.account,
    this.roles = const {},
    this.libraryNames = const [],
    this.totalSeries,
    this.totalBooks,
    this.extra = const [],
  });

  final String? version;
  final String? account; // email (Komga) or username (Kavita)
  final Set<String> roles;
  final List<String> libraryNames;
  final int? totalSeries;
  final int? totalBooks;
  final List<ServerDetailRow> extra;

  static const empty = ServerFacts();
}

/// Full model the details dialog renders: local connection metadata plus the
/// fetched [facts]. When [online] is false the server was unreachable or auth
/// expired, and [facts] is [ServerFacts.empty] (the dialog shows connection
/// info plus a Retry).
class ServerDetails {
  const ServerDetails({
    required this.kind,
    required this.label,
    required this.baseUrl,
    required this.online,
    required this.facts,
  });

  final SourceKind kind;
  final String label;
  final String baseUrl;
  final bool online;
  final ServerFacts facts;
}

/// Runs [task], swallowing any error into null. Makes each detail fetch
/// best-effort so one failing endpoint never blanks the whole popup.
Future<T?> bestEffort<T>(Future<T> Function() task) async {
  try {
    return await task();
  } catch (_) {
    return null;
  }
}
