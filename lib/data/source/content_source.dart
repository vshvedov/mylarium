import '../komga/komga_api.dart';

/// The kind of a content source. Persisted as the enum NAME string (never the
/// index), so adding variants later cannot reinterpret existing rows.
enum SourceKind { komga, localCopy, safTree, iosBookmark, icloudCopy, urlDownload }

/// Abstraction over a place comics come from. Today only [KomgaSource]; the
/// local sources land in T7. Repositories never assume a single source.
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
