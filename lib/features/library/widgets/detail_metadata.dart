import 'package:flutter/material.dart';

import '../../../app/l10n.dart';
import '../../../data/source/models/book_dto.dart';
import '../../../data/source/models/series_dto.dart';
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
  factory DetailMetadata.book(BuildContext context, BookDto? b) {
    if (b == null) return const DetailMetadata._(chips: [], rows: [], linkLabels: []);
    final l10n = context.l10n;
    final authors =
        b.authors.map((a) => a.name).where((n) => n.isNotEmpty).toSet();
    return DetailMetadata._(
      chips: b.tags,
      rows: [
        if (authors.isNotEmpty) (l10n.metaBy, authors.join(', ')),
        if (b.releaseDate != null) (l10n.metaReleased, _fmtDate(b.releaseDate!)),
        if (b.pagesCount > 0) (l10n.factPages, '${b.pagesCount}'),
        if (b.sizeBytes != null) (l10n.factSize, _fmtBytes(b.sizeBytes!)),
        if (b.readDate != null) (l10n.metaLastRead, _fmtDate(b.readDate!)),
      ],
      linkLabels: [for (final l in b.links) l.label],
    );
  }

  /// From the live [SeriesDto] (null when offline -> renders nothing). The
  /// summary is shown by the series screen, so it is not repeated here.
  factory DetailMetadata.series(BuildContext context, SeriesDto? s) {
    if (s == null) return const DetailMetadata._(chips: [], rows: [], linkLabels: []);
    final l10n = context.l10n;
    return DetailMetadata._(
      chips: [...s.genres, ...s.tags],
      rows: [
        if (s.publisher != null) (l10n.metaPublisher, s.publisher!),
        if (s.ageRating != null) (l10n.metaAgeRating, '${s.ageRating}+'),
        if (s.language != null) (l10n.metaLanguage, s.language!),
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
                    context.l10n.metaLinks,
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
