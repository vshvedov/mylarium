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

  test('seeds the mode from the reading-direction hint', () async {
    expect((await repo.load('s1', 'a', mangaDirection: 'RIGHT_TO_LEFT')).mode,
        ReadingMode.pagedRtl);
    expect((await repo.load('s1', 'b', mangaDirection: 'WEBTOON')).mode,
        ReadingMode.webtoon);
    expect((await repo.load('s1', 'c', mangaDirection: 'VERTICAL')).mode,
        ReadingMode.webtoon);
    expect((await repo.load('s1', 'd', mangaDirection: 'LEFT_TO_RIGHT')).mode,
        ReadingMode.pagedLtr);
  });

  test('has() reflects persisted settings', () async {
    expect(await repo.has('s1', 'ser1'), isFalse);
    await repo.save('s1', 'ser1', const ReaderSettings());
    expect(await repo.has('s1', 'ser1'), isTrue);
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

  test('direction round-trips and defaults to ltr', () async {
    expect(const ReaderSettings().direction, ReadingDirection.ltr);
    await repo.save('s1', 'ser1',
        const ReaderSettings(direction: ReadingDirection.rtl));
    expect((await repo.load('s1', 'ser1')).direction, ReadingDirection.rtl);
  });

  test('defaults seed direction from the manga hint', () async {
    expect(ReaderSettings.defaults(mangaDirection: 'RIGHT_TO_LEFT').direction,
        ReadingDirection.rtl);
    expect(ReaderSettings.defaults(mangaDirection: 'LEFT_TO_RIGHT').direction,
        ReadingDirection.ltr);
    expect(ReaderSettings.defaults(mangaDirection: 'WEBTOON').direction,
        ReadingDirection.ltr);
  });

  test('effectiveRtl across all modes', () {
    expect(effectiveRtl(const ReaderSettings(mode: ReadingMode.pagedLtr)),
        isFalse);
    expect(effectiveRtl(const ReaderSettings(mode: ReadingMode.pagedRtl)),
        isTrue);
    expect(
        effectiveRtl(const ReaderSettings(
            mode: ReadingMode.doublePage, direction: ReadingDirection.rtl)),
        isTrue);
    expect(
        effectiveRtl(const ReaderSettings(
            mode: ReadingMode.doublePage, direction: ReadingDirection.ltr)),
        isFalse);
    expect(
        effectiveRtl(const ReaderSettings(
            mode: ReadingMode.webtoon, direction: ReadingDirection.rtl)),
        isFalse);
    expect(
        effectiveRtl(const ReaderSettings(
            mode: ReadingMode.webtoonGaps, direction: ReadingDirection.rtl)),
        isFalse);
  });
}
