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
  static const VerificationMeta _autoCacheEnabledMeta = const VerificationMeta(
    'autoCacheEnabled',
  );
  @override
  late final GeneratedColumn<bool> autoCacheEnabled = GeneratedColumn<bool>(
    'auto_cache_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_cache_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _downloadWifiOnlyMeta = const VerificationMeta(
    'downloadWifiOnly',
  );
  @override
  late final GeneratedColumn<bool> downloadWifiOnly = GeneratedColumn<bool>(
    'download_wifi_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("download_wifi_only" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageQualitySmartMeta = const VerificationMeta(
    'imageQualitySmart',
  );
  @override
  late final GeneratedColumn<bool> imageQualitySmart = GeneratedColumn<bool>(
    'image_quality_smart',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("image_quality_smart" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _imageQualityManualLevelMeta =
      const VerificationMeta('imageQualityManualLevel');
  @override
  late final GeneratedColumn<int> imageQualityManualLevel =
      GeneratedColumn<int>(
        'image_quality_manual_level',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(2),
      );
  static const VerificationMeta _homeLayoutMeta = const VerificationMeta(
    'homeLayout',
  );
  @override
  late final GeneratedColumn<String> homeLayout = GeneratedColumn<String>(
    'home_layout',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deleteOnReadMeta = const VerificationMeta(
    'deleteOnRead',
  );
  @override
  late final GeneratedColumn<bool> deleteOnRead = GeneratedColumn<bool>(
    'delete_on_read',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("delete_on_read" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    themeMode,
    reduceMotionOverride,
    cacheCapBytes,
    autoCacheEnabled,
    downloadWifiOnly,
    deviceId,
    imageQualitySmart,
    imageQualityManualLevel,
    homeLayout,
    deleteOnRead,
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
    if (data.containsKey('auto_cache_enabled')) {
      context.handle(
        _autoCacheEnabledMeta,
        autoCacheEnabled.isAcceptableOrUnknown(
          data['auto_cache_enabled']!,
          _autoCacheEnabledMeta,
        ),
      );
    }
    if (data.containsKey('download_wifi_only')) {
      context.handle(
        _downloadWifiOnlyMeta,
        downloadWifiOnly.isAcceptableOrUnknown(
          data['download_wifi_only']!,
          _downloadWifiOnlyMeta,
        ),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('image_quality_smart')) {
      context.handle(
        _imageQualitySmartMeta,
        imageQualitySmart.isAcceptableOrUnknown(
          data['image_quality_smart']!,
          _imageQualitySmartMeta,
        ),
      );
    }
    if (data.containsKey('image_quality_manual_level')) {
      context.handle(
        _imageQualityManualLevelMeta,
        imageQualityManualLevel.isAcceptableOrUnknown(
          data['image_quality_manual_level']!,
          _imageQualityManualLevelMeta,
        ),
      );
    }
    if (data.containsKey('home_layout')) {
      context.handle(
        _homeLayoutMeta,
        homeLayout.isAcceptableOrUnknown(data['home_layout']!, _homeLayoutMeta),
      );
    }
    if (data.containsKey('delete_on_read')) {
      context.handle(
        _deleteOnReadMeta,
        deleteOnRead.isAcceptableOrUnknown(
          data['delete_on_read']!,
          _deleteOnReadMeta,
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
      autoCacheEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_cache_enabled'],
      )!,
      downloadWifiOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}download_wifi_only'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      imageQualitySmart: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}image_quality_smart'],
      )!,
      imageQualityManualLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}image_quality_manual_level'],
      )!,
      homeLayout: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}home_layout'],
      ),
      deleteOnRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}delete_on_read'],
      ),
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

  /// Whether opening a chapter auto-downloads it in the background (the
  /// ephemeral, LRU-evicted auto-cache pool).
  final bool autoCacheEnabled;

  /// Whether auto-cache downloads require Wi-Fi. Manual downloads ignore this.
  final bool downloadWifiOnly;

  /// Stable per-install id (uuid v4), generated once on first settings read.
  /// Stamped on local reading sessions; forward-compat for phase-2 multi-device
  /// dedup. NULL only between the column add and the first generation.
  final String? deviceId;

  /// Reader image quality. When true, Mylarium picks the page decode ceiling for
  /// the device; when false, [imageQualityManualLevel] selects it.
  final bool imageQualitySmart;

  /// Manual quality stop (index into the reader's ceiling table), used only when
  /// [imageQualitySmart] is false. Defaults to the middle stop.
  final int imageQualityManualLevel;

  /// JSON-encoded home-screen row layout (order + per-row visibility). NULL until
  /// the user customizes it, in which case the default order/visibility applies.
  final String? homeLayout;

  /// When true, a chapter's auto-cached copy is deleted as soon as it is read
  /// (reclaims space). Manual (permanent) downloads are exempt. Nullable so the
  /// current row mapper can read an older settings row that predates this column
  /// (intermediate-version reads); a null value means off (the default).
  final bool? deleteOnRead;
  const AppSetting({
    required this.id,
    required this.themeMode,
    required this.reduceMotionOverride,
    required this.cacheCapBytes,
    required this.autoCacheEnabled,
    required this.downloadWifiOnly,
    this.deviceId,
    required this.imageQualitySmart,
    required this.imageQualityManualLevel,
    this.homeLayout,
    this.deleteOnRead,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['theme_mode'] = Variable<String>(themeMode);
    map['reduce_motion_override'] = Variable<bool>(reduceMotionOverride);
    map['cache_cap_bytes'] = Variable<int>(cacheCapBytes);
    map['auto_cache_enabled'] = Variable<bool>(autoCacheEnabled);
    map['download_wifi_only'] = Variable<bool>(downloadWifiOnly);
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['image_quality_smart'] = Variable<bool>(imageQualitySmart);
    map['image_quality_manual_level'] = Variable<int>(imageQualityManualLevel);
    if (!nullToAbsent || homeLayout != null) {
      map['home_layout'] = Variable<String>(homeLayout);
    }
    if (!nullToAbsent || deleteOnRead != null) {
      map['delete_on_read'] = Variable<bool>(deleteOnRead);
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      themeMode: Value(themeMode),
      reduceMotionOverride: Value(reduceMotionOverride),
      cacheCapBytes: Value(cacheCapBytes),
      autoCacheEnabled: Value(autoCacheEnabled),
      downloadWifiOnly: Value(downloadWifiOnly),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      imageQualitySmart: Value(imageQualitySmart),
      imageQualityManualLevel: Value(imageQualityManualLevel),
      homeLayout: homeLayout == null && nullToAbsent
          ? const Value.absent()
          : Value(homeLayout),
      deleteOnRead: deleteOnRead == null && nullToAbsent
          ? const Value.absent()
          : Value(deleteOnRead),
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
      autoCacheEnabled: serializer.fromJson<bool>(json['autoCacheEnabled']),
      downloadWifiOnly: serializer.fromJson<bool>(json['downloadWifiOnly']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      imageQualitySmart: serializer.fromJson<bool>(json['imageQualitySmart']),
      imageQualityManualLevel: serializer.fromJson<int>(
        json['imageQualityManualLevel'],
      ),
      homeLayout: serializer.fromJson<String?>(json['homeLayout']),
      deleteOnRead: serializer.fromJson<bool?>(json['deleteOnRead']),
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
      'autoCacheEnabled': serializer.toJson<bool>(autoCacheEnabled),
      'downloadWifiOnly': serializer.toJson<bool>(downloadWifiOnly),
      'deviceId': serializer.toJson<String?>(deviceId),
      'imageQualitySmart': serializer.toJson<bool>(imageQualitySmart),
      'imageQualityManualLevel': serializer.toJson<int>(
        imageQualityManualLevel,
      ),
      'homeLayout': serializer.toJson<String?>(homeLayout),
      'deleteOnRead': serializer.toJson<bool?>(deleteOnRead),
    };
  }

  AppSetting copyWith({
    int? id,
    String? themeMode,
    bool? reduceMotionOverride,
    int? cacheCapBytes,
    bool? autoCacheEnabled,
    bool? downloadWifiOnly,
    Value<String?> deviceId = const Value.absent(),
    bool? imageQualitySmart,
    int? imageQualityManualLevel,
    Value<String?> homeLayout = const Value.absent(),
    Value<bool?> deleteOnRead = const Value.absent(),
  }) => AppSetting(
    id: id ?? this.id,
    themeMode: themeMode ?? this.themeMode,
    reduceMotionOverride: reduceMotionOverride ?? this.reduceMotionOverride,
    cacheCapBytes: cacheCapBytes ?? this.cacheCapBytes,
    autoCacheEnabled: autoCacheEnabled ?? this.autoCacheEnabled,
    downloadWifiOnly: downloadWifiOnly ?? this.downloadWifiOnly,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    imageQualitySmart: imageQualitySmart ?? this.imageQualitySmart,
    imageQualityManualLevel:
        imageQualityManualLevel ?? this.imageQualityManualLevel,
    homeLayout: homeLayout.present ? homeLayout.value : this.homeLayout,
    deleteOnRead: deleteOnRead.present ? deleteOnRead.value : this.deleteOnRead,
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
      autoCacheEnabled: data.autoCacheEnabled.present
          ? data.autoCacheEnabled.value
          : this.autoCacheEnabled,
      downloadWifiOnly: data.downloadWifiOnly.present
          ? data.downloadWifiOnly.value
          : this.downloadWifiOnly,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      imageQualitySmart: data.imageQualitySmart.present
          ? data.imageQualitySmart.value
          : this.imageQualitySmart,
      imageQualityManualLevel: data.imageQualityManualLevel.present
          ? data.imageQualityManualLevel.value
          : this.imageQualityManualLevel,
      homeLayout: data.homeLayout.present
          ? data.homeLayout.value
          : this.homeLayout,
      deleteOnRead: data.deleteOnRead.present
          ? data.deleteOnRead.value
          : this.deleteOnRead,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('reduceMotionOverride: $reduceMotionOverride, ')
          ..write('cacheCapBytes: $cacheCapBytes, ')
          ..write('autoCacheEnabled: $autoCacheEnabled, ')
          ..write('downloadWifiOnly: $downloadWifiOnly, ')
          ..write('deviceId: $deviceId, ')
          ..write('imageQualitySmart: $imageQualitySmart, ')
          ..write('imageQualityManualLevel: $imageQualityManualLevel, ')
          ..write('homeLayout: $homeLayout, ')
          ..write('deleteOnRead: $deleteOnRead')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    themeMode,
    reduceMotionOverride,
    cacheCapBytes,
    autoCacheEnabled,
    downloadWifiOnly,
    deviceId,
    imageQualitySmart,
    imageQualityManualLevel,
    homeLayout,
    deleteOnRead,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.reduceMotionOverride == this.reduceMotionOverride &&
          other.cacheCapBytes == this.cacheCapBytes &&
          other.autoCacheEnabled == this.autoCacheEnabled &&
          other.downloadWifiOnly == this.downloadWifiOnly &&
          other.deviceId == this.deviceId &&
          other.imageQualitySmart == this.imageQualitySmart &&
          other.imageQualityManualLevel == this.imageQualityManualLevel &&
          other.homeLayout == this.homeLayout &&
          other.deleteOnRead == this.deleteOnRead);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<String> themeMode;
  final Value<bool> reduceMotionOverride;
  final Value<int> cacheCapBytes;
  final Value<bool> autoCacheEnabled;
  final Value<bool> downloadWifiOnly;
  final Value<String?> deviceId;
  final Value<bool> imageQualitySmart;
  final Value<int> imageQualityManualLevel;
  final Value<String?> homeLayout;
  final Value<bool?> deleteOnRead;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.reduceMotionOverride = const Value.absent(),
    this.cacheCapBytes = const Value.absent(),
    this.autoCacheEnabled = const Value.absent(),
    this.downloadWifiOnly = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.imageQualitySmart = const Value.absent(),
    this.imageQualityManualLevel = const Value.absent(),
    this.homeLayout = const Value.absent(),
    this.deleteOnRead = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.reduceMotionOverride = const Value.absent(),
    this.cacheCapBytes = const Value.absent(),
    this.autoCacheEnabled = const Value.absent(),
    this.downloadWifiOnly = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.imageQualitySmart = const Value.absent(),
    this.imageQualityManualLevel = const Value.absent(),
    this.homeLayout = const Value.absent(),
    this.deleteOnRead = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<String>? themeMode,
    Expression<bool>? reduceMotionOverride,
    Expression<int>? cacheCapBytes,
    Expression<bool>? autoCacheEnabled,
    Expression<bool>? downloadWifiOnly,
    Expression<String>? deviceId,
    Expression<bool>? imageQualitySmart,
    Expression<int>? imageQualityManualLevel,
    Expression<String>? homeLayout,
    Expression<bool>? deleteOnRead,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (reduceMotionOverride != null)
        'reduce_motion_override': reduceMotionOverride,
      if (cacheCapBytes != null) 'cache_cap_bytes': cacheCapBytes,
      if (autoCacheEnabled != null) 'auto_cache_enabled': autoCacheEnabled,
      if (downloadWifiOnly != null) 'download_wifi_only': downloadWifiOnly,
      if (deviceId != null) 'device_id': deviceId,
      if (imageQualitySmart != null) 'image_quality_smart': imageQualitySmart,
      if (imageQualityManualLevel != null)
        'image_quality_manual_level': imageQualityManualLevel,
      if (homeLayout != null) 'home_layout': homeLayout,
      if (deleteOnRead != null) 'delete_on_read': deleteOnRead,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? themeMode,
    Value<bool>? reduceMotionOverride,
    Value<int>? cacheCapBytes,
    Value<bool>? autoCacheEnabled,
    Value<bool>? downloadWifiOnly,
    Value<String?>? deviceId,
    Value<bool>? imageQualitySmart,
    Value<int>? imageQualityManualLevel,
    Value<String?>? homeLayout,
    Value<bool?>? deleteOnRead,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      reduceMotionOverride: reduceMotionOverride ?? this.reduceMotionOverride,
      cacheCapBytes: cacheCapBytes ?? this.cacheCapBytes,
      autoCacheEnabled: autoCacheEnabled ?? this.autoCacheEnabled,
      downloadWifiOnly: downloadWifiOnly ?? this.downloadWifiOnly,
      deviceId: deviceId ?? this.deviceId,
      imageQualitySmart: imageQualitySmart ?? this.imageQualitySmart,
      imageQualityManualLevel:
          imageQualityManualLevel ?? this.imageQualityManualLevel,
      homeLayout: homeLayout ?? this.homeLayout,
      deleteOnRead: deleteOnRead ?? this.deleteOnRead,
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
    if (autoCacheEnabled.present) {
      map['auto_cache_enabled'] = Variable<bool>(autoCacheEnabled.value);
    }
    if (downloadWifiOnly.present) {
      map['download_wifi_only'] = Variable<bool>(downloadWifiOnly.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (imageQualitySmart.present) {
      map['image_quality_smart'] = Variable<bool>(imageQualitySmart.value);
    }
    if (imageQualityManualLevel.present) {
      map['image_quality_manual_level'] = Variable<int>(
        imageQualityManualLevel.value,
      );
    }
    if (homeLayout.present) {
      map['home_layout'] = Variable<String>(homeLayout.value);
    }
    if (deleteOnRead.present) {
      map['delete_on_read'] = Variable<bool>(deleteOnRead.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('reduceMotionOverride: $reduceMotionOverride, ')
          ..write('cacheCapBytes: $cacheCapBytes, ')
          ..write('autoCacheEnabled: $autoCacheEnabled, ')
          ..write('downloadWifiOnly: $downloadWifiOnly, ')
          ..write('deviceId: $deviceId, ')
          ..write('imageQualitySmart: $imageQualitySmart, ')
          ..write('imageQualityManualLevel: $imageQualityManualLevel, ')
          ..write('homeLayout: $homeLayout, ')
          ..write('deleteOnRead: $deleteOnRead')
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
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ltr'),
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
    direction,
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
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
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
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
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

  /// Horizontal reading direction (`ltr` / `rtl`), `.name`-encoded. Added in v11
  /// (T4): the source of truth for double-page direction; paged modes also carry
  /// it in `mode`, kept in lockstep by the settings normalizer.
  final String direction;
  const ReaderSettingsRow({
    required this.sourceId,
    required this.seriesId,
    required this.mode,
    required this.fit,
    required this.taps,
    required this.invertTaps,
    required this.doubleTapZoom,
    required this.animatePageTurn,
    required this.direction,
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
    map['direction'] = Variable<String>(direction);
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
      direction: Value(direction),
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
      direction: serializer.fromJson<String>(json['direction']),
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
      'direction': serializer.toJson<String>(direction),
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
    String? direction,
  }) => ReaderSettingsRow(
    sourceId: sourceId ?? this.sourceId,
    seriesId: seriesId ?? this.seriesId,
    mode: mode ?? this.mode,
    fit: fit ?? this.fit,
    taps: taps ?? this.taps,
    invertTaps: invertTaps ?? this.invertTaps,
    doubleTapZoom: doubleTapZoom ?? this.doubleTapZoom,
    animatePageTurn: animatePageTurn ?? this.animatePageTurn,
    direction: direction ?? this.direction,
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
      direction: data.direction.present ? data.direction.value : this.direction,
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
          ..write('animatePageTurn: $animatePageTurn, ')
          ..write('direction: $direction')
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
    direction,
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
          other.animatePageTurn == this.animatePageTurn &&
          other.direction == this.direction);
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
  final Value<String> direction;
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
    this.direction = const Value.absent(),
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
    this.direction = const Value.absent(),
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
    Expression<String>? direction,
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
      if (direction != null) 'direction': direction,
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
    Value<String>? direction,
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
      direction: direction ?? this.direction,
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
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
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
          ..write('direction: $direction, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedAssetsTable extends CachedAssets
    with TableInfo<$CachedAssetsTable, CachedAsset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedAssetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
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
    requiredDuringInsert: false,
    defaultValue: const Constant('archive'),
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _shaMeta = const VerificationMeta('sha');
  @override
  late final GeneratedColumn<String> sha = GeneratedColumn<String>(
    'sha',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastAccessedAtMeta = const VerificationMeta(
    'lastAccessedAt',
  );
  @override
  late final GeneratedColumn<int> lastAccessedAt = GeneratedColumn<int>(
    'last_accessed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _permanentMeta = const VerificationMeta(
    'permanent',
  );
  @override
  late final GeneratedColumn<bool> permanent = GeneratedColumn<bool>(
    'permanent',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("permanent" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceId,
    bookId,
    kind,
    relativePath,
    sizeBytes,
    sha,
    lastAccessedAt,
    pinned,
    permanent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedAsset> instance, {
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
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('sha')) {
      context.handle(
        _shaMeta,
        sha.isAcceptableOrUnknown(data['sha']!, _shaMeta),
      );
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
        _lastAccessedAtMeta,
        lastAccessedAt.isAcceptableOrUnknown(
          data['last_accessed_at']!,
          _lastAccessedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAccessedAtMeta);
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('permanent')) {
      context.handle(
        _permanentMeta,
        permanent.isAcceptableOrUnknown(data['permanent']!, _permanentMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, bookId};
  @override
  CachedAsset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedAsset(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      sha: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha'],
      ),
      lastAccessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_accessed_at'],
      )!,
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      permanent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}permanent'],
      )!,
    );
  }

  @override
  $CachedAssetsTable createAlias(String alias) {
    return $CachedAssetsTable(attachedDatabase, alias);
  }
}

class CachedAsset extends DataClass implements Insertable<CachedAsset> {
  final String sourceId;
  final String bookId;

  /// Asset kind; `archive` for the downloaded CBZ/CBR.
  final String kind;

  /// Path relative to applicationSupport.
  final String relativePath;
  final int sizeBytes;

  /// Reserved for an integrity hash; unused in T5.
  final String? sha;
  final int lastAccessedAt;
  final bool pinned;
  final bool permanent;
  const CachedAsset({
    required this.sourceId,
    required this.bookId,
    required this.kind,
    required this.relativePath,
    required this.sizeBytes,
    this.sha,
    required this.lastAccessedAt,
    required this.pinned,
    required this.permanent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['book_id'] = Variable<String>(bookId);
    map['kind'] = Variable<String>(kind);
    map['relative_path'] = Variable<String>(relativePath);
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || sha != null) {
      map['sha'] = Variable<String>(sha);
    }
    map['last_accessed_at'] = Variable<int>(lastAccessedAt);
    map['pinned'] = Variable<bool>(pinned);
    map['permanent'] = Variable<bool>(permanent);
    return map;
  }

  CachedAssetsCompanion toCompanion(bool nullToAbsent) {
    return CachedAssetsCompanion(
      sourceId: Value(sourceId),
      bookId: Value(bookId),
      kind: Value(kind),
      relativePath: Value(relativePath),
      sizeBytes: Value(sizeBytes),
      sha: sha == null && nullToAbsent ? const Value.absent() : Value(sha),
      lastAccessedAt: Value(lastAccessedAt),
      pinned: Value(pinned),
      permanent: Value(permanent),
    );
  }

  factory CachedAsset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedAsset(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      bookId: serializer.fromJson<String>(json['bookId']),
      kind: serializer.fromJson<String>(json['kind']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      sha: serializer.fromJson<String?>(json['sha']),
      lastAccessedAt: serializer.fromJson<int>(json['lastAccessedAt']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      permanent: serializer.fromJson<bool>(json['permanent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'bookId': serializer.toJson<String>(bookId),
      'kind': serializer.toJson<String>(kind),
      'relativePath': serializer.toJson<String>(relativePath),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'sha': serializer.toJson<String?>(sha),
      'lastAccessedAt': serializer.toJson<int>(lastAccessedAt),
      'pinned': serializer.toJson<bool>(pinned),
      'permanent': serializer.toJson<bool>(permanent),
    };
  }

  CachedAsset copyWith({
    String? sourceId,
    String? bookId,
    String? kind,
    String? relativePath,
    int? sizeBytes,
    Value<String?> sha = const Value.absent(),
    int? lastAccessedAt,
    bool? pinned,
    bool? permanent,
  }) => CachedAsset(
    sourceId: sourceId ?? this.sourceId,
    bookId: bookId ?? this.bookId,
    kind: kind ?? this.kind,
    relativePath: relativePath ?? this.relativePath,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    sha: sha.present ? sha.value : this.sha,
    lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    pinned: pinned ?? this.pinned,
    permanent: permanent ?? this.permanent,
  );
  CachedAsset copyWithCompanion(CachedAssetsCompanion data) {
    return CachedAsset(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      kind: data.kind.present ? data.kind.value : this.kind,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      sha: data.sha.present ? data.sha.value : this.sha,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      permanent: data.permanent.present ? data.permanent.value : this.permanent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedAsset(')
          ..write('sourceId: $sourceId, ')
          ..write('bookId: $bookId, ')
          ..write('kind: $kind, ')
          ..write('relativePath: $relativePath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha: $sha, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('pinned: $pinned, ')
          ..write('permanent: $permanent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sourceId,
    bookId,
    kind,
    relativePath,
    sizeBytes,
    sha,
    lastAccessedAt,
    pinned,
    permanent,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedAsset &&
          other.sourceId == this.sourceId &&
          other.bookId == this.bookId &&
          other.kind == this.kind &&
          other.relativePath == this.relativePath &&
          other.sizeBytes == this.sizeBytes &&
          other.sha == this.sha &&
          other.lastAccessedAt == this.lastAccessedAt &&
          other.pinned == this.pinned &&
          other.permanent == this.permanent);
}

class CachedAssetsCompanion extends UpdateCompanion<CachedAsset> {
  final Value<String> sourceId;
  final Value<String> bookId;
  final Value<String> kind;
  final Value<String> relativePath;
  final Value<int> sizeBytes;
  final Value<String?> sha;
  final Value<int> lastAccessedAt;
  final Value<bool> pinned;
  final Value<bool> permanent;
  final Value<int> rowid;
  const CachedAssetsCompanion({
    this.sourceId = const Value.absent(),
    this.bookId = const Value.absent(),
    this.kind = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.sha = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.pinned = const Value.absent(),
    this.permanent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedAssetsCompanion.insert({
    required String sourceId,
    required String bookId,
    this.kind = const Value.absent(),
    required String relativePath,
    this.sizeBytes = const Value.absent(),
    this.sha = const Value.absent(),
    required int lastAccessedAt,
    this.pinned = const Value.absent(),
    this.permanent = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       bookId = Value(bookId),
       relativePath = Value(relativePath),
       lastAccessedAt = Value(lastAccessedAt);
  static Insertable<CachedAsset> custom({
    Expression<String>? sourceId,
    Expression<String>? bookId,
    Expression<String>? kind,
    Expression<String>? relativePath,
    Expression<int>? sizeBytes,
    Expression<String>? sha,
    Expression<int>? lastAccessedAt,
    Expression<bool>? pinned,
    Expression<bool>? permanent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (bookId != null) 'book_id': bookId,
      if (kind != null) 'kind': kind,
      if (relativePath != null) 'relative_path': relativePath,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (sha != null) 'sha': sha,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (pinned != null) 'pinned': pinned,
      if (permanent != null) 'permanent': permanent,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedAssetsCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? bookId,
    Value<String>? kind,
    Value<String>? relativePath,
    Value<int>? sizeBytes,
    Value<String?>? sha,
    Value<int>? lastAccessedAt,
    Value<bool>? pinned,
    Value<bool>? permanent,
    Value<int>? rowid,
  }) {
    return CachedAssetsCompanion(
      sourceId: sourceId ?? this.sourceId,
      bookId: bookId ?? this.bookId,
      kind: kind ?? this.kind,
      relativePath: relativePath ?? this.relativePath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      sha: sha ?? this.sha,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      pinned: pinned ?? this.pinned,
      permanent: permanent ?? this.permanent,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (sha.present) {
      map['sha'] = Variable<String>(sha.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<int>(lastAccessedAt.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (permanent.present) {
      map['permanent'] = Variable<bool>(permanent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedAssetsCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('bookId: $bookId, ')
          ..write('kind: $kind, ')
          ..write('relativePath: $relativePath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('sha: $sha, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('pinned: $pinned, ')
          ..write('permanent: $permanent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadTasksTable extends DownloadTasks
    with TableInfo<$DownloadTasksTable, DownloadTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadTasksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('enqueued'),
  );
  static const VerificationMeta _bytesDownloadedMeta = const VerificationMeta(
    'bytesDownloaded',
  );
  @override
  late final GeneratedColumn<int> bytesDownloaded = GeneratedColumn<int>(
    'bytes_downloaded',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalBytesMeta = const VerificationMeta(
    'totalBytes',
  );
  @override
  late final GeneratedColumn<int> totalBytes = GeneratedColumn<int>(
    'total_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requiresWifiMeta = const VerificationMeta(
    'requiresWifi',
  );
  @override
  late final GeneratedColumn<bool> requiresWifi = GeneratedColumn<bool>(
    'requires_wifi',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("requires_wifi" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _permanentMeta = const VerificationMeta(
    'permanent',
  );
  @override
  late final GeneratedColumn<bool> permanent = GeneratedColumn<bool>(
    'permanent',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("permanent" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceId,
    bookId,
    taskId,
    state,
    bytesDownloaded,
    totalBytes,
    requiresWifi,
    permanent,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadTask> instance, {
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
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('bytes_downloaded')) {
      context.handle(
        _bytesDownloadedMeta,
        bytesDownloaded.isAcceptableOrUnknown(
          data['bytes_downloaded']!,
          _bytesDownloadedMeta,
        ),
      );
    }
    if (data.containsKey('total_bytes')) {
      context.handle(
        _totalBytesMeta,
        totalBytes.isAcceptableOrUnknown(data['total_bytes']!, _totalBytesMeta),
      );
    }
    if (data.containsKey('requires_wifi')) {
      context.handle(
        _requiresWifiMeta,
        requiresWifi.isAcceptableOrUnknown(
          data['requires_wifi']!,
          _requiresWifiMeta,
        ),
      );
    }
    if (data.containsKey('permanent')) {
      context.handle(
        _permanentMeta,
        permanent.isAcceptableOrUnknown(data['permanent']!, _permanentMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, bookId};
  @override
  DownloadTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadTask(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      bytesDownloaded: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes_downloaded'],
      )!,
      totalBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_bytes'],
      ),
      requiresWifi: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}requires_wifi'],
      )!,
      permanent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}permanent'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DownloadTasksTable createAlias(String alias) {
    return $DownloadTasksTable(attachedDatabase, alias);
  }
}

class DownloadTask extends DataClass implements Insertable<DownloadTask> {
  final String sourceId;
  final String bookId;
  final String taskId;
  final String state;
  final int bytesDownloaded;
  final int? totalBytes;
  final bool requiresWifi;

  /// True for a manual download (goes to the permanent downloads pool); false
  /// for an auto-cache download. Lets resume-on-launch pick the right pool.
  final bool permanent;
  final int updatedAt;
  const DownloadTask({
    required this.sourceId,
    required this.bookId,
    required this.taskId,
    required this.state,
    required this.bytesDownloaded,
    this.totalBytes,
    required this.requiresWifi,
    required this.permanent,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['book_id'] = Variable<String>(bookId);
    map['task_id'] = Variable<String>(taskId);
    map['state'] = Variable<String>(state);
    map['bytes_downloaded'] = Variable<int>(bytesDownloaded);
    if (!nullToAbsent || totalBytes != null) {
      map['total_bytes'] = Variable<int>(totalBytes);
    }
    map['requires_wifi'] = Variable<bool>(requiresWifi);
    map['permanent'] = Variable<bool>(permanent);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  DownloadTasksCompanion toCompanion(bool nullToAbsent) {
    return DownloadTasksCompanion(
      sourceId: Value(sourceId),
      bookId: Value(bookId),
      taskId: Value(taskId),
      state: Value(state),
      bytesDownloaded: Value(bytesDownloaded),
      totalBytes: totalBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(totalBytes),
      requiresWifi: Value(requiresWifi),
      permanent: Value(permanent),
      updatedAt: Value(updatedAt),
    );
  }

  factory DownloadTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadTask(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      bookId: serializer.fromJson<String>(json['bookId']),
      taskId: serializer.fromJson<String>(json['taskId']),
      state: serializer.fromJson<String>(json['state']),
      bytesDownloaded: serializer.fromJson<int>(json['bytesDownloaded']),
      totalBytes: serializer.fromJson<int?>(json['totalBytes']),
      requiresWifi: serializer.fromJson<bool>(json['requiresWifi']),
      permanent: serializer.fromJson<bool>(json['permanent']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'bookId': serializer.toJson<String>(bookId),
      'taskId': serializer.toJson<String>(taskId),
      'state': serializer.toJson<String>(state),
      'bytesDownloaded': serializer.toJson<int>(bytesDownloaded),
      'totalBytes': serializer.toJson<int?>(totalBytes),
      'requiresWifi': serializer.toJson<bool>(requiresWifi),
      'permanent': serializer.toJson<bool>(permanent),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  DownloadTask copyWith({
    String? sourceId,
    String? bookId,
    String? taskId,
    String? state,
    int? bytesDownloaded,
    Value<int?> totalBytes = const Value.absent(),
    bool? requiresWifi,
    bool? permanent,
    int? updatedAt,
  }) => DownloadTask(
    sourceId: sourceId ?? this.sourceId,
    bookId: bookId ?? this.bookId,
    taskId: taskId ?? this.taskId,
    state: state ?? this.state,
    bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
    totalBytes: totalBytes.present ? totalBytes.value : this.totalBytes,
    requiresWifi: requiresWifi ?? this.requiresWifi,
    permanent: permanent ?? this.permanent,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DownloadTask copyWithCompanion(DownloadTasksCompanion data) {
    return DownloadTask(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      state: data.state.present ? data.state.value : this.state,
      bytesDownloaded: data.bytesDownloaded.present
          ? data.bytesDownloaded.value
          : this.bytesDownloaded,
      totalBytes: data.totalBytes.present
          ? data.totalBytes.value
          : this.totalBytes,
      requiresWifi: data.requiresWifi.present
          ? data.requiresWifi.value
          : this.requiresWifi,
      permanent: data.permanent.present ? data.permanent.value : this.permanent,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTask(')
          ..write('sourceId: $sourceId, ')
          ..write('bookId: $bookId, ')
          ..write('taskId: $taskId, ')
          ..write('state: $state, ')
          ..write('bytesDownloaded: $bytesDownloaded, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('requiresWifi: $requiresWifi, ')
          ..write('permanent: $permanent, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sourceId,
    bookId,
    taskId,
    state,
    bytesDownloaded,
    totalBytes,
    requiresWifi,
    permanent,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadTask &&
          other.sourceId == this.sourceId &&
          other.bookId == this.bookId &&
          other.taskId == this.taskId &&
          other.state == this.state &&
          other.bytesDownloaded == this.bytesDownloaded &&
          other.totalBytes == this.totalBytes &&
          other.requiresWifi == this.requiresWifi &&
          other.permanent == this.permanent &&
          other.updatedAt == this.updatedAt);
}

class DownloadTasksCompanion extends UpdateCompanion<DownloadTask> {
  final Value<String> sourceId;
  final Value<String> bookId;
  final Value<String> taskId;
  final Value<String> state;
  final Value<int> bytesDownloaded;
  final Value<int?> totalBytes;
  final Value<bool> requiresWifi;
  final Value<bool> permanent;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const DownloadTasksCompanion({
    this.sourceId = const Value.absent(),
    this.bookId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.state = const Value.absent(),
    this.bytesDownloaded = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.requiresWifi = const Value.absent(),
    this.permanent = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadTasksCompanion.insert({
    required String sourceId,
    required String bookId,
    required String taskId,
    this.state = const Value.absent(),
    this.bytesDownloaded = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.requiresWifi = const Value.absent(),
    this.permanent = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       bookId = Value(bookId),
       taskId = Value(taskId),
       updatedAt = Value(updatedAt);
  static Insertable<DownloadTask> custom({
    Expression<String>? sourceId,
    Expression<String>? bookId,
    Expression<String>? taskId,
    Expression<String>? state,
    Expression<int>? bytesDownloaded,
    Expression<int>? totalBytes,
    Expression<bool>? requiresWifi,
    Expression<bool>? permanent,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (bookId != null) 'book_id': bookId,
      if (taskId != null) 'task_id': taskId,
      if (state != null) 'state': state,
      if (bytesDownloaded != null) 'bytes_downloaded': bytesDownloaded,
      if (totalBytes != null) 'total_bytes': totalBytes,
      if (requiresWifi != null) 'requires_wifi': requiresWifi,
      if (permanent != null) 'permanent': permanent,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadTasksCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? bookId,
    Value<String>? taskId,
    Value<String>? state,
    Value<int>? bytesDownloaded,
    Value<int?>? totalBytes,
    Value<bool>? requiresWifi,
    Value<bool>? permanent,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return DownloadTasksCompanion(
      sourceId: sourceId ?? this.sourceId,
      bookId: bookId ?? this.bookId,
      taskId: taskId ?? this.taskId,
      state: state ?? this.state,
      bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
      totalBytes: totalBytes ?? this.totalBytes,
      requiresWifi: requiresWifi ?? this.requiresWifi,
      permanent: permanent ?? this.permanent,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (bytesDownloaded.present) {
      map['bytes_downloaded'] = Variable<int>(bytesDownloaded.value);
    }
    if (totalBytes.present) {
      map['total_bytes'] = Variable<int>(totalBytes.value);
    }
    if (requiresWifi.present) {
      map['requires_wifi'] = Variable<bool>(requiresWifi.value);
    }
    if (permanent.present) {
      map['permanent'] = Variable<bool>(permanent.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadTasksCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('bookId: $bookId, ')
          ..write('taskId: $taskId, ')
          ..write('state: $state, ')
          ..write('bytesDownloaded: $bytesDownloaded, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('requiresWifi: $requiresWifi, ')
          ..write('permanent: $permanent, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookStateTable extends BookState
    with TableInfo<$BookStateTable, BookStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookStateTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _currentPageMeta = const VerificationMeta(
    'currentPage',
  );
  @override
  late final GeneratedColumn<int> currentPage = GeneratedColumn<int>(
    'current_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _progressVolumesMeta = const VerificationMeta(
    'progressVolumes',
  );
  @override
  late final GeneratedColumn<double> progressVolumes = GeneratedColumn<double>(
    'progress_volumes',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timesRereadMeta = const VerificationMeta(
    'timesReread',
  );
  @override
  late final GeneratedColumn<int> timesReread = GeneratedColumn<int>(
    'times_reread',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isRereadingMeta = const VerificationMeta(
    'isRereading',
  );
  @override
  late final GeneratedColumn<bool> isRereading = GeneratedColumn<bool>(
    'is_rereading',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_rereading" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<int> finishedAt = GeneratedColumn<int>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visibilityMeta = const VerificationMeta(
    'visibility',
  );
  @override
  late final GeneratedColumn<String> visibility = GeneratedColumn<String>(
    'visibility',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('private'),
  );
  static const VerificationMeta _shareToFeedMeta = const VerificationMeta(
    'shareToFeed',
  );
  @override
  late final GeneratedColumn<bool> shareToFeed = GeneratedColumn<bool>(
    'share_to_feed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("share_to_feed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteUpdatedAtMeta = const VerificationMeta(
    'remoteUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> remoteUpdatedAt = GeneratedColumn<int>(
    'remote_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reconciledAtMeta = const VerificationMeta(
    'reconciledAt',
  );
  @override
  late final GeneratedColumn<int> reconciledAt = GeneratedColumn<int>(
    'reconciled_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceId,
    bookId,
    status,
    currentPage,
    progressVolumes,
    rating,
    timesReread,
    isRereading,
    startedAt,
    finishedAt,
    visibility,
    shareToFeed,
    updatedAt,
    remoteUpdatedAt,
    reconciledAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookStateRow> instance, {
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
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('current_page')) {
      context.handle(
        _currentPageMeta,
        currentPage.isAcceptableOrUnknown(
          data['current_page']!,
          _currentPageMeta,
        ),
      );
    }
    if (data.containsKey('progress_volumes')) {
      context.handle(
        _progressVolumesMeta,
        progressVolumes.isAcceptableOrUnknown(
          data['progress_volumes']!,
          _progressVolumesMeta,
        ),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('times_reread')) {
      context.handle(
        _timesRereadMeta,
        timesReread.isAcceptableOrUnknown(
          data['times_reread']!,
          _timesRereadMeta,
        ),
      );
    }
    if (data.containsKey('is_rereading')) {
      context.handle(
        _isRereadingMeta,
        isRereading.isAcceptableOrUnknown(
          data['is_rereading']!,
          _isRereadingMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('visibility')) {
      context.handle(
        _visibilityMeta,
        visibility.isAcceptableOrUnknown(data['visibility']!, _visibilityMeta),
      );
    }
    if (data.containsKey('share_to_feed')) {
      context.handle(
        _shareToFeedMeta,
        shareToFeed.isAcceptableOrUnknown(
          data['share_to_feed']!,
          _shareToFeedMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('remote_updated_at')) {
      context.handle(
        _remoteUpdatedAtMeta,
        remoteUpdatedAt.isAcceptableOrUnknown(
          data['remote_updated_at']!,
          _remoteUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('reconciled_at')) {
      context.handle(
        _reconciledAtMeta,
        reconciledAt.isAcceptableOrUnknown(
          data['reconciled_at']!,
          _reconciledAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, bookId};
  @override
  BookStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookStateRow(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      currentPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_page'],
      )!,
      progressVolumes: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress_volumes'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
      timesReread: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_reread'],
      )!,
      isRereading: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_rereading'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      ),
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}finished_at'],
      ),
      visibility: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visibility'],
      )!,
      shareToFeed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}share_to_feed'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      remoteUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_updated_at'],
      ),
      reconciledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reconciled_at'],
      ),
    );
  }

  @override
  $BookStateTable createAlias(String alias) {
    return $BookStateTable(attachedDatabase, alias);
  }
}

class BookStateRow extends DataClass implements Insertable<BookStateRow> {
  final String sourceId;
  final String bookId;

  /// One of [ReadStatus] by name, or NULL before any progress is recorded.
  final String? status;
  final int currentPage;

  /// RESERVED (forward-compat for Komga volume progress); unwritten in phase 1.
  final double? progressVolumes;

  /// RESERVED (no rating UI in phase 1).
  final int? rating;
  final int timesReread;
  final bool isRereading;
  final int? startedAt;
  final int? finishedAt;
  final String visibility;
  final bool shareToFeed;

  /// Local lastModified, epoch ms (device clock).
  final int updatedAt;

  /// Last-seen Komga progress lastModified, epoch ms (SERVER clock). The
  /// "is there something new on the server" baseline; only ever a server value,
  /// NULL when the server has no read progress for this book. Never compared
  /// against a device clock.
  final int? remoteUpdatedAt;

  /// When this book was last reconciled, epoch ms (DEVICE clock). Drives the
  /// reconcile rotation (least-recently-reconciled first); NULL = never
  /// reconciled, so it sorts to the head. Kept separate from [remoteUpdatedAt]
  /// so the rotation order and the freshness comparison never mix clock
  /// domains.
  final int? reconciledAt;
  const BookStateRow({
    required this.sourceId,
    required this.bookId,
    this.status,
    required this.currentPage,
    this.progressVolumes,
    this.rating,
    required this.timesReread,
    required this.isRereading,
    this.startedAt,
    this.finishedAt,
    required this.visibility,
    required this.shareToFeed,
    required this.updatedAt,
    this.remoteUpdatedAt,
    this.reconciledAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['book_id'] = Variable<String>(bookId);
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    map['current_page'] = Variable<int>(currentPage);
    if (!nullToAbsent || progressVolumes != null) {
      map['progress_volumes'] = Variable<double>(progressVolumes);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    map['times_reread'] = Variable<int>(timesReread);
    map['is_rereading'] = Variable<bool>(isRereading);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<int>(startedAt);
    }
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<int>(finishedAt);
    }
    map['visibility'] = Variable<String>(visibility);
    map['share_to_feed'] = Variable<bool>(shareToFeed);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || remoteUpdatedAt != null) {
      map['remote_updated_at'] = Variable<int>(remoteUpdatedAt);
    }
    if (!nullToAbsent || reconciledAt != null) {
      map['reconciled_at'] = Variable<int>(reconciledAt);
    }
    return map;
  }

  BookStateCompanion toCompanion(bool nullToAbsent) {
    return BookStateCompanion(
      sourceId: Value(sourceId),
      bookId: Value(bookId),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      currentPage: Value(currentPage),
      progressVolumes: progressVolumes == null && nullToAbsent
          ? const Value.absent()
          : Value(progressVolumes),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      timesReread: Value(timesReread),
      isRereading: Value(isRereading),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      visibility: Value(visibility),
      shareToFeed: Value(shareToFeed),
      updatedAt: Value(updatedAt),
      remoteUpdatedAt: remoteUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUpdatedAt),
      reconciledAt: reconciledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reconciledAt),
    );
  }

  factory BookStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookStateRow(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      bookId: serializer.fromJson<String>(json['bookId']),
      status: serializer.fromJson<String?>(json['status']),
      currentPage: serializer.fromJson<int>(json['currentPage']),
      progressVolumes: serializer.fromJson<double?>(json['progressVolumes']),
      rating: serializer.fromJson<int?>(json['rating']),
      timesReread: serializer.fromJson<int>(json['timesReread']),
      isRereading: serializer.fromJson<bool>(json['isRereading']),
      startedAt: serializer.fromJson<int?>(json['startedAt']),
      finishedAt: serializer.fromJson<int?>(json['finishedAt']),
      visibility: serializer.fromJson<String>(json['visibility']),
      shareToFeed: serializer.fromJson<bool>(json['shareToFeed']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      remoteUpdatedAt: serializer.fromJson<int?>(json['remoteUpdatedAt']),
      reconciledAt: serializer.fromJson<int?>(json['reconciledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'bookId': serializer.toJson<String>(bookId),
      'status': serializer.toJson<String?>(status),
      'currentPage': serializer.toJson<int>(currentPage),
      'progressVolumes': serializer.toJson<double?>(progressVolumes),
      'rating': serializer.toJson<int?>(rating),
      'timesReread': serializer.toJson<int>(timesReread),
      'isRereading': serializer.toJson<bool>(isRereading),
      'startedAt': serializer.toJson<int?>(startedAt),
      'finishedAt': serializer.toJson<int?>(finishedAt),
      'visibility': serializer.toJson<String>(visibility),
      'shareToFeed': serializer.toJson<bool>(shareToFeed),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'remoteUpdatedAt': serializer.toJson<int?>(remoteUpdatedAt),
      'reconciledAt': serializer.toJson<int?>(reconciledAt),
    };
  }

  BookStateRow copyWith({
    String? sourceId,
    String? bookId,
    Value<String?> status = const Value.absent(),
    int? currentPage,
    Value<double?> progressVolumes = const Value.absent(),
    Value<int?> rating = const Value.absent(),
    int? timesReread,
    bool? isRereading,
    Value<int?> startedAt = const Value.absent(),
    Value<int?> finishedAt = const Value.absent(),
    String? visibility,
    bool? shareToFeed,
    int? updatedAt,
    Value<int?> remoteUpdatedAt = const Value.absent(),
    Value<int?> reconciledAt = const Value.absent(),
  }) => BookStateRow(
    sourceId: sourceId ?? this.sourceId,
    bookId: bookId ?? this.bookId,
    status: status.present ? status.value : this.status,
    currentPage: currentPage ?? this.currentPage,
    progressVolumes: progressVolumes.present
        ? progressVolumes.value
        : this.progressVolumes,
    rating: rating.present ? rating.value : this.rating,
    timesReread: timesReread ?? this.timesReread,
    isRereading: isRereading ?? this.isRereading,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    visibility: visibility ?? this.visibility,
    shareToFeed: shareToFeed ?? this.shareToFeed,
    updatedAt: updatedAt ?? this.updatedAt,
    remoteUpdatedAt: remoteUpdatedAt.present
        ? remoteUpdatedAt.value
        : this.remoteUpdatedAt,
    reconciledAt: reconciledAt.present ? reconciledAt.value : this.reconciledAt,
  );
  BookStateRow copyWithCompanion(BookStateCompanion data) {
    return BookStateRow(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      status: data.status.present ? data.status.value : this.status,
      currentPage: data.currentPage.present
          ? data.currentPage.value
          : this.currentPage,
      progressVolumes: data.progressVolumes.present
          ? data.progressVolumes.value
          : this.progressVolumes,
      rating: data.rating.present ? data.rating.value : this.rating,
      timesReread: data.timesReread.present
          ? data.timesReread.value
          : this.timesReread,
      isRereading: data.isRereading.present
          ? data.isRereading.value
          : this.isRereading,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      visibility: data.visibility.present
          ? data.visibility.value
          : this.visibility,
      shareToFeed: data.shareToFeed.present
          ? data.shareToFeed.value
          : this.shareToFeed,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      remoteUpdatedAt: data.remoteUpdatedAt.present
          ? data.remoteUpdatedAt.value
          : this.remoteUpdatedAt,
      reconciledAt: data.reconciledAt.present
          ? data.reconciledAt.value
          : this.reconciledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookStateRow(')
          ..write('sourceId: $sourceId, ')
          ..write('bookId: $bookId, ')
          ..write('status: $status, ')
          ..write('currentPage: $currentPage, ')
          ..write('progressVolumes: $progressVolumes, ')
          ..write('rating: $rating, ')
          ..write('timesReread: $timesReread, ')
          ..write('isRereading: $isRereading, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('visibility: $visibility, ')
          ..write('shareToFeed: $shareToFeed, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('reconciledAt: $reconciledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sourceId,
    bookId,
    status,
    currentPage,
    progressVolumes,
    rating,
    timesReread,
    isRereading,
    startedAt,
    finishedAt,
    visibility,
    shareToFeed,
    updatedAt,
    remoteUpdatedAt,
    reconciledAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookStateRow &&
          other.sourceId == this.sourceId &&
          other.bookId == this.bookId &&
          other.status == this.status &&
          other.currentPage == this.currentPage &&
          other.progressVolumes == this.progressVolumes &&
          other.rating == this.rating &&
          other.timesReread == this.timesReread &&
          other.isRereading == this.isRereading &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.visibility == this.visibility &&
          other.shareToFeed == this.shareToFeed &&
          other.updatedAt == this.updatedAt &&
          other.remoteUpdatedAt == this.remoteUpdatedAt &&
          other.reconciledAt == this.reconciledAt);
}

class BookStateCompanion extends UpdateCompanion<BookStateRow> {
  final Value<String> sourceId;
  final Value<String> bookId;
  final Value<String?> status;
  final Value<int> currentPage;
  final Value<double?> progressVolumes;
  final Value<int?> rating;
  final Value<int> timesReread;
  final Value<bool> isRereading;
  final Value<int?> startedAt;
  final Value<int?> finishedAt;
  final Value<String> visibility;
  final Value<bool> shareToFeed;
  final Value<int> updatedAt;
  final Value<int?> remoteUpdatedAt;
  final Value<int?> reconciledAt;
  final Value<int> rowid;
  const BookStateCompanion({
    this.sourceId = const Value.absent(),
    this.bookId = const Value.absent(),
    this.status = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.progressVolumes = const Value.absent(),
    this.rating = const Value.absent(),
    this.timesReread = const Value.absent(),
    this.isRereading = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.visibility = const Value.absent(),
    this.shareToFeed = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.remoteUpdatedAt = const Value.absent(),
    this.reconciledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookStateCompanion.insert({
    required String sourceId,
    required String bookId,
    this.status = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.progressVolumes = const Value.absent(),
    this.rating = const Value.absent(),
    this.timesReread = const Value.absent(),
    this.isRereading = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.visibility = const Value.absent(),
    this.shareToFeed = const Value.absent(),
    required int updatedAt,
    this.remoteUpdatedAt = const Value.absent(),
    this.reconciledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       bookId = Value(bookId),
       updatedAt = Value(updatedAt);
  static Insertable<BookStateRow> custom({
    Expression<String>? sourceId,
    Expression<String>? bookId,
    Expression<String>? status,
    Expression<int>? currentPage,
    Expression<double>? progressVolumes,
    Expression<int>? rating,
    Expression<int>? timesReread,
    Expression<bool>? isRereading,
    Expression<int>? startedAt,
    Expression<int>? finishedAt,
    Expression<String>? visibility,
    Expression<bool>? shareToFeed,
    Expression<int>? updatedAt,
    Expression<int>? remoteUpdatedAt,
    Expression<int>? reconciledAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (bookId != null) 'book_id': bookId,
      if (status != null) 'status': status,
      if (currentPage != null) 'current_page': currentPage,
      if (progressVolumes != null) 'progress_volumes': progressVolumes,
      if (rating != null) 'rating': rating,
      if (timesReread != null) 'times_reread': timesReread,
      if (isRereading != null) 'is_rereading': isRereading,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (visibility != null) 'visibility': visibility,
      if (shareToFeed != null) 'share_to_feed': shareToFeed,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (remoteUpdatedAt != null) 'remote_updated_at': remoteUpdatedAt,
      if (reconciledAt != null) 'reconciled_at': reconciledAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookStateCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? bookId,
    Value<String?>? status,
    Value<int>? currentPage,
    Value<double?>? progressVolumes,
    Value<int?>? rating,
    Value<int>? timesReread,
    Value<bool>? isRereading,
    Value<int?>? startedAt,
    Value<int?>? finishedAt,
    Value<String>? visibility,
    Value<bool>? shareToFeed,
    Value<int>? updatedAt,
    Value<int?>? remoteUpdatedAt,
    Value<int?>? reconciledAt,
    Value<int>? rowid,
  }) {
    return BookStateCompanion(
      sourceId: sourceId ?? this.sourceId,
      bookId: bookId ?? this.bookId,
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      progressVolumes: progressVolumes ?? this.progressVolumes,
      rating: rating ?? this.rating,
      timesReread: timesReread ?? this.timesReread,
      isRereading: isRereading ?? this.isRereading,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      visibility: visibility ?? this.visibility,
      shareToFeed: shareToFeed ?? this.shareToFeed,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
      reconciledAt: reconciledAt ?? this.reconciledAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (currentPage.present) {
      map['current_page'] = Variable<int>(currentPage.value);
    }
    if (progressVolumes.present) {
      map['progress_volumes'] = Variable<double>(progressVolumes.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (timesReread.present) {
      map['times_reread'] = Variable<int>(timesReread.value);
    }
    if (isRereading.present) {
      map['is_rereading'] = Variable<bool>(isRereading.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<int>(finishedAt.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<String>(visibility.value);
    }
    if (shareToFeed.present) {
      map['share_to_feed'] = Variable<bool>(shareToFeed.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (remoteUpdatedAt.present) {
      map['remote_updated_at'] = Variable<int>(remoteUpdatedAt.value);
    }
    if (reconciledAt.present) {
      map['reconciled_at'] = Variable<int>(reconciledAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookStateCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('bookId: $bookId, ')
          ..write('status: $status, ')
          ..write('currentPage: $currentPage, ')
          ..write('progressVolumes: $progressVolumes, ')
          ..write('rating: $rating, ')
          ..write('timesReread: $timesReread, ')
          ..write('isRereading: $isRereading, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('visibility: $visibility, ')
          ..write('shareToFeed: $shareToFeed, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('reconciledAt: $reconciledAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingSessionsTable extends ReadingSessions
    with TableInfo<$ReadingSessionsTable, ReadingSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
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
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeSecondsMeta = const VerificationMeta(
    'activeSeconds',
  );
  @override
  late final GeneratedColumn<int> activeSeconds = GeneratedColumn<int>(
    'active_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startPageMeta = const VerificationMeta(
    'startPage',
  );
  @override
  late final GeneratedColumn<int> startPage = GeneratedColumn<int>(
    'start_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endPageMeta = const VerificationMeta(
    'endPage',
  );
  @override
  late final GeneratedColumn<int> endPage = GeneratedColumn<int>(
    'end_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pagesReadMeta = const VerificationMeta(
    'pagesRead',
  );
  @override
  late final GeneratedColumn<int> pagesRead = GeneratedColumn<int>(
    'pages_read',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletionMeta = const VerificationMeta(
    'isCompletion',
  );
  @override
  late final GeneratedColumn<bool> isCompletion = GeneratedColumn<bool>(
    'is_completion',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completion" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rereadIndexMeta = const VerificationMeta(
    'rereadIndex',
  );
  @override
  late final GeneratedColumn<int> rereadIndex = GeneratedColumn<int>(
    'reread_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visibilityMeta = const VerificationMeta(
    'visibility',
  );
  @override
  late final GeneratedColumn<String> visibility = GeneratedColumn<String>(
    'visibility',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('private'),
  );
  static const VerificationMeta _shareToFeedMeta = const VerificationMeta(
    'shareToFeed',
  );
  @override
  late final GeneratedColumn<bool> shareToFeed = GeneratedColumn<bool>(
    'share_to_feed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("share_to_feed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    bookId,
    seriesId,
    startedAt,
    endedAt,
    activeSeconds,
    startPage,
    endPage,
    pagesRead,
    isCompletion,
    rereadIndex,
    deviceId,
    visibility,
    shareToFeed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    if (data.containsKey('active_seconds')) {
      context.handle(
        _activeSecondsMeta,
        activeSeconds.isAcceptableOrUnknown(
          data['active_seconds']!,
          _activeSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activeSecondsMeta);
    }
    if (data.containsKey('start_page')) {
      context.handle(
        _startPageMeta,
        startPage.isAcceptableOrUnknown(data['start_page']!, _startPageMeta),
      );
    } else if (isInserting) {
      context.missing(_startPageMeta);
    }
    if (data.containsKey('end_page')) {
      context.handle(
        _endPageMeta,
        endPage.isAcceptableOrUnknown(data['end_page']!, _endPageMeta),
      );
    } else if (isInserting) {
      context.missing(_endPageMeta);
    }
    if (data.containsKey('pages_read')) {
      context.handle(
        _pagesReadMeta,
        pagesRead.isAcceptableOrUnknown(data['pages_read']!, _pagesReadMeta),
      );
    } else if (isInserting) {
      context.missing(_pagesReadMeta);
    }
    if (data.containsKey('is_completion')) {
      context.handle(
        _isCompletionMeta,
        isCompletion.isAcceptableOrUnknown(
          data['is_completion']!,
          _isCompletionMeta,
        ),
      );
    }
    if (data.containsKey('reread_index')) {
      context.handle(
        _rereadIndexMeta,
        rereadIndex.isAcceptableOrUnknown(
          data['reread_index']!,
          _rereadIndexMeta,
        ),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('visibility')) {
      context.handle(
        _visibilityMeta,
        visibility.isAcceptableOrUnknown(data['visibility']!, _visibilityMeta),
      );
    }
    if (data.containsKey('share_to_feed')) {
      context.handle(
        _shareToFeedMeta,
        shareToFeed.isAcceptableOrUnknown(
          data['share_to_feed']!,
          _shareToFeedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at'],
      )!,
      activeSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_seconds'],
      )!,
      startPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_page'],
      )!,
      endPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_page'],
      )!,
      pagesRead: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pages_read'],
      )!,
      isCompletion: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completion'],
      )!,
      rereadIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reread_index'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      visibility: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visibility'],
      )!,
      shareToFeed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}share_to_feed'],
      )!,
    );
  }

  @override
  $ReadingSessionsTable createAlias(String alias) {
    return $ReadingSessionsTable(attachedDatabase, alias);
  }
}

class ReadingSessionRow extends DataClass
    implements Insertable<ReadingSessionRow> {
  /// uuid v4.
  final String id;
  final String sourceId;
  final String bookId;
  final String seriesId;

  /// Epoch ms.
  final int startedAt;
  final int endedAt;

  /// Idle-capped active reading seconds.
  final int activeSeconds;
  final int startPage;
  final int endPage;
  final int pagesRead;
  final bool isCompletion;
  final int rereadIndex;
  final String deviceId;
  final String visibility;
  final bool shareToFeed;
  const ReadingSessionRow({
    required this.id,
    required this.sourceId,
    required this.bookId,
    required this.seriesId,
    required this.startedAt,
    required this.endedAt,
    required this.activeSeconds,
    required this.startPage,
    required this.endPage,
    required this.pagesRead,
    required this.isCompletion,
    required this.rereadIndex,
    required this.deviceId,
    required this.visibility,
    required this.shareToFeed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_id'] = Variable<String>(sourceId);
    map['book_id'] = Variable<String>(bookId);
    map['series_id'] = Variable<String>(seriesId);
    map['started_at'] = Variable<int>(startedAt);
    map['ended_at'] = Variable<int>(endedAt);
    map['active_seconds'] = Variable<int>(activeSeconds);
    map['start_page'] = Variable<int>(startPage);
    map['end_page'] = Variable<int>(endPage);
    map['pages_read'] = Variable<int>(pagesRead);
    map['is_completion'] = Variable<bool>(isCompletion);
    map['reread_index'] = Variable<int>(rereadIndex);
    map['device_id'] = Variable<String>(deviceId);
    map['visibility'] = Variable<String>(visibility);
    map['share_to_feed'] = Variable<bool>(shareToFeed);
    return map;
  }

  ReadingSessionsCompanion toCompanion(bool nullToAbsent) {
    return ReadingSessionsCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      bookId: Value(bookId),
      seriesId: Value(seriesId),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
      activeSeconds: Value(activeSeconds),
      startPage: Value(startPage),
      endPage: Value(endPage),
      pagesRead: Value(pagesRead),
      isCompletion: Value(isCompletion),
      rereadIndex: Value(rereadIndex),
      deviceId: Value(deviceId),
      visibility: Value(visibility),
      shareToFeed: Value(shareToFeed),
    );
  }

  factory ReadingSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingSessionRow(
      id: serializer.fromJson<String>(json['id']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      bookId: serializer.fromJson<String>(json['bookId']),
      seriesId: serializer.fromJson<String>(json['seriesId']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      endedAt: serializer.fromJson<int>(json['endedAt']),
      activeSeconds: serializer.fromJson<int>(json['activeSeconds']),
      startPage: serializer.fromJson<int>(json['startPage']),
      endPage: serializer.fromJson<int>(json['endPage']),
      pagesRead: serializer.fromJson<int>(json['pagesRead']),
      isCompletion: serializer.fromJson<bool>(json['isCompletion']),
      rereadIndex: serializer.fromJson<int>(json['rereadIndex']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      visibility: serializer.fromJson<String>(json['visibility']),
      shareToFeed: serializer.fromJson<bool>(json['shareToFeed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceId': serializer.toJson<String>(sourceId),
      'bookId': serializer.toJson<String>(bookId),
      'seriesId': serializer.toJson<String>(seriesId),
      'startedAt': serializer.toJson<int>(startedAt),
      'endedAt': serializer.toJson<int>(endedAt),
      'activeSeconds': serializer.toJson<int>(activeSeconds),
      'startPage': serializer.toJson<int>(startPage),
      'endPage': serializer.toJson<int>(endPage),
      'pagesRead': serializer.toJson<int>(pagesRead),
      'isCompletion': serializer.toJson<bool>(isCompletion),
      'rereadIndex': serializer.toJson<int>(rereadIndex),
      'deviceId': serializer.toJson<String>(deviceId),
      'visibility': serializer.toJson<String>(visibility),
      'shareToFeed': serializer.toJson<bool>(shareToFeed),
    };
  }

  ReadingSessionRow copyWith({
    String? id,
    String? sourceId,
    String? bookId,
    String? seriesId,
    int? startedAt,
    int? endedAt,
    int? activeSeconds,
    int? startPage,
    int? endPage,
    int? pagesRead,
    bool? isCompletion,
    int? rereadIndex,
    String? deviceId,
    String? visibility,
    bool? shareToFeed,
  }) => ReadingSessionRow(
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    bookId: bookId ?? this.bookId,
    seriesId: seriesId ?? this.seriesId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    activeSeconds: activeSeconds ?? this.activeSeconds,
    startPage: startPage ?? this.startPage,
    endPage: endPage ?? this.endPage,
    pagesRead: pagesRead ?? this.pagesRead,
    isCompletion: isCompletion ?? this.isCompletion,
    rereadIndex: rereadIndex ?? this.rereadIndex,
    deviceId: deviceId ?? this.deviceId,
    visibility: visibility ?? this.visibility,
    shareToFeed: shareToFeed ?? this.shareToFeed,
  );
  ReadingSessionRow copyWithCompanion(ReadingSessionsCompanion data) {
    return ReadingSessionRow(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      activeSeconds: data.activeSeconds.present
          ? data.activeSeconds.value
          : this.activeSeconds,
      startPage: data.startPage.present ? data.startPage.value : this.startPage,
      endPage: data.endPage.present ? data.endPage.value : this.endPage,
      pagesRead: data.pagesRead.present ? data.pagesRead.value : this.pagesRead,
      isCompletion: data.isCompletion.present
          ? data.isCompletion.value
          : this.isCompletion,
      rereadIndex: data.rereadIndex.present
          ? data.rereadIndex.value
          : this.rereadIndex,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      visibility: data.visibility.present
          ? data.visibility.value
          : this.visibility,
      shareToFeed: data.shareToFeed.present
          ? data.shareToFeed.value
          : this.shareToFeed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSessionRow(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('bookId: $bookId, ')
          ..write('seriesId: $seriesId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('activeSeconds: $activeSeconds, ')
          ..write('startPage: $startPage, ')
          ..write('endPage: $endPage, ')
          ..write('pagesRead: $pagesRead, ')
          ..write('isCompletion: $isCompletion, ')
          ..write('rereadIndex: $rereadIndex, ')
          ..write('deviceId: $deviceId, ')
          ..write('visibility: $visibility, ')
          ..write('shareToFeed: $shareToFeed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceId,
    bookId,
    seriesId,
    startedAt,
    endedAt,
    activeSeconds,
    startPage,
    endPage,
    pagesRead,
    isCompletion,
    rereadIndex,
    deviceId,
    visibility,
    shareToFeed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingSessionRow &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.bookId == this.bookId &&
          other.seriesId == this.seriesId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.activeSeconds == this.activeSeconds &&
          other.startPage == this.startPage &&
          other.endPage == this.endPage &&
          other.pagesRead == this.pagesRead &&
          other.isCompletion == this.isCompletion &&
          other.rereadIndex == this.rereadIndex &&
          other.deviceId == this.deviceId &&
          other.visibility == this.visibility &&
          other.shareToFeed == this.shareToFeed);
}

class ReadingSessionsCompanion extends UpdateCompanion<ReadingSessionRow> {
  final Value<String> id;
  final Value<String> sourceId;
  final Value<String> bookId;
  final Value<String> seriesId;
  final Value<int> startedAt;
  final Value<int> endedAt;
  final Value<int> activeSeconds;
  final Value<int> startPage;
  final Value<int> endPage;
  final Value<int> pagesRead;
  final Value<bool> isCompletion;
  final Value<int> rereadIndex;
  final Value<String> deviceId;
  final Value<String> visibility;
  final Value<bool> shareToFeed;
  final Value<int> rowid;
  const ReadingSessionsCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.bookId = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.activeSeconds = const Value.absent(),
    this.startPage = const Value.absent(),
    this.endPage = const Value.absent(),
    this.pagesRead = const Value.absent(),
    this.isCompletion = const Value.absent(),
    this.rereadIndex = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.visibility = const Value.absent(),
    this.shareToFeed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingSessionsCompanion.insert({
    required String id,
    required String sourceId,
    required String bookId,
    required String seriesId,
    required int startedAt,
    required int endedAt,
    required int activeSeconds,
    required int startPage,
    required int endPage,
    required int pagesRead,
    this.isCompletion = const Value.absent(),
    this.rereadIndex = const Value.absent(),
    required String deviceId,
    this.visibility = const Value.absent(),
    this.shareToFeed = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceId = Value(sourceId),
       bookId = Value(bookId),
       seriesId = Value(seriesId),
       startedAt = Value(startedAt),
       endedAt = Value(endedAt),
       activeSeconds = Value(activeSeconds),
       startPage = Value(startPage),
       endPage = Value(endPage),
       pagesRead = Value(pagesRead),
       deviceId = Value(deviceId);
  static Insertable<ReadingSessionRow> custom({
    Expression<String>? id,
    Expression<String>? sourceId,
    Expression<String>? bookId,
    Expression<String>? seriesId,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<int>? activeSeconds,
    Expression<int>? startPage,
    Expression<int>? endPage,
    Expression<int>? pagesRead,
    Expression<bool>? isCompletion,
    Expression<int>? rereadIndex,
    Expression<String>? deviceId,
    Expression<String>? visibility,
    Expression<bool>? shareToFeed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (bookId != null) 'book_id': bookId,
      if (seriesId != null) 'series_id': seriesId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (activeSeconds != null) 'active_seconds': activeSeconds,
      if (startPage != null) 'start_page': startPage,
      if (endPage != null) 'end_page': endPage,
      if (pagesRead != null) 'pages_read': pagesRead,
      if (isCompletion != null) 'is_completion': isCompletion,
      if (rereadIndex != null) 'reread_index': rereadIndex,
      if (deviceId != null) 'device_id': deviceId,
      if (visibility != null) 'visibility': visibility,
      if (shareToFeed != null) 'share_to_feed': shareToFeed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceId,
    Value<String>? bookId,
    Value<String>? seriesId,
    Value<int>? startedAt,
    Value<int>? endedAt,
    Value<int>? activeSeconds,
    Value<int>? startPage,
    Value<int>? endPage,
    Value<int>? pagesRead,
    Value<bool>? isCompletion,
    Value<int>? rereadIndex,
    Value<String>? deviceId,
    Value<String>? visibility,
    Value<bool>? shareToFeed,
    Value<int>? rowid,
  }) {
    return ReadingSessionsCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      bookId: bookId ?? this.bookId,
      seriesId: seriesId ?? this.seriesId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      activeSeconds: activeSeconds ?? this.activeSeconds,
      startPage: startPage ?? this.startPage,
      endPage: endPage ?? this.endPage,
      pagesRead: pagesRead ?? this.pagesRead,
      isCompletion: isCompletion ?? this.isCompletion,
      rereadIndex: rereadIndex ?? this.rereadIndex,
      deviceId: deviceId ?? this.deviceId,
      visibility: visibility ?? this.visibility,
      shareToFeed: shareToFeed ?? this.shareToFeed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (activeSeconds.present) {
      map['active_seconds'] = Variable<int>(activeSeconds.value);
    }
    if (startPage.present) {
      map['start_page'] = Variable<int>(startPage.value);
    }
    if (endPage.present) {
      map['end_page'] = Variable<int>(endPage.value);
    }
    if (pagesRead.present) {
      map['pages_read'] = Variable<int>(pagesRead.value);
    }
    if (isCompletion.present) {
      map['is_completion'] = Variable<bool>(isCompletion.value);
    }
    if (rereadIndex.present) {
      map['reread_index'] = Variable<int>(rereadIndex.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<String>(visibility.value);
    }
    if (shareToFeed.present) {
      map['share_to_feed'] = Variable<bool>(shareToFeed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSessionsCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('bookId: $bookId, ')
          ..write('seriesId: $seriesId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('activeSeconds: $activeSeconds, ')
          ..write('startPage: $startPage, ')
          ..write('endPage: $endPage, ')
          ..write('pagesRead: $pagesRead, ')
          ..write('isCompletion: $isCompletion, ')
          ..write('rereadIndex: $rereadIndex, ')
          ..write('deviceId: $deviceId, ')
          ..write('visibility: $visibility, ')
          ..write('shareToFeed: $shareToFeed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
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
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _queuedAtMeta = const VerificationMeta(
    'queuedAt',
  );
  @override
  late final GeneratedColumn<int> queuedAt = GeneratedColumn<int>(
    'queued_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
    'op',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('progress'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    bookId,
    page,
    completed,
    queuedAt,
    attempts,
    state,
    op,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('queued_at')) {
      context.handle(
        _queuedAtMeta,
        queuedAt.isAcceptableOrUnknown(data['queued_at']!, _queuedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_queuedAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      queuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}queued_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueRow extends DataClass implements Insertable<SyncQueueRow> {
  final int id;
  final String sourceId;
  final String bookId;
  final int page;
  final bool completed;
  final int queuedAt;
  final int attempts;
  final String state;
  final String op;
  const SyncQueueRow({
    required this.id,
    required this.sourceId,
    required this.bookId,
    required this.page,
    required this.completed,
    required this.queuedAt,
    required this.attempts,
    required this.state,
    required this.op,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_id'] = Variable<String>(sourceId);
    map['book_id'] = Variable<String>(bookId);
    map['page'] = Variable<int>(page);
    map['completed'] = Variable<bool>(completed);
    map['queued_at'] = Variable<int>(queuedAt);
    map['attempts'] = Variable<int>(attempts);
    map['state'] = Variable<String>(state);
    map['op'] = Variable<String>(op);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      bookId: Value(bookId),
      page: Value(page),
      completed: Value(completed),
      queuedAt: Value(queuedAt),
      attempts: Value(attempts),
      state: Value(state),
      op: Value(op),
    );
  }

  factory SyncQueueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueRow(
      id: serializer.fromJson<int>(json['id']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      bookId: serializer.fromJson<String>(json['bookId']),
      page: serializer.fromJson<int>(json['page']),
      completed: serializer.fromJson<bool>(json['completed']),
      queuedAt: serializer.fromJson<int>(json['queuedAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      state: serializer.fromJson<String>(json['state']),
      op: serializer.fromJson<String>(json['op']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceId': serializer.toJson<String>(sourceId),
      'bookId': serializer.toJson<String>(bookId),
      'page': serializer.toJson<int>(page),
      'completed': serializer.toJson<bool>(completed),
      'queuedAt': serializer.toJson<int>(queuedAt),
      'attempts': serializer.toJson<int>(attempts),
      'state': serializer.toJson<String>(state),
      'op': serializer.toJson<String>(op),
    };
  }

  SyncQueueRow copyWith({
    int? id,
    String? sourceId,
    String? bookId,
    int? page,
    bool? completed,
    int? queuedAt,
    int? attempts,
    String? state,
    String? op,
  }) => SyncQueueRow(
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    bookId: bookId ?? this.bookId,
    page: page ?? this.page,
    completed: completed ?? this.completed,
    queuedAt: queuedAt ?? this.queuedAt,
    attempts: attempts ?? this.attempts,
    state: state ?? this.state,
    op: op ?? this.op,
  );
  SyncQueueRow copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueRow(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      page: data.page.present ? data.page.value : this.page,
      completed: data.completed.present ? data.completed.value : this.completed,
      queuedAt: data.queuedAt.present ? data.queuedAt.value : this.queuedAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      state: data.state.present ? data.state.value : this.state,
      op: data.op.present ? data.op.value : this.op,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueRow(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('bookId: $bookId, ')
          ..write('page: $page, ')
          ..write('completed: $completed, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('attempts: $attempts, ')
          ..write('state: $state, ')
          ..write('op: $op')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceId,
    bookId,
    page,
    completed,
    queuedAt,
    attempts,
    state,
    op,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueRow &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.bookId == this.bookId &&
          other.page == this.page &&
          other.completed == this.completed &&
          other.queuedAt == this.queuedAt &&
          other.attempts == this.attempts &&
          other.state == this.state &&
          other.op == this.op);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueRow> {
  final Value<int> id;
  final Value<String> sourceId;
  final Value<String> bookId;
  final Value<int> page;
  final Value<bool> completed;
  final Value<int> queuedAt;
  final Value<int> attempts;
  final Value<String> state;
  final Value<String> op;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.bookId = const Value.absent(),
    this.page = const Value.absent(),
    this.completed = const Value.absent(),
    this.queuedAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.state = const Value.absent(),
    this.op = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String sourceId,
    required String bookId,
    required int page,
    this.completed = const Value.absent(),
    required int queuedAt,
    this.attempts = const Value.absent(),
    this.state = const Value.absent(),
    this.op = const Value.absent(),
  }) : sourceId = Value(sourceId),
       bookId = Value(bookId),
       page = Value(page),
       queuedAt = Value(queuedAt);
  static Insertable<SyncQueueRow> custom({
    Expression<int>? id,
    Expression<String>? sourceId,
    Expression<String>? bookId,
    Expression<int>? page,
    Expression<bool>? completed,
    Expression<int>? queuedAt,
    Expression<int>? attempts,
    Expression<String>? state,
    Expression<String>? op,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (bookId != null) 'book_id': bookId,
      if (page != null) 'page': page,
      if (completed != null) 'completed': completed,
      if (queuedAt != null) 'queued_at': queuedAt,
      if (attempts != null) 'attempts': attempts,
      if (state != null) 'state': state,
      if (op != null) 'op': op,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? sourceId,
    Value<String>? bookId,
    Value<int>? page,
    Value<bool>? completed,
    Value<int>? queuedAt,
    Value<int>? attempts,
    Value<String>? state,
    Value<String>? op,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      bookId: bookId ?? this.bookId,
      page: page ?? this.page,
      completed: completed ?? this.completed,
      queuedAt: queuedAt ?? this.queuedAt,
      attempts: attempts ?? this.attempts,
      state: state ?? this.state,
      op: op ?? this.op,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (queuedAt.present) {
      map['queued_at'] = Variable<int>(queuedAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('bookId: $bookId, ')
          ..write('page: $page, ')
          ..write('completed: $completed, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('attempts: $attempts, ')
          ..write('state: $state, ')
          ..write('op: $op')
          ..write(')'))
        .toString();
  }
}

class $SeriesMetaTable extends SeriesMeta
    with TableInfo<$SeriesMetaTable, SeriesMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesMetaTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _publisherMeta = const VerificationMeta(
    'publisher',
  );
  @override
  late final GeneratedColumn<String> publisher = GeneratedColumn<String>(
    'publisher',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genresMeta = const VerificationMeta('genres');
  @override
  late final GeneratedColumn<String> genres = GeneratedColumn<String>(
    'genres',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceId,
    seriesId,
    publisher,
    genres,
    rating,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeriesMetaRow> instance, {
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
    if (data.containsKey('publisher')) {
      context.handle(
        _publisherMeta,
        publisher.isAcceptableOrUnknown(data['publisher']!, _publisherMeta),
      );
    }
    if (data.containsKey('genres')) {
      context.handle(
        _genresMeta,
        genres.isAcceptableOrUnknown(data['genres']!, _genresMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, seriesId};
  @override
  SeriesMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesMetaRow(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      )!,
      publisher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}publisher'],
      ),
      genres: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genres'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
    );
  }

  @override
  $SeriesMetaTable createAlias(String alias) {
    return $SeriesMetaTable(attachedDatabase, alias);
  }
}

class SeriesMetaRow extends DataClass implements Insertable<SeriesMetaRow> {
  final String sourceId;
  final String seriesId;
  final String? publisher;

  /// JSON-encoded `List<String>` of genres (tag-overlap breakdown).
  final String? genres;

  /// The user's local star rating for the series (T3). Komga exposes no
  /// user-rating endpoint, so this is a device-only mirror. Preserved across
  /// series re-syncs because `seriesMetaToRow` never writes it (the
  /// insertOnConflictUpdate update set omits the absent column).
  final int? rating;
  const SeriesMetaRow({
    required this.sourceId,
    required this.seriesId,
    this.publisher,
    this.genres,
    this.rating,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['series_id'] = Variable<String>(seriesId);
    if (!nullToAbsent || publisher != null) {
      map['publisher'] = Variable<String>(publisher);
    }
    if (!nullToAbsent || genres != null) {
      map['genres'] = Variable<String>(genres);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    return map;
  }

  SeriesMetaCompanion toCompanion(bool nullToAbsent) {
    return SeriesMetaCompanion(
      sourceId: Value(sourceId),
      seriesId: Value(seriesId),
      publisher: publisher == null && nullToAbsent
          ? const Value.absent()
          : Value(publisher),
      genres: genres == null && nullToAbsent
          ? const Value.absent()
          : Value(genres),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
    );
  }

  factory SeriesMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesMetaRow(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      seriesId: serializer.fromJson<String>(json['seriesId']),
      publisher: serializer.fromJson<String?>(json['publisher']),
      genres: serializer.fromJson<String?>(json['genres']),
      rating: serializer.fromJson<int?>(json['rating']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'seriesId': serializer.toJson<String>(seriesId),
      'publisher': serializer.toJson<String?>(publisher),
      'genres': serializer.toJson<String?>(genres),
      'rating': serializer.toJson<int?>(rating),
    };
  }

  SeriesMetaRow copyWith({
    String? sourceId,
    String? seriesId,
    Value<String?> publisher = const Value.absent(),
    Value<String?> genres = const Value.absent(),
    Value<int?> rating = const Value.absent(),
  }) => SeriesMetaRow(
    sourceId: sourceId ?? this.sourceId,
    seriesId: seriesId ?? this.seriesId,
    publisher: publisher.present ? publisher.value : this.publisher,
    genres: genres.present ? genres.value : this.genres,
    rating: rating.present ? rating.value : this.rating,
  );
  SeriesMetaRow copyWithCompanion(SeriesMetaCompanion data) {
    return SeriesMetaRow(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      publisher: data.publisher.present ? data.publisher.value : this.publisher,
      genres: data.genres.present ? data.genres.value : this.genres,
      rating: data.rating.present ? data.rating.value : this.rating,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesMetaRow(')
          ..write('sourceId: $sourceId, ')
          ..write('seriesId: $seriesId, ')
          ..write('publisher: $publisher, ')
          ..write('genres: $genres, ')
          ..write('rating: $rating')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(sourceId, seriesId, publisher, genres, rating);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesMetaRow &&
          other.sourceId == this.sourceId &&
          other.seriesId == this.seriesId &&
          other.publisher == this.publisher &&
          other.genres == this.genres &&
          other.rating == this.rating);
}

class SeriesMetaCompanion extends UpdateCompanion<SeriesMetaRow> {
  final Value<String> sourceId;
  final Value<String> seriesId;
  final Value<String?> publisher;
  final Value<String?> genres;
  final Value<int?> rating;
  final Value<int> rowid;
  const SeriesMetaCompanion({
    this.sourceId = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.publisher = const Value.absent(),
    this.genres = const Value.absent(),
    this.rating = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeriesMetaCompanion.insert({
    required String sourceId,
    required String seriesId,
    this.publisher = const Value.absent(),
    this.genres = const Value.absent(),
    this.rating = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       seriesId = Value(seriesId);
  static Insertable<SeriesMetaRow> custom({
    Expression<String>? sourceId,
    Expression<String>? seriesId,
    Expression<String>? publisher,
    Expression<String>? genres,
    Expression<int>? rating,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (seriesId != null) 'series_id': seriesId,
      if (publisher != null) 'publisher': publisher,
      if (genres != null) 'genres': genres,
      if (rating != null) 'rating': rating,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeriesMetaCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? seriesId,
    Value<String?>? publisher,
    Value<String?>? genres,
    Value<int?>? rating,
    Value<int>? rowid,
  }) {
    return SeriesMetaCompanion(
      sourceId: sourceId ?? this.sourceId,
      seriesId: seriesId ?? this.seriesId,
      publisher: publisher ?? this.publisher,
      genres: genres ?? this.genres,
      rating: rating ?? this.rating,
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
    if (publisher.present) {
      map['publisher'] = Variable<String>(publisher.value);
    }
    if (genres.present) {
      map['genres'] = Variable<String>(genres.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesMetaCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('seriesId: $seriesId, ')
          ..write('publisher: $publisher, ')
          ..write('genres: $genres, ')
          ..write('rating: $rating, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ColorSettingsTable extends ColorSettings
    with TableInfo<$ColorSettingsTable, ColorSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ColorSettingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeIdMeta = const VerificationMeta(
    'scopeId',
  );
  @override
  late final GeneratedColumn<String> scopeId = GeneratedColumn<String>(
    'scope_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _brightnessMeta = const VerificationMeta(
    'brightness',
  );
  @override
  late final GeneratedColumn<double> brightness = GeneratedColumn<double>(
    'brightness',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _contrastMeta = const VerificationMeta(
    'contrast',
  );
  @override
  late final GeneratedColumn<double> contrast = GeneratedColumn<double>(
    'contrast',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _gammaMeta = const VerificationMeta('gamma');
  @override
  late final GeneratedColumn<double> gamma = GeneratedColumn<double>(
    'gamma',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _autoLevelsMeta = const VerificationMeta(
    'autoLevels',
  );
  @override
  late final GeneratedColumn<bool> autoLevels = GeneratedColumn<bool>(
    'auto_levels',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_levels" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceId,
    scope,
    scopeId,
    enabled,
    brightness,
    contrast,
    gamma,
    mode,
    autoLevels,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'color_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ColorSettingsRow> instance, {
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
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('scope_id')) {
      context.handle(
        _scopeIdMeta,
        scopeId.isAcceptableOrUnknown(data['scope_id']!, _scopeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeIdMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('brightness')) {
      context.handle(
        _brightnessMeta,
        brightness.isAcceptableOrUnknown(data['brightness']!, _brightnessMeta),
      );
    }
    if (data.containsKey('contrast')) {
      context.handle(
        _contrastMeta,
        contrast.isAcceptableOrUnknown(data['contrast']!, _contrastMeta),
      );
    }
    if (data.containsKey('gamma')) {
      context.handle(
        _gammaMeta,
        gamma.isAcceptableOrUnknown(data['gamma']!, _gammaMeta),
      );
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('auto_levels')) {
      context.handle(
        _autoLevelsMeta,
        autoLevels.isAcceptableOrUnknown(data['auto_levels']!, _autoLevelsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, scope, scopeId};
  @override
  ColorSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ColorSettingsRow(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      scopeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_id'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      brightness: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}brightness'],
      )!,
      contrast: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}contrast'],
      )!,
      gamma: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gamma'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      autoLevels: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_levels'],
      )!,
    );
  }

  @override
  $ColorSettingsTable createAlias(String alias) {
    return $ColorSettingsTable(attachedDatabase, alias);
  }
}

class ColorSettingsRow extends DataClass
    implements Insertable<ColorSettingsRow> {
  /// FK to `Sources.id` (empty string for the app-wide `global` row).
  final String sourceId;

  /// `ColorScopeKind.name`: `global` | `series` | `book`.
  final String scope;

  /// The owning id for the scope: empty for global, seriesId for series,
  /// bookId for book.
  final String scopeId;

  /// Whether correction is enabled at this scope. Persisted per scope so the
  /// user can independently toggle global / series / chapter. A disabled
  /// most-specific row acts as an explicit "no correction here" override.
  final bool enabled;
  final double brightness;
  final double contrast;
  final double gamma;
  final String mode;
  final bool autoLevels;
  const ColorSettingsRow({
    required this.sourceId,
    required this.scope,
    required this.scopeId,
    required this.enabled,
    required this.brightness,
    required this.contrast,
    required this.gamma,
    required this.mode,
    required this.autoLevels,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['scope'] = Variable<String>(scope);
    map['scope_id'] = Variable<String>(scopeId);
    map['enabled'] = Variable<bool>(enabled);
    map['brightness'] = Variable<double>(brightness);
    map['contrast'] = Variable<double>(contrast);
    map['gamma'] = Variable<double>(gamma);
    map['mode'] = Variable<String>(mode);
    map['auto_levels'] = Variable<bool>(autoLevels);
    return map;
  }

  ColorSettingsCompanion toCompanion(bool nullToAbsent) {
    return ColorSettingsCompanion(
      sourceId: Value(sourceId),
      scope: Value(scope),
      scopeId: Value(scopeId),
      enabled: Value(enabled),
      brightness: Value(brightness),
      contrast: Value(contrast),
      gamma: Value(gamma),
      mode: Value(mode),
      autoLevels: Value(autoLevels),
    );
  }

  factory ColorSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ColorSettingsRow(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      scope: serializer.fromJson<String>(json['scope']),
      scopeId: serializer.fromJson<String>(json['scopeId']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      brightness: serializer.fromJson<double>(json['brightness']),
      contrast: serializer.fromJson<double>(json['contrast']),
      gamma: serializer.fromJson<double>(json['gamma']),
      mode: serializer.fromJson<String>(json['mode']),
      autoLevels: serializer.fromJson<bool>(json['autoLevels']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'scope': serializer.toJson<String>(scope),
      'scopeId': serializer.toJson<String>(scopeId),
      'enabled': serializer.toJson<bool>(enabled),
      'brightness': serializer.toJson<double>(brightness),
      'contrast': serializer.toJson<double>(contrast),
      'gamma': serializer.toJson<double>(gamma),
      'mode': serializer.toJson<String>(mode),
      'autoLevels': serializer.toJson<bool>(autoLevels),
    };
  }

  ColorSettingsRow copyWith({
    String? sourceId,
    String? scope,
    String? scopeId,
    bool? enabled,
    double? brightness,
    double? contrast,
    double? gamma,
    String? mode,
    bool? autoLevels,
  }) => ColorSettingsRow(
    sourceId: sourceId ?? this.sourceId,
    scope: scope ?? this.scope,
    scopeId: scopeId ?? this.scopeId,
    enabled: enabled ?? this.enabled,
    brightness: brightness ?? this.brightness,
    contrast: contrast ?? this.contrast,
    gamma: gamma ?? this.gamma,
    mode: mode ?? this.mode,
    autoLevels: autoLevels ?? this.autoLevels,
  );
  ColorSettingsRow copyWithCompanion(ColorSettingsCompanion data) {
    return ColorSettingsRow(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      scope: data.scope.present ? data.scope.value : this.scope,
      scopeId: data.scopeId.present ? data.scopeId.value : this.scopeId,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      brightness: data.brightness.present
          ? data.brightness.value
          : this.brightness,
      contrast: data.contrast.present ? data.contrast.value : this.contrast,
      gamma: data.gamma.present ? data.gamma.value : this.gamma,
      mode: data.mode.present ? data.mode.value : this.mode,
      autoLevels: data.autoLevels.present
          ? data.autoLevels.value
          : this.autoLevels,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ColorSettingsRow(')
          ..write('sourceId: $sourceId, ')
          ..write('scope: $scope, ')
          ..write('scopeId: $scopeId, ')
          ..write('enabled: $enabled, ')
          ..write('brightness: $brightness, ')
          ..write('contrast: $contrast, ')
          ..write('gamma: $gamma, ')
          ..write('mode: $mode, ')
          ..write('autoLevels: $autoLevels')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sourceId,
    scope,
    scopeId,
    enabled,
    brightness,
    contrast,
    gamma,
    mode,
    autoLevels,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ColorSettingsRow &&
          other.sourceId == this.sourceId &&
          other.scope == this.scope &&
          other.scopeId == this.scopeId &&
          other.enabled == this.enabled &&
          other.brightness == this.brightness &&
          other.contrast == this.contrast &&
          other.gamma == this.gamma &&
          other.mode == this.mode &&
          other.autoLevels == this.autoLevels);
}

class ColorSettingsCompanion extends UpdateCompanion<ColorSettingsRow> {
  final Value<String> sourceId;
  final Value<String> scope;
  final Value<String> scopeId;
  final Value<bool> enabled;
  final Value<double> brightness;
  final Value<double> contrast;
  final Value<double> gamma;
  final Value<String> mode;
  final Value<bool> autoLevels;
  final Value<int> rowid;
  const ColorSettingsCompanion({
    this.sourceId = const Value.absent(),
    this.scope = const Value.absent(),
    this.scopeId = const Value.absent(),
    this.enabled = const Value.absent(),
    this.brightness = const Value.absent(),
    this.contrast = const Value.absent(),
    this.gamma = const Value.absent(),
    this.mode = const Value.absent(),
    this.autoLevels = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ColorSettingsCompanion.insert({
    required String sourceId,
    required String scope,
    required String scopeId,
    this.enabled = const Value.absent(),
    this.brightness = const Value.absent(),
    this.contrast = const Value.absent(),
    this.gamma = const Value.absent(),
    this.mode = const Value.absent(),
    this.autoLevels = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       scope = Value(scope),
       scopeId = Value(scopeId);
  static Insertable<ColorSettingsRow> custom({
    Expression<String>? sourceId,
    Expression<String>? scope,
    Expression<String>? scopeId,
    Expression<bool>? enabled,
    Expression<double>? brightness,
    Expression<double>? contrast,
    Expression<double>? gamma,
    Expression<String>? mode,
    Expression<bool>? autoLevels,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (scope != null) 'scope': scope,
      if (scopeId != null) 'scope_id': scopeId,
      if (enabled != null) 'enabled': enabled,
      if (brightness != null) 'brightness': brightness,
      if (contrast != null) 'contrast': contrast,
      if (gamma != null) 'gamma': gamma,
      if (mode != null) 'mode': mode,
      if (autoLevels != null) 'auto_levels': autoLevels,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ColorSettingsCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? scope,
    Value<String>? scopeId,
    Value<bool>? enabled,
    Value<double>? brightness,
    Value<double>? contrast,
    Value<double>? gamma,
    Value<String>? mode,
    Value<bool>? autoLevels,
    Value<int>? rowid,
  }) {
    return ColorSettingsCompanion(
      sourceId: sourceId ?? this.sourceId,
      scope: scope ?? this.scope,
      scopeId: scopeId ?? this.scopeId,
      enabled: enabled ?? this.enabled,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      gamma: gamma ?? this.gamma,
      mode: mode ?? this.mode,
      autoLevels: autoLevels ?? this.autoLevels,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (scopeId.present) {
      map['scope_id'] = Variable<String>(scopeId.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (brightness.present) {
      map['brightness'] = Variable<double>(brightness.value);
    }
    if (contrast.present) {
      map['contrast'] = Variable<double>(contrast.value);
    }
    if (gamma.present) {
      map['gamma'] = Variable<double>(gamma.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (autoLevels.present) {
      map['auto_levels'] = Variable<bool>(autoLevels.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ColorSettingsCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('scope: $scope, ')
          ..write('scopeId: $scopeId, ')
          ..write('enabled: $enabled, ')
          ..write('brightness: $brightness, ')
          ..write('contrast: $contrast, ')
          ..write('gamma: $gamma, ')
          ..write('mode: $mode, ')
          ..write('autoLevels: $autoLevels, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PinsTable extends Pins with TableInfo<$PinsTable, PinRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PinsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _pinnedAtMeta = const VerificationMeta(
    'pinnedAt',
  );
  @override
  late final GeneratedColumn<int> pinnedAt = GeneratedColumn<int>(
    'pinned_at',
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
    pinnedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pins';
  @override
  VerificationContext validateIntegrity(
    Insertable<PinRow> instance, {
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
    if (data.containsKey('pinned_at')) {
      context.handle(
        _pinnedAtMeta,
        pinnedAt.isAcceptableOrUnknown(data['pinned_at']!, _pinnedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_pinnedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, ownerType, ownerId};
  @override
  PinRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PinRow(
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
      pinnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pinned_at'],
      )!,
    );
  }

  @override
  $PinsTable createAlias(String alias) {
    return $PinsTable(attachedDatabase, alias);
  }
}

class PinRow extends DataClass implements Insertable<PinRow> {
  /// FK to `Sources.id`.
  final String sourceId;

  /// `series` or `book`.
  final String ownerType;

  /// The series id or book id, per [ownerType].
  final String ownerId;

  /// When the pin was created (epoch ms); the rail orders newest first.
  final int pinnedAt;
  const PinRow({
    required this.sourceId,
    required this.ownerType,
    required this.ownerId,
    required this.pinnedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['owner_type'] = Variable<String>(ownerType);
    map['owner_id'] = Variable<String>(ownerId);
    map['pinned_at'] = Variable<int>(pinnedAt);
    return map;
  }

  PinsCompanion toCompanion(bool nullToAbsent) {
    return PinsCompanion(
      sourceId: Value(sourceId),
      ownerType: Value(ownerType),
      ownerId: Value(ownerId),
      pinnedAt: Value(pinnedAt),
    );
  }

  factory PinRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PinRow(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      ownerType: serializer.fromJson<String>(json['ownerType']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      pinnedAt: serializer.fromJson<int>(json['pinnedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'ownerType': serializer.toJson<String>(ownerType),
      'ownerId': serializer.toJson<String>(ownerId),
      'pinnedAt': serializer.toJson<int>(pinnedAt),
    };
  }

  PinRow copyWith({
    String? sourceId,
    String? ownerType,
    String? ownerId,
    int? pinnedAt,
  }) => PinRow(
    sourceId: sourceId ?? this.sourceId,
    ownerType: ownerType ?? this.ownerType,
    ownerId: ownerId ?? this.ownerId,
    pinnedAt: pinnedAt ?? this.pinnedAt,
  );
  PinRow copyWithCompanion(PinsCompanion data) {
    return PinRow(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      ownerType: data.ownerType.present ? data.ownerType.value : this.ownerType,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      pinnedAt: data.pinnedAt.present ? data.pinnedAt.value : this.pinnedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PinRow(')
          ..write('sourceId: $sourceId, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('pinnedAt: $pinnedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sourceId, ownerType, ownerId, pinnedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PinRow &&
          other.sourceId == this.sourceId &&
          other.ownerType == this.ownerType &&
          other.ownerId == this.ownerId &&
          other.pinnedAt == this.pinnedAt);
}

class PinsCompanion extends UpdateCompanion<PinRow> {
  final Value<String> sourceId;
  final Value<String> ownerType;
  final Value<String> ownerId;
  final Value<int> pinnedAt;
  final Value<int> rowid;
  const PinsCompanion({
    this.sourceId = const Value.absent(),
    this.ownerType = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.pinnedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PinsCompanion.insert({
    required String sourceId,
    required String ownerType,
    required String ownerId,
    required int pinnedAt,
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       ownerType = Value(ownerType),
       ownerId = Value(ownerId),
       pinnedAt = Value(pinnedAt);
  static Insertable<PinRow> custom({
    Expression<String>? sourceId,
    Expression<String>? ownerType,
    Expression<String>? ownerId,
    Expression<int>? pinnedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (ownerType != null) 'owner_type': ownerType,
      if (ownerId != null) 'owner_id': ownerId,
      if (pinnedAt != null) 'pinned_at': pinnedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PinsCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? ownerType,
    Value<String>? ownerId,
    Value<int>? pinnedAt,
    Value<int>? rowid,
  }) {
    return PinsCompanion(
      sourceId: sourceId ?? this.sourceId,
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      pinnedAt: pinnedAt ?? this.pinnedAt,
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
    if (pinnedAt.present) {
      map['pinned_at'] = Variable<int>(pinnedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PinsCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('pinnedAt: $pinnedAt, ')
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
  late final $CachedAssetsTable cachedAssets = $CachedAssetsTable(this);
  late final $DownloadTasksTable downloadTasks = $DownloadTasksTable(this);
  late final $BookStateTable bookState = $BookStateTable(this);
  late final $ReadingSessionsTable readingSessions = $ReadingSessionsTable(
    this,
  );
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $SeriesMetaTable seriesMeta = $SeriesMetaTable(this);
  late final $ColorSettingsTable colorSettings = $ColorSettingsTable(this);
  late final $PinsTable pins = $PinsTable(this);
  late final Index seriesKeyset = Index(
    'series_keyset',
    'CREATE INDEX series_keyset ON series (source_id, title_sort, id)',
  );
  late final Index seriesKeysetLib = Index(
    'series_keyset_lib',
    'CREATE INDEX series_keyset_lib ON series (source_id, library_id, title_sort, id)',
  );
  late final Index cachedAssetsLru = Index(
    'cached_assets_lru',
    'CREATE INDEX cached_assets_lru ON cached_assets (last_accessed_at)',
  );
  late final Index syncQueueBook = Index(
    'sync_queue_book',
    'CREATE UNIQUE INDEX sync_queue_book ON sync_queue (source_id, book_id)',
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
    cachedAssets,
    downloadTasks,
    bookState,
    readingSessions,
    syncQueue,
    seriesMeta,
    colorSettings,
    pins,
    seriesKeyset,
    seriesKeysetLib,
    cachedAssetsLru,
    syncQueueBook,
  ];
}

typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> themeMode,
      Value<bool> reduceMotionOverride,
      Value<int> cacheCapBytes,
      Value<bool> autoCacheEnabled,
      Value<bool> downloadWifiOnly,
      Value<String?> deviceId,
      Value<bool> imageQualitySmart,
      Value<int> imageQualityManualLevel,
      Value<String?> homeLayout,
      Value<bool?> deleteOnRead,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> themeMode,
      Value<bool> reduceMotionOverride,
      Value<int> cacheCapBytes,
      Value<bool> autoCacheEnabled,
      Value<bool> downloadWifiOnly,
      Value<String?> deviceId,
      Value<bool> imageQualitySmart,
      Value<int> imageQualityManualLevel,
      Value<String?> homeLayout,
      Value<bool?> deleteOnRead,
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

  ColumnFilters<bool> get autoCacheEnabled => $composableBuilder(
    column: $table.autoCacheEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get downloadWifiOnly => $composableBuilder(
    column: $table.downloadWifiOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get imageQualitySmart => $composableBuilder(
    column: $table.imageQualitySmart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get imageQualityManualLevel => $composableBuilder(
    column: $table.imageQualityManualLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeLayout => $composableBuilder(
    column: $table.homeLayout,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleteOnRead => $composableBuilder(
    column: $table.deleteOnRead,
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

  ColumnOrderings<bool> get autoCacheEnabled => $composableBuilder(
    column: $table.autoCacheEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get downloadWifiOnly => $composableBuilder(
    column: $table.downloadWifiOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get imageQualitySmart => $composableBuilder(
    column: $table.imageQualitySmart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get imageQualityManualLevel => $composableBuilder(
    column: $table.imageQualityManualLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeLayout => $composableBuilder(
    column: $table.homeLayout,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleteOnRead => $composableBuilder(
    column: $table.deleteOnRead,
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

  GeneratedColumn<bool> get autoCacheEnabled => $composableBuilder(
    column: $table.autoCacheEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get downloadWifiOnly => $composableBuilder(
    column: $table.downloadWifiOnly,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get imageQualitySmart => $composableBuilder(
    column: $table.imageQualitySmart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get imageQualityManualLevel => $composableBuilder(
    column: $table.imageQualityManualLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get homeLayout => $composableBuilder(
    column: $table.homeLayout,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleteOnRead => $composableBuilder(
    column: $table.deleteOnRead,
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
                Value<bool> autoCacheEnabled = const Value.absent(),
                Value<bool> downloadWifiOnly = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<bool> imageQualitySmart = const Value.absent(),
                Value<int> imageQualityManualLevel = const Value.absent(),
                Value<String?> homeLayout = const Value.absent(),
                Value<bool?> deleteOnRead = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                themeMode: themeMode,
                reduceMotionOverride: reduceMotionOverride,
                cacheCapBytes: cacheCapBytes,
                autoCacheEnabled: autoCacheEnabled,
                downloadWifiOnly: downloadWifiOnly,
                deviceId: deviceId,
                imageQualitySmart: imageQualitySmart,
                imageQualityManualLevel: imageQualityManualLevel,
                homeLayout: homeLayout,
                deleteOnRead: deleteOnRead,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> reduceMotionOverride = const Value.absent(),
                Value<int> cacheCapBytes = const Value.absent(),
                Value<bool> autoCacheEnabled = const Value.absent(),
                Value<bool> downloadWifiOnly = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<bool> imageQualitySmart = const Value.absent(),
                Value<int> imageQualityManualLevel = const Value.absent(),
                Value<String?> homeLayout = const Value.absent(),
                Value<bool?> deleteOnRead = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                themeMode: themeMode,
                reduceMotionOverride: reduceMotionOverride,
                cacheCapBytes: cacheCapBytes,
                autoCacheEnabled: autoCacheEnabled,
                downloadWifiOnly: downloadWifiOnly,
                deviceId: deviceId,
                imageQualitySmart: imageQualitySmart,
                imageQualityManualLevel: imageQualityManualLevel,
                homeLayout: homeLayout,
                deleteOnRead: deleteOnRead,
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
      Value<String> direction,
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
      Value<String> direction,
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

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
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

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
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

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);
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
                Value<String> direction = const Value.absent(),
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
                direction: direction,
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
                Value<String> direction = const Value.absent(),
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
                direction: direction,
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
typedef $$CachedAssetsTableCreateCompanionBuilder =
    CachedAssetsCompanion Function({
      required String sourceId,
      required String bookId,
      Value<String> kind,
      required String relativePath,
      Value<int> sizeBytes,
      Value<String?> sha,
      required int lastAccessedAt,
      Value<bool> pinned,
      Value<bool> permanent,
      Value<int> rowid,
    });
typedef $$CachedAssetsTableUpdateCompanionBuilder =
    CachedAssetsCompanion Function({
      Value<String> sourceId,
      Value<String> bookId,
      Value<String> kind,
      Value<String> relativePath,
      Value<int> sizeBytes,
      Value<String?> sha,
      Value<int> lastAccessedAt,
      Value<bool> pinned,
      Value<bool> permanent,
      Value<int> rowid,
    });

class $$CachedAssetsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedAssetsTable> {
  $$CachedAssetsTableFilterComposer({
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

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha => $composableBuilder(
    column: $table.sha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get permanent => $composableBuilder(
    column: $table.permanent,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedAssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedAssetsTable> {
  $$CachedAssetsTableOrderingComposer({
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

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha => $composableBuilder(
    column: $table.sha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get permanent => $composableBuilder(
    column: $table.permanent,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedAssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedAssetsTable> {
  $$CachedAssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get sha =>
      $composableBuilder(column: $table.sha, builder: (column) => column);

  GeneratedColumn<int> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<bool> get permanent =>
      $composableBuilder(column: $table.permanent, builder: (column) => column);
}

class $$CachedAssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedAssetsTable,
          CachedAsset,
          $$CachedAssetsTableFilterComposer,
          $$CachedAssetsTableOrderingComposer,
          $$CachedAssetsTableAnnotationComposer,
          $$CachedAssetsTableCreateCompanionBuilder,
          $$CachedAssetsTableUpdateCompanionBuilder,
          (
            CachedAsset,
            BaseReferences<_$AppDatabase, $CachedAssetsTable, CachedAsset>,
          ),
          CachedAsset,
          PrefetchHooks Function()
        > {
  $$CachedAssetsTableTableManager(_$AppDatabase db, $CachedAssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String?> sha = const Value.absent(),
                Value<int> lastAccessedAt = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<bool> permanent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedAssetsCompanion(
                sourceId: sourceId,
                bookId: bookId,
                kind: kind,
                relativePath: relativePath,
                sizeBytes: sizeBytes,
                sha: sha,
                lastAccessedAt: lastAccessedAt,
                pinned: pinned,
                permanent: permanent,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String bookId,
                Value<String> kind = const Value.absent(),
                required String relativePath,
                Value<int> sizeBytes = const Value.absent(),
                Value<String?> sha = const Value.absent(),
                required int lastAccessedAt,
                Value<bool> pinned = const Value.absent(),
                Value<bool> permanent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedAssetsCompanion.insert(
                sourceId: sourceId,
                bookId: bookId,
                kind: kind,
                relativePath: relativePath,
                sizeBytes: sizeBytes,
                sha: sha,
                lastAccessedAt: lastAccessedAt,
                pinned: pinned,
                permanent: permanent,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedAssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedAssetsTable,
      CachedAsset,
      $$CachedAssetsTableFilterComposer,
      $$CachedAssetsTableOrderingComposer,
      $$CachedAssetsTableAnnotationComposer,
      $$CachedAssetsTableCreateCompanionBuilder,
      $$CachedAssetsTableUpdateCompanionBuilder,
      (
        CachedAsset,
        BaseReferences<_$AppDatabase, $CachedAssetsTable, CachedAsset>,
      ),
      CachedAsset,
      PrefetchHooks Function()
    >;
typedef $$DownloadTasksTableCreateCompanionBuilder =
    DownloadTasksCompanion Function({
      required String sourceId,
      required String bookId,
      required String taskId,
      Value<String> state,
      Value<int> bytesDownloaded,
      Value<int?> totalBytes,
      Value<bool> requiresWifi,
      Value<bool> permanent,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$DownloadTasksTableUpdateCompanionBuilder =
    DownloadTasksCompanion Function({
      Value<String> sourceId,
      Value<String> bookId,
      Value<String> taskId,
      Value<String> state,
      Value<int> bytesDownloaded,
      Value<int?> totalBytes,
      Value<bool> requiresWifi,
      Value<bool> permanent,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$DownloadTasksTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadTasksTable> {
  $$DownloadTasksTableFilterComposer({
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

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytesDownloaded => $composableBuilder(
    column: $table.bytesDownloaded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requiresWifi => $composableBuilder(
    column: $table.requiresWifi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get permanent => $composableBuilder(
    column: $table.permanent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadTasksTable> {
  $$DownloadTasksTableOrderingComposer({
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

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytesDownloaded => $composableBuilder(
    column: $table.bytesDownloaded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requiresWifi => $composableBuilder(
    column: $table.requiresWifi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get permanent => $composableBuilder(
    column: $table.permanent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadTasksTable> {
  $$DownloadTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get bytesDownloaded => $composableBuilder(
    column: $table.bytesDownloaded,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get requiresWifi => $composableBuilder(
    column: $table.requiresWifi,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get permanent =>
      $composableBuilder(column: $table.permanent, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DownloadTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadTasksTable,
          DownloadTask,
          $$DownloadTasksTableFilterComposer,
          $$DownloadTasksTableOrderingComposer,
          $$DownloadTasksTableAnnotationComposer,
          $$DownloadTasksTableCreateCompanionBuilder,
          $$DownloadTasksTableUpdateCompanionBuilder,
          (
            DownloadTask,
            BaseReferences<_$AppDatabase, $DownloadTasksTable, DownloadTask>,
          ),
          DownloadTask,
          PrefetchHooks Function()
        > {
  $$DownloadTasksTableTableManager(_$AppDatabase db, $DownloadTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> bytesDownloaded = const Value.absent(),
                Value<int?> totalBytes = const Value.absent(),
                Value<bool> requiresWifi = const Value.absent(),
                Value<bool> permanent = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadTasksCompanion(
                sourceId: sourceId,
                bookId: bookId,
                taskId: taskId,
                state: state,
                bytesDownloaded: bytesDownloaded,
                totalBytes: totalBytes,
                requiresWifi: requiresWifi,
                permanent: permanent,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String bookId,
                required String taskId,
                Value<String> state = const Value.absent(),
                Value<int> bytesDownloaded = const Value.absent(),
                Value<int?> totalBytes = const Value.absent(),
                Value<bool> requiresWifi = const Value.absent(),
                Value<bool> permanent = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DownloadTasksCompanion.insert(
                sourceId: sourceId,
                bookId: bookId,
                taskId: taskId,
                state: state,
                bytesDownloaded: bytesDownloaded,
                totalBytes: totalBytes,
                requiresWifi: requiresWifi,
                permanent: permanent,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadTasksTable,
      DownloadTask,
      $$DownloadTasksTableFilterComposer,
      $$DownloadTasksTableOrderingComposer,
      $$DownloadTasksTableAnnotationComposer,
      $$DownloadTasksTableCreateCompanionBuilder,
      $$DownloadTasksTableUpdateCompanionBuilder,
      (
        DownloadTask,
        BaseReferences<_$AppDatabase, $DownloadTasksTable, DownloadTask>,
      ),
      DownloadTask,
      PrefetchHooks Function()
    >;
typedef $$BookStateTableCreateCompanionBuilder =
    BookStateCompanion Function({
      required String sourceId,
      required String bookId,
      Value<String?> status,
      Value<int> currentPage,
      Value<double?> progressVolumes,
      Value<int?> rating,
      Value<int> timesReread,
      Value<bool> isRereading,
      Value<int?> startedAt,
      Value<int?> finishedAt,
      Value<String> visibility,
      Value<bool> shareToFeed,
      required int updatedAt,
      Value<int?> remoteUpdatedAt,
      Value<int?> reconciledAt,
      Value<int> rowid,
    });
typedef $$BookStateTableUpdateCompanionBuilder =
    BookStateCompanion Function({
      Value<String> sourceId,
      Value<String> bookId,
      Value<String?> status,
      Value<int> currentPage,
      Value<double?> progressVolumes,
      Value<int?> rating,
      Value<int> timesReread,
      Value<bool> isRereading,
      Value<int?> startedAt,
      Value<int?> finishedAt,
      Value<String> visibility,
      Value<bool> shareToFeed,
      Value<int> updatedAt,
      Value<int?> remoteUpdatedAt,
      Value<int?> reconciledAt,
      Value<int> rowid,
    });

class $$BookStateTableFilterComposer
    extends Composer<_$AppDatabase, $BookStateTable> {
  $$BookStateTableFilterComposer({
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

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progressVolumes => $composableBuilder(
    column: $table.progressVolumes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timesReread => $composableBuilder(
    column: $table.timesReread,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRereading => $composableBuilder(
    column: $table.isRereading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shareToFeed => $composableBuilder(
    column: $table.shareToFeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reconciledAt => $composableBuilder(
    column: $table.reconciledAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookStateTableOrderingComposer
    extends Composer<_$AppDatabase, $BookStateTable> {
  $$BookStateTableOrderingComposer({
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

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progressVolumes => $composableBuilder(
    column: $table.progressVolumes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesReread => $composableBuilder(
    column: $table.timesReread,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRereading => $composableBuilder(
    column: $table.isRereading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shareToFeed => $composableBuilder(
    column: $table.shareToFeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reconciledAt => $composableBuilder(
    column: $table.reconciledAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookStateTable> {
  $$BookStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get progressVolumes => $composableBuilder(
    column: $table.progressVolumes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get timesReread => $composableBuilder(
    column: $table.timesReread,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRereading => $composableBuilder(
    column: $table.isRereading,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get shareToFeed => $composableBuilder(
    column: $table.shareToFeed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reconciledAt => $composableBuilder(
    column: $table.reconciledAt,
    builder: (column) => column,
  );
}

class $$BookStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookStateTable,
          BookStateRow,
          $$BookStateTableFilterComposer,
          $$BookStateTableOrderingComposer,
          $$BookStateTableAnnotationComposer,
          $$BookStateTableCreateCompanionBuilder,
          $$BookStateTableUpdateCompanionBuilder,
          (
            BookStateRow,
            BaseReferences<_$AppDatabase, $BookStateTable, BookStateRow>,
          ),
          BookStateRow,
          PrefetchHooks Function()
        > {
  $$BookStateTableTableManager(_$AppDatabase db, $BookStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<int> currentPage = const Value.absent(),
                Value<double?> progressVolumes = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<int> timesReread = const Value.absent(),
                Value<bool> isRereading = const Value.absent(),
                Value<int?> startedAt = const Value.absent(),
                Value<int?> finishedAt = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                Value<bool> shareToFeed = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> remoteUpdatedAt = const Value.absent(),
                Value<int?> reconciledAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookStateCompanion(
                sourceId: sourceId,
                bookId: bookId,
                status: status,
                currentPage: currentPage,
                progressVolumes: progressVolumes,
                rating: rating,
                timesReread: timesReread,
                isRereading: isRereading,
                startedAt: startedAt,
                finishedAt: finishedAt,
                visibility: visibility,
                shareToFeed: shareToFeed,
                updatedAt: updatedAt,
                remoteUpdatedAt: remoteUpdatedAt,
                reconciledAt: reconciledAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String bookId,
                Value<String?> status = const Value.absent(),
                Value<int> currentPage = const Value.absent(),
                Value<double?> progressVolumes = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<int> timesReread = const Value.absent(),
                Value<bool> isRereading = const Value.absent(),
                Value<int?> startedAt = const Value.absent(),
                Value<int?> finishedAt = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                Value<bool> shareToFeed = const Value.absent(),
                required int updatedAt,
                Value<int?> remoteUpdatedAt = const Value.absent(),
                Value<int?> reconciledAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookStateCompanion.insert(
                sourceId: sourceId,
                bookId: bookId,
                status: status,
                currentPage: currentPage,
                progressVolumes: progressVolumes,
                rating: rating,
                timesReread: timesReread,
                isRereading: isRereading,
                startedAt: startedAt,
                finishedAt: finishedAt,
                visibility: visibility,
                shareToFeed: shareToFeed,
                updatedAt: updatedAt,
                remoteUpdatedAt: remoteUpdatedAt,
                reconciledAt: reconciledAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookStateTable,
      BookStateRow,
      $$BookStateTableFilterComposer,
      $$BookStateTableOrderingComposer,
      $$BookStateTableAnnotationComposer,
      $$BookStateTableCreateCompanionBuilder,
      $$BookStateTableUpdateCompanionBuilder,
      (
        BookStateRow,
        BaseReferences<_$AppDatabase, $BookStateTable, BookStateRow>,
      ),
      BookStateRow,
      PrefetchHooks Function()
    >;
typedef $$ReadingSessionsTableCreateCompanionBuilder =
    ReadingSessionsCompanion Function({
      required String id,
      required String sourceId,
      required String bookId,
      required String seriesId,
      required int startedAt,
      required int endedAt,
      required int activeSeconds,
      required int startPage,
      required int endPage,
      required int pagesRead,
      Value<bool> isCompletion,
      Value<int> rereadIndex,
      required String deviceId,
      Value<String> visibility,
      Value<bool> shareToFeed,
      Value<int> rowid,
    });
typedef $$ReadingSessionsTableUpdateCompanionBuilder =
    ReadingSessionsCompanion Function({
      Value<String> id,
      Value<String> sourceId,
      Value<String> bookId,
      Value<String> seriesId,
      Value<int> startedAt,
      Value<int> endedAt,
      Value<int> activeSeconds,
      Value<int> startPage,
      Value<int> endPage,
      Value<int> pagesRead,
      Value<bool> isCompletion,
      Value<int> rereadIndex,
      Value<String> deviceId,
      Value<String> visibility,
      Value<bool> shareToFeed,
      Value<int> rowid,
    });

class $$ReadingSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableFilterComposer({
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

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeSeconds => $composableBuilder(
    column: $table.activeSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startPage => $composableBuilder(
    column: $table.startPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endPage => $composableBuilder(
    column: $table.endPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pagesRead => $composableBuilder(
    column: $table.pagesRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompletion => $composableBuilder(
    column: $table.isCompletion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rereadIndex => $composableBuilder(
    column: $table.rereadIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shareToFeed => $composableBuilder(
    column: $table.shareToFeed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeSeconds => $composableBuilder(
    column: $table.activeSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startPage => $composableBuilder(
    column: $table.startPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endPage => $composableBuilder(
    column: $table.endPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pagesRead => $composableBuilder(
    column: $table.pagesRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompletion => $composableBuilder(
    column: $table.isCompletion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rereadIndex => $composableBuilder(
    column: $table.rereadIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shareToFeed => $composableBuilder(
    column: $table.shareToFeed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get activeSeconds => $composableBuilder(
    column: $table.activeSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startPage =>
      $composableBuilder(column: $table.startPage, builder: (column) => column);

  GeneratedColumn<int> get endPage =>
      $composableBuilder(column: $table.endPage, builder: (column) => column);

  GeneratedColumn<int> get pagesRead =>
      $composableBuilder(column: $table.pagesRead, builder: (column) => column);

  GeneratedColumn<bool> get isCompletion => $composableBuilder(
    column: $table.isCompletion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rereadIndex => $composableBuilder(
    column: $table.rereadIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get shareToFeed => $composableBuilder(
    column: $table.shareToFeed,
    builder: (column) => column,
  );
}

class $$ReadingSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingSessionsTable,
          ReadingSessionRow,
          $$ReadingSessionsTableFilterComposer,
          $$ReadingSessionsTableOrderingComposer,
          $$ReadingSessionsTableAnnotationComposer,
          $$ReadingSessionsTableCreateCompanionBuilder,
          $$ReadingSessionsTableUpdateCompanionBuilder,
          (
            ReadingSessionRow,
            BaseReferences<
              _$AppDatabase,
              $ReadingSessionsTable,
              ReadingSessionRow
            >,
          ),
          ReadingSessionRow,
          PrefetchHooks Function()
        > {
  $$ReadingSessionsTableTableManager(
    _$AppDatabase db,
    $ReadingSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<String> seriesId = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int> endedAt = const Value.absent(),
                Value<int> activeSeconds = const Value.absent(),
                Value<int> startPage = const Value.absent(),
                Value<int> endPage = const Value.absent(),
                Value<int> pagesRead = const Value.absent(),
                Value<bool> isCompletion = const Value.absent(),
                Value<int> rereadIndex = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                Value<bool> shareToFeed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingSessionsCompanion(
                id: id,
                sourceId: sourceId,
                bookId: bookId,
                seriesId: seriesId,
                startedAt: startedAt,
                endedAt: endedAt,
                activeSeconds: activeSeconds,
                startPage: startPage,
                endPage: endPage,
                pagesRead: pagesRead,
                isCompletion: isCompletion,
                rereadIndex: rereadIndex,
                deviceId: deviceId,
                visibility: visibility,
                shareToFeed: shareToFeed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceId,
                required String bookId,
                required String seriesId,
                required int startedAt,
                required int endedAt,
                required int activeSeconds,
                required int startPage,
                required int endPage,
                required int pagesRead,
                Value<bool> isCompletion = const Value.absent(),
                Value<int> rereadIndex = const Value.absent(),
                required String deviceId,
                Value<String> visibility = const Value.absent(),
                Value<bool> shareToFeed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingSessionsCompanion.insert(
                id: id,
                sourceId: sourceId,
                bookId: bookId,
                seriesId: seriesId,
                startedAt: startedAt,
                endedAt: endedAt,
                activeSeconds: activeSeconds,
                startPage: startPage,
                endPage: endPage,
                pagesRead: pagesRead,
                isCompletion: isCompletion,
                rereadIndex: rereadIndex,
                deviceId: deviceId,
                visibility: visibility,
                shareToFeed: shareToFeed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingSessionsTable,
      ReadingSessionRow,
      $$ReadingSessionsTableFilterComposer,
      $$ReadingSessionsTableOrderingComposer,
      $$ReadingSessionsTableAnnotationComposer,
      $$ReadingSessionsTableCreateCompanionBuilder,
      $$ReadingSessionsTableUpdateCompanionBuilder,
      (
        ReadingSessionRow,
        BaseReferences<_$AppDatabase, $ReadingSessionsTable, ReadingSessionRow>,
      ),
      ReadingSessionRow,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String sourceId,
      required String bookId,
      required int page,
      Value<bool> completed,
      required int queuedAt,
      Value<int> attempts,
      Value<String> state,
      Value<String> op,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> sourceId,
      Value<String> bookId,
      Value<int> page,
      Value<bool> completed,
      Value<int> queuedAt,
      Value<int> attempts,
      Value<String> state,
      Value<String> op,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
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

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get queuedAt => $composableBuilder(
    column: $table.queuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
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

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get queuedAt => $composableBuilder(
    column: $table.queuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<int> get queuedAt =>
      $composableBuilder(column: $table.queuedAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueRow,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueRow,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueRow>,
          ),
          SyncQueueRow,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<int> queuedAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> op = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                sourceId: sourceId,
                bookId: bookId,
                page: page,
                completed: completed,
                queuedAt: queuedAt,
                attempts: attempts,
                state: state,
                op: op,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sourceId,
                required String bookId,
                required int page,
                Value<bool> completed = const Value.absent(),
                required int queuedAt,
                Value<int> attempts = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> op = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                sourceId: sourceId,
                bookId: bookId,
                page: page,
                completed: completed,
                queuedAt: queuedAt,
                attempts: attempts,
                state: state,
                op: op,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueRow,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueRow,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueRow>,
      ),
      SyncQueueRow,
      PrefetchHooks Function()
    >;
typedef $$SeriesMetaTableCreateCompanionBuilder =
    SeriesMetaCompanion Function({
      required String sourceId,
      required String seriesId,
      Value<String?> publisher,
      Value<String?> genres,
      Value<int?> rating,
      Value<int> rowid,
    });
typedef $$SeriesMetaTableUpdateCompanionBuilder =
    SeriesMetaCompanion Function({
      Value<String> sourceId,
      Value<String> seriesId,
      Value<String?> publisher,
      Value<String?> genres,
      Value<int?> rating,
      Value<int> rowid,
    });

class $$SeriesMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SeriesMetaTable> {
  $$SeriesMetaTableFilterComposer({
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

  ColumnFilters<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SeriesMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SeriesMetaTable> {
  $$SeriesMetaTableOrderingComposer({
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

  ColumnOrderings<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeriesMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeriesMetaTable> {
  $$SeriesMetaTableAnnotationComposer({
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

  GeneratedColumn<String> get publisher =>
      $composableBuilder(column: $table.publisher, builder: (column) => column);

  GeneratedColumn<String> get genres =>
      $composableBuilder(column: $table.genres, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);
}

class $$SeriesMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeriesMetaTable,
          SeriesMetaRow,
          $$SeriesMetaTableFilterComposer,
          $$SeriesMetaTableOrderingComposer,
          $$SeriesMetaTableAnnotationComposer,
          $$SeriesMetaTableCreateCompanionBuilder,
          $$SeriesMetaTableUpdateCompanionBuilder,
          (
            SeriesMetaRow,
            BaseReferences<_$AppDatabase, $SeriesMetaTable, SeriesMetaRow>,
          ),
          SeriesMetaRow,
          PrefetchHooks Function()
        > {
  $$SeriesMetaTableTableManager(_$AppDatabase db, $SeriesMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> seriesId = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesMetaCompanion(
                sourceId: sourceId,
                seriesId: seriesId,
                publisher: publisher,
                genres: genres,
                rating: rating,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String seriesId,
                Value<String?> publisher = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesMetaCompanion.insert(
                sourceId: sourceId,
                seriesId: seriesId,
                publisher: publisher,
                genres: genres,
                rating: rating,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeriesMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeriesMetaTable,
      SeriesMetaRow,
      $$SeriesMetaTableFilterComposer,
      $$SeriesMetaTableOrderingComposer,
      $$SeriesMetaTableAnnotationComposer,
      $$SeriesMetaTableCreateCompanionBuilder,
      $$SeriesMetaTableUpdateCompanionBuilder,
      (
        SeriesMetaRow,
        BaseReferences<_$AppDatabase, $SeriesMetaTable, SeriesMetaRow>,
      ),
      SeriesMetaRow,
      PrefetchHooks Function()
    >;
typedef $$ColorSettingsTableCreateCompanionBuilder =
    ColorSettingsCompanion Function({
      required String sourceId,
      required String scope,
      required String scopeId,
      Value<bool> enabled,
      Value<double> brightness,
      Value<double> contrast,
      Value<double> gamma,
      Value<String> mode,
      Value<bool> autoLevels,
      Value<int> rowid,
    });
typedef $$ColorSettingsTableUpdateCompanionBuilder =
    ColorSettingsCompanion Function({
      Value<String> sourceId,
      Value<String> scope,
      Value<String> scopeId,
      Value<bool> enabled,
      Value<double> brightness,
      Value<double> contrast,
      Value<double> gamma,
      Value<String> mode,
      Value<bool> autoLevels,
      Value<int> rowid,
    });

class $$ColorSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $ColorSettingsTable> {
  $$ColorSettingsTableFilterComposer({
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

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeId => $composableBuilder(
    column: $table.scopeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get brightness => $composableBuilder(
    column: $table.brightness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get contrast => $composableBuilder(
    column: $table.contrast,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gamma => $composableBuilder(
    column: $table.gamma,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoLevels => $composableBuilder(
    column: $table.autoLevels,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ColorSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ColorSettingsTable> {
  $$ColorSettingsTableOrderingComposer({
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

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeId => $composableBuilder(
    column: $table.scopeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get brightness => $composableBuilder(
    column: $table.brightness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get contrast => $composableBuilder(
    column: $table.contrast,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gamma => $composableBuilder(
    column: $table.gamma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoLevels => $composableBuilder(
    column: $table.autoLevels,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ColorSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ColorSettingsTable> {
  $$ColorSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get scopeId =>
      $composableBuilder(column: $table.scopeId, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<double> get brightness => $composableBuilder(
    column: $table.brightness,
    builder: (column) => column,
  );

  GeneratedColumn<double> get contrast =>
      $composableBuilder(column: $table.contrast, builder: (column) => column);

  GeneratedColumn<double> get gamma =>
      $composableBuilder(column: $table.gamma, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<bool> get autoLevels => $composableBuilder(
    column: $table.autoLevels,
    builder: (column) => column,
  );
}

class $$ColorSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ColorSettingsTable,
          ColorSettingsRow,
          $$ColorSettingsTableFilterComposer,
          $$ColorSettingsTableOrderingComposer,
          $$ColorSettingsTableAnnotationComposer,
          $$ColorSettingsTableCreateCompanionBuilder,
          $$ColorSettingsTableUpdateCompanionBuilder,
          (
            ColorSettingsRow,
            BaseReferences<
              _$AppDatabase,
              $ColorSettingsTable,
              ColorSettingsRow
            >,
          ),
          ColorSettingsRow,
          PrefetchHooks Function()
        > {
  $$ColorSettingsTableTableManager(_$AppDatabase db, $ColorSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ColorSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ColorSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ColorSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<String> scopeId = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<double> brightness = const Value.absent(),
                Value<double> contrast = const Value.absent(),
                Value<double> gamma = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<bool> autoLevels = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ColorSettingsCompanion(
                sourceId: sourceId,
                scope: scope,
                scopeId: scopeId,
                enabled: enabled,
                brightness: brightness,
                contrast: contrast,
                gamma: gamma,
                mode: mode,
                autoLevels: autoLevels,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String scope,
                required String scopeId,
                Value<bool> enabled = const Value.absent(),
                Value<double> brightness = const Value.absent(),
                Value<double> contrast = const Value.absent(),
                Value<double> gamma = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<bool> autoLevels = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ColorSettingsCompanion.insert(
                sourceId: sourceId,
                scope: scope,
                scopeId: scopeId,
                enabled: enabled,
                brightness: brightness,
                contrast: contrast,
                gamma: gamma,
                mode: mode,
                autoLevels: autoLevels,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ColorSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ColorSettingsTable,
      ColorSettingsRow,
      $$ColorSettingsTableFilterComposer,
      $$ColorSettingsTableOrderingComposer,
      $$ColorSettingsTableAnnotationComposer,
      $$ColorSettingsTableCreateCompanionBuilder,
      $$ColorSettingsTableUpdateCompanionBuilder,
      (
        ColorSettingsRow,
        BaseReferences<_$AppDatabase, $ColorSettingsTable, ColorSettingsRow>,
      ),
      ColorSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$PinsTableCreateCompanionBuilder =
    PinsCompanion Function({
      required String sourceId,
      required String ownerType,
      required String ownerId,
      required int pinnedAt,
      Value<int> rowid,
    });
typedef $$PinsTableUpdateCompanionBuilder =
    PinsCompanion Function({
      Value<String> sourceId,
      Value<String> ownerType,
      Value<String> ownerId,
      Value<int> pinnedAt,
      Value<int> rowid,
    });

class $$PinsTableFilterComposer extends Composer<_$AppDatabase, $PinsTable> {
  $$PinsTableFilterComposer({
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

  ColumnFilters<int> get pinnedAt => $composableBuilder(
    column: $table.pinnedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PinsTableOrderingComposer extends Composer<_$AppDatabase, $PinsTable> {
  $$PinsTableOrderingComposer({
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

  ColumnOrderings<int> get pinnedAt => $composableBuilder(
    column: $table.pinnedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PinsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PinsTable> {
  $$PinsTableAnnotationComposer({
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

  GeneratedColumn<int> get pinnedAt =>
      $composableBuilder(column: $table.pinnedAt, builder: (column) => column);
}

class $$PinsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PinsTable,
          PinRow,
          $$PinsTableFilterComposer,
          $$PinsTableOrderingComposer,
          $$PinsTableAnnotationComposer,
          $$PinsTableCreateCompanionBuilder,
          $$PinsTableUpdateCompanionBuilder,
          (PinRow, BaseReferences<_$AppDatabase, $PinsTable, PinRow>),
          PinRow,
          PrefetchHooks Function()
        > {
  $$PinsTableTableManager(_$AppDatabase db, $PinsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PinsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PinsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PinsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> ownerType = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<int> pinnedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PinsCompanion(
                sourceId: sourceId,
                ownerType: ownerType,
                ownerId: ownerId,
                pinnedAt: pinnedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String ownerType,
                required String ownerId,
                required int pinnedAt,
                Value<int> rowid = const Value.absent(),
              }) => PinsCompanion.insert(
                sourceId: sourceId,
                ownerType: ownerType,
                ownerId: ownerId,
                pinnedAt: pinnedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PinsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PinsTable,
      PinRow,
      $$PinsTableFilterComposer,
      $$PinsTableOrderingComposer,
      $$PinsTableAnnotationComposer,
      $$PinsTableCreateCompanionBuilder,
      $$PinsTableUpdateCompanionBuilder,
      (PinRow, BaseReferences<_$AppDatabase, $PinsTable, PinRow>),
      PinRow,
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
  $$CachedAssetsTableTableManager get cachedAssets =>
      $$CachedAssetsTableTableManager(_db, _db.cachedAssets);
  $$DownloadTasksTableTableManager get downloadTasks =>
      $$DownloadTasksTableTableManager(_db, _db.downloadTasks);
  $$BookStateTableTableManager get bookState =>
      $$BookStateTableTableManager(_db, _db.bookState);
  $$ReadingSessionsTableTableManager get readingSessions =>
      $$ReadingSessionsTableTableManager(_db, _db.readingSessions);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$SeriesMetaTableTableManager get seriesMeta =>
      $$SeriesMetaTableTableManager(_db, _db.seriesMeta);
  $$ColorSettingsTableTableManager get colorSettings =>
      $$ColorSettingsTableTableManager(_db, _db.colorSettings);
  $$PinsTableTableManager get pins => $$PinsTableTableManager(_db, _db.pins);
}
