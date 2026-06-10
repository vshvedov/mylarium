import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/local/import_service.dart';
import '../../../data/source/source_providers.dart';
import 'local_providers.dart';

part 'import_controller.g.dart';

/// Phases of one import run, driven by [ImportController]. The results sheet
/// renders [ImportRunDone]; the home/browse import buttons render a progress
/// indicator while the state is [ImportRunActive].
sealed class ImportRunState {
  const ImportRunState();
}

class ImportRunIdle extends ImportRunState {
  const ImportRunIdle();
}

class ImportRunActive extends ImportRunState {
  const ImportRunActive({
    required this.done,
    required this.total,
    required this.currentName,
  });
  final int done;
  final int total;
  final String currentName;
}

class ImportRunDone extends ImportRunState {
  const ImportRunDone(this.result);
  final ImportResult result;
}

/// Drives a pick-then-import run. The picker's extension filter is UX-only
/// (magic-byte sniffing decides for real, per the imports rule); per-file
/// progress comes from importing one file at a time.
@riverpod
class ImportController extends _$ImportController {
  @override
  ImportRunState build() => const ImportRunIdle();

  /// Opens the OS picker and imports the selection. Returns the batch result
  /// (also left in state as [ImportRunDone]) or null when the user cancelled
  /// the picker or a run is already active.
  Future<ImportResult?> pickAndImport() async {
    if (state is ImportRunActive) return null;
    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['cbz', 'cbr', 'cbt'],
    );
    final files = [
      for (final f in picked?.files ?? const <PlatformFile>[])
        if (f.path != null) PickedFile(path: f.path!, name: f.name),
    ];
    if (files.isEmpty) {
      state = const ImportRunIdle();
      return null;
    }
    return importFiles(files);
  }

  /// Imports [files] one at a time so the UI can show per-file progress.
  /// Exposed separately from [pickAndImport] so tests can drive the state
  /// machine without an OS picker.
  Future<ImportResult> importFiles(List<PickedFile> files) async {
    final service = ref.read(importServiceProvider);
    final localId = await service.ensureLocalSource();
    final results = <FileImportResult>[];
    for (var i = 0; i < files.length; i++) {
      state = ImportRunActive(
        done: i,
        total: files.length,
        currentName: files[i].name,
      );
      final batch = await service.importFiles([files[i]]);
      results.addAll(batch.files);
    }
    final result = ImportResult(results);
    state = ImportRunDone(result);
    // The source row may have just been created. Do NOT invalidate the
    // keepAlive active-source provider here (its build() picks the first
    // source by id and could switch the user away); only adopt the local
    // source when nothing is active yet.
    final active = await ref.read(activeSourceIdProvider.future);
    if (active == null) {
      ref.read(activeSourceIdProvider.notifier).select(localId);
    }
    return result;
  }

  void reset() => state = const ImportRunIdle();
}
