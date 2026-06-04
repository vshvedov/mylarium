/// A series is treated as age-restricted when its `ageRating` is set and at or
/// above this value. A heuristic (Komga ageRating is an arbitrary per-series
/// integer); kept as a single named constant so the grid SQL filter and the
/// rail/Dart-side filter never drift apart. Configurable per-library visibility
/// is governed by `LibraryPrefs.showRestricted` + the library lock.
const int kRestrictedAgeRating = 18;

/// Whether a series with this (nullable) ageRating is restricted. A NULL rating
/// is never restricted (the source supplied none).
bool isRestrictedAgeRating(int? ageRating) =>
    ageRating != null && ageRating >= kRestrictedAgeRating;
