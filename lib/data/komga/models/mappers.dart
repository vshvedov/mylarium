import 'package:drift/drift.dart';

import '../../../core/db/database.dart';
import 'book_dto.dart';
import 'library_dto.dart';
import 'series_dto.dart';

/// DTO -> Drift row mappers. Every row carries [sourceId] (CLAUDE.md: every
/// persisted row carries a sourceId).
LibrariesCompanion libraryToRow(String sourceId, LibraryDto dto) =>
    LibrariesCompanion(
      sourceId: Value(sourceId),
      id: Value(dto.id),
      name: Value(dto.name),
    );

SeriesCompanion seriesToRow(String sourceId, SeriesDto dto) => SeriesCompanion(
      sourceId: Value(sourceId),
      id: Value(dto.id),
      libraryId: Value(dto.libraryId),
      title: Value(dto.title),
      titleSort: Value(dto.titleSort),
      // Stays NULL when the source supplies none (never 0).
      ageRating: Value(dto.ageRating),
      status: Value(dto.status),
      summary: Value(dto.summary),
      booksCount: Value(dto.booksCount),
    );

BooksCompanion bookToRow(String sourceId, BookDto dto) => BooksCompanion(
      sourceId: Value(sourceId),
      id: Value(dto.id),
      seriesId: Value(dto.seriesId),
      libraryId: Value(dto.libraryId),
      title: Value(dto.title),
      number: Value(dto.number),
      numberSort: Value(dto.numberSort),
      pagesCount: Value(dto.pagesCount),
      mediaType: Value(dto.mediaType),
      sizeBytes: Value(dto.sizeBytes),
      readPage: Value(dto.readPage),
      completed: Value(dto.completed),
    );
