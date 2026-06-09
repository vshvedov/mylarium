import '../komga/komga_api.dart';
import 'content_api.dart';

/// The kind of a content source. Persisted as the enum NAME string (never the
/// index), so adding variants later cannot reinterpret existing rows.
///
/// [local] is the device's single "Local files" source (copy-on-import);
/// [safTree] is one Android folder library (T4). The remaining values are
/// per-comic provenance kinds stored on `LocalComics.kind`, not source kinds.
enum SourceKind {
  komga,
  kavita,
  local,
  localCopy,
  safTree,
  iosBookmark,
  icloudCopy,
  urlDownload
}

/// Abstraction over a place comics come from. Today [KomgaSource] and
/// [KavitaSource]; the local sources land later. Repositories never assume a
/// single source.
abstract class ContentSource {
  String get id;
  SourceKind get kind;
  String get label;
}

/// A connected Komga server. Carries the transport ([api]) and [baseUrl] so a
/// `sourceId` can be resolved to the client that serves it.
class KomgaSource implements ContentSource {
  const KomgaSource({
    required this.id,
    required this.label,
    required this.baseUrl,
    required this.api,
  });

  @override
  final String id;

  @override
  final String label;

  @override
  SourceKind get kind => SourceKind.komga;

  final String baseUrl;
  final KomgaApi api;
}

/// A connected Kavita server. Carries the transport ([api]) and [baseUrl] so a
/// `sourceId` can be resolved to the client that serves it.
class KavitaSource implements ContentSource {
  const KavitaSource({
    required this.id,
    required this.label,
    required this.baseUrl,
    required this.api,
  });

  @override
  final String id;

  @override
  final String label;

  @override
  SourceKind get kind => SourceKind.kavita;

  final String baseUrl;
  final ContentApi api;
}
