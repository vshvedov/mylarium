import 'dart:convert';

import '../../source/models/page.dart';

/// Kavita paginates list endpoints with a `Pagination` RESPONSE header (note:
/// not `X-Pagination`), a JSON object
/// `{currentPage, itemsPerPage, totalItems, totalPages}`. The body is a bare
/// JSON array. This wraps a decoded array into the shared [Page] envelope.
///
/// [header] is the raw `Pagination` header value (may be null when absent, e.g.
/// on non-paged endpoints); [content] is the already-mapped items.
Page<T> kavitaPage<T>(String? header, List<T> content, {int requestedSize = 0}) {
  Map<String, Object?>? meta;
  if (header != null && header.isNotEmpty) {
    try {
      final decoded = jsonDecode(header);
      if (decoded is Map<String, Object?>) meta = decoded;
    } catch (_) {
      meta = null;
    }
  }
  int asInt(Object? v, int fallback) => (v as num?)?.toInt() ?? fallback;

  if (meta == null) {
    // Header absent: synthesize. A short page is the last one.
    final size = requestedSize > 0 ? requestedSize : content.length;
    return Page(
      content: content,
      totalElements: content.length,
      number: 0,
      last: content.length < size || content.isEmpty,
      totalPages: content.isEmpty ? 0 : 1,
      size: size,
      numberOfElements: content.length,
      first: true,
      empty: content.isEmpty,
    );
  }

  // Kavita currentPage is 1-based; the shared Page.number is 0-based.
  final currentPage = asInt(meta['currentPage'], 1);
  final totalPages = asInt(meta['totalPages'], currentPage);
  final itemsPerPage = asInt(meta['itemsPerPage'], content.length);
  return Page(
    content: content,
    totalElements: asInt(meta['totalItems'], content.length),
    number: currentPage - 1,
    last: currentPage >= totalPages,
    totalPages: totalPages,
    size: itemsPerPage,
    numberOfElements: content.length,
    first: currentPage <= 1,
    empty: content.isEmpty,
  );
}
