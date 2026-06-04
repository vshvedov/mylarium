// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _reduceMotionOverrideMeta =
      const VerificationMeta('reduceMotionOverride');
  @override
  late final GeneratedColumn<bool> reduceMotionOverride = GeneratedColumn<bool>(
    'reduce_motion_override',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reduce_motion_override" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _cacheCapBytesMeta = const VerificationMeta(
    'cacheCapBytes',
  );
  @override
  late final GeneratedColumn<int> cacheCapBytes = GeneratedColumn<int>(
    'cache_cap_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2147483648),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    themeMode,
    reduceMotionOverride,
    cacheCapBytes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('reduce_motion_override')) {
      context.handle(
        _reduceMotionOverrideMeta,
        reduceMotionOverride.isAcceptableOrUnknown(
          data['reduce_motion_override']!,
          _reduceMotionOverrideMeta,
        ),
      );
    }
    if (data.containsKey('cache_cap_bytes')) {
      context.handle(
        _cacheCapBytesMeta,
        cacheCapBytes.isAcceptableOrUnknown(
          data['cache_cap_bytes']!,
          _cacheCapBytesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      reduceMotionOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reduce_motion_override'],
      )!,
      cacheCapBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cache_cap_bytes'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;
  final String themeMode;
  final bool reduceMotionOverride;
  final int cacheCapBytes;
  const AppSetting({
    required this.id,
    required this.themeMode,
    required this.reduceMotionOverride,
    required this.cacheCapBytes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['theme_mode'] = Variable<String>(themeMode);
    map['reduce_motion_override'] = Variable<bool>(reduceMotionOverride);
    map['cache_cap_bytes'] = Variable<int>(cacheCapBytes);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      themeMode: Value(themeMode),
      reduceMotionOverride: Value(reduceMotionOverride),
      cacheCapBytes: Value(cacheCapBytes),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      reduceMotionOverride: serializer.fromJson<bool>(
        json['reduceMotionOverride'],
      ),
      cacheCapBytes: serializer.fromJson<int>(json['cacheCapBytes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'themeMode': serializer.toJson<String>(themeMode),
      'reduceMotionOverride': serializer.toJson<bool>(reduceMotionOverride),
      'cacheCapBytes': serializer.toJson<int>(cacheCapBytes),
    };
  }

  AppSetting copyWith({
    int? id,
    String? themeMode,
    bool? reduceMotionOverride,
    int? cacheCapBytes,
  }) => AppSetting(
    id: id ?? this.id,
    themeMode: themeMode ?? this.themeMode,
    reduceMotionOverride: reduceMotionOverride ?? this.reduceMotionOverride,
    cacheCapBytes: cacheCapBytes ?? this.cacheCapBytes,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      reduceMotionOverride: data.reduceMotionOverride.present
          ? data.reduceMotionOverride.value
          : this.reduceMotionOverride,
      cacheCapBytes: data.cacheCapBytes.present
          ? data.cacheCapBytes.value
          : this.cacheCapBytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('reduceMotionOverride: $reduceMotionOverride, ')
          ..write('cacheCapBytes: $cacheCapBytes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, themeMode, reduceMotionOverride, cacheCapBytes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.reduceMotionOverride == this.reduceMotionOverride &&
          other.cacheCapBytes == this.cacheCapBytes);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<String> themeMode;
  final Value<bool> reduceMotionOverride;
  final Value<int> cacheCapBytes;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.reduceMotionOverride = const Value.absent(),
    this.cacheCapBytes = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.reduceMotionOverride = const Value.absent(),
    this.cacheCapBytes = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<String>? themeMode,
    Expression<bool>? reduceMotionOverride,
    Expression<int>? cacheCapBytes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (reduceMotionOverride != null)
        'reduce_motion_override': reduceMotionOverride,
      if (cacheCapBytes != null) 'cache_cap_bytes': cacheCapBytes,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? themeMode,
    Value<bool>? reduceMotionOverride,
    Value<int>? cacheCapBytes,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      reduceMotionOverride: reduceMotionOverride ?? this.reduceMotionOverride,
      cacheCapBytes: cacheCapBytes ?? this.cacheCapBytes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (reduceMotionOverride.present) {
      map['reduce_motion_override'] = Variable<bool>(
        reduceMotionOverride.value,
      );
    }
    if (cacheCapBytes.present) {
      map['cache_cap_bytes'] = Variable<int>(cacheCapBytes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('reduceMotionOverride: $reduceMotionOverride, ')
          ..write('cacheCapBytes: $cacheCapBytes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [appSettings];
}

typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> themeMode,
      Value<bool> reduceMotionOverride,
      Value<int> cacheCapBytes,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> themeMode,
      Value<bool> reduceMotionOverride,
      Value<int> cacheCapBytes,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reduceMotionOverride => $composableBuilder(
    column: $table.reduceMotionOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cacheCapBytes => $composableBuilder(
    column: $table.cacheCapBytes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reduceMotionOverride => $composableBuilder(
    column: $table.reduceMotionOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cacheCapBytes => $composableBuilder(
    column: $table.cacheCapBytes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<bool> get reduceMotionOverride => $composableBuilder(
    column: $table.reduceMotionOverride,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cacheCapBytes => $composableBuilder(
    column: $table.cacheCapBytes,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> reduceMotionOverride = const Value.absent(),
                Value<int> cacheCapBytes = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                themeMode: themeMode,
                reduceMotionOverride: reduceMotionOverride,
                cacheCapBytes: cacheCapBytes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> reduceMotionOverride = const Value.absent(),
                Value<int> cacheCapBytes = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                themeMode: themeMode,
                reduceMotionOverride: reduceMotionOverride,
                cacheCapBytes: cacheCapBytes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
