import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:mylarium/features/reader/color/color_settings.dart';
import 'package:mylarium/features/reader/color/color_settings_repository.dart';

void main() {
  late AppDatabase db;
  late ColorSettingsRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ColorSettingsRepository(db);
  });
  tearDown(() => db.close());

  test('resolve returns identity when nothing is persisted', () async {
    expect(await repo.resolve('s1', 'ser1', 'b1'), ColorAdjustments.identity);
  });

  test('round-trips all fields + enable at a scope', () async {
    const adj = ColorAdjustments(
      brightness: 0.25,
      contrast: -0.5,
      gamma: 1.8,
      mode: ColorMode.sepia,
      autoLevels: true,
    );
    await repo.save(const ColorScope.global(), adj, enabled: true);
    final scoped = await repo.forScope(const ColorScope.global());
    expect(scoped, isNotNull);
    expect(scoped!.adjustments, adj);
    expect(scoped.enabled, isTrue);
  });

  test('precedence: book over series over global', () async {
    await repo.save(const ColorScope.global(),
        const ColorAdjustments(brightness: 0.1), enabled: true);
    await repo.save(ColorScope.series('s1', 'ser1'),
        const ColorAdjustments(brightness: 0.2), enabled: true);
    await repo.save(ColorScope.book('s1', 'b1'),
        const ColorAdjustments(brightness: 0.3), enabled: true);

    expect((await repo.resolve('s1', 'ser1', 'b1')).brightness, 0.3);
  });

  test('a disabled book row is an explicit "off" (resolves to identity)',
      () async {
    await repo.save(const ColorScope.global(),
        const ColorAdjustments(brightness: 0.1), enabled: true);
    await repo.save(ColorScope.book('s1', 'b1'),
        const ColorAdjustments(brightness: 0.3), enabled: false);
    expect(await repo.resolve('s1', 'ser1', 'b1'), ColorAdjustments.identity);
  });

  test('falls back to series when the book has no row', () async {
    await repo.save(ColorScope.series('s1', 'ser1'),
        const ColorAdjustments(brightness: 0.2), enabled: true);
    expect((await repo.resolve('s1', 'ser1', 'b1')).brightness, 0.2);
  });

  test('reset deletes the scope row and resolve falls back up', () async {
    await repo.save(const ColorScope.global(),
        const ColorAdjustments(brightness: 0.1), enabled: true);
    await repo.save(ColorScope.book('s1', 'b1'),
        const ColorAdjustments(brightness: 0.3), enabled: true);
    expect((await repo.resolve('s1', 'ser1', 'b1')).brightness, 0.3);

    await repo.reset(ColorScope.book('s1', 'b1'));
    expect(await repo.forScope(ColorScope.book('s1', 'b1')), isNull);
    expect((await repo.resolve('s1', 'ser1', 'b1')).brightness, 0.1);
  });

  test('an empty seriesId skips the series tier (no empty-key collision)',
      () async {
    await repo.save(ColorScope.series('s1', ''),
        const ColorAdjustments(brightness: 0.9), enabled: true);
    expect(await repo.resolve('s1', '', 'b1'), ColorAdjustments.identity);
  });
}
