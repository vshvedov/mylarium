import 'dart:io';

import 'package:file_selector/file_selector.dart' as fs;
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:gal/gal.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'capture_models.dart';

part 'capture_export.g.dart';

/// Photos album that mobile exports land in.
const _kExportAlbum = 'Mylarium';

/// Outcome of exporting a capture, mapped to a user-facing message by the caller.
enum CaptureExportResult {
  /// Written into the system Photos library (mobile).
  savedToPhotos,

  /// Written to a user-chosen file location (desktop).
  savedToFile,

  /// The user dismissed the desktop save dialog; nothing was written.
  cancelled,

  /// Photos add-access was denied (mobile).
  permissionDenied,

  /// Any other failure (write error, unsupported platform).
  failed,
}

/// Suggested filename for an exported capture: `<chapter> p<page>.png`, with
/// filesystem-illegal characters replaced by spaces. Used both as the Photos
/// filename basis and the desktop save dialog's suggested name. No long dashes
/// (CLAUDE.md). Falls back to `Untitled` when the chapter title is unknown.
String exportFileName(Capture c) {
  final title = (c.bookTitle ?? '').trim();
  final base = title.isEmpty ? 'Untitled' : title;
  final safe = base
      .replaceAll(RegExp(r'[\\/:*?"<>|]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return '${safe.isEmpty ? 'Untitled' : safe} p${c.pageNumber + 1}.png';
}

/// Exports a saved capture's PNG the platform-appropriate way: into the Photos
/// library on Android/iOS (in the [_kExportAlbum] album), or to a user-chosen
/// file via a save dialog on desktop. Pure of UI; the viewer is a thin caller
/// and tests override [captureExporterProvider] with a fake.
class CaptureExporter {
  const CaptureExporter();

  Future<CaptureExportResult> export(Capture capture) async {
    final path = capture.absolutePath;
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        await Gal.putImage(path, album: _kExportAlbum);
        return CaptureExportResult.savedToPhotos;
      } on GalException catch (e) {
        return e.type == GalExceptionType.accessDenied
            ? CaptureExportResult.permissionDenied
            : CaptureExportResult.failed;
      } catch (_) {
        return CaptureExportResult.failed;
      }
    }
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      try {
        final location =
            await fs.getSaveLocation(suggestedName: exportFileName(capture));
        if (location == null) return CaptureExportResult.cancelled;
        await File(path).copy(location.path);
        return CaptureExportResult.savedToFile;
      } catch (_) {
        return CaptureExportResult.failed;
      }
    }
    return CaptureExportResult.failed;
  }
}

@riverpod
CaptureExporter captureExporter(Ref ref) => const CaptureExporter();
