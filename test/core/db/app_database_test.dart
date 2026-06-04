import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('getOrCreateSettings inserts once and does not clobber', () async {
    final a = await db.getOrCreateSettings();
    await db.updateThemeMode('dark');
    final b = await db.getOrCreateSettings();
    expect(a.id, 1);
    expect(b.themeMode, 'dark');
  });

  test('updates persist', () async {
    await db.getOrCreateSettings();
    await db.updateReduceMotionOverride(true);
    expect((await db.getOrCreateSettings()).reduceMotionOverride, true);
  });

  test('defaults on first create', () async {
    final s = await db.getOrCreateSettings();
    expect(s.themeMode, 'system');
    expect(s.reduceMotionOverride, false);
    expect(s.cacheCapBytes, 2147483648);
  });
}
