import 'dart:io';

/// Reusable disk-budget primitive for the LRU-capped on-disk pools (the
/// auto-cache archive pool, the scratch store for staged tree archives). One
/// place owns the "total everything, then evict least-recently-used until the
/// total fits" walk so every pool keeps identical cap semantics.
///
/// Two layers, because the pools differ in where their LRU ordering lives:
/// - [selectVictims] is the pure core: given candidates already ordered
///   least-recently-used first (the auto-cache orders by DB `lastAccessedAt`,
///   directory pools by file mtime), it picks the evictions needed to fit the
///   cap. Pool-specific exemptions stay at the call site: the auto-cache
///   filters pinned/permanent assets OUT of the candidates entirely (they are
///   never evicted and never count toward the cap), while a directory pool's
///   kept file still counts but is skipped via [keep].
/// - [enforce] is the directory walk built on that core: it lists [dir],
///   totals file sizes, orders by mtime, and deletes until the cap fits.
class DiskQuota {
  const DiskQuota._();

  /// Pure LRU victim selection. [orderedCandidates] must be ordered
  /// least-recently-used FIRST. Totals [sizeOf] over ALL candidates; when the
  /// total exceeds [capBytes], returns the in-order evictions needed for the
  /// remainder to fit. Candidates matching [keep] count toward the total but
  /// are never selected (so a kept candidate can leave the pool over cap).
  static List<T> selectVictims<T>({
    required List<T> orderedCandidates,
    required int capBytes,
    required int Function(T) sizeOf,
    bool Function(T)? keep,
  }) {
    var total = orderedCandidates.fold<int>(0, (sum, c) => sum + sizeOf(c));
    if (total <= capBytes) return const <Never>[];
    final victims = <T>[];
    for (final candidate in orderedCandidates) {
      if (total <= capBytes) break;
      if (keep != null && keep(candidate)) continue;
      victims.add(candidate);
      total -= sizeOf(candidate);
    }
    return victims;
  }

  /// Walks [dir] (one level, or [recursive]), totals the sizes of files
  /// passing [include], and evicts least-recently-modified files until the
  /// total fits [capBytes]. Files whose absolute path is in [keepPaths] still
  /// count toward the total but are never evicted. Each eviction runs
  /// [onEvict] when provided (the callback owns deletion, e.g. removing
  /// companion stamp files or DB rows alongside the file); otherwise the file
  /// itself is deleted best-effort. Returns the total bytes evicted.
  static Future<int> enforce({
    required Directory dir,
    required int capBytes,
    bool recursive = false,
    bool Function(File file)? include,
    Set<String> keepPaths = const {},
    Future<void> Function(File file)? onEvict,
  }) async {
    if (!await dir.exists()) return 0;
    final files = <File>[];
    final sizes = <String, int>{};
    await for (final entity in dir.list(recursive: recursive)) {
      if (entity is! File) continue;
      if (include != null && !include(entity)) continue;
      files.add(entity);
      sizes[entity.path] = await entity.length();
    }
    final total = sizes.values.fold<int>(0, (sum, size) => sum + size);
    if (total <= capBytes) return 0;
    final stats = <(File, DateTime)>[
      for (final f in files) (f, (await f.stat()).modified),
    ]..sort((a, b) => a.$2.compareTo(b.$2));
    final victims = selectVictims<File>(
      orderedCandidates: [for (final (file, _) in stats) file],
      capBytes: capBytes,
      sizeOf: (file) => sizes[file.path]!,
      keep: keepPaths.isEmpty ? null : (file) => keepPaths.contains(file.path),
    );
    var freed = 0;
    for (final file in victims) {
      if (onEvict != null) {
        await onEvict(file);
      } else {
        try {
          if (await file.exists()) await file.delete();
        } on FileSystemException {
          // Best-effort cleanup; a stuck file is reclaimed on a later pass.
        }
      }
      freed += sizes[file.path]!;
    }
    return freed;
  }
}
