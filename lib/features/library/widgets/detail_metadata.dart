import 'package:flutter/material.dart';

import '../../../data/komga/models/book_dto.dart';
import '../../../data/komga/models/series_dto.dart';
import 'detail_header.dart' show DetailPill;

/// The richer T3 metadata block for a book or series detail: genre/tag chips and
/// a set of label/value rows (authors, publisher, age rating, language, release
/// date, file info, read date) plus external links. Renders nothing when there
/// is nothing to show (e.g. the live DTO was null offline). Fields that are
/// empty are omitted individually.
class DetailMetadata extends StatelessWidget {
  const DetailMetadata._({
    required this.chips,
    required this.rows,
    required this.linkLabels,
  });

  /// From the live [BookDto] (null when offline -> renders nothing).
  factory DetailMetadata.book(BookDto? b) {
    if (b == null) return const DetailMetadata._(chips: [], rows: [], linkLabels: []);
    final authors =
        b.authors.map((a) => a.name).where((n) => n.isNotEmpty).toSet();
    return DetailMetadata._(
      chips: b.tags,
      rows: [
        if (authors.isNotEmpty) ('By', authors.join(', ')),
        if (b.releaseDate != null) ('Released', _fmtDate(b.releaseDate!)),
        if (b.pagesCount > 0) ('Pages', '${b.pagesCount}'),
        if (b.sizeBytes != null) ('Size', _fmtBytes(b.sizeBytes!)),
        if (b.readDate != null) ('Last read', _fmtDate(b.readDate!)),
      ],
      linkLabels: [for (final l in b.links) l.label],
    );
  }

  /// From the live [SeriesDto] (null when offline -> renders nothing). The
  /// summary is shown by the series screen, so it is not repeated here.
  factory DetailMetadata.series(SeriesDto? s) {
    if (s == null) return const DetailMetadata._(chips: [], rows: [], linkLabels: []);
    return DetailMetadata._(
      chips: [...s.genres, ...s.tags],
      rows: [
        if (s.publisher != null) ('Publisher', s.publisher!),
        if (s.ageRating != null) ('Age rating', '${s.ageRating}+'),
        if (s.language != null) ('Language', s.language!),
      ],
      linkLabels: [for (final l in s.links) l.label],
    );
  }

  final List<String> chips;
  final List<(String, String)> rows;
  final List<String> linkLabels;

  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty && rows.isEmpty && linkLabels.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (chips.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final c in chips.take(20)) DetailPill(c)],
          ),
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 96,
                  child: Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(value, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        if (linkLabels.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 96,
                  child: Text(
                    'Links',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(linkLabels.join(', '),
                      style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

String _fmtDate(int epochMs) {
  final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}

String _fmtBytes(int b) {
  if (b < 1024) return '$b B';
  const units = ['KB', 'MB', 'GB'];
  var v = b / 1024;
  var i = 0;
  while (v >= 1024 && i < units.length - 1) {
    v /= 1024;
    i++;
  }
  return '${v.toStringAsFixed(1)} ${units[i]}';
}
