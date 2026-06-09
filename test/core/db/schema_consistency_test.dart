import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mylarium/core/db/database.dart';

import '../../drift/generated/schema.dart';

/// Standing guard for the migration subsystem (see CLAUDE.md "Migrations are the
/// highest-risk subsystem"). These tests are NOT tied to any one feature: they
/// must keep passing as every future migration is added, and they fail loudly
/// the moment someone changes `createAll` without a matching `onUpgrade` step.
///
/// `_kBaselineVersion` is 16. When you add a migration you bump the schema
/// version, add the `onUpgrade` step, dump `drift_schema_v<N>.json`, regenerate
/// `test/drift/generated/`, and add the N-1 -> N step to the per-version test in
/// `captures_migration_test.dart`. THIS file then re-verifies, automatically,
/// that upgraders and fresh installs converge on an identical schema.
void main() {
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('a fresh install opens at the current schema version', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    // Touch the db so it actually opens (runs onCreate / createAll).
    await db.customStatement('SELECT 1');
    expect(db.schemaVersion, greaterThanOrEqualTo(16));
  });

  test(
      'upgrading from the baseline yields the SAME schema as a fresh install '
      '(catches a createAll change with no matching onUpgrade step)', () async {
    // Build a database at the v16 baseline, then open the real AppDatabase on it
    // so drift runs the full onUpgrade chain up to the current version.
    final connection = await verifier.startAt(16);
    final db = AppDatabase(connection);
    addTearDown(db.close);
    await db.customStatement('SELECT 1'); // open + migrate to current

    // With no reference schema attached, validateDatabaseSchema compares the
    // migrated runtime schema against what `createAll` would build from scratch.
    // If they differ (e.g. a column was added to a table but not to onUpgrade),
    // this throws -- which is exactly the regression we want to catch.
    await db.validateDatabaseSchema();
  });
}
