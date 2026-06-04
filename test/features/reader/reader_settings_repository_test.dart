import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/features/reader/reader_models.dart';
import 'package:mylarium/features/reader/reader_settings_repository.dart';

void main() {
  late AppDatabase db;
  late ReaderSettingsRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ReaderSettingsRepository(db);
  });
  tearDown(() => db.close());

  test('returns LTR defaults when nothing is persisted', () async {
    final s = await repo.load('s1', 'ser1');
    expect(s.mode, ReadingMode.pagedLtr);
    expect(s.fit, FitMode.screen);
    expect(s.doubleTapZoom, isTrue);
  });

  test('seeds RTL from a manga direction hint', () async {
    final s = await repo.load('s1', 'ser1', mangaDirection: 'RIGHT_TO_LEFT');
    expect(s.mode, ReadingMode.pagedRtl);
  });

  test('round-trips all fields', () async {
    const settings = ReaderSettings(
      mode: ReadingMode.webtoonGaps,
      fit: FitMode.width,
      taps: TapZonePreset.kindleStyle,
      invertTaps: true,
      doubleTapZoom: false,
      animatePageTurn: false,
    );
    await repo.save('s1', 'ser1', settings);

    final loaded = await repo.load('s1', 'ser1');
    expect(loaded.mode, ReadingMode.webtoonGaps);
    expect(loaded.fit, FitMode.width);
    expect(loaded.taps, TapZonePreset.kindleStyle);
    expect(loaded.invertTaps, isTrue);
    expect(loaded.doubleTapZoom, isFalse);
    expect(loaded.animatePageTurn, isFalse);
  });

  test('settings are scoped per series', () async {
    await repo.save('s1', 'ser1',
        const ReaderSettings(mode: ReadingMode.pagedRtl));
    final other = await repo.load('s1', 'ser2');
    expect(other.mode, ReadingMode.pagedLtr);
  });
}
