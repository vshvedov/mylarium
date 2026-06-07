import 'package:flutter/foundation.dart';

import '../../core/db/database.dart';
import '../../data/source/models/book_dto.dart';
import '../../data/source/models/series_dto.dart';
import 'pin_controllers.dart' show PinnedEntry;

/// A transport-agnostic display model for a single home-rail tile. Built from a
/// Komga DTO (network rails), a cached Drift row (downloaded / recently-read
/// rails), or a resolved pin. The home consumes one `List<RailItem>` per rail so
/// the loading/skeleton wiring is uniform.
@immutable
class RailItem {
  const RailItem({
    required this.ownerType,
    required this.ownerId,
    required this.title,
    this.subtitle,
    this.stacked = false,
  });

  /// `series` or `book`.
  final String ownerType;
  final String ownerId;
  final String title;

  /// Chapter number line for books (e.g. `No. 3`); null for series.
  final String? subtitle;

  /// The multi-book "deck" treatment (series with more than one book).
  final bool stacked;

  static String? _bookSubtitle(String number) =>
      number.isEmpty ? null : 'No. $number';

  factory RailItem.fromSeriesDto(SeriesDto s) => RailItem(
        ownerType: 'series',
        ownerId: s.id,
        title: s.title,
        stacked: s.booksCount > 1,
      );

  factory RailItem.fromBookDto(BookDto b) => RailItem(
        ownerType: 'book',
        ownerId: b.id,
        title: b.title,
        subtitle: _bookSubtitle(b.number),
      );

  /// From a cached book row (the downloaded / recently-read rails).
  factory RailItem.fromBookRow(Book b) => RailItem(
        ownerType: 'book',
        ownerId: b.id,
        title: b.title,
        subtitle: _bookSubtitle(b.number),
      );

  /// From an already-resolved, already-gated pin (the Pinned rail).
  factory RailItem.fromPinned(PinnedEntry e) => RailItem(
        ownerType: e.ownerType,
        ownerId: e.ownerId,
        title: e.title,
        subtitle: e.subtitle,
        stacked: e.stacked,
      );

  @override
  bool operator ==(Object other) =>
      other is RailItem &&
      other.ownerType == ownerType &&
      other.ownerId == ownerId &&
      other.title == title &&
      other.subtitle == subtitle &&
      other.stacked == stacked;

  @override
  int get hashCode => Object.hash(ownerType, ownerId, title, subtitle, stacked);
}
