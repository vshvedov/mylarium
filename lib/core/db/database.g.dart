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

class $SourcesTable extends Sources with TableInfo<$SourcesTable, Source> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseUrlMeta = const VerificationMeta(
    'baseUrl',
  );
  @override
  late final GeneratedColumn<String> baseUrl = GeneratedColumn<String>(
    'base_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authKindMeta = const VerificationMeta(
    'authKind',
  );
  @override
  late final GeneratedColumn<String> authKind = GeneratedColumn<String>(
    'auth_kind',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _handleMeta = const VerificationMeta('handle');
  @override
  late final GeneratedColumn<String> handle = GeneratedColumn<String>(
    'handle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    baseUrl,
    authKind,
    handle,
    label,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<Source> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('base_url')) {
      context.handle(
        _baseUrlMeta,
        baseUrl.isAcceptableOrUnknown(data['base_url']!, _baseUrlMeta),
      );
    }
    if (data.containsKey('auth_kind')) {
      context.handle(
        _authKindMeta,
        authKind.isAcceptableOrUnknown(data['auth_kind']!, _authKindMeta),
      );
    }
    if (data.containsKey('handle')) {
      context.handle(
        _handleMeta,
        handle.isAcceptableOrUnknown(data['handle']!, _handleMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Source map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Source(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      baseUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_url'],
      ),
      authKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_kind'],
      ),
      handle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}handle'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
    );
  }

  @override
  $SourcesTable createAlias(String alias) {
    return $SourcesTable(attachedDatabase, alias);
  }
}

class Source extends DataClass implements Insertable<Source> {
  /// App-generated source id (uuid v4). See SecureStore key `komga.cred.<id>`.
  final String id;

  /// `SourceKind` name string, e.g. `komga`.
  final String kind;

  /// Server origin (scheme + host + optional path prefix); no `/api/v1`.
  final String? baseUrl;

  /// `apiKey` or `basic` for Komga; null for sources without remote auth.
  final String? authKind;

  /// Reserved for local sources (SAF tree URI / iOS bookmark) in T7; null here.
  final String? handle;

  /// Human-facing label shown in source lists.
  final String label;
  const Source({
    required this.id,
    required this.kind,
    this.baseUrl,
    this.authKind,
    this.handle,
    required this.label,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || baseUrl != null) {
      map['base_url'] = Variable<String>(baseUrl);
    }
    if (!nullToAbsent || authKind != null) {
      map['auth_kind'] = Variable<String>(authKind);
    }
    if (!nullToAbsent || handle != null) {
      map['handle'] = Variable<String>(handle);
    }
    map['label'] = Variable<String>(label);
    return map;
  }

  SourcesCompanion toCompanion(bool nullToAbsent) {
    return SourcesCompanion(
      id: Value(id),
      kind: Value(kind),
      baseUrl: baseUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(baseUrl),
      authKind: authKind == null && nullToAbsent
          ? const Value.absent()
          : Value(authKind),
      handle: handle == null && nullToAbsent
          ? const Value.absent()
          : Value(handle),
      label: Value(label),
    );
  }

