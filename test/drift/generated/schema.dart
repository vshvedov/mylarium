// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';
import 'package:drift/internal/migrations.dart';
import 'schema_v16.dart' as v16;
import 'schema_v17.dart' as v17;
import 'schema_v18.dart' as v18;

class GeneratedHelper implements SchemaInstantiationHelper {
  @override
  GeneratedDatabase databaseForVersion(QueryExecutor db, int version) {
    switch (version) {
      case 16:
        return v16.DatabaseAtV16(db);
      case 17:
        return v17.DatabaseAtV17(db);
      case 18:
        return v18.DatabaseAtV18(db);
      default:
        throw MissingSchemaException(version, versions);
    }
  }

  static const versions = const [16, 17, 18];
}
