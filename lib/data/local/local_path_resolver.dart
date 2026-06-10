import '../../core/db/database.dart';
import '../../core/fs/app_paths.dart';
import '../../core/fs/scratch_store.dart';
import 'tree_fs.dart';

/// Maps a [LocalComic] row to a readable archive file path, dispatching on the
/// row's provenance [LocalComic.kind]:
///
/// - copied imports (`localCopy` / `urlDownload`) resolve their RELATIVE
///   [LocalComic.managedPath] under the application support directory;
/// - SAF tree rows (`safTree`, T4) are staged from the card into the scratch
///   store on first read (archive decode needs random file access a SAF
///   content stream cannot provide) and reused from scratch afterwards,
///   validated against the source file's mtime and LRU-evicted by the store.
///
/// Shared by the reader (T3/T4); throws [StateError] when the row has no
/// readable path, and whatever the SAF copy throws when the card is gone (the
/// reader shows its non-blocking error state).
class LocalPathResolver {
  LocalPathResolver({TreeFs? treeFs, this.scratch = const ScratchStore()}) {
    _treeFs = treeFs;
  }

  /// Lazy so constructing the resolver never touches plugins off-Android
  /// (tests, iOS): the SAF-backed default is only created on the tree path.
  TreeFs? _treeFs;
  final ScratchStore scratch;

  TreeFs get _fs => _treeFs ??= SafTreeFs();

  Future<String> archivePath(LocalComic comic) async {
    final managed = comic.managedPath;
    if (managed != null) return AppPaths.resolve(managed);

    final docPath = comic.treeDocPath;
    if (docPath != null) {
      final hit =
          await scratch.staged(comic.id, lastModified: comic.lastModified);
      if (hit != null) return hit.path;
      final dest =
          await scratch.prepare(comic.id, lastModified: comic.lastModified);
      await _fs.copyToLocal(docPath, dest.path);
      // Keep the book being opened; trim older stagings past the cap.
      await scratch.enforceCap(keepComicId: comic.id);
      return dest.path;
    }

    throw StateError(
      'No readable path for local comic ${comic.id} (kind ${comic.kind})',
    );
  }
}
