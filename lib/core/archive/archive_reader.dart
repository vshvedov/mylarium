import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'archive_extractor.dart' show ArchiveException, readArchiveEntrySync;

/// A persistent, per-archive page reader.
///
/// [ArchiveExtractor.page] spawns a fresh isolate for every page. Paging a
/// downloaded chapter through that path stalls: the per-page isolate spawn
/// dominates the read, so the reader's precache window cannot stay ahead and the
/// reader shows its loading spinner on a page that is already on disk.
///
/// [ArchiveReader] spawns ONE worker isolate for the open archive and serves
/// every page request over a port, so a read costs only the decode (no per-page
/// spawn). A small in-memory LRU of recently read entry bytes means re-decoding a
/// page at a new width (the reader's focus-resolution upgrade) or flipping back
/// never re-reads through the worker.
///
/// One reader is owned per open book by the reader screen and disposed on close.
/// The worker starts lazily on the first [page] call.
class ArchiveReader {
  ArchiveReader(this.archivePath, {int memCacheEntries = 8})
      : assert(memCacheEntries >= 0),
        _memCacheEntries = memCacheEntries;

  final String archivePath;
  final int _memCacheEntries;

  Isolate? _isolate;
  SendPort? _commands;
  ReceivePort? _replies;
  Future<void>? _starting;
  var _nextId = 0;
  final _pending = <int, Completer<Uint8List>>{};

  // Insertion-ordered, so the first key is the least-recently used.
  final _cache = <String, Uint8List>{};
  bool _disposed = false;

  /// Decompressed bytes of [entry] inside the archive. Throws [ArchiveException]
  /// when the entry is missing or the archive cannot be read, and [StateError]
  /// once the reader has been disposed.
  Future<Uint8List> page(String entry) async {
    if (_disposed) throw StateError('ArchiveReader is disposed');
    final hit = _cache.remove(entry);
    if (hit != null) {
      _cache[entry] = hit; // move to most-recently-used
      return hit;
    }
    await _ensureStarted();
    if (_disposed) throw StateError('ArchiveReader is disposed');
    final id = _nextId++;
    final completer = Completer<Uint8List>();
    _pending[id] = completer;
    _commands!.send([id, entry]);
    final bytes = await completer.future;
    _remember(entry, bytes);
    return bytes;
  }

  void _remember(String entry, Uint8List bytes) {
    if (_memCacheEntries == 0) return;
    _cache[entry] = bytes;
    while (_cache.length > _memCacheEntries) {
      _cache.remove(_cache.keys.first);
    }
  }

  Future<void> _ensureStarted() {
    if (_commands != null) return Future<void>.value();
    return _starting ??= _start();
  }

  Future<void> _start() async {
    final replies = ReceivePort();
    _replies = replies;
    final ready = Completer<SendPort>();
    replies.listen((message) {
      // The worker's first message is its command SendPort.
      if (message is SendPort) {
        if (!ready.isCompleted) ready.complete(message);
        return;
      }
      // Every later message is [id, bytes, errorMessage].
      final list = message as List;
      final completer = _pending.remove(list[0] as int);
      if (completer == null || completer.isCompleted) return;
      final error = list[2] as String?;
      if (error != null) {
        completer.completeError(ArchiveException(error, path: archivePath));
      } else {
        completer.complete(list[1] as Uint8List);
      }
    });
    try {
      _isolate = await Isolate.spawn(
        _archiveWorkerEntry,
        [archivePath, replies.sendPort],
        debugName: 'archive-reader',
      );
      _commands = await ready.future;
    } catch (e) {
      replies.close();
      _replies = null;
      _starting = null; // let a later read retry the spawn
      rethrow;
    }
  }

  /// Tears down the worker and fails any in-flight reads. Idempotent.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    try {
      _commands?.send(_kClose);
    } catch (_) {}
    for (final completer in _pending.values) {
      if (!completer.isCompleted) {
        completer.completeError(StateError('ArchiveReader is disposed'));
      }
    }
    _pending.clear();
    _cache.clear();
    _isolate?.kill(priority: Isolate.beforeNextEvent);
    _replies?.close();
    _isolate = null;
    _commands = null;
  }
}

const _kClose = 'close';

/// Worker isolate body: replies with its command [SendPort], then serves each
/// `[id, entry]` request as `[id, bytes, null]` or `[id, null, errorMessage]`.
/// Requests run on the isolate's event loop one at a time (one file at a time),
/// so the shared decode never races itself.
void _archiveWorkerEntry(List<Object?> init) {
  final path = init[0] as String;
  final replies = init[1] as SendPort;
  final commands = ReceivePort();
  replies.send(commands.sendPort);

  commands.listen((message) {
    if (message == _kClose) {
      commands.close();
      return;
    }
    final request = message as List;
    final id = request[0] as int;
    final entry = request[1] as String;
    try {
      replies.send([id, readArchiveEntrySync(path, entry), null]);
    } on ArchiveException catch (e) {
      replies.send([id, null, e.message]);
    } catch (e) {
      replies.send([id, null, e.toString()]);
    }
  });
}