  factory Source.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Source(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      baseUrl: serializer.fromJson<String?>(json['baseUrl']),
      authKind: serializer.fromJson<String?>(json['authKind']),
      handle: serializer.fromJson<String?>(json['handle']),
      label: serializer.fromJson<String>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'baseUrl': serializer.toJson<String?>(baseUrl),
      'authKind': serializer.toJson<String?>(authKind),
      'handle': serializer.toJson<String?>(handle),
      'label': serializer.toJson<String>(label),
    };
  }

  Source copyWith({
    String? id,
    String? kind,
    Value<String?> baseUrl = const Value.absent(),
    Value<String?> authKind = const Value.absent(),
    Value<String?> handle = const Value.absent(),
    String? label,
  }) => Source(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    baseUrl: baseUrl.present ? baseUrl.value : this.baseUrl,
    authKind: authKind.present ? authKind.value : this.authKind,
    handle: handle.present ? handle.value : this.handle,
    label: label ?? this.label,
  );
  Source copyWithCompanion(SourcesCompanion data) {
    return Source(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      baseUrl: data.baseUrl.present ? data.baseUrl.value : this.baseUrl,
      authKind: data.authKind.present ? data.authKind.value : this.authKind,
      handle: data.handle.present ? data.handle.value : this.handle,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Source(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('authKind: $authKind, ')
          ..write('handle: $handle, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, baseUrl, authKind, handle, label);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Source &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.baseUrl == this.baseUrl &&
          other.authKind == this.authKind &&
          other.handle == this.handle &&
          other.label == this.label);
}

class SourcesCompanion extends UpdateCompanion<Source> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String?> baseUrl;
  final Value<String?> authKind;
  final Value<String?> handle;
  final Value<String> label;
  final Value<int> rowid;
  const SourcesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.baseUrl = const Value.absent(),
    this.authKind = const Value.absent(),
    this.handle = const Value.absent(),
    this.label = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SourcesCompanion.insert({
    required String id,
    required String kind,
    this.baseUrl = const Value.absent(),
    this.authKind = const Value.absent(),
    this.handle = const Value.absent(),
    required String label,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       label = Value(label);
  static Insertable<Source> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? baseUrl,
    Expression<String>? authKind,
    Expression<String>? handle,
    Expression<String>? label,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (baseUrl != null) 'base_url': baseUrl,
      if (authKind != null) 'auth_kind': authKind,
      if (handle != null) 'handle': handle,
      if (label != null) 'label': label,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SourcesCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<String?>? baseUrl,
    Value<String?>? authKind,
    Value<String?>? handle,
    Value<String>? label,
    Value<int>? rowid,
  }) {
    return SourcesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      baseUrl: baseUrl ?? this.baseUrl,
      authKind: authKind ?? this.authKind,
      handle: handle ?? this.handle,
      label: label ?? this.label,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (baseUrl.present) {
      map['base_url'] = Variable<String>(baseUrl.value);
    }
    if (authKind.present) {
      map['auth_kind'] = Variable<String>(authKind.value);
    }
    if (handle.present) {
      map['handle'] = Variable<String>(handle.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourcesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('baseUrl: $baseUrl, ')
          ..write('authKind: $authKind, ')
          ..write('handle: $handle, ')
          ..write('label: $label, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LibrariesTable extends Libraries
    with TableInfo<$LibrariesTable, Library> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibrariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [sourceId, id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'libraries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Library> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, id};
  @override
  Library map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Library(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $LibrariesTable createAlias(String alias) {
    return $LibrariesTable(attachedDatabase, alias);
  }
}

class Library extends DataClass implements Insertable<Library> {
  /// FK to `Sources.id`.
  final String sourceId;

  /// Komga library id.
  final String id;
  final String name;
  const Library({required this.sourceId, required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  LibrariesCompanion toCompanion(bool nullToAbsent) {
    return LibrariesCompanion(
      sourceId: Value(sourceId),
      id: Value(id),
      name: Value(name),
    );
  }

  factory Library.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Library(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Library copyWith({String? sourceId, String? id, String? name}) => Library(
    sourceId: sourceId ?? this.sourceId,
    id: id ?? this.id,
    name: name ?? this.name,
  );
  Library copyWithCompanion(LibrariesCompanion data) {
    return Library(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Library(')
          ..write('sourceId: $sourceId, ')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sourceId, id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Library &&
          other.sourceId == this.sourceId &&
          other.id == this.id &&
          other.name == this.name);
}

class LibrariesCompanion extends UpdateCompanion<Library> {
  final Value<String> sourceId;
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const LibrariesCompanion({
    this.sourceId = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibrariesCompanion.insert({
    required String sourceId,
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       id = Value(id),
       name = Value(name);
  static Insertable<Library> custom({
    Expression<String>? sourceId,
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibrariesCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return LibrariesCompanion(
      sourceId: sourceId ?? this.sourceId,
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibrariesCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeriesTable extends Series with TableInfo<$SeriesTable, SeriesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _libraryIdMeta = const VerificationMeta(
    'libraryId',
  );
  @override
  late final GeneratedColumn<String> libraryId = GeneratedColumn<String>(
    'library_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleSortMeta = const VerificationMeta(
    'titleSort',
  );
  @override
  late final GeneratedColumn<String> titleSort = GeneratedColumn<String>(
    'title_sort',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageRatingMeta = const VerificationMeta(
    'ageRating',
  );
  @override
  late final GeneratedColumn<int> ageRating = GeneratedColumn<int>(
    'age_rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _booksCountMeta = const VerificationMeta(
    'booksCount',
  );
  @override
  late final GeneratedColumn<int> booksCount = GeneratedColumn<int>(
    'books_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceId,
    id,
    libraryId,
    title,
    titleSort,
    ageRating,
    status,
    summary,
    booksCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeriesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('library_id')) {
      context.handle(
        _libraryIdMeta,
        libraryId.isAcceptableOrUnknown(data['library_id']!, _libraryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_libraryIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('title_sort')) {
      context.handle(
        _titleSortMeta,
        titleSort.isAcceptableOrUnknown(data['title_sort']!, _titleSortMeta),
      );
    } else if (isInserting) {
      context.missing(_titleSortMeta);
    }
    if (data.containsKey('age_rating')) {
      context.handle(
        _ageRatingMeta,
        ageRating.isAcceptableOrUnknown(data['age_rating']!, _ageRatingMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('books_count')) {
      context.handle(
        _booksCountMeta,
        booksCount.isAcceptableOrUnknown(data['books_count']!, _booksCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, id};
  @override
  SeriesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesRow(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      libraryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}library_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      titleSort: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_sort'],
      )!,
      ageRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age_rating'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      booksCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}books_count'],
      )!,
    );
  }

  @override
  $SeriesTable createAlias(String alias) {
    return $SeriesTable(attachedDatabase, alias);
  }
}

class SeriesRow extends DataClass implements Insertable<SeriesRow> {
  /// FK to `Sources.id`.
  final String sourceId;

  /// Komga series id.
  final String id;

  /// Komga library id this series belongs to.
  final String libraryId;
  final String title;
  final String titleSort;
  final int? ageRating;
  final String? status;
  final String? summary;
  final int booksCount;
  const SeriesRow({
    required this.sourceId,
    required this.id,
    required this.libraryId,
    required this.title,
    required this.titleSort,
    this.ageRating,
    this.status,
    this.summary,
    required this.booksCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['id'] = Variable<String>(id);
    map['library_id'] = Variable<String>(libraryId);
    map['title'] = Variable<String>(title);
    map['title_sort'] = Variable<String>(titleSort);
    if (!nullToAbsent || ageRating != null) {
      map['age_rating'] = Variable<int>(ageRating);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    map['books_count'] = Variable<int>(booksCount);
    return map;
  }

  SeriesCompanion toCompanion(bool nullToAbsent) {
    return SeriesCompanion(
      sourceId: Value(sourceId),
      id: Value(id),
      libraryId: Value(libraryId),
      title: Value(title),
      titleSort: Value(titleSort),
      ageRating: ageRating == null && nullToAbsent
          ? const Value.absent()
          : Value(ageRating),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      booksCount: Value(booksCount),
    );
  }

  factory SeriesRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesRow(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      id: serializer.fromJson<String>(json['id']),
      libraryId: serializer.fromJson<String>(json['libraryId']),
      title: serializer.fromJson<String>(json['title']),
      titleSort: serializer.fromJson<String>(json['titleSort']),
      ageRating: serializer.fromJson<int?>(json['ageRating']),
      status: serializer.fromJson<String?>(json['status']),
      summary: serializer.fromJson<String?>(json['summary']),
      booksCount: serializer.fromJson<int>(json['booksCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'id': serializer.toJson<String>(id),
      'libraryId': serializer.toJson<String>(libraryId),
      'title': serializer.toJson<String>(title),
      'titleSort': serializer.toJson<String>(titleSort),
      'ageRating': serializer.toJson<int?>(ageRating),
      'status': serializer.toJson<String?>(status),
      'summary': serializer.toJson<String?>(summary),
      'booksCount': serializer.toJson<int>(booksCount),
    };
  }

  SeriesRow copyWith({
    String? sourceId,
    String? id,
    String? libraryId,
    String? title,
    String? titleSort,
    Value<int?> ageRating = const Value.absent(),
    Value<String?> status = const Value.absent(),
    Value<String?> summary = const Value.absent(),
    int? booksCount,
  }) => SeriesRow(
    sourceId: sourceId ?? this.sourceId,
    id: id ?? this.id,
    libraryId: libraryId ?? this.libraryId,
    title: title ?? this.title,
    titleSort: titleSort ?? this.titleSort,
    ageRating: ageRating.present ? ageRating.value : this.ageRating,
    status: status.present ? status.value : this.status,
    summary: summary.present ? summary.value : this.summary,
    booksCount: booksCount ?? this.booksCount,
  );
  SeriesRow copyWithCompanion(SeriesCompanion data) {
    return SeriesRow(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      id: data.id.present ? data.id.value : this.id,
      libraryId: data.libraryId.present ? data.libraryId.value : this.libraryId,
      title: data.title.present ? data.title.value : this.title,
      titleSort: data.titleSort.present ? data.titleSort.value : this.titleSort,
      ageRating: data.ageRating.present ? data.ageRating.value : this.ageRating,
      status: data.status.present ? data.status.value : this.status,
      summary: data.summary.present ? data.summary.value : this.summary,
      booksCount: data.booksCount.present
          ? data.booksCount.value
          : this.booksCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesRow(')
          ..write('sourceId: $sourceId, ')
          ..write('id: $id, ')
          ..write('libraryId: $libraryId, ')
          ..write('title: $title, ')
          ..write('titleSort: $titleSort, ')
          ..write('ageRating: $ageRating, ')
          ..write('status: $status, ')
          ..write('summary: $summary, ')
          ..write('booksCount: $booksCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sourceId,
    id,
    libraryId,
    title,
    titleSort,
    ageRating,
    status,
    summary,
    booksCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesRow &&
          other.sourceId == this.sourceId &&
          other.id == this.id &&
          other.libraryId == this.libraryId &&
          other.title == this.title &&
          other.titleSort == this.titleSort &&
          other.ageRating == this.ageRating &&
          other.status == this.status &&
          other.summary == this.summary &&
          other.booksCount == this.booksCount);
}

class SeriesCompanion extends UpdateCompanion<SeriesRow> {
  final Value<String> sourceId;
  final Value<String> id;
  final Value<String> libraryId;
  final Value<String> title;
  final Value<String> titleSort;
  final Value<int?> ageRating;
  final Value<String?> status;
  final Value<String?> summary;
  final Value<int> booksCount;
  final Value<int> rowid;
  const SeriesCompanion({
    this.sourceId = const Value.absent(),
    this.id = const Value.absent(),
    this.libraryId = const Value.absent(),
    this.title = const Value.absent(),
    this.titleSort = const Value.absent(),
    this.ageRating = const Value.absent(),
    this.status = const Value.absent(),
    this.summary = const Value.absent(),
    this.booksCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeriesCompanion.insert({
    required String sourceId,
    required String id,
    required String libraryId,
    required String title,
    required String titleSort,
    this.ageRating = const Value.absent(),
    this.status = const Value.absent(),
    this.summary = const Value.absent(),
    this.booksCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       id = Value(id),
       libraryId = Value(libraryId),
       title = Value(title),
       titleSort = Value(titleSort);
  static Insertable<SeriesRow> custom({
    Expression<String>? sourceId,
    Expression<String>? id,
    Expression<String>? libraryId,
    Expression<String>? title,
    Expression<String>? titleSort,
    Expression<int>? ageRating,
    Expression<String>? status,
    Expression<String>? summary,
    Expression<int>? booksCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (id != null) 'id': id,
      if (libraryId != null) 'library_id': libraryId,
      if (title != null) 'title': title,
      if (titleSort != null) 'title_sort': titleSort,
      if (ageRating != null) 'age_rating': ageRating,
      if (status != null) 'status': status,
      if (summary != null) 'summary': summary,
      if (booksCount != null) 'books_count': booksCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeriesCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? id,
    Value<String>? libraryId,
    Value<String>? title,
    Value<String>? titleSort,
    Value<int?>? ageRating,
    Value<String?>? status,
    Value<String?>? summary,
    Value<int>? booksCount,
    Value<int>? rowid,
  }) {
    return SeriesCompanion(
      sourceId: sourceId ?? this.sourceId,
      id: id ?? this.id,
      libraryId: libraryId ?? this.libraryId,
      title: title ?? this.title,
      titleSort: titleSort ?? this.titleSort,
      ageRating: ageRating ?? this.ageRating,
      status: status ?? this.status,
      summary: summary ?? this.summary,
      booksCount: booksCount ?? this.booksCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (libraryId.present) {
      map['library_id'] = Variable<String>(libraryId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (titleSort.present) {
      map['title_sort'] = Variable<String>(titleSort.value);
    }
    if (ageRating.present) {
      map['age_rating'] = Variable<int>(ageRating.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (booksCount.present) {
      map['books_count'] = Variable<int>(booksCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('id: $id, ')
          ..write('libraryId: $libraryId, ')
          ..write('title: $title, ')
          ..write('titleSort: $titleSort, ')
          ..write('ageRating: $ageRating, ')
          ..write('status: $status, ')
          ..write('summary: $summary, ')
          ..write('booksCount: $booksCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _libraryIdMeta = const VerificationMeta(
    'libraryId',
  );
  @override
  late final GeneratedColumn<String> libraryId = GeneratedColumn<String>(
    'library_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberSortMeta = const VerificationMeta(
    'numberSort',
  );
  @override
  late final GeneratedColumn<double> numberSort = GeneratedColumn<double>(
    'number_sort',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pagesCountMeta = const VerificationMeta(
    'pagesCount',
  );
  @override
  late final GeneratedColumn<int> pagesCount = GeneratedColumn<int>(
    'pages_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readPageMeta = const VerificationMeta(
    'readPage',
  );
  @override
  late final GeneratedColumn<int> readPage = GeneratedColumn<int>(
    'read_page',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceId,
    id,
    seriesId,
    libraryId,
    title,
    number,
    numberSort,
    pagesCount,
    mediaType,
    sizeBytes,
    readPage,
    completed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<Book> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    if (data.containsKey('library_id')) {
      context.handle(
        _libraryIdMeta,
        libraryId.isAcceptableOrUnknown(data['library_id']!, _libraryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_libraryIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('number_sort')) {
      context.handle(
        _numberSortMeta,
        numberSort.isAcceptableOrUnknown(data['number_sort']!, _numberSortMeta),
      );
    }
    if (data.containsKey('pages_count')) {
      context.handle(
        _pagesCountMeta,
        pagesCount.isAcceptableOrUnknown(data['pages_count']!, _pagesCountMeta),
      );
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('read_page')) {
      context.handle(
        _readPageMeta,
        readPage.isAcceptableOrUnknown(data['read_page']!, _readPageMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      )!,
      libraryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}library_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number'],
      )!,
      numberSort: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}number_sort'],
      ),
      pagesCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pages_count'],
      )!,
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      readPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}read_page'],
      ),
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  /// FK to `Sources.id`.
  final String sourceId;

  /// Komga book id.
  final String id;

  /// Komga series id this book belongs to.
  final String seriesId;

  /// Komga library id this book belongs to.
  final String libraryId;
  final String title;

  /// Issue/volume number as a display string (e.g. "1", "1.5", "Special").
  final String number;
  final double? numberSort;
  final int pagesCount;
  final String? mediaType;
  final int? sizeBytes;
  final int? readPage;
  final bool completed;
  const Book({
    required this.sourceId,
    required this.id,
    required this.seriesId,
    required this.libraryId,
    required this.title,
    required this.number,
    this.numberSort,
    required this.pagesCount,
    this.mediaType,
    this.sizeBytes,
    this.readPage,
    required this.completed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['id'] = Variable<String>(id);
    map['series_id'] = Variable<String>(seriesId);
    map['library_id'] = Variable<String>(libraryId);
    map['title'] = Variable<String>(title);
    map['number'] = Variable<String>(number);
    if (!nullToAbsent || numberSort != null) {
      map['number_sort'] = Variable<double>(numberSort);
    }
    map['pages_count'] = Variable<int>(pagesCount);
    if (!nullToAbsent || mediaType != null) {
      map['media_type'] = Variable<String>(mediaType);
    }
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    if (!nullToAbsent || readPage != null) {
      map['read_page'] = Variable<int>(readPage);
    }
    map['completed'] = Variable<bool>(completed);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      sourceId: Value(sourceId),
      id: Value(id),
      seriesId: Value(seriesId),
      libraryId: Value(libraryId),
      title: Value(title),
      number: Value(number),
      numberSort: numberSort == null && nullToAbsent
          ? const Value.absent()
          : Value(numberSort),
      pagesCount: Value(pagesCount),
      mediaType: mediaType == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaType),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      readPage: readPage == null && nullToAbsent
          ? const Value.absent()
          : Value(readPage),
      completed: Value(completed),
    );
  }

  factory Book.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      id: serializer.fromJson<String>(json['id']),
      seriesId: serializer.fromJson<String>(json['seriesId']),
      libraryId: serializer.fromJson<String>(json['libraryId']),
      title: serializer.fromJson<String>(json['title']),
      number: serializer.fromJson<String>(json['number']),
      numberSort: serializer.fromJson<double?>(json['numberSort']),
      pagesCount: serializer.fromJson<int>(json['pagesCount']),
      mediaType: serializer.fromJson<String?>(json['mediaType']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      readPage: serializer.fromJson<int?>(json['readPage']),
      completed: serializer.fromJson<bool>(json['completed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'id': serializer.toJson<String>(id),
      'seriesId': serializer.toJson<String>(seriesId),
      'libraryId': serializer.toJson<String>(libraryId),
      'title': serializer.toJson<String>(title),
      'number': serializer.toJson<String>(number),
      'numberSort': serializer.toJson<double?>(numberSort),
      'pagesCount': serializer.toJson<int>(pagesCount),
      'mediaType': serializer.toJson<String?>(mediaType),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'readPage': serializer.toJson<int?>(readPage),
      'completed': serializer.toJson<bool>(completed),
    };
  }

  Book copyWith({
    String? sourceId,
    String? id,
    String? seriesId,
    String? libraryId,
    String? title,
    String? number,
    Value<double?> numberSort = const Value.absent(),
    int? pagesCount,
    Value<String?> mediaType = const Value.absent(),
    Value<int?> sizeBytes = const Value.absent(),
    Value<int?> readPage = const Value.absent(),
    bool? completed,
  }) => Book(
    sourceId: sourceId ?? this.sourceId,
    id: id ?? this.id,
    seriesId: seriesId ?? this.seriesId,
    libraryId: libraryId ?? this.libraryId,
    title: title ?? this.title,
    number: number ?? this.number,
    numberSort: numberSort.present ? numberSort.value : this.numberSort,
    pagesCount: pagesCount ?? this.pagesCount,
    mediaType: mediaType.present ? mediaType.value : this.mediaType,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    readPage: readPage.present ? readPage.value : this.readPage,
    completed: completed ?? this.completed,
  );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      id: data.id.present ? data.id.value : this.id,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      libraryId: data.libraryId.present ? data.libraryId.value : this.libraryId,
      title: data.title.present ? data.title.value : this.title,
      number: data.number.present ? data.number.value : this.number,
      numberSort: data.numberSort.present
          ? data.numberSort.value
          : this.numberSort,
      pagesCount: data.pagesCount.present
          ? data.pagesCount.value
          : this.pagesCount,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      readPage: data.readPage.present ? data.readPage.value : this.readPage,
      completed: data.completed.present ? data.completed.value : this.completed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('sourceId: $sourceId, ')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('libraryId: $libraryId, ')
          ..write('title: $title, ')
          ..write('number: $number, ')
          ..write('numberSort: $numberSort, ')
          ..write('pagesCount: $pagesCount, ')
          ..write('mediaType: $mediaType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('readPage: $readPage, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sourceId,
    id,
    seriesId,
    libraryId,
    title,
    number,
    numberSort,
    pagesCount,
    mediaType,
    sizeBytes,
    readPage,
    completed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.sourceId == this.sourceId &&
          other.id == this.id &&
          other.seriesId == this.seriesId &&
          other.libraryId == this.libraryId &&
          other.title == this.title &&
          other.number == this.number &&
          other.numberSort == this.numberSort &&
          other.pagesCount == this.pagesCount &&
          other.mediaType == this.mediaType &&
          other.sizeBytes == this.sizeBytes &&
          other.readPage == this.readPage &&
          other.completed == this.completed);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<String> sourceId;
  final Value<String> id;
  final Value<String> seriesId;
  final Value<String> libraryId;
  final Value<String> title;
  final Value<String> number;
  final Value<double?> numberSort;
  final Value<int> pagesCount;
  final Value<String?> mediaType;
  final Value<int?> sizeBytes;
  final Value<int?> readPage;
  final Value<bool> completed;
  final Value<int> rowid;
  const BooksCompanion({
    this.sourceId = const Value.absent(),
    this.id = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.libraryId = const Value.absent(),
    this.title = const Value.absent(),
    this.number = const Value.absent(),
    this.numberSort = const Value.absent(),
    this.pagesCount = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.readPage = const Value.absent(),
    this.completed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BooksCompanion.insert({
    required String sourceId,
    required String id,
    required String seriesId,
    required String libraryId,
    required String title,
    required String number,
    this.numberSort = const Value.absent(),
    this.pagesCount = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.readPage = const Value.absent(),
    this.completed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       id = Value(id),
       seriesId = Value(seriesId),
       libraryId = Value(libraryId),
       title = Value(title),
       number = Value(number);
  static Insertable<Book> custom({
    Expression<String>? sourceId,
    Expression<String>? id,
    Expression<String>? seriesId,
    Expression<String>? libraryId,
    Expression<String>? title,
    Expression<String>? number,
    Expression<double>? numberSort,
    Expression<int>? pagesCount,
    Expression<String>? mediaType,
    Expression<int>? sizeBytes,
    Expression<int>? readPage,
    Expression<bool>? completed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (id != null) 'id': id,
      if (seriesId != null) 'series_id': seriesId,
      if (libraryId != null) 'library_id': libraryId,
      if (title != null) 'title': title,
      if (number != null) 'number': number,
      if (numberSort != null) 'number_sort': numberSort,
      if (pagesCount != null) 'pages_count': pagesCount,
      if (mediaType != null) 'media_type': mediaType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (readPage != null) 'read_page': readPage,
      if (completed != null) 'completed': completed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BooksCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? id,
    Value<String>? seriesId,
    Value<String>? libraryId,
    Value<String>? title,
    Value<String>? number,
    Value<double?>? numberSort,
    Value<int>? pagesCount,
    Value<String?>? mediaType,
    Value<int?>? sizeBytes,
    Value<int?>? readPage,
    Value<bool>? completed,
    Value<int>? rowid,
  }) {
    return BooksCompanion(
      sourceId: sourceId ?? this.sourceId,
      id: id ?? this.id,
      seriesId: seriesId ?? this.seriesId,
      libraryId: libraryId ?? this.libraryId,
      title: title ?? this.title,
      number: number ?? this.number,
      numberSort: numberSort ?? this.numberSort,
      pagesCount: pagesCount ?? this.pagesCount,
      mediaType: mediaType ?? this.mediaType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      readPage: readPage ?? this.readPage,
      completed: completed ?? this.completed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (libraryId.present) {
      map['library_id'] = Variable<String>(libraryId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (numberSort.present) {
      map['number_sort'] = Variable<double>(numberSort.value);
    }
    if (pagesCount.present) {
      map['pages_count'] = Variable<int>(pagesCount.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (readPage.present) {
      map['read_page'] = Variable<int>(readPage.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('libraryId: $libraryId, ')
          ..write('title: $title, ')
          ..write('number: $number, ')
          ..write('numberSort: $numberSort, ')
          ..write('pagesCount: $pagesCount, ')
          ..write('mediaType: $mediaType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('readPage: $readPage, ')
          ..write('completed: $completed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ThumbnailsTable extends Thumbnails
    with TableInfo<$ThumbnailsTable, Thumbnail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThumbnailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerTypeMeta = const VerificationMeta(
    'ownerType',
  );
  @override
  late final GeneratedColumn<String> ownerType = GeneratedColumn<String>(
    'owner_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<Uint8List> bytes = GeneratedColumn<Uint8List>(
    'bytes',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diskPathMeta = const VerificationMeta(
    'diskPath',
  );
  @override
  late final GeneratedColumn<String> diskPath = GeneratedColumn<String>(
    'disk_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  @override
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
    'etag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceId,
    ownerType,
    ownerId,
    bytes,
    diskPath,
    etag,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'thumbnails';
  @override
  VerificationContext validateIntegrity(
    Insertable<Thumbnail> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('owner_type')) {
      context.handle(
        _ownerTypeMeta,
        ownerType.isAcceptableOrUnknown(data['owner_type']!, _ownerTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerTypeMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    }
    if (data.containsKey('disk_path')) {
      context.handle(
        _diskPathMeta,
        diskPath.isAcceptableOrUnknown(data['disk_path']!, _diskPathMeta),
      );
    }
    if (data.containsKey('etag')) {
      context.handle(
        _etagMeta,
        etag.isAcceptableOrUnknown(data['etag']!, _etagMeta),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, ownerType, ownerId};
  @override
  Thumbnail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Thumbnail(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      ownerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_type'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}bytes'],
      ),
      diskPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}disk_path'],
      ),
      etag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etag'],
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $ThumbnailsTable createAlias(String alias) {
    return $ThumbnailsTable(attachedDatabase, alias);
  }
}

class Thumbnail extends DataClass implements Insertable<Thumbnail> {
  /// FK to `Sources.id`.
  final String sourceId;

  /// `series` or `book`.
  final String ownerType;

  /// Komga id of the owning series/book.
  final String ownerId;
  final Uint8List? bytes;

  /// Path RELATIVE to applicationSupport when the image spilled to disk.
  final String? diskPath;
  final String? etag;
  final int fetchedAt;
  const Thumbnail({
    required this.sourceId,
    required this.ownerType,
    required this.ownerId,
    this.bytes,
    this.diskPath,
    this.etag,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['owner_type'] = Variable<String>(ownerType);
    map['owner_id'] = Variable<String>(ownerId);
    if (!nullToAbsent || bytes != null) {
      map['bytes'] = Variable<Uint8List>(bytes);
    }
    if (!nullToAbsent || diskPath != null) {
      map['disk_path'] = Variable<String>(diskPath);
    }
    if (!nullToAbsent || etag != null) {
      map['etag'] = Variable<String>(etag);
    }
    map['fetched_at'] = Variable<int>(fetchedAt);
    return map;
  }

  ThumbnailsCompanion toCompanion(bool nullToAbsent) {
    return ThumbnailsCompanion(
      sourceId: Value(sourceId),
      ownerType: Value(ownerType),
      ownerId: Value(ownerId),
      bytes: bytes == null && nullToAbsent
          ? const Value.absent()
          : Value(bytes),
      diskPath: diskPath == null && nullToAbsent
          ? const Value.absent()
          : Value(diskPath),
      etag: etag == null && nullToAbsent ? const Value.absent() : Value(etag),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory Thumbnail.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Thumbnail(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      ownerType: serializer.fromJson<String>(json['ownerType']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      bytes: serializer.fromJson<Uint8List?>(json['bytes']),
      diskPath: serializer.fromJson<String?>(json['diskPath']),
      etag: serializer.fromJson<String?>(json['etag']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'ownerType': serializer.toJson<String>(ownerType),
      'ownerId': serializer.toJson<String>(ownerId),
      'bytes': serializer.toJson<Uint8List?>(bytes),
      'diskPath': serializer.toJson<String?>(diskPath),
      'etag': serializer.toJson<String?>(etag),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
    };
  }

  Thumbnail copyWith({
    String? sourceId,
    String? ownerType,
    String? ownerId,
    Value<Uint8List?> bytes = const Value.absent(),
    Value<String?> diskPath = const Value.absent(),
    Value<String?> etag = const Value.absent(),
    int? fetchedAt,
  }) => Thumbnail(
    sourceId: sourceId ?? this.sourceId,
    ownerType: ownerType ?? this.ownerType,
    ownerId: ownerId ?? this.ownerId,
    bytes: bytes.present ? bytes.value : this.bytes,
    diskPath: diskPath.present ? diskPath.value : this.diskPath,
    etag: etag.present ? etag.value : this.etag,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  Thumbnail copyWithCompanion(ThumbnailsCompanion data) {
    return Thumbnail(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      ownerType: data.ownerType.present ? data.ownerType.value : this.ownerType,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      diskPath: data.diskPath.present ? data.diskPath.value : this.diskPath,
      etag: data.etag.present ? data.etag.value : this.etag,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Thumbnail(')
          ..write('sourceId: $sourceId, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('bytes: $bytes, ')
          ..write('diskPath: $diskPath, ')
          ..write('etag: $etag, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sourceId,
    ownerType,
    ownerId,
    $driftBlobEquality.hash(bytes),
    diskPath,
    etag,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Thumbnail &&
          other.sourceId == this.sourceId &&
          other.ownerType == this.ownerType &&
          other.ownerId == this.ownerId &&
          $driftBlobEquality.equals(other.bytes, this.bytes) &&
          other.diskPath == this.diskPath &&
          other.etag == this.etag &&
          other.fetchedAt == this.fetchedAt);
}

class ThumbnailsCompanion extends UpdateCompanion<Thumbnail> {
  final Value<String> sourceId;
  final Value<String> ownerType;
  final Value<String> ownerId;
  final Value<Uint8List?> bytes;
  final Value<String?> diskPath;
  final Value<String?> etag;
  final Value<int> fetchedAt;
  final Value<int> rowid;
  const ThumbnailsCompanion({
    this.sourceId = const Value.absent(),
    this.ownerType = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.bytes = const Value.absent(),
    this.diskPath = const Value.absent(),
    this.etag = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ThumbnailsCompanion.insert({
    required String sourceId,
    required String ownerType,
    required String ownerId,
    this.bytes = const Value.absent(),
    this.diskPath = const Value.absent(),
    this.etag = const Value.absent(),
    required int fetchedAt,
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       ownerType = Value(ownerType),
       ownerId = Value(ownerId),
       fetchedAt = Value(fetchedAt);
  static Insertable<Thumbnail> custom({
    Expression<String>? sourceId,
    Expression<String>? ownerType,
    Expression<String>? ownerId,
    Expression<Uint8List>? bytes,
    Expression<String>? diskPath,
    Expression<String>? etag,
    Expression<int>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (ownerType != null) 'owner_type': ownerType,
      if (ownerId != null) 'owner_id': ownerId,
      if (bytes != null) 'bytes': bytes,
      if (diskPath != null) 'disk_path': diskPath,
      if (etag != null) 'etag': etag,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ThumbnailsCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? ownerType,
    Value<String>? ownerId,
    Value<Uint8List?>? bytes,
    Value<String?>? diskPath,
    Value<String?>? etag,
    Value<int>? fetchedAt,
    Value<int>? rowid,
  }) {
    return ThumbnailsCompanion(
      sourceId: sourceId ?? this.sourceId,
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      bytes: bytes ?? this.bytes,
      diskPath: diskPath ?? this.diskPath,
      etag: etag ?? this.etag,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (ownerType.present) {
      map['owner_type'] = Variable<String>(ownerType.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<Uint8List>(bytes.value);
    }
    if (diskPath.present) {
      map['disk_path'] = Variable<String>(diskPath.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThumbnailsCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('bytes: $bytes, ')
          ..write('diskPath: $diskPath, ')
          ..write('etag: $etag, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedMetadataTable extends CachedMetadata
    with TableInfo<$CachedMetadataTable, CachedMetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerTypeMeta = const VerificationMeta(
    'ownerType',
  );
  @override
  late final GeneratedColumn<String> ownerType = GeneratedColumn<String>(
    'owner_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceId,
    ownerType,
    ownerId,
    json,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedMetadataRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('owner_type')) {
      context.handle(
        _ownerTypeMeta,
        ownerType.isAcceptableOrUnknown(data['owner_type']!, _ownerTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerTypeMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, ownerType, ownerId};
  @override
  CachedMetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedMetadataRow(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      ownerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_type'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $CachedMetadataTable createAlias(String alias) {
    return $CachedMetadataTable(attachedDatabase, alias);
  }
}

class CachedMetadataRow extends DataClass
    implements Insertable<CachedMetadataRow> {
  /// FK to `Sources.id`.
  final String sourceId;

  /// `collections` or `readlists`.
  final String ownerType;
  final String ownerId;
  final String json;
  final int fetchedAt;
  const CachedMetadataRow({
    required this.sourceId,
    required this.ownerType,
    required this.ownerId,
    required this.json,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['owner_type'] = Variable<String>(ownerType);
    map['owner_id'] = Variable<String>(ownerId);
    map['json'] = Variable<String>(json);
    map['fetched_at'] = Variable<int>(fetchedAt);
    return map;
  }

  CachedMetadataCompanion toCompanion(bool nullToAbsent) {
    return CachedMetadataCompanion(
      sourceId: Value(sourceId),
      ownerType: Value(ownerType),
      ownerId: Value(ownerId),
      json: Value(json),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory CachedMetadataRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedMetadataRow(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      ownerType: serializer.fromJson<String>(json['ownerType']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      json: serializer.fromJson<String>(json['json']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'ownerType': serializer.toJson<String>(ownerType),
      'ownerId': serializer.toJson<String>(ownerId),
      'json': serializer.toJson<String>(json),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
    };
  }

  CachedMetadataRow copyWith({
    String? sourceId,
    String? ownerType,
    String? ownerId,
    String? json,
    int? fetchedAt,
  }) => CachedMetadataRow(
    sourceId: sourceId ?? this.sourceId,
    ownerType: ownerType ?? this.ownerType,
    ownerId: ownerId ?? this.ownerId,
    json: json ?? this.json,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  CachedMetadataRow copyWithCompanion(CachedMetadataCompanion data) {
    return CachedMetadataRow(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      ownerType: data.ownerType.present ? data.ownerType.value : this.ownerType,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      json: data.json.present ? data.json.value : this.json,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedMetadataRow(')
          ..write('sourceId: $sourceId, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('json: $json, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(sourceId, ownerType, ownerId, json, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedMetadataRow &&
          other.sourceId == this.sourceId &&
          other.ownerType == this.ownerType &&
          other.ownerId == this.ownerId &&
          other.json == this.json &&
          other.fetchedAt == this.fetchedAt);
}

class CachedMetadataCompanion extends UpdateCompanion<CachedMetadataRow> {
  final Value<String> sourceId;
  final Value<String> ownerType;
  final Value<String> ownerId;
  final Value<String> json;
  final Value<int> fetchedAt;
  final Value<int> rowid;
  const CachedMetadataCompanion({
    this.sourceId = const Value.absent(),
    this.ownerType = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.json = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedMetadataCompanion.insert({
    required String sourceId,
    required String ownerType,
    required String ownerId,
    required String json,
    required int fetchedAt,
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       ownerType = Value(ownerType),
       ownerId = Value(ownerId),
       json = Value(json),
       fetchedAt = Value(fetchedAt);
  static Insertable<CachedMetadataRow> custom({
    Expression<String>? sourceId,
    Expression<String>? ownerType,
    Expression<String>? ownerId,
    Expression<String>? json,
    Expression<int>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (ownerType != null) 'owner_type': ownerType,
      if (ownerId != null) 'owner_id': ownerId,
      if (json != null) 'json': json,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedMetadataCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? ownerType,
    Value<String>? ownerId,
    Value<String>? json,
    Value<int>? fetchedAt,
    Value<int>? rowid,
  }) {
    return CachedMetadataCompanion(
      sourceId: sourceId ?? this.sourceId,
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      json: json ?? this.json,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (ownerType.present) {
      map['owner_type'] = Variable<String>(ownerType.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedMetadataCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('json: $json, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LibraryPrefsTable extends LibraryPrefs
    with TableInfo<$LibraryPrefsTable, LibraryPref> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryPrefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _libraryIdMeta = const VerificationMeta(
    'libraryId',
  );
  @override
  late final GeneratedColumn<String> libraryId = GeneratedColumn<String>(
    'library_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lockedMeta = const VerificationMeta('locked');
  @override
  late final GeneratedColumn<bool> locked = GeneratedColumn<bool>(
    'locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _showRestrictedMeta = const VerificationMeta(
    'showRestricted',
  );
  @override
  late final GeneratedColumn<bool> showRestricted = GeneratedColumn<bool>(
    'show_restricted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_restricted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceId,
    libraryId,
    locked,
    showRestricted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_prefs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryPref> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('library_id')) {
      context.handle(
        _libraryIdMeta,
        libraryId.isAcceptableOrUnknown(data['library_id']!, _libraryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_libraryIdMeta);
    }
    if (data.containsKey('locked')) {
      context.handle(
        _lockedMeta,
        locked.isAcceptableOrUnknown(data['locked']!, _lockedMeta),
      );
    }
    if (data.containsKey('show_restricted')) {
      context.handle(
        _showRestrictedMeta,
        showRestricted.isAcceptableOrUnknown(
          data['show_restricted']!,
          _showRestrictedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, libraryId};
  @override
  LibraryPref map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryPref(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      libraryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}library_id'],
      )!,
      locked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}locked'],
      )!,
      showRestricted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_restricted'],
      )!,
    );
  }

  @override
  $LibraryPrefsTable createAlias(String alias) {
    return $LibraryPrefsTable(attachedDatabase, alias);
  }
}

class LibraryPref extends DataClass implements Insertable<LibraryPref> {
  /// FK to `Sources.id`.
  final String sourceId;

  /// Komga library id.
  final String libraryId;
  final bool locked;
  final bool showRestricted;
  const LibraryPref({
    required this.sourceId,
    required this.libraryId,
    required this.locked,
    required this.showRestricted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['library_id'] = Variable<String>(libraryId);
    map['locked'] = Variable<bool>(locked);
    map['show_restricted'] = Variable<bool>(showRestricted);
    return map;
  }

  LibraryPrefsCompanion toCompanion(bool nullToAbsent) {
    return LibraryPrefsCompanion(
      sourceId: Value(sourceId),
      libraryId: Value(libraryId),
      locked: Value(locked),
      showRestricted: Value(showRestricted),
    );
  }

  factory LibraryPref.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryPref(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      libraryId: serializer.fromJson<String>(json['libraryId']),
      locked: serializer.fromJson<bool>(json['locked']),
      showRestricted: serializer.fromJson<bool>(json['showRestricted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'libraryId': serializer.toJson<String>(libraryId),
      'locked': serializer.toJson<bool>(locked),
      'showRestricted': serializer.toJson<bool>(showRestricted),
    };
  }

  LibraryPref copyWith({
    String? sourceId,
    String? libraryId,
    bool? locked,
    bool? showRestricted,
  }) => LibraryPref(
    sourceId: sourceId ?? this.sourceId,
    libraryId: libraryId ?? this.libraryId,
    locked: locked ?? this.locked,
    showRestricted: showRestricted ?? this.showRestricted,
  );
  LibraryPref copyWithCompanion(LibraryPrefsCompanion data) {
    return LibraryPref(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      libraryId: data.libraryId.present ? data.libraryId.value : this.libraryId,
      locked: data.locked.present ? data.locked.value : this.locked,
      showRestricted: data.showRestricted.present
          ? data.showRestricted.value
          : this.showRestricted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryPref(')
          ..write('sourceId: $sourceId, ')
          ..write('libraryId: $libraryId, ')
          ..write('locked: $locked, ')
          ..write('showRestricted: $showRestricted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sourceId, libraryId, locked, showRestricted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryPref &&
          other.sourceId == this.sourceId &&
          other.libraryId == this.libraryId &&
          other.locked == this.locked &&
          other.showRestricted == this.showRestricted);
}

class LibraryPrefsCompanion extends UpdateCompanion<LibraryPref> {
  final Value<String> sourceId;
  final Value<String> libraryId;
  final Value<bool> locked;
  final Value<bool> showRestricted;
  final Value<int> rowid;
  const LibraryPrefsCompanion({
    this.sourceId = const Value.absent(),
    this.libraryId = const Value.absent(),
    this.locked = const Value.absent(),
    this.showRestricted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryPrefsCompanion.insert({
    required String sourceId,
    required String libraryId,
    this.locked = const Value.absent(),
    this.showRestricted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       libraryId = Value(libraryId);
  static Insertable<LibraryPref> custom({
    Expression<String>? sourceId,
    Expression<String>? libraryId,
    Expression<bool>? locked,
    Expression<bool>? showRestricted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (libraryId != null) 'library_id': libraryId,
      if (locked != null) 'locked': locked,
      if (showRestricted != null) 'show_restricted': showRestricted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryPrefsCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? libraryId,
    Value<bool>? locked,
    Value<bool>? showRestricted,
    Value<int>? rowid,
  }) {
    return LibraryPrefsCompanion(
      sourceId: sourceId ?? this.sourceId,
      libraryId: libraryId ?? this.libraryId,
      locked: locked ?? this.locked,
      showRestricted: showRestricted ?? this.showRestricted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (libraryId.present) {
      map['library_id'] = Variable<String>(libraryId.value);
    }
    if (locked.present) {
      map['locked'] = Variable<bool>(locked.value);
    }
    if (showRestricted.present) {
      map['show_restricted'] = Variable<bool>(showRestricted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryPrefsCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('libraryId: $libraryId, ')
          ..write('locked: $locked, ')
          ..write('showRestricted: $showRestricted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReaderSettingsTable extends ReaderSettings
    with TableInfo<$ReaderSettingsTable, ReaderSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReaderSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fitMeta = const VerificationMeta('fit');
  @override
  late final GeneratedColumn<String> fit = GeneratedColumn<String>(
    'fit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tapsMeta = const VerificationMeta('taps');
  @override
  late final GeneratedColumn<String> taps = GeneratedColumn<String>(
    'taps',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invertTapsMeta = const VerificationMeta(
    'invertTaps',
  );
  @override
  late final GeneratedColumn<bool> invertTaps = GeneratedColumn<bool>(
    'invert_taps',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("invert_taps" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _doubleTapZoomMeta = const VerificationMeta(
    'doubleTapZoom',
  );
  @override
  late final GeneratedColumn<bool> doubleTapZoom = GeneratedColumn<bool>(
    'double_tap_zoom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("double_tap_zoom" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _animatePageTurnMeta = const VerificationMeta(
    'animatePageTurn',
  );
  @override
  late final GeneratedColumn<bool> animatePageTurn = GeneratedColumn<bool>(
    'animate_page_turn',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("animate_page_turn" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceId,
    seriesId,
    mode,
    fit,
    taps,
    invertTaps,
    doubleTapZoom,
    animatePageTurn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reader_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReaderSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('fit')) {
      context.handle(
        _fitMeta,
        fit.isAcceptableOrUnknown(data['fit']!, _fitMeta),
      );
    } else if (isInserting) {
      context.missing(_fitMeta);
    }
    if (data.containsKey('taps')) {
      context.handle(
        _tapsMeta,
        taps.isAcceptableOrUnknown(data['taps']!, _tapsMeta),
      );
    } else if (isInserting) {
      context.missing(_tapsMeta);
    }
    if (data.containsKey('invert_taps')) {
      context.handle(
        _invertTapsMeta,
        invertTaps.isAcceptableOrUnknown(data['invert_taps']!, _invertTapsMeta),
      );
    }
    if (data.containsKey('double_tap_zoom')) {
      context.handle(
        _doubleTapZoomMeta,
        doubleTapZoom.isAcceptableOrUnknown(
          data['double_tap_zoom']!,
          _doubleTapZoomMeta,
        ),
      );
    }
    if (data.containsKey('animate_page_turn')) {
      context.handle(
        _animatePageTurnMeta,
        animatePageTurn.isAcceptableOrUnknown(
          data['animate_page_turn']!,
          _animatePageTurnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, seriesId};
  @override
  ReaderSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReaderSettingsRow(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      fit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fit'],
      )!,
      taps: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}taps'],
      )!,
      invertTaps: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}invert_taps'],
      )!,
      doubleTapZoom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}double_tap_zoom'],
      )!,
      animatePageTurn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}animate_page_turn'],
      )!,
    );
  }

  @override
  $ReaderSettingsTable createAlias(String alias) {
    return $ReaderSettingsTable(attachedDatabase, alias);
  }
}

class ReaderSettingsRow extends DataClass
    implements Insertable<ReaderSettingsRow> {
  /// FK to `Sources.id`.
  final String sourceId;

  /// Komga series id these settings apply to.
  final String seriesId;
  final String mode;
  final String fit;
  final String taps;
  final bool invertTaps;
  final bool doubleTapZoom;
  final bool animatePageTurn;
  const ReaderSettingsRow({
    required this.sourceId,
    required this.seriesId,
    required this.mode,
    required this.fit,
    required this.taps,
    required this.invertTaps,
    required this.doubleTapZoom,
    required this.animatePageTurn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['series_id'] = Variable<String>(seriesId);
    map['mode'] = Variable<String>(mode);
    map['fit'] = Variable<String>(fit);
    map['taps'] = Variable<String>(taps);
    map['invert_taps'] = Variable<bool>(invertTaps);
    map['double_tap_zoom'] = Variable<bool>(doubleTapZoom);
    map['animate_page_turn'] = Variable<bool>(animatePageTurn);
    return map;
  }

  ReaderSettingsCompanion toCompanion(bool nullToAbsent) {
    return ReaderSettingsCompanion(
      sourceId: Value(sourceId),
      seriesId: Value(seriesId),
      mode: Value(mode),
      fit: Value(fit),
      taps: Value(taps),
      invertTaps: Value(invertTaps),
      doubleTapZoom: Value(doubleTapZoom),
      animatePageTurn: Value(animatePageTurn),
    );
  }

  factory ReaderSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReaderSettingsRow(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      seriesId: serializer.fromJson<String>(json['seriesId']),
      mode: serializer.fromJson<String>(json['mode']),
      fit: serializer.fromJson<String>(json['fit']),
      taps: serializer.fromJson<String>(json['taps']),
      invertTaps: serializer.fromJson<bool>(json['invertTaps']),
      doubleTapZoom: serializer.fromJson<bool>(json['doubleTapZoom']),
      animatePageTurn: serializer.fromJson<bool>(json['animatePageTurn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'seriesId': serializer.toJson<String>(seriesId),
      'mode': serializer.toJson<String>(mode),
      'fit': serializer.toJson<String>(fit),
      'taps': serializer.toJson<String>(taps),
      'invertTaps': serializer.toJson<bool>(invertTaps),
      'doubleTapZoom': serializer.toJson<bool>(doubleTapZoom),
      'animatePageTurn': serializer.toJson<bool>(animatePageTurn),
    };
  }

  ReaderSettingsRow copyWith({
    String? sourceId,
    String? seriesId,
    String? mode,
    String? fit,
    String? taps,
    bool? invertTaps,
    bool? doubleTapZoom,
    bool? animatePageTurn,
  }) => ReaderSettingsRow(
    sourceId: sourceId ?? this.sourceId,
    seriesId: seriesId ?? this.seriesId,
    mode: mode ?? this.mode,
    fit: fit ?? this.fit,
    taps: taps ?? this.taps,
    invertTaps: invertTaps ?? this.invertTaps,
    doubleTapZoom: doubleTapZoom ?? this.doubleTapZoom,
    animatePageTurn: animatePageTurn ?? this.animatePageTurn,
  );
  ReaderSettingsRow copyWithCompanion(ReaderSettingsCompanion data) {
    return ReaderSettingsRow(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      mode: data.mode.present ? data.mode.value : this.mode,
      fit: data.fit.present ? data.fit.value : this.fit,
      taps: data.taps.present ? data.taps.value : this.taps,
      invertTaps: data.invertTaps.present
          ? data.invertTaps.value
          : this.invertTaps,
      doubleTapZoom: data.doubleTapZoom.present
          ? data.doubleTapZoom.value
          : this.doubleTapZoom,
      animatePageTurn: data.animatePageTurn.present
          ? data.animatePageTurn.value
          : this.animatePageTurn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReaderSettingsRow(')
          ..write('sourceId: $sourceId, ')
          ..write('seriesId: $seriesId, ')
          ..write('mode: $mode, ')
          ..write('fit: $fit, ')
          ..write('taps: $taps, ')
          ..write('invertTaps: $invertTaps, ')
          ..write('doubleTapZoom: $doubleTapZoom, ')
          ..write('animatePageTurn: $animatePageTurn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sourceId,
    seriesId,
    mode,
    fit,
    taps,
    invertTaps,
    doubleTapZoom,
    animatePageTurn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReaderSettingsRow &&
          other.sourceId == this.sourceId &&
          other.seriesId == this.seriesId &&
          other.mode == this.mode &&
          other.fit == this.fit &&
          other.taps == this.taps &&
          other.invertTaps == this.invertTaps &&
          other.doubleTapZoom == this.doubleTapZoom &&
          other.animatePageTurn == this.animatePageTurn);
}

class ReaderSettingsCompanion extends UpdateCompanion<ReaderSettingsRow> {
  final Value<String> sourceId;
  final Value<String> seriesId;
  final Value<String> mode;
  final Value<String> fit;
  final Value<String> taps;
  final Value<bool> invertTaps;
  final Value<bool> doubleTapZoom;
  final Value<bool> animatePageTurn;
  final Value<int> rowid;
  const ReaderSettingsCompanion({
    this.sourceId = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.mode = const Value.absent(),
    this.fit = const Value.absent(),
    this.taps = const Value.absent(),
    this.invertTaps = const Value.absent(),
    this.doubleTapZoom = const Value.absent(),
    this.animatePageTurn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReaderSettingsCompanion.insert({
    required String sourceId,
    required String seriesId,
    required String mode,
    required String fit,
    required String taps,
    this.invertTaps = const Value.absent(),
    this.doubleTapZoom = const Value.absent(),
    this.animatePageTurn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       seriesId = Value(seriesId),
       mode = Value(mode),
       fit = Value(fit),
       taps = Value(taps);
  static Insertable<ReaderSettingsRow> custom({
    Expression<String>? sourceId,
    Expression<String>? seriesId,
    Expression<String>? mode,
    Expression<String>? fit,
    Expression<String>? taps,
    Expression<bool>? invertTaps,
    Expression<bool>? doubleTapZoom,
    Expression<bool>? animatePageTurn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (seriesId != null) 'series_id': seriesId,
      if (mode != null) 'mode': mode,
      if (fit != null) 'fit': fit,
      if (taps != null) 'taps': taps,
      if (invertTaps != null) 'invert_taps': invertTaps,
      if (doubleTapZoom != null) 'double_tap_zoom': doubleTapZoom,
      if (animatePageTurn != null) 'animate_page_turn': animatePageTurn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReaderSettingsCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? seriesId,
    Value<String>? mode,
    Value<String>? fit,
    Value<String>? taps,
    Value<bool>? invertTaps,
    Value<bool>? doubleTapZoom,
    Value<bool>? animatePageTurn,
    Value<int>? rowid,
  }) {
    return ReaderSettingsCompanion(
      sourceId: sourceId ?? this.sourceId,
      seriesId: seriesId ?? this.seriesId,
      mode: mode ?? this.mode,
      fit: fit ?? this.fit,
      taps: taps ?? this.taps,
      invertTaps: invertTaps ?? this.invertTaps,
      doubleTapZoom: doubleTapZoom ?? this.doubleTapZoom,
      animatePageTurn: animatePageTurn ?? this.animatePageTurn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (fit.present) {
      map['fit'] = Variable<String>(fit.value);
    }
    if (taps.present) {
      map['taps'] = Variable<String>(taps.value);
    }
    if (invertTaps.present) {
      map['invert_taps'] = Variable<bool>(invertTaps.value);
    }
    if (doubleTapZoom.present) {
      map['double_tap_zoom'] = Variable<bool>(doubleTapZoom.value);
    }
    if (animatePageTurn.present) {
      map['animate_page_turn'] = Variable<bool>(animatePageTurn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReaderSettingsCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('seriesId: $seriesId, ')
          ..write('mode: $mode, ')
          ..write('fit: $fit, ')
          ..write('taps: $taps, ')
          ..write('invertTaps: $invertTaps, ')
          ..write('doubleTapZoom: $doubleTapZoom, ')
          ..write('animatePageTurn: $animatePageTurn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $SourcesTable sources = $SourcesTable(this);
  late final $LibrariesTable libraries = $LibrariesTable(this);
  late final $SeriesTable series = $SeriesTable(this);
  late final $BooksTable books = $BooksTable(this);
  late final $ThumbnailsTable thumbnails = $ThumbnailsTable(this);
  late final $CachedMetadataTable cachedMetadata = $CachedMetadataTable(this);
  late final $LibraryPrefsTable libraryPrefs = $LibraryPrefsTable(this);
  late final $ReaderSettingsTable readerSettings = $ReaderSettingsTable(this);
  late final Index seriesKeyset = Index(
    'series_keyset',
    'CREATE INDEX series_keyset ON series (source_id, title_sort, id)',
  );
  late final Index seriesKeysetLib = Index(
    'series_keyset_lib',
    'CREATE INDEX series_keyset_lib ON series (source_id, library_id, title_sort, id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appSettings,
    sources,
    libraries,
    series,
    books,
    thumbnails,
    cachedMetadata,
    libraryPrefs,
    readerSettings,
    seriesKeyset,
    seriesKeysetLib,
  ];
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
typedef $$SourcesTableCreateCompanionBuilder =
    SourcesCompanion Function({
      required String id,
      required String kind,
      Value<String?> baseUrl,
      Value<String?> authKind,
      Value<String?> handle,
      required String label,
      Value<int> rowid,
    });
typedef $$SourcesTableUpdateCompanionBuilder =
    SourcesCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<String?> baseUrl,
      Value<String?> authKind,
      Value<String?> handle,
      Value<String> label,
      Value<int> rowid,
    });

class $$SourcesTableFilterComposer
    extends Composer<_$AppDatabase, $SourcesTable> {
  $$SourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authKind => $composableBuilder(
    column: $table.authKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get handle => $composableBuilder(
    column: $table.handle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $SourcesTable> {
  $$SourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseUrl => $composableBuilder(
    column: $table.baseUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authKind => $composableBuilder(
    column: $table.authKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get handle => $composableBuilder(
    column: $table.handle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SourcesTable> {
  $$SourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get baseUrl =>
      $composableBuilder(column: $table.baseUrl, builder: (column) => column);

  GeneratedColumn<String> get authKind =>
      $composableBuilder(column: $table.authKind, builder: (column) => column);

  GeneratedColumn<String> get handle =>
      $composableBuilder(column: $table.handle, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);
}

class $$SourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SourcesTable,
          Source,
          $$SourcesTableFilterComposer,
          $$SourcesTableOrderingComposer,
          $$SourcesTableAnnotationComposer,
          $$SourcesTableCreateCompanionBuilder,
          $$SourcesTableUpdateCompanionBuilder,
          (Source, BaseReferences<_$AppDatabase, $SourcesTable, Source>),
          Source,
          PrefetchHooks Function()
        > {
  $$SourcesTableTableManager(_$AppDatabase db, $SourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> baseUrl = const Value.absent(),
                Value<String?> authKind = const Value.absent(),
                Value<String?> handle = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourcesCompanion(
                id: id,
                kind: kind,
                baseUrl: baseUrl,
                authKind: authKind,
                handle: handle,
                label: label,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                Value<String?> baseUrl = const Value.absent(),
                Value<String?> authKind = const Value.absent(),
                Value<String?> handle = const Value.absent(),
                required String label,
                Value<int> rowid = const Value.absent(),
              }) => SourcesCompanion.insert(
                id: id,
                kind: kind,
                baseUrl: baseUrl,
                authKind: authKind,
                handle: handle,
                label: label,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SourcesTable,
      Source,
      $$SourcesTableFilterComposer,
      $$SourcesTableOrderingComposer,
      $$SourcesTableAnnotationComposer,
      $$SourcesTableCreateCompanionBuilder,
      $$SourcesTableUpdateCompanionBuilder,
      (Source, BaseReferences<_$AppDatabase, $SourcesTable, Source>),
      Source,
      PrefetchHooks Function()
    >;
typedef $$LibrariesTableCreateCompanionBuilder =
    LibrariesCompanion Function({
      required String sourceId,
      required String id,
      required String name,
      Value<int> rowid,
    });
typedef $$LibrariesTableUpdateCompanionBuilder =
    LibrariesCompanion Function({
      Value<String> sourceId,
      Value<String> id,
      Value<String> name,
      Value<int> rowid,
    });

class $$LibrariesTableFilterComposer
    extends Composer<_$AppDatabase, $LibrariesTable> {
  $$LibrariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LibrariesTableOrderingComposer
    extends Composer<_$AppDatabase, $LibrariesTable> {
  $$LibrariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibrariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibrariesTable> {
  $$LibrariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$LibrariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibrariesTable,
          Library,
          $$LibrariesTableFilterComposer,
          $$LibrariesTableOrderingComposer,
          $$LibrariesTableAnnotationComposer,
          $$LibrariesTableCreateCompanionBuilder,
          $$LibrariesTableUpdateCompanionBuilder,
          (Library, BaseReferences<_$AppDatabase, $LibrariesTable, Library>),
          Library,
          PrefetchHooks Function()
        > {
  $$LibrariesTableTableManager(_$AppDatabase db, $LibrariesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibrariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibrariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibrariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibrariesCompanion(
                sourceId: sourceId,
                id: id,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String id,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => LibrariesCompanion.insert(
                sourceId: sourceId,
                id: id,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LibrariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibrariesTable,
      Library,
      $$LibrariesTableFilterComposer,
      $$LibrariesTableOrderingComposer,
      $$LibrariesTableAnnotationComposer,
      $$LibrariesTableCreateCompanionBuilder,
      $$LibrariesTableUpdateCompanionBuilder,
      (Library, BaseReferences<_$AppDatabase, $LibrariesTable, Library>),
      Library,
      PrefetchHooks Function()
    >;
typedef $$SeriesTableCreateCompanionBuilder =
    SeriesCompanion Function({
      required String sourceId,
      required String id,
      required String libraryId,
      required String title,
      required String titleSort,
      Value<int?> ageRating,
      Value<String?> status,
      Value<String?> summary,
      Value<int> booksCount,
      Value<int> rowid,
    });
typedef $$SeriesTableUpdateCompanionBuilder =
    SeriesCompanion Function({
      Value<String> sourceId,
      Value<String> id,
      Value<String> libraryId,
      Value<String> title,
      Value<String> titleSort,
      Value<int?> ageRating,
      Value<String?> status,
      Value<String?> summary,
      Value<int> booksCount,
      Value<int> rowid,
    });

class $$SeriesTableFilterComposer
    extends Composer<_$AppDatabase, $SeriesTable> {
  $$SeriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get libraryId => $composableBuilder(
    column: $table.libraryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleSort => $composableBuilder(
    column: $table.titleSort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ageRating => $composableBuilder(
    column: $table.ageRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get booksCount => $composableBuilder(
    column: $table.booksCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SeriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SeriesTable> {
  $$SeriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get libraryId => $composableBuilder(
    column: $table.libraryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleSort => $composableBuilder(
    column: $table.titleSort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ageRating => $composableBuilder(
    column: $table.ageRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get booksCount => $composableBuilder(
    column: $table.booksCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeriesTable> {
  $$SeriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get libraryId =>
      $composableBuilder(column: $table.libraryId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get titleSort =>
      $composableBuilder(column: $table.titleSort, builder: (column) => column);

  GeneratedColumn<int> get ageRating =>
      $composableBuilder(column: $table.ageRating, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<int> get booksCount => $composableBuilder(
    column: $table.booksCount,
    builder: (column) => column,
  );
}

class $$SeriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeriesTable,
          SeriesRow,
          $$SeriesTableFilterComposer,
          $$SeriesTableOrderingComposer,
          $$SeriesTableAnnotationComposer,
          $$SeriesTableCreateCompanionBuilder,
          $$SeriesTableUpdateCompanionBuilder,
          (SeriesRow, BaseReferences<_$AppDatabase, $SeriesTable, SeriesRow>),
          SeriesRow,
          PrefetchHooks Function()
        > {
  $$SeriesTableTableManager(_$AppDatabase db, $SeriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> libraryId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> titleSort = const Value.absent(),
                Value<int?> ageRating = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<int> booksCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesCompanion(
                sourceId: sourceId,
                id: id,
                libraryId: libraryId,
                title: title,
                titleSort: titleSort,
                ageRating: ageRating,
                status: status,
                summary: summary,
                booksCount: booksCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String id,
                required String libraryId,
                required String title,
                required String titleSort,
                Value<int?> ageRating = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<int> booksCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesCompanion.insert(
                sourceId: sourceId,
                id: id,
                libraryId: libraryId,
                title: title,
                titleSort: titleSort,
                ageRating: ageRating,
                status: status,
                summary: summary,
                booksCount: booksCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeriesTable,
      SeriesRow,
      $$SeriesTableFilterComposer,
      $$SeriesTableOrderingComposer,
      $$SeriesTableAnnotationComposer,
      $$SeriesTableCreateCompanionBuilder,
      $$SeriesTableUpdateCompanionBuilder,
      (SeriesRow, BaseReferences<_$AppDatabase, $SeriesTable, SeriesRow>),
      SeriesRow,
      PrefetchHooks Function()
    >;
typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({
      required String sourceId,
      required String id,
      required String seriesId,
      required String libraryId,
      required String title,
      required String number,
      Value<double?> numberSort,
      Value<int> pagesCount,
      Value<String?> mediaType,
      Value<int?> sizeBytes,
      Value<int?> readPage,
      Value<bool> completed,
      Value<int> rowid,
    });
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({
      Value<String> sourceId,
      Value<String> id,
      Value<String> seriesId,
      Value<String> libraryId,
      Value<String> title,
      Value<String> number,
      Value<double?> numberSort,
      Value<int> pagesCount,
      Value<String?> mediaType,
      Value<int?> sizeBytes,
      Value<int?> readPage,
      Value<bool> completed,
      Value<int> rowid,
    });

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get libraryId => $composableBuilder(
    column: $table.libraryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get numberSort => $composableBuilder(
    column: $table.numberSort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pagesCount => $composableBuilder(
    column: $table.pagesCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readPage => $composableBuilder(
    column: $table.readPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get libraryId => $composableBuilder(
    column: $table.libraryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get numberSort => $composableBuilder(
    column: $table.numberSort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pagesCount => $composableBuilder(
    column: $table.pagesCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readPage => $composableBuilder(
    column: $table.readPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumn<String> get libraryId =>
      $composableBuilder(column: $table.libraryId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<double> get numberSort => $composableBuilder(
    column: $table.numberSort,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pagesCount => $composableBuilder(
    column: $table.pagesCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get readPage =>
      $composableBuilder(column: $table.readPage, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          Book,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (Book, BaseReferences<_$AppDatabase, $BooksTable, Book>),
          Book,
          PrefetchHooks Function()
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> seriesId = const Value.absent(),
                Value<String> libraryId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> number = const Value.absent(),
                Value<double?> numberSort = const Value.absent(),
                Value<int> pagesCount = const Value.absent(),
                Value<String?> mediaType = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<int?> readPage = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion(
                sourceId: sourceId,
                id: id,
                seriesId: seriesId,
                libraryId: libraryId,
                title: title,
                number: number,
                numberSort: numberSort,
                pagesCount: pagesCount,
                mediaType: mediaType,
                sizeBytes: sizeBytes,
                readPage: readPage,
                completed: completed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String id,
                required String seriesId,
                required String libraryId,
                required String title,
                required String number,
                Value<double?> numberSort = const Value.absent(),
                Value<int> pagesCount = const Value.absent(),
                Value<String?> mediaType = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<int?> readPage = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion.insert(
                sourceId: sourceId,
                id: id,
                seriesId: seriesId,
                libraryId: libraryId,
                title: title,
                number: number,
                numberSort: numberSort,
                pagesCount: pagesCount,
                mediaType: mediaType,
                sizeBytes: sizeBytes,
                readPage: readPage,
                completed: completed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      Book,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (Book, BaseReferences<_$AppDatabase, $BooksTable, Book>),
      Book,
      PrefetchHooks Function()
    >;
typedef $$ThumbnailsTableCreateCompanionBuilder =
    ThumbnailsCompanion Function({
      required String sourceId,
      required String ownerType,
      required String ownerId,
      Value<Uint8List?> bytes,
      Value<String?> diskPath,
      Value<String?> etag,
      required int fetchedAt,
      Value<int> rowid,
    });
typedef $$ThumbnailsTableUpdateCompanionBuilder =
    ThumbnailsCompanion Function({
      Value<String> sourceId,
      Value<String> ownerType,
      Value<String> ownerId,
      Value<Uint8List?> bytes,
      Value<String?> diskPath,
      Value<String?> etag,
      Value<int> fetchedAt,
      Value<int> rowid,
    });

class $$ThumbnailsTableFilterComposer
    extends Composer<_$AppDatabase, $ThumbnailsTable> {
  $$ThumbnailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerType => $composableBuilder(
    column: $table.ownerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diskPath => $composableBuilder(
    column: $table.diskPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ThumbnailsTableOrderingComposer
    extends Composer<_$AppDatabase, $ThumbnailsTable> {
  $$ThumbnailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerType => $composableBuilder(
    column: $table.ownerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diskPath => $composableBuilder(
    column: $table.diskPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ThumbnailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ThumbnailsTable> {
  $$ThumbnailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get ownerType =>
      $composableBuilder(column: $table.ownerType, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<Uint8List> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<String> get diskPath =>
      $composableBuilder(column: $table.diskPath, builder: (column) => column);

  GeneratedColumn<String> get etag =>
      $composableBuilder(column: $table.etag, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$ThumbnailsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ThumbnailsTable,
          Thumbnail,
          $$ThumbnailsTableFilterComposer,
          $$ThumbnailsTableOrderingComposer,
          $$ThumbnailsTableAnnotationComposer,
          $$ThumbnailsTableCreateCompanionBuilder,
          $$ThumbnailsTableUpdateCompanionBuilder,
          (
            Thumbnail,
            BaseReferences<_$AppDatabase, $ThumbnailsTable, Thumbnail>,
          ),
          Thumbnail,
          PrefetchHooks Function()
        > {
  $$ThumbnailsTableTableManager(_$AppDatabase db, $ThumbnailsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThumbnailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThumbnailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThumbnailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> ownerType = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<Uint8List?> bytes = const Value.absent(),
                Value<String?> diskPath = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ThumbnailsCompanion(
                sourceId: sourceId,
                ownerType: ownerType,
                ownerId: ownerId,
                bytes: bytes,
                diskPath: diskPath,
                etag: etag,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String ownerType,
                required String ownerId,
                Value<Uint8List?> bytes = const Value.absent(),
                Value<String?> diskPath = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                required int fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => ThumbnailsCompanion.insert(
                sourceId: sourceId,
                ownerType: ownerType,
                ownerId: ownerId,
                bytes: bytes,
                diskPath: diskPath,
                etag: etag,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ThumbnailsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ThumbnailsTable,
      Thumbnail,
      $$ThumbnailsTableFilterComposer,
      $$ThumbnailsTableOrderingComposer,
      $$ThumbnailsTableAnnotationComposer,
      $$ThumbnailsTableCreateCompanionBuilder,
      $$ThumbnailsTableUpdateCompanionBuilder,
      (Thumbnail, BaseReferences<_$AppDatabase, $ThumbnailsTable, Thumbnail>),
      Thumbnail,
      PrefetchHooks Function()
    >;
typedef $$CachedMetadataTableCreateCompanionBuilder =
    CachedMetadataCompanion Function({
      required String sourceId,
      required String ownerType,
      required String ownerId,
      required String json,
      required int fetchedAt,
      Value<int> rowid,
    });
typedef $$CachedMetadataTableUpdateCompanionBuilder =
    CachedMetadataCompanion Function({
      Value<String> sourceId,
      Value<String> ownerType,
      Value<String> ownerId,
      Value<String> json,
      Value<int> fetchedAt,
      Value<int> rowid,
    });

class $$CachedMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $CachedMetadataTable> {
  $$CachedMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerType => $composableBuilder(
    column: $table.ownerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedMetadataTable> {
  $$CachedMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerType => $composableBuilder(
    column: $table.ownerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedMetadataTable> {
  $$CachedMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get ownerType =>
      $composableBuilder(column: $table.ownerType, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$CachedMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedMetadataTable,
          CachedMetadataRow,
          $$CachedMetadataTableFilterComposer,
          $$CachedMetadataTableOrderingComposer,
          $$CachedMetadataTableAnnotationComposer,
          $$CachedMetadataTableCreateCompanionBuilder,
          $$CachedMetadataTableUpdateCompanionBuilder,
          (
            CachedMetadataRow,
            BaseReferences<
              _$AppDatabase,
              $CachedMetadataTable,
              CachedMetadataRow
            >,
          ),
          CachedMetadataRow,
          PrefetchHooks Function()
        > {
  $$CachedMetadataTableTableManager(
    _$AppDatabase db,
    $CachedMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> ownerType = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> json = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedMetadataCompanion(
                sourceId: sourceId,
                ownerType: ownerType,
                ownerId: ownerId,
                json: json,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String ownerType,
                required String ownerId,
                required String json,
                required int fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedMetadataCompanion.insert(
                sourceId: sourceId,
                ownerType: ownerType,
                ownerId: ownerId,
                json: json,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedMetadataTable,
      CachedMetadataRow,
      $$CachedMetadataTableFilterComposer,
      $$CachedMetadataTableOrderingComposer,
      $$CachedMetadataTableAnnotationComposer,
      $$CachedMetadataTableCreateCompanionBuilder,
      $$CachedMetadataTableUpdateCompanionBuilder,
      (
        CachedMetadataRow,
        BaseReferences<_$AppDatabase, $CachedMetadataTable, CachedMetadataRow>,
      ),
      CachedMetadataRow,
      PrefetchHooks Function()
    >;
typedef $$LibraryPrefsTableCreateCompanionBuilder =
    LibraryPrefsCompanion Function({
      required String sourceId,
      required String libraryId,
      Value<bool> locked,
      Value<bool> showRestricted,
      Value<int> rowid,
    });
typedef $$LibraryPrefsTableUpdateCompanionBuilder =
    LibraryPrefsCompanion Function({
      Value<String> sourceId,
      Value<String> libraryId,
      Value<bool> locked,
      Value<bool> showRestricted,
      Value<int> rowid,
    });

class $$LibraryPrefsTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryPrefsTable> {
  $$LibraryPrefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get libraryId => $composableBuilder(
    column: $table.libraryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showRestricted => $composableBuilder(
    column: $table.showRestricted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LibraryPrefsTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryPrefsTable> {
  $$LibraryPrefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get libraryId => $composableBuilder(
    column: $table.libraryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showRestricted => $composableBuilder(
    column: $table.showRestricted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryPrefsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryPrefsTable> {
  $$LibraryPrefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get libraryId =>
      $composableBuilder(column: $table.libraryId, builder: (column) => column);

  GeneratedColumn<bool> get locked =>
      $composableBuilder(column: $table.locked, builder: (column) => column);

  GeneratedColumn<bool> get showRestricted => $composableBuilder(
    column: $table.showRestricted,
    builder: (column) => column,
  );
}

class $$LibraryPrefsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryPrefsTable,
          LibraryPref,
          $$LibraryPrefsTableFilterComposer,
          $$LibraryPrefsTableOrderingComposer,
          $$LibraryPrefsTableAnnotationComposer,
          $$LibraryPrefsTableCreateCompanionBuilder,
          $$LibraryPrefsTableUpdateCompanionBuilder,
          (
            LibraryPref,
            BaseReferences<_$AppDatabase, $LibraryPrefsTable, LibraryPref>,
          ),
          LibraryPref,
          PrefetchHooks Function()
        > {
  $$LibraryPrefsTableTableManager(_$AppDatabase db, $LibraryPrefsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryPrefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryPrefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryPrefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> libraryId = const Value.absent(),
                Value<bool> locked = const Value.absent(),
                Value<bool> showRestricted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryPrefsCompanion(
                sourceId: sourceId,
                libraryId: libraryId,
                locked: locked,
                showRestricted: showRestricted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String libraryId,
                Value<bool> locked = const Value.absent(),
                Value<bool> showRestricted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryPrefsCompanion.insert(
                sourceId: sourceId,
                libraryId: libraryId,
                locked: locked,
                showRestricted: showRestricted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LibraryPrefsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryPrefsTable,
      LibraryPref,
      $$LibraryPrefsTableFilterComposer,
      $$LibraryPrefsTableOrderingComposer,
      $$LibraryPrefsTableAnnotationComposer,
      $$LibraryPrefsTableCreateCompanionBuilder,
      $$LibraryPrefsTableUpdateCompanionBuilder,
      (
        LibraryPref,
        BaseReferences<_$AppDatabase, $LibraryPrefsTable, LibraryPref>,
      ),
      LibraryPref,
      PrefetchHooks Function()
    >;
typedef $$ReaderSettingsTableCreateCompanionBuilder =
    ReaderSettingsCompanion Function({
      required String sourceId,
      required String seriesId,
      required String mode,
      required String fit,
      required String taps,
      Value<bool> invertTaps,
      Value<bool> doubleTapZoom,
      Value<bool> animatePageTurn,
      Value<int> rowid,
    });
typedef $$ReaderSettingsTableUpdateCompanionBuilder =
    ReaderSettingsCompanion Function({
      Value<String> sourceId,
      Value<String> seriesId,
      Value<String> mode,
      Value<String> fit,
      Value<String> taps,
      Value<bool> invertTaps,
      Value<bool> doubleTapZoom,
      Value<bool> animatePageTurn,
      Value<int> rowid,
    });

class $$ReaderSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $ReaderSettingsTable> {
  $$ReaderSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fit => $composableBuilder(
    column: $table.fit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taps => $composableBuilder(
    column: $table.taps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get invertTaps => $composableBuilder(
    column: $table.invertTaps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get doubleTapZoom => $composableBuilder(
    column: $table.doubleTapZoom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get animatePageTurn => $composableBuilder(
    column: $table.animatePageTurn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReaderSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReaderSettingsTable> {
  $$ReaderSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fit => $composableBuilder(
    column: $table.fit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taps => $composableBuilder(
    column: $table.taps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get invertTaps => $composableBuilder(
    column: $table.invertTaps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get doubleTapZoom => $composableBuilder(
    column: $table.doubleTapZoom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get animatePageTurn => $composableBuilder(
    column: $table.animatePageTurn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReaderSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReaderSettingsTable> {
  $$ReaderSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get fit =>
      $composableBuilder(column: $table.fit, builder: (column) => column);

  GeneratedColumn<String> get taps =>
      $composableBuilder(column: $table.taps, builder: (column) => column);

  GeneratedColumn<bool> get invertTaps => $composableBuilder(
    column: $table.invertTaps,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get doubleTapZoom => $composableBuilder(
    column: $table.doubleTapZoom,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get animatePageTurn => $composableBuilder(
    column: $table.animatePageTurn,
    builder: (column) => column,
  );
}

class $$ReaderSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReaderSettingsTable,
          ReaderSettingsRow,
          $$ReaderSettingsTableFilterComposer,
          $$ReaderSettingsTableOrderingComposer,
          $$ReaderSettingsTableAnnotationComposer,
          $$ReaderSettingsTableCreateCompanionBuilder,
          $$ReaderSettingsTableUpdateCompanionBuilder,
          (
            ReaderSettingsRow,
            BaseReferences<
              _$AppDatabase,
              $ReaderSettingsTable,
              ReaderSettingsRow
            >,
          ),
          ReaderSettingsRow,
          PrefetchHooks Function()
        > {
  $$ReaderSettingsTableTableManager(
    _$AppDatabase db,
    $ReaderSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReaderSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReaderSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReaderSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> seriesId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> fit = const Value.absent(),
                Value<String> taps = const Value.absent(),
                Value<bool> invertTaps = const Value.absent(),
                Value<bool> doubleTapZoom = const Value.absent(),
                Value<bool> animatePageTurn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReaderSettingsCompanion(
                sourceId: sourceId,
                seriesId: seriesId,
                mode: mode,
                fit: fit,
                taps: taps,
                invertTaps: invertTaps,
                doubleTapZoom: doubleTapZoom,
                animatePageTurn: animatePageTurn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String seriesId,
                required String mode,
                required String fit,
                required String taps,
                Value<bool> invertTaps = const Value.absent(),
                Value<bool> doubleTapZoom = const Value.absent(),
                Value<bool> animatePageTurn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReaderSettingsCompanion.insert(
                sourceId: sourceId,
                seriesId: seriesId,
                mode: mode,
                fit: fit,
                taps: taps,
                invertTaps: invertTaps,
                doubleTapZoom: doubleTapZoom,
                animatePageTurn: animatePageTurn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReaderSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReaderSettingsTable,
      ReaderSettingsRow,
      $$ReaderSettingsTableFilterComposer,
      $$ReaderSettingsTableOrderingComposer,
      $$ReaderSettingsTableAnnotationComposer,
      $$ReaderSettingsTableCreateCompanionBuilder,
      $$ReaderSettingsTableUpdateCompanionBuilder,
      (
        ReaderSettingsRow,
        BaseReferences<_$AppDatabase, $ReaderSettingsTable, ReaderSettingsRow>,
      ),
      ReaderSettingsRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$SourcesTableTableManager get sources =>
      $$SourcesTableTableManager(_db, _db.sources);
  $$LibrariesTableTableManager get libraries =>
      $$LibrariesTableTableManager(_db, _db.libraries);
  $$SeriesTableTableManager get series =>
      $$SeriesTableTableManager(_db, _db.series);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$ThumbnailsTableTableManager get thumbnails =>
      $$ThumbnailsTableTableManager(_db, _db.thumbnails);
  $$CachedMetadataTableTableManager get cachedMetadata =>
      $$CachedMetadataTableTableManager(_db, _db.cachedMetadata);
  $$LibraryPrefsTableTableManager get libraryPrefs =>
      $$LibraryPrefsTableTableManager(_db, _db.libraryPrefs);
  $$ReaderSettingsTableTableManager get readerSettings =>
      $$ReaderSettingsTableTableManager(_db, _db.readerSettings);
}
