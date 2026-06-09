import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

void main() {
  // Regression for the "re-prompts for Komga credentials on every restart" bug.
  //
  // The migration chain (versions 1..15) was collapsed into a single baseline,
  // anchored at version 16 (above every pre-collapse version that ever shipped).
  // Devices updated in place still carried an on-disk DB stamped 2..15. Drift
  // cannot open such a database incrementally, so the open threw and main() fell
  // back to an ephemeral in-memory DB on every launch: the connected source
  // never persisted and onboarding re-prompted forever. openOrResetDatabase
  // discards an incompatible file so the database is recreated at the baseline.

  test('drift cannot open a pre-collapse DB incrementally (the bug)', () async {
    final dir = await Directory.systemTemp.createTemp('mylarium_db_bug');
    addTearDown(() => dir.delete(recursive: true));
    final file = File(p.join(dir.path, 'mylarium.sqlite'));

    // Simulate a pre-collapse build's on-disk database (version below baseline).
    final raw = sqlite3.open(file.path);
    raw.userVersion = 15;
    raw.dispose();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    // The migrator runs lazily on the first query and fails: there is no
    // onUpgrade path from a pre-collapse version to the baseline.
    await expectLater(db.getOrCreateSettings(), throwsA(anything));
  });

  test('openOrResetDatabase recreates a pre-collapse DB instead of failing',
      () async {
    final dir = await Directory.systemTemp.createTemp('mylarium_db_reset');
    addTearDown(() => dir.delete(recursive: true));
    final file = File(p.join(dir.path, 'mylarium.sqlite'));

    // A pre-collapse DB: a sub-baseline user_version plus a now-foreign table.
    final raw = sqlite3.open(file.path);
    raw.userVersion = 15;
    raw.execute('CREATE TABLE stale(x INTEGER);');
    raw.dispose();

    final db = AppDatabase(await openOrResetDatabase(file));
    addTearDown(db.close);

    // Opens cleanly at the baseline and behaves like a fresh database.
    expect(await db.hasAnySource(), isFalse);
    expect((await db.getOrCreateSettings()).id, 1);

    // The on-disk file was reset to the current baseline version.
    final check = sqlite3.open(file.path, mode: OpenMode.readOnly);
    addTearDown(check.dispose);
    expect(check.userVersion, db.schemaVersion);
  });

  test('openOrResetDatabase resets a downgrade DB (newer than this build)',
      () async {
    final dir = await Directory.systemTemp.createTemp('mylarium_db_downgrade');
    addTearDown(() => dir.delete(recursive: true));
    final file = File(p.join(dir.path, 'mylarium.sqlite'));

    // A DB written by a future build whose schema this (older) build cannot
    // downgrade to: drift would throw, so it must be reset.
    final raw = sqlite3.open(file.path);
    raw.userVersion = 999;
    raw.dispose();

    final db = AppDatabase(await openOrResetDatabase(file));
    addTearDown(db.close);
    expect(await db.hasAnySource(), isFalse);

    final check = sqlite3.open(file.path, mode: OpenMode.readOnly);
    addTearDown(check.dispose);
    expect(check.userVersion, db.schemaVersion);
  });

  test('openOrResetDatabase leaves a baseline DB untouched across a restart',
      () async {
    final dir = await Directory.systemTemp.createTemp('mylarium_db_keep');
    addTearDown(() => dir.delete(recursive: true));
    final file = File(p.join(dir.path, 'mylarium.sqlite'));

    // First run: create the baseline DB and persist a source row.
    final first = AppDatabase(await openOrResetDatabase(file));
    await first.getOrCreateSettings();
    await first.customStatement(
      "INSERT INTO sources (id, kind, label) VALUES ('s1', 'komga', 'srv')",
    );
    expect(await first.hasAnySource(), isTrue);
    await first.close();

    // Second run (a restart): a same-baseline DB must survive, not be wiped.
    final second = AppDatabase(await openOrResetDatabase(file));
    addTearDown(second.close);
    expect(await second.hasAnySource(), isTrue);
  });
}
