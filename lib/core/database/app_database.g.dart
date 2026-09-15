// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PropertiesTable extends Properties
    with TableInfo<$PropertiesTable, Property> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PropertiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
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
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerNameMeta = const VerificationMeta(
    'ownerName',
  );
  @override
  late final GeneratedColumn<String> ownerName = GeneratedColumn<String>(
    'owner_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerContactMeta = const VerificationMeta(
    'ownerContact',
  );
  @override
  late final GeneratedColumn<String> ownerContact = GeneratedColumn<String>(
    'owner_contact',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    address,
    ownerName,
    ownerContact,
    isPrimary,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'properties';
  @override
  VerificationContext validateIntegrity(
    Insertable<Property> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('owner_name')) {
      context.handle(
        _ownerNameMeta,
        ownerName.isAcceptableOrUnknown(data['owner_name']!, _ownerNameMeta),
      );
    }
    if (data.containsKey('owner_contact')) {
      context.handle(
        _ownerContactMeta,
        ownerContact.isAcceptableOrUnknown(
          data['owner_contact']!,
          _ownerContactMeta,
        ),
      );
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Property map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Property(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      ownerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_name'],
      ),
      ownerContact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_contact'],
      ),
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
    );
  }

  @override
  $PropertiesTable createAlias(String alias) {
    return $PropertiesTable(attachedDatabase, alias);
  }
}

class Property extends DataClass implements Insertable<Property> {
  final String id;
  final String name;
  final String? address;
  final String? ownerName;
  final String? ownerContact;
  final bool isPrimary;
  const Property({
    required this.id,
    required this.name,
    this.address,
    this.ownerName,
    this.ownerContact,
    required this.isPrimary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || ownerName != null) {
      map['owner_name'] = Variable<String>(ownerName);
    }
    if (!nullToAbsent || ownerContact != null) {
      map['owner_contact'] = Variable<String>(ownerContact);
    }
    map['is_primary'] = Variable<bool>(isPrimary);
    return map;
  }

  PropertiesCompanion toCompanion(bool nullToAbsent) {
    return PropertiesCompanion(
      id: Value(id),
      name: Value(name),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      ownerName: ownerName == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerName),
      ownerContact: ownerContact == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerContact),
      isPrimary: Value(isPrimary),
    );
  }

  factory Property.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Property(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String?>(json['address']),
      ownerName: serializer.fromJson<String?>(json['ownerName']),
      ownerContact: serializer.fromJson<String?>(json['ownerContact']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String?>(address),
      'ownerName': serializer.toJson<String?>(ownerName),
      'ownerContact': serializer.toJson<String?>(ownerContact),
      'isPrimary': serializer.toJson<bool>(isPrimary),
    };
  }

  Property copyWith({
    String? id,
    String? name,
    Value<String?> address = const Value.absent(),
    Value<String?> ownerName = const Value.absent(),
    Value<String?> ownerContact = const Value.absent(),
    bool? isPrimary,
  }) => Property(
    id: id ?? this.id,
    name: name ?? this.name,
    address: address.present ? address.value : this.address,
    ownerName: ownerName.present ? ownerName.value : this.ownerName,
    ownerContact: ownerContact.present ? ownerContact.value : this.ownerContact,
    isPrimary: isPrimary ?? this.isPrimary,
  );
  Property copyWithCompanion(PropertiesCompanion data) {
    return Property(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      ownerName: data.ownerName.present ? data.ownerName.value : this.ownerName,
      ownerContact: data.ownerContact.present
          ? data.ownerContact.value
          : this.ownerContact,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Property(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('ownerName: $ownerName, ')
          ..write('ownerContact: $ownerContact, ')
          ..write('isPrimary: $isPrimary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, address, ownerName, ownerContact, isPrimary);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Property &&
          other.id == this.id &&
          other.name == this.name &&
          other.address == this.address &&
          other.ownerName == this.ownerName &&
          other.ownerContact == this.ownerContact &&
          other.isPrimary == this.isPrimary);
}

class PropertiesCompanion extends UpdateCompanion<Property> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> address;
  final Value<String?> ownerName;
  final Value<String?> ownerContact;
  final Value<bool> isPrimary;
  final Value<int> rowid;
  const PropertiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.ownerName = const Value.absent(),
    this.ownerContact = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PropertiesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.address = const Value.absent(),
    this.ownerName = const Value.absent(),
    this.ownerContact = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Property> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? address,
    Expression<String>? ownerName,
    Expression<String>? ownerContact,
    Expression<bool>? isPrimary,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (ownerName != null) 'owner_name': ownerName,
      if (ownerContact != null) 'owner_contact': ownerContact,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PropertiesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? address,
    Value<String?>? ownerName,
    Value<String?>? ownerContact,
    Value<bool>? isPrimary,
    Value<int>? rowid,
  }) {
    return PropertiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      ownerName: ownerName ?? this.ownerName,
      ownerContact: ownerContact ?? this.ownerContact,
      isPrimary: isPrimary ?? this.isPrimary,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (ownerName.present) {
      map['owner_name'] = Variable<String>(ownerName.value);
    }
    if (ownerContact.present) {
      map['owner_contact'] = Variable<String>(ownerContact.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PropertiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('ownerName: $ownerName, ')
          ..write('ownerContact: $ownerContact, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoomTypesTable extends RoomTypes
    with TableInfo<$RoomTypesTable, RoomType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
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
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'room_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoomType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoomType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoomType(
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
  $RoomTypesTable createAlias(String alias) {
    return $RoomTypesTable(attachedDatabase, alias);
  }
}

class RoomType extends DataClass implements Insertable<RoomType> {
  final String id;
  final String name;
  const RoomType({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  RoomTypesCompanion toCompanion(bool nullToAbsent) {
    return RoomTypesCompanion(id: Value(id), name: Value(name));
  }

  factory RoomType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoomType(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  RoomType copyWith({String? id, String? name}) =>
      RoomType(id: id ?? this.id, name: name ?? this.name);
  RoomType copyWithCompanion(RoomTypesCompanion data) {
    return RoomType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoomType(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoomType && other.id == this.id && other.name == this.name);
}

class RoomTypesCompanion extends UpdateCompanion<RoomType> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const RoomTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoomTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<RoomType> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoomTypesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return RoomTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
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
    return (StringBuffer('RoomTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoomsTable extends Rooms with TableInfo<$RoomsTable, Room> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _propertyIdMeta = const VerificationMeta(
    'propertyId',
  );
  @override
  late final GeneratedColumn<String> propertyId = GeneratedColumn<String>(
    'property_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES properties (id)',
    ),
  );
  static const VerificationMeta _roomTypeIdMeta = const VerificationMeta(
    'roomTypeId',
  );
  @override
  late final GeneratedColumn<String> roomTypeId = GeneratedColumn<String>(
    'room_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES room_types (id)',
    ),
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
  static const VerificationMeta _capacityMeta = const VerificationMeta(
    'capacity',
  );
  @override
  late final GeneratedColumn<int> capacity = GeneratedColumn<int>(
    'capacity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratePerPersonWeekdayCentsMeta =
      const VerificationMeta('ratePerPersonWeekdayCents');
  @override
  late final GeneratedColumn<int> ratePerPersonWeekdayCents =
      GeneratedColumn<int>(
        'rate_per_person_weekday_cents',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _ratePerPersonWeekendCentsMeta =
      const VerificationMeta('ratePerPersonWeekendCents');
  @override
  late final GeneratedColumn<int> ratePerPersonWeekendCents =
      GeneratedColumn<int>(
        'rate_per_person_weekend_cents',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    propertyId,
    roomTypeId,
    name,
    capacity,
    ratePerPersonWeekdayCents,
    ratePerPersonWeekendCents,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rooms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Room> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('property_id')) {
      context.handle(
        _propertyIdMeta,
        propertyId.isAcceptableOrUnknown(data['property_id']!, _propertyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_propertyIdMeta);
    }
    if (data.containsKey('room_type_id')) {
      context.handle(
        _roomTypeIdMeta,
        roomTypeId.isAcceptableOrUnknown(
          data['room_type_id']!,
          _roomTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_roomTypeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('capacity')) {
      context.handle(
        _capacityMeta,
        capacity.isAcceptableOrUnknown(data['capacity']!, _capacityMeta),
      );
    } else if (isInserting) {
      context.missing(_capacityMeta);
    }
    if (data.containsKey('rate_per_person_weekday_cents')) {
      context.handle(
        _ratePerPersonWeekdayCentsMeta,
        ratePerPersonWeekdayCents.isAcceptableOrUnknown(
          data['rate_per_person_weekday_cents']!,
          _ratePerPersonWeekdayCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ratePerPersonWeekdayCentsMeta);
    }
    if (data.containsKey('rate_per_person_weekend_cents')) {
      context.handle(
        _ratePerPersonWeekendCentsMeta,
        ratePerPersonWeekendCents.isAcceptableOrUnknown(
          data['rate_per_person_weekend_cents']!,
          _ratePerPersonWeekendCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ratePerPersonWeekendCentsMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Room map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Room(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      propertyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}property_id'],
      )!,
      roomTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_type_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      capacity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capacity'],
      )!,
      ratePerPersonWeekdayCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate_per_person_weekday_cents'],
      )!,
      ratePerPersonWeekendCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate_per_person_weekend_cents'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $RoomsTable createAlias(String alias) {
    return $RoomsTable(attachedDatabase, alias);
  }
}

class Room extends DataClass implements Insertable<Room> {
  final String id;
  final String propertyId;
  final String roomTypeId;
  final String name;
  final int capacity;

  /// Tarifa por persona, en centavos, lunes a jueves.
  final int ratePerPersonWeekdayCents;

  /// Tarifa por persona, en centavos, viernes a domingo.
  final int ratePerPersonWeekendCents;
  final bool isActive;
  const Room({
    required this.id,
    required this.propertyId,
    required this.roomTypeId,
    required this.name,
    required this.capacity,
    required this.ratePerPersonWeekdayCents,
    required this.ratePerPersonWeekendCents,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['property_id'] = Variable<String>(propertyId);
    map['room_type_id'] = Variable<String>(roomTypeId);
    map['name'] = Variable<String>(name);
    map['capacity'] = Variable<int>(capacity);
    map['rate_per_person_weekday_cents'] = Variable<int>(
      ratePerPersonWeekdayCents,
    );
    map['rate_per_person_weekend_cents'] = Variable<int>(
      ratePerPersonWeekendCents,
    );
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  RoomsCompanion toCompanion(bool nullToAbsent) {
    return RoomsCompanion(
      id: Value(id),
      propertyId: Value(propertyId),
      roomTypeId: Value(roomTypeId),
      name: Value(name),
      capacity: Value(capacity),
      ratePerPersonWeekdayCents: Value(ratePerPersonWeekdayCents),
      ratePerPersonWeekendCents: Value(ratePerPersonWeekendCents),
      isActive: Value(isActive),
    );
  }

  factory Room.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Room(
      id: serializer.fromJson<String>(json['id']),
      propertyId: serializer.fromJson<String>(json['propertyId']),
      roomTypeId: serializer.fromJson<String>(json['roomTypeId']),
      name: serializer.fromJson<String>(json['name']),
      capacity: serializer.fromJson<int>(json['capacity']),
      ratePerPersonWeekdayCents: serializer.fromJson<int>(
        json['ratePerPersonWeekdayCents'],
      ),
      ratePerPersonWeekendCents: serializer.fromJson<int>(
        json['ratePerPersonWeekendCents'],
      ),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'propertyId': serializer.toJson<String>(propertyId),
      'roomTypeId': serializer.toJson<String>(roomTypeId),
      'name': serializer.toJson<String>(name),
      'capacity': serializer.toJson<int>(capacity),
      'ratePerPersonWeekdayCents': serializer.toJson<int>(
        ratePerPersonWeekdayCents,
      ),
      'ratePerPersonWeekendCents': serializer.toJson<int>(
        ratePerPersonWeekendCents,
      ),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Room copyWith({
    String? id,
    String? propertyId,
    String? roomTypeId,
    String? name,
    int? capacity,
    int? ratePerPersonWeekdayCents,
    int? ratePerPersonWeekendCents,
    bool? isActive,
  }) => Room(
    id: id ?? this.id,
    propertyId: propertyId ?? this.propertyId,
    roomTypeId: roomTypeId ?? this.roomTypeId,
    name: name ?? this.name,
    capacity: capacity ?? this.capacity,
    ratePerPersonWeekdayCents:
        ratePerPersonWeekdayCents ?? this.ratePerPersonWeekdayCents,
    ratePerPersonWeekendCents:
        ratePerPersonWeekendCents ?? this.ratePerPersonWeekendCents,
    isActive: isActive ?? this.isActive,
  );
  Room copyWithCompanion(RoomsCompanion data) {
    return Room(
      id: data.id.present ? data.id.value : this.id,
      propertyId: data.propertyId.present
          ? data.propertyId.value
          : this.propertyId,
      roomTypeId: data.roomTypeId.present
          ? data.roomTypeId.value
          : this.roomTypeId,
      name: data.name.present ? data.name.value : this.name,
      capacity: data.capacity.present ? data.capacity.value : this.capacity,
      ratePerPersonWeekdayCents: data.ratePerPersonWeekdayCents.present
          ? data.ratePerPersonWeekdayCents.value
          : this.ratePerPersonWeekdayCents,
      ratePerPersonWeekendCents: data.ratePerPersonWeekendCents.present
          ? data.ratePerPersonWeekendCents.value
          : this.ratePerPersonWeekendCents,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Room(')
          ..write('id: $id, ')
          ..write('propertyId: $propertyId, ')
          ..write('roomTypeId: $roomTypeId, ')
          ..write('name: $name, ')
          ..write('capacity: $capacity, ')
          ..write('ratePerPersonWeekdayCents: $ratePerPersonWeekdayCents, ')
          ..write('ratePerPersonWeekendCents: $ratePerPersonWeekendCents, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    propertyId,
    roomTypeId,
    name,
    capacity,
    ratePerPersonWeekdayCents,
    ratePerPersonWeekendCents,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Room &&
          other.id == this.id &&
          other.propertyId == this.propertyId &&
          other.roomTypeId == this.roomTypeId &&
          other.name == this.name &&
          other.capacity == this.capacity &&
          other.ratePerPersonWeekdayCents == this.ratePerPersonWeekdayCents &&
          other.ratePerPersonWeekendCents == this.ratePerPersonWeekendCents &&
          other.isActive == this.isActive);
}

class RoomsCompanion extends UpdateCompanion<Room> {
  final Value<String> id;
  final Value<String> propertyId;
  final Value<String> roomTypeId;
  final Value<String> name;
  final Value<int> capacity;
  final Value<int> ratePerPersonWeekdayCents;
  final Value<int> ratePerPersonWeekendCents;
  final Value<bool> isActive;
  final Value<int> rowid;
  const RoomsCompanion({
    this.id = const Value.absent(),
    this.propertyId = const Value.absent(),
    this.roomTypeId = const Value.absent(),
    this.name = const Value.absent(),
    this.capacity = const Value.absent(),
    this.ratePerPersonWeekdayCents = const Value.absent(),
    this.ratePerPersonWeekendCents = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoomsCompanion.insert({
    this.id = const Value.absent(),
    required String propertyId,
    required String roomTypeId,
    required String name,
    required int capacity,
    required int ratePerPersonWeekdayCents,
    required int ratePerPersonWeekendCents,
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : propertyId = Value(propertyId),
       roomTypeId = Value(roomTypeId),
       name = Value(name),
       capacity = Value(capacity),
       ratePerPersonWeekdayCents = Value(ratePerPersonWeekdayCents),
       ratePerPersonWeekendCents = Value(ratePerPersonWeekendCents);
  static Insertable<Room> custom({
    Expression<String>? id,
    Expression<String>? propertyId,
    Expression<String>? roomTypeId,
    Expression<String>? name,
    Expression<int>? capacity,
    Expression<int>? ratePerPersonWeekdayCents,
    Expression<int>? ratePerPersonWeekendCents,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (propertyId != null) 'property_id': propertyId,
      if (roomTypeId != null) 'room_type_id': roomTypeId,
      if (name != null) 'name': name,
      if (capacity != null) 'capacity': capacity,
      if (ratePerPersonWeekdayCents != null)
        'rate_per_person_weekday_cents': ratePerPersonWeekdayCents,
      if (ratePerPersonWeekendCents != null)
        'rate_per_person_weekend_cents': ratePerPersonWeekendCents,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoomsCompanion copyWith({
    Value<String>? id,
    Value<String>? propertyId,
    Value<String>? roomTypeId,
    Value<String>? name,
    Value<int>? capacity,
    Value<int>? ratePerPersonWeekdayCents,
    Value<int>? ratePerPersonWeekendCents,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return RoomsCompanion(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      roomTypeId: roomTypeId ?? this.roomTypeId,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      ratePerPersonWeekdayCents:
          ratePerPersonWeekdayCents ?? this.ratePerPersonWeekdayCents,
      ratePerPersonWeekendCents:
          ratePerPersonWeekendCents ?? this.ratePerPersonWeekendCents,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (propertyId.present) {
      map['property_id'] = Variable<String>(propertyId.value);
    }
    if (roomTypeId.present) {
      map['room_type_id'] = Variable<String>(roomTypeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (capacity.present) {
      map['capacity'] = Variable<int>(capacity.value);
    }
    if (ratePerPersonWeekdayCents.present) {
      map['rate_per_person_weekday_cents'] = Variable<int>(
        ratePerPersonWeekdayCents.value,
      );
    }
    if (ratePerPersonWeekendCents.present) {
      map['rate_per_person_weekend_cents'] = Variable<int>(
        ratePerPersonWeekendCents.value,
      );
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomsCompanion(')
          ..write('id: $id, ')
          ..write('propertyId: $propertyId, ')
          ..write('roomTypeId: $roomTypeId, ')
          ..write('name: $name, ')
          ..write('capacity: $capacity, ')
          ..write('ratePerPersonWeekdayCents: $ratePerPersonWeekdayCents, ')
          ..write('ratePerPersonWeekendCents: $ratePerPersonWeekendCents, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GuestsTable extends Guests with TableInfo<$GuestsTable, Guest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GuestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fullName,
    documentId,
    phone,
    email,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'guests';
  @override
  VerificationContext validateIntegrity(
    Insertable<Guest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Guest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Guest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $GuestsTable createAlias(String alias) {
    return $GuestsTable(attachedDatabase, alias);
  }
}

class Guest extends DataClass implements Insertable<Guest> {
  final String id;
  final String fullName;
  final String? documentId;
  final String? phone;
  final String? email;
  final String? notes;
  const Guest({
    required this.id,
    required this.fullName,
    this.documentId,
    this.phone,
    this.email,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || documentId != null) {
      map['document_id'] = Variable<String>(documentId);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  GuestsCompanion toCompanion(bool nullToAbsent) {
    return GuestsCompanion(
      id: Value(id),
      fullName: Value(fullName),
      documentId: documentId == null && nullToAbsent
          ? const Value.absent()
          : Value(documentId),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Guest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Guest(
      id: serializer.fromJson<String>(json['id']),
      fullName: serializer.fromJson<String>(json['fullName']),
      documentId: serializer.fromJson<String?>(json['documentId']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fullName': serializer.toJson<String>(fullName),
      'documentId': serializer.toJson<String?>(documentId),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Guest copyWith({
    String? id,
    String? fullName,
    Value<String?> documentId = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => Guest(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    documentId: documentId.present ? documentId.value : this.documentId,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    notes: notes.present ? notes.value : this.notes,
  );
  Guest copyWithCompanion(GuestsCompanion data) {
    return Guest(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Guest(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('documentId: $documentId, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, fullName, documentId, phone, email, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Guest &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.documentId == this.documentId &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.notes == this.notes);
}

class GuestsCompanion extends UpdateCompanion<Guest> {
  final Value<String> id;
  final Value<String> fullName;
  final Value<String?> documentId;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> notes;
  final Value<int> rowid;
  const GuestsCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.documentId = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GuestsCompanion.insert({
    this.id = const Value.absent(),
    required String fullName,
    this.documentId = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : fullName = Value(fullName);
  static Insertable<Guest> custom({
    Expression<String>? id,
    Expression<String>? fullName,
    Expression<String>? documentId,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (documentId != null) 'document_id': documentId,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GuestsCompanion copyWith({
    Value<String>? id,
    Value<String>? fullName,
    Value<String?>? documentId,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return GuestsCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      documentId: documentId ?? this.documentId,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GuestsCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('documentId: $documentId, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReservationsTable extends Reservations
    with TableInfo<$ReservationsTable, Reservation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReservationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _guestIdMeta = const VerificationMeta(
    'guestId',
  );
  @override
  late final GeneratedColumn<String> guestId = GeneratedColumn<String>(
    'guest_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES guests (id)',
    ),
  );
  static const VerificationMeta _checkInDateMeta = const VerificationMeta(
    'checkInDate',
  );
  @override
  late final GeneratedColumn<DateTime> checkInDate = GeneratedColumn<DateTime>(
    'check_in_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkOutDateMeta = const VerificationMeta(
    'checkOutDate',
  );
  @override
  late final GeneratedColumn<DateTime> checkOutDate = GeneratedColumn<DateTime>(
    'check_out_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReservationStatus, String>
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(ReservationStatus.pending.name),
  ).withConverter<ReservationStatus>($ReservationsTable.$converterstatus);
  static const VerificationMeta _totalPriceCentsMeta = const VerificationMeta(
    'totalPriceCents',
  );
  @override
  late final GeneratedColumn<int> totalPriceCents = GeneratedColumn<int>(
    'total_price_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    guestId,
    checkInDate,
    checkOutDate,
    status,
    totalPriceCents,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reservations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reservation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('guest_id')) {
      context.handle(
        _guestIdMeta,
        guestId.isAcceptableOrUnknown(data['guest_id']!, _guestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_guestIdMeta);
    }
    if (data.containsKey('check_in_date')) {
      context.handle(
        _checkInDateMeta,
        checkInDate.isAcceptableOrUnknown(
          data['check_in_date']!,
          _checkInDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkInDateMeta);
    }
    if (data.containsKey('check_out_date')) {
      context.handle(
        _checkOutDateMeta,
        checkOutDate.isAcceptableOrUnknown(
          data['check_out_date']!,
          _checkOutDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkOutDateMeta);
    }
    if (data.containsKey('total_price_cents')) {
      context.handle(
        _totalPriceCentsMeta,
        totalPriceCents.isAcceptableOrUnknown(
          data['total_price_cents']!,
          _totalPriceCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalPriceCentsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reservation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reservation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      guestId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guest_id'],
      )!,
      checkInDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}check_in_date'],
      )!,
      checkOutDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}check_out_date'],
      )!,
      status: $ReservationsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      totalPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_price_cents'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReservationsTable createAlias(String alias) {
    return $ReservationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReservationStatus, String, String>
  $converterstatus = const EnumNameConverter<ReservationStatus>(
    ReservationStatus.values,
  );
}

class Reservation extends DataClass implements Insertable<Reservation> {
  final String id;
  final String guestId;

  /// Fecha de calendario, sin hora (check-in es siempre a las 14:00).
  final DateTime checkInDate;

  /// Fecha de calendario, sin hora (check-out es siempre a las 11:00).
  final DateTime checkOutDate;
  final ReservationStatus status;

  /// Precio final de la reserva, en centavos. Parte de un cálculo
  /// automático (tarifa x personas x noches por habitación) pero es
  /// editable a mano.
  final int totalPriceCents;
  final DateTime createdAt;
  const Reservation({
    required this.id,
    required this.guestId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.status,
    required this.totalPriceCents,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['guest_id'] = Variable<String>(guestId);
    map['check_in_date'] = Variable<DateTime>(checkInDate);
    map['check_out_date'] = Variable<DateTime>(checkOutDate);
    {
      map['status'] = Variable<String>(
        $ReservationsTable.$converterstatus.toSql(status),
      );
    }
    map['total_price_cents'] = Variable<int>(totalPriceCents);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReservationsCompanion toCompanion(bool nullToAbsent) {
    return ReservationsCompanion(
      id: Value(id),
      guestId: Value(guestId),
      checkInDate: Value(checkInDate),
      checkOutDate: Value(checkOutDate),
      status: Value(status),
      totalPriceCents: Value(totalPriceCents),
      createdAt: Value(createdAt),
    );
  }

  factory Reservation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reservation(
      id: serializer.fromJson<String>(json['id']),
      guestId: serializer.fromJson<String>(json['guestId']),
      checkInDate: serializer.fromJson<DateTime>(json['checkInDate']),
      checkOutDate: serializer.fromJson<DateTime>(json['checkOutDate']),
      status: $ReservationsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      totalPriceCents: serializer.fromJson<int>(json['totalPriceCents']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'guestId': serializer.toJson<String>(guestId),
      'checkInDate': serializer.toJson<DateTime>(checkInDate),
      'checkOutDate': serializer.toJson<DateTime>(checkOutDate),
      'status': serializer.toJson<String>(
        $ReservationsTable.$converterstatus.toJson(status),
      ),
      'totalPriceCents': serializer.toJson<int>(totalPriceCents),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Reservation copyWith({
    String? id,
    String? guestId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    ReservationStatus? status,
    int? totalPriceCents,
    DateTime? createdAt,
  }) => Reservation(
    id: id ?? this.id,
    guestId: guestId ?? this.guestId,
    checkInDate: checkInDate ?? this.checkInDate,
    checkOutDate: checkOutDate ?? this.checkOutDate,
    status: status ?? this.status,
    totalPriceCents: totalPriceCents ?? this.totalPriceCents,
    createdAt: createdAt ?? this.createdAt,
  );
  Reservation copyWithCompanion(ReservationsCompanion data) {
    return Reservation(
      id: data.id.present ? data.id.value : this.id,
      guestId: data.guestId.present ? data.guestId.value : this.guestId,
      checkInDate: data.checkInDate.present
          ? data.checkInDate.value
          : this.checkInDate,
      checkOutDate: data.checkOutDate.present
          ? data.checkOutDate.value
          : this.checkOutDate,
      status: data.status.present ? data.status.value : this.status,
      totalPriceCents: data.totalPriceCents.present
          ? data.totalPriceCents.value
          : this.totalPriceCents,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reservation(')
          ..write('id: $id, ')
          ..write('guestId: $guestId, ')
          ..write('checkInDate: $checkInDate, ')
          ..write('checkOutDate: $checkOutDate, ')
          ..write('status: $status, ')
          ..write('totalPriceCents: $totalPriceCents, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    guestId,
    checkInDate,
    checkOutDate,
    status,
    totalPriceCents,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reservation &&
          other.id == this.id &&
          other.guestId == this.guestId &&
          other.checkInDate == this.checkInDate &&
          other.checkOutDate == this.checkOutDate &&
          other.status == this.status &&
          other.totalPriceCents == this.totalPriceCents &&
          other.createdAt == this.createdAt);
}

class ReservationsCompanion extends UpdateCompanion<Reservation> {
  final Value<String> id;
  final Value<String> guestId;
  final Value<DateTime> checkInDate;
  final Value<DateTime> checkOutDate;
  final Value<ReservationStatus> status;
  final Value<int> totalPriceCents;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ReservationsCompanion({
    this.id = const Value.absent(),
    this.guestId = const Value.absent(),
    this.checkInDate = const Value.absent(),
    this.checkOutDate = const Value.absent(),
    this.status = const Value.absent(),
    this.totalPriceCents = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReservationsCompanion.insert({
    this.id = const Value.absent(),
    required String guestId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    this.status = const Value.absent(),
    required int totalPriceCents,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : guestId = Value(guestId),
       checkInDate = Value(checkInDate),
       checkOutDate = Value(checkOutDate),
       totalPriceCents = Value(totalPriceCents);
  static Insertable<Reservation> custom({
    Expression<String>? id,
    Expression<String>? guestId,
    Expression<DateTime>? checkInDate,
    Expression<DateTime>? checkOutDate,
    Expression<String>? status,
    Expression<int>? totalPriceCents,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (guestId != null) 'guest_id': guestId,
      if (checkInDate != null) 'check_in_date': checkInDate,
      if (checkOutDate != null) 'check_out_date': checkOutDate,
      if (status != null) 'status': status,
      if (totalPriceCents != null) 'total_price_cents': totalPriceCents,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReservationsCompanion copyWith({
    Value<String>? id,
    Value<String>? guestId,
    Value<DateTime>? checkInDate,
    Value<DateTime>? checkOutDate,
    Value<ReservationStatus>? status,
    Value<int>? totalPriceCents,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ReservationsCompanion(
      id: id ?? this.id,
      guestId: guestId ?? this.guestId,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      status: status ?? this.status,
      totalPriceCents: totalPriceCents ?? this.totalPriceCents,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (guestId.present) {
      map['guest_id'] = Variable<String>(guestId.value);
    }
    if (checkInDate.present) {
      map['check_in_date'] = Variable<DateTime>(checkInDate.value);
    }
    if (checkOutDate.present) {
      map['check_out_date'] = Variable<DateTime>(checkOutDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ReservationsTable.$converterstatus.toSql(status.value),
      );
    }
    if (totalPriceCents.present) {
      map['total_price_cents'] = Variable<int>(totalPriceCents.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReservationsCompanion(')
          ..write('id: $id, ')
          ..write('guestId: $guestId, ')
          ..write('checkInDate: $checkInDate, ')
          ..write('checkOutDate: $checkOutDate, ')
          ..write('status: $status, ')
          ..write('totalPriceCents: $totalPriceCents, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReservationRoomsTable extends ReservationRooms
    with TableInfo<$ReservationRoomsTable, ReservationRoom> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReservationRoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _reservationIdMeta = const VerificationMeta(
    'reservationId',
  );
  @override
  late final GeneratedColumn<String> reservationId = GeneratedColumn<String>(
    'reservation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reservations (id)',
    ),
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rooms (id)',
    ),
  );
  static const VerificationMeta _guestsCountMeta = const VerificationMeta(
    'guestsCount',
  );
  @override
  late final GeneratedColumn<int> guestsCount = GeneratedColumn<int>(
    'guests_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalCentsMeta = const VerificationMeta(
    'subtotalCents',
  );
  @override
  late final GeneratedColumn<int> subtotalCents = GeneratedColumn<int>(
    'subtotal_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    reservationId,
    roomId,
    guestsCount,
    subtotalCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reservation_rooms';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReservationRoom> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('reservation_id')) {
      context.handle(
        _reservationIdMeta,
        reservationId.isAcceptableOrUnknown(
          data['reservation_id']!,
          _reservationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reservationIdMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('guests_count')) {
      context.handle(
        _guestsCountMeta,
        guestsCount.isAcceptableOrUnknown(
          data['guests_count']!,
          _guestsCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_guestsCountMeta);
    }
    if (data.containsKey('subtotal_cents')) {
      context.handle(
        _subtotalCentsMeta,
        subtotalCents.isAcceptableOrUnknown(
          data['subtotal_cents']!,
          _subtotalCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subtotalCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReservationRoom map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReservationRoom(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      reservationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reservation_id'],
      )!,
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      )!,
      guestsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}guests_count'],
      )!,
      subtotalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subtotal_cents'],
      )!,
    );
  }

  @override
  $ReservationRoomsTable createAlias(String alias) {
    return $ReservationRoomsTable(attachedDatabase, alias);
  }
}

class ReservationRoom extends DataClass implements Insertable<ReservationRoom> {
  final String id;
  final String reservationId;
  final String roomId;
  final int guestsCount;

  /// Subtotal de esta línea, en centavos, calculado al momento de crear la
  /// reserva (tarifa vigente x personas x noches). Se guarda para no
  /// depender de que la tarifa de la habitación no cambie después.
  final int subtotalCents;
  const ReservationRoom({
    required this.id,
    required this.reservationId,
    required this.roomId,
    required this.guestsCount,
    required this.subtotalCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['reservation_id'] = Variable<String>(reservationId);
    map['room_id'] = Variable<String>(roomId);
    map['guests_count'] = Variable<int>(guestsCount);
    map['subtotal_cents'] = Variable<int>(subtotalCents);
    return map;
  }

  ReservationRoomsCompanion toCompanion(bool nullToAbsent) {
    return ReservationRoomsCompanion(
      id: Value(id),
      reservationId: Value(reservationId),
      roomId: Value(roomId),
      guestsCount: Value(guestsCount),
      subtotalCents: Value(subtotalCents),
    );
  }

  factory ReservationRoom.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReservationRoom(
      id: serializer.fromJson<String>(json['id']),
      reservationId: serializer.fromJson<String>(json['reservationId']),
      roomId: serializer.fromJson<String>(json['roomId']),
      guestsCount: serializer.fromJson<int>(json['guestsCount']),
      subtotalCents: serializer.fromJson<int>(json['subtotalCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'reservationId': serializer.toJson<String>(reservationId),
      'roomId': serializer.toJson<String>(roomId),
      'guestsCount': serializer.toJson<int>(guestsCount),
      'subtotalCents': serializer.toJson<int>(subtotalCents),
    };
  }

  ReservationRoom copyWith({
    String? id,
    String? reservationId,
    String? roomId,
    int? guestsCount,
    int? subtotalCents,
  }) => ReservationRoom(
    id: id ?? this.id,
    reservationId: reservationId ?? this.reservationId,
    roomId: roomId ?? this.roomId,
    guestsCount: guestsCount ?? this.guestsCount,
    subtotalCents: subtotalCents ?? this.subtotalCents,
  );
  ReservationRoom copyWithCompanion(ReservationRoomsCompanion data) {
    return ReservationRoom(
      id: data.id.present ? data.id.value : this.id,
      reservationId: data.reservationId.present
          ? data.reservationId.value
          : this.reservationId,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      guestsCount: data.guestsCount.present
          ? data.guestsCount.value
          : this.guestsCount,
      subtotalCents: data.subtotalCents.present
          ? data.subtotalCents.value
          : this.subtotalCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReservationRoom(')
          ..write('id: $id, ')
          ..write('reservationId: $reservationId, ')
          ..write('roomId: $roomId, ')
          ..write('guestsCount: $guestsCount, ')
          ..write('subtotalCents: $subtotalCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, reservationId, roomId, guestsCount, subtotalCents);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReservationRoom &&
          other.id == this.id &&
          other.reservationId == this.reservationId &&
          other.roomId == this.roomId &&
          other.guestsCount == this.guestsCount &&
          other.subtotalCents == this.subtotalCents);
}

class ReservationRoomsCompanion extends UpdateCompanion<ReservationRoom> {
  final Value<String> id;
  final Value<String> reservationId;
  final Value<String> roomId;
  final Value<int> guestsCount;
  final Value<int> subtotalCents;
  final Value<int> rowid;
  const ReservationRoomsCompanion({
    this.id = const Value.absent(),
    this.reservationId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.guestsCount = const Value.absent(),
    this.subtotalCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReservationRoomsCompanion.insert({
    this.id = const Value.absent(),
    required String reservationId,
    required String roomId,
    required int guestsCount,
    required int subtotalCents,
    this.rowid = const Value.absent(),
  }) : reservationId = Value(reservationId),
       roomId = Value(roomId),
       guestsCount = Value(guestsCount),
       subtotalCents = Value(subtotalCents);
  static Insertable<ReservationRoom> custom({
    Expression<String>? id,
    Expression<String>? reservationId,
    Expression<String>? roomId,
    Expression<int>? guestsCount,
    Expression<int>? subtotalCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reservationId != null) 'reservation_id': reservationId,
      if (roomId != null) 'room_id': roomId,
      if (guestsCount != null) 'guests_count': guestsCount,
      if (subtotalCents != null) 'subtotal_cents': subtotalCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReservationRoomsCompanion copyWith({
    Value<String>? id,
    Value<String>? reservationId,
    Value<String>? roomId,
    Value<int>? guestsCount,
    Value<int>? subtotalCents,
    Value<int>? rowid,
  }) {
    return ReservationRoomsCompanion(
      id: id ?? this.id,
      reservationId: reservationId ?? this.reservationId,
      roomId: roomId ?? this.roomId,
      guestsCount: guestsCount ?? this.guestsCount,
      subtotalCents: subtotalCents ?? this.subtotalCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (reservationId.present) {
      map['reservation_id'] = Variable<String>(reservationId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (guestsCount.present) {
      map['guests_count'] = Variable<int>(guestsCount.value);
    }
    if (subtotalCents.present) {
      map['subtotal_cents'] = Variable<int>(subtotalCents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReservationRoomsCompanion(')
          ..write('id: $id, ')
          ..write('reservationId: $reservationId, ')
          ..write('roomId: $roomId, ')
          ..write('guestsCount: $guestsCount, ')
          ..write('subtotalCents: $subtotalCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _reservationIdMeta = const VerificationMeta(
    'reservationId',
  );
  @override
  late final GeneratedColumn<String> reservationId = GeneratedColumn<String>(
    'reservation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reservations (id)',
    ),
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod, String> method =
      GeneratedColumn<String>(
        'method',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PaymentMethod>($PaymentsTable.$convertermethod);
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
    'paid_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    reservationId,
    amountCents,
    method,
    paidAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('reservation_id')) {
      context.handle(
        _reservationIdMeta,
        reservationId.isAcceptableOrUnknown(
          data['reservation_id']!,
          _reservationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reservationIdMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      reservationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reservation_id'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      method: $PaymentsTable.$convertermethod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}method'],
        )!,
      ),
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_at'],
      )!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PaymentMethod, String, String> $convertermethod =
      const EnumNameConverter<PaymentMethod>(PaymentMethod.values);
}

class Payment extends DataClass implements Insertable<Payment> {
  final String id;
  final String reservationId;

  /// Monto en centavos. Puede ser negativo: un reembolso es un pago más
  /// con monto negativo, no una entidad separada.
  final int amountCents;
  final PaymentMethod method;
  final DateTime paidAt;
  const Payment({
    required this.id,
    required this.reservationId,
    required this.amountCents,
    required this.method,
    required this.paidAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['reservation_id'] = Variable<String>(reservationId);
    map['amount_cents'] = Variable<int>(amountCents);
    {
      map['method'] = Variable<String>(
        $PaymentsTable.$convertermethod.toSql(method),
      );
    }
    map['paid_at'] = Variable<DateTime>(paidAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      reservationId: Value(reservationId),
      amountCents: Value(amountCents),
      method: Value(method),
      paidAt: Value(paidAt),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<String>(json['id']),
      reservationId: serializer.fromJson<String>(json['reservationId']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      method: $PaymentsTable.$convertermethod.fromJson(
        serializer.fromJson<String>(json['method']),
      ),
      paidAt: serializer.fromJson<DateTime>(json['paidAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'reservationId': serializer.toJson<String>(reservationId),
      'amountCents': serializer.toJson<int>(amountCents),
      'method': serializer.toJson<String>(
        $PaymentsTable.$convertermethod.toJson(method),
      ),
      'paidAt': serializer.toJson<DateTime>(paidAt),
    };
  }

  Payment copyWith({
    String? id,
    String? reservationId,
    int? amountCents,
    PaymentMethod? method,
    DateTime? paidAt,
  }) => Payment(
    id: id ?? this.id,
    reservationId: reservationId ?? this.reservationId,
    amountCents: amountCents ?? this.amountCents,
    method: method ?? this.method,
    paidAt: paidAt ?? this.paidAt,
  );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      reservationId: data.reservationId.present
          ? data.reservationId.value
          : this.reservationId,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      method: data.method.present ? data.method.value : this.method,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('reservationId: $reservationId, ')
          ..write('amountCents: $amountCents, ')
          ..write('method: $method, ')
          ..write('paidAt: $paidAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, reservationId, amountCents, method, paidAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.reservationId == this.reservationId &&
          other.amountCents == this.amountCents &&
          other.method == this.method &&
          other.paidAt == this.paidAt);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<String> id;
  final Value<String> reservationId;
  final Value<int> amountCents;
  final Value<PaymentMethod> method;
  final Value<DateTime> paidAt;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.reservationId = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.method = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    this.id = const Value.absent(),
    required String reservationId,
    required int amountCents,
    required PaymentMethod method,
    this.paidAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : reservationId = Value(reservationId),
       amountCents = Value(amountCents),
       method = Value(method);
  static Insertable<Payment> custom({
    Expression<String>? id,
    Expression<String>? reservationId,
    Expression<int>? amountCents,
    Expression<String>? method,
    Expression<DateTime>? paidAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reservationId != null) 'reservation_id': reservationId,
      if (amountCents != null) 'amount_cents': amountCents,
      if (method != null) 'method': method,
      if (paidAt != null) 'paid_at': paidAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? reservationId,
    Value<int>? amountCents,
    Value<PaymentMethod>? method,
    Value<DateTime>? paidAt,
    Value<int>? rowid,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      reservationId: reservationId ?? this.reservationId,
      amountCents: amountCents ?? this.amountCents,
      method: method ?? this.method,
      paidAt: paidAt ?? this.paidAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (reservationId.present) {
      map['reservation_id'] = Variable<String>(reservationId.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(
        $PaymentsTable.$convertermethod.toSql(method.value),
      );
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('reservationId: $reservationId, ')
          ..write('amountCents: $amountCents, ')
          ..write('method: $method, ')
          ..write('paidAt: $paidAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('app_settings'),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('USD'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, currency];
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
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
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
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String id;
  final String currency;
  const AppSetting({required this.id, required this.currency});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['currency'] = Variable<String>(currency);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(id: Value(id), currency: Value(currency));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<String>(json['id']),
      currency: serializer.fromJson<String>(json['currency']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'currency': serializer.toJson<String>(currency),
    };
  }

  AppSetting copyWith({String? id, String? currency}) =>
      AppSetting(id: id ?? this.id, currency: currency ?? this.currency);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      currency: data.currency.present ? data.currency.value : this.currency,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('currency: $currency')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, currency);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.currency == this.currency);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> id;
  final Value<String> currency;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.currency = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.currency = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<String>? id,
    Expression<String>? currency,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currency != null) 'currency': currency,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? id,
    Value<String>? currency,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      currency: currency ?? this.currency,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('currency: $currency, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PropertiesTable properties = $PropertiesTable(this);
  late final $RoomTypesTable roomTypes = $RoomTypesTable(this);
  late final $RoomsTable rooms = $RoomsTable(this);
  late final $GuestsTable guests = $GuestsTable(this);
  late final $ReservationsTable reservations = $ReservationsTable(this);
  late final $ReservationRoomsTable reservationRooms = $ReservationRoomsTable(
    this,
  );
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    properties,
    roomTypes,
    rooms,
    guests,
    reservations,
    reservationRooms,
    payments,
    appSettings,
  ];
}

typedef $$PropertiesTableCreateCompanionBuilder =
    PropertiesCompanion Function({
      Value<String> id,
      required String name,
      Value<String?> address,
      Value<String?> ownerName,
      Value<String?> ownerContact,
      Value<bool> isPrimary,
      Value<int> rowid,
    });
typedef $$PropertiesTableUpdateCompanionBuilder =
    PropertiesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> address,
      Value<String?> ownerName,
      Value<String?> ownerContact,
      Value<bool> isPrimary,
      Value<int> rowid,
    });

final class $$PropertiesTableReferences
    extends BaseReferences<_$AppDatabase, $PropertiesTable, Property> {
  $$PropertiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoomsTable, List<Room>> _roomsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.rooms,
    aliasName: $_aliasNameGenerator(db.properties.id, db.rooms.propertyId),
  );

  $$RoomsTableProcessedTableManager get roomsRefs {
    final manager = $$RoomsTableTableManager(
      $_db,
      $_db.rooms,
    ).filter((f) => f.propertyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_roomsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PropertiesTableFilterComposer
    extends Composer<_$AppDatabase, $PropertiesTable> {
  $$PropertiesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerContact => $composableBuilder(
    column: $table.ownerContact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> roomsRefs(
    Expression<bool> Function($$RoomsTableFilterComposer f) f,
  ) {
    final $$RoomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.propertyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomsTableFilterComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PropertiesTableOrderingComposer
    extends Composer<_$AppDatabase, $PropertiesTable> {
  $$PropertiesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerContact => $composableBuilder(
    column: $table.ownerContact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PropertiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PropertiesTable> {
  $$PropertiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get ownerName =>
      $composableBuilder(column: $table.ownerName, builder: (column) => column);

  GeneratedColumn<String> get ownerContact => $composableBuilder(
    column: $table.ownerContact,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  Expression<T> roomsRefs<T extends Object>(
    Expression<T> Function($$RoomsTableAnnotationComposer a) f,
  ) {
    final $$RoomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.propertyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomsTableAnnotationComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PropertiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PropertiesTable,
          Property,
          $$PropertiesTableFilterComposer,
          $$PropertiesTableOrderingComposer,
          $$PropertiesTableAnnotationComposer,
          $$PropertiesTableCreateCompanionBuilder,
          $$PropertiesTableUpdateCompanionBuilder,
          (Property, $$PropertiesTableReferences),
          Property,
          PrefetchHooks Function({bool roomsRefs})
        > {
  $$PropertiesTableTableManager(_$AppDatabase db, $PropertiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PropertiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PropertiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PropertiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> ownerName = const Value.absent(),
                Value<String?> ownerContact = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PropertiesCompanion(
                id: id,
                name: name,
                address: address,
                ownerName: ownerName,
                ownerContact: ownerContact,
                isPrimary: isPrimary,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                Value<String?> address = const Value.absent(),
                Value<String?> ownerName = const Value.absent(),
                Value<String?> ownerContact = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PropertiesCompanion.insert(
                id: id,
                name: name,
                address: address,
                ownerName: ownerName,
                ownerContact: ownerContact,
                isPrimary: isPrimary,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PropertiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({roomsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (roomsRefs) db.rooms],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (roomsRefs)
                    await $_getPrefetchedData<Property, $PropertiesTable, Room>(
                      currentTable: table,
                      referencedTable: $$PropertiesTableReferences
                          ._roomsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PropertiesTableReferences(db, table, p0).roomsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.propertyId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PropertiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PropertiesTable,
      Property,
      $$PropertiesTableFilterComposer,
      $$PropertiesTableOrderingComposer,
      $$PropertiesTableAnnotationComposer,
      $$PropertiesTableCreateCompanionBuilder,
      $$PropertiesTableUpdateCompanionBuilder,
      (Property, $$PropertiesTableReferences),
      Property,
      PrefetchHooks Function({bool roomsRefs})
    >;
typedef $$RoomTypesTableCreateCompanionBuilder =
    RoomTypesCompanion Function({
      Value<String> id,
      required String name,
      Value<int> rowid,
    });
typedef $$RoomTypesTableUpdateCompanionBuilder =
    RoomTypesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> rowid,
    });

final class $$RoomTypesTableReferences
    extends BaseReferences<_$AppDatabase, $RoomTypesTable, RoomType> {
  $$RoomTypesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoomsTable, List<Room>> _roomsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.rooms,
    aliasName: $_aliasNameGenerator(db.roomTypes.id, db.rooms.roomTypeId),
  );

  $$RoomsTableProcessedTableManager get roomsRefs {
    final manager = $$RoomsTableTableManager(
      $_db,
      $_db.rooms,
    ).filter((f) => f.roomTypeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_roomsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoomTypesTableFilterComposer
    extends Composer<_$AppDatabase, $RoomTypesTable> {
  $$RoomTypesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> roomsRefs(
    Expression<bool> Function($$RoomsTableFilterComposer f) f,
  ) {
    final $$RoomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.roomTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomsTableFilterComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoomTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoomTypesTable> {
  $$RoomTypesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoomTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoomTypesTable> {
  $$RoomTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> roomsRefs<T extends Object>(
    Expression<T> Function($$RoomsTableAnnotationComposer a) f,
  ) {
    final $$RoomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.roomTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomsTableAnnotationComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoomTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoomTypesTable,
          RoomType,
          $$RoomTypesTableFilterComposer,
          $$RoomTypesTableOrderingComposer,
          $$RoomTypesTableAnnotationComposer,
          $$RoomTypesTableCreateCompanionBuilder,
          $$RoomTypesTableUpdateCompanionBuilder,
          (RoomType, $$RoomTypesTableReferences),
          RoomType,
          PrefetchHooks Function({bool roomsRefs})
        > {
  $$RoomTypesTableTableManager(_$AppDatabase db, $RoomTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoomTypesCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => RoomTypesCompanion.insert(id: id, name: name, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RoomTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({roomsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (roomsRefs) db.rooms],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (roomsRefs)
                    await $_getPrefetchedData<RoomType, $RoomTypesTable, Room>(
                      currentTable: table,
                      referencedTable: $$RoomTypesTableReferences
                          ._roomsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RoomTypesTableReferences(db, table, p0).roomsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.roomTypeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoomTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoomTypesTable,
      RoomType,
      $$RoomTypesTableFilterComposer,
      $$RoomTypesTableOrderingComposer,
      $$RoomTypesTableAnnotationComposer,
      $$RoomTypesTableCreateCompanionBuilder,
      $$RoomTypesTableUpdateCompanionBuilder,
      (RoomType, $$RoomTypesTableReferences),
      RoomType,
      PrefetchHooks Function({bool roomsRefs})
    >;
typedef $$RoomsTableCreateCompanionBuilder =
    RoomsCompanion Function({
      Value<String> id,
      required String propertyId,
      required String roomTypeId,
      required String name,
      required int capacity,
      required int ratePerPersonWeekdayCents,
      required int ratePerPersonWeekendCents,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$RoomsTableUpdateCompanionBuilder =
    RoomsCompanion Function({
      Value<String> id,
      Value<String> propertyId,
      Value<String> roomTypeId,
      Value<String> name,
      Value<int> capacity,
      Value<int> ratePerPersonWeekdayCents,
      Value<int> ratePerPersonWeekendCents,
      Value<bool> isActive,
      Value<int> rowid,
    });

final class $$RoomsTableReferences
    extends BaseReferences<_$AppDatabase, $RoomsTable, Room> {
  $$RoomsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PropertiesTable _propertyIdTable(_$AppDatabase db) => db.properties
      .createAlias($_aliasNameGenerator(db.rooms.propertyId, db.properties.id));

  $$PropertiesTableProcessedTableManager get propertyId {
    final $_column = $_itemColumn<String>('property_id')!;

    final manager = $$PropertiesTableTableManager(
      $_db,
      $_db.properties,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_propertyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RoomTypesTable _roomTypeIdTable(_$AppDatabase db) => db.roomTypes
      .createAlias($_aliasNameGenerator(db.rooms.roomTypeId, db.roomTypes.id));

  $$RoomTypesTableProcessedTableManager get roomTypeId {
    final $_column = $_itemColumn<String>('room_type_id')!;

    final manager = $$RoomTypesTableTableManager(
      $_db,
      $_db.roomTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roomTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ReservationRoomsTable, List<ReservationRoom>>
  _reservationRoomsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reservationRooms,
    aliasName: $_aliasNameGenerator(db.rooms.id, db.reservationRooms.roomId),
  );

  $$ReservationRoomsTableProcessedTableManager get reservationRoomsRefs {
    final manager = $$ReservationRoomsTableTableManager(
      $_db,
      $_db.reservationRooms,
    ).filter((f) => f.roomId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _reservationRoomsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoomsTableFilterComposer extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ratePerPersonWeekdayCents => $composableBuilder(
    column: $table.ratePerPersonWeekdayCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ratePerPersonWeekendCents => $composableBuilder(
    column: $table.ratePerPersonWeekendCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  $$PropertiesTableFilterComposer get propertyId {
    final $$PropertiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.propertyId,
      referencedTable: $db.properties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PropertiesTableFilterComposer(
            $db: $db,
            $table: $db.properties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoomTypesTableFilterComposer get roomTypeId {
    final $$RoomTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomTypeId,
      referencedTable: $db.roomTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomTypesTableFilterComposer(
            $db: $db,
            $table: $db.roomTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> reservationRoomsRefs(
    Expression<bool> Function($$ReservationRoomsTableFilterComposer f) f,
  ) {
    final $$ReservationRoomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reservationRooms,
      getReferencedColumn: (t) => t.roomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReservationRoomsTableFilterComposer(
            $db: $db,
            $table: $db.reservationRooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoomsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ratePerPersonWeekdayCents => $composableBuilder(
    column: $table.ratePerPersonWeekdayCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ratePerPersonWeekendCents => $composableBuilder(
    column: $table.ratePerPersonWeekendCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  $$PropertiesTableOrderingComposer get propertyId {
    final $$PropertiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.propertyId,
      referencedTable: $db.properties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PropertiesTableOrderingComposer(
            $db: $db,
            $table: $db.properties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoomTypesTableOrderingComposer get roomTypeId {
    final $$RoomTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomTypeId,
      referencedTable: $db.roomTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomTypesTableOrderingComposer(
            $db: $db,
            $table: $db.roomTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get capacity =>
      $composableBuilder(column: $table.capacity, builder: (column) => column);

  GeneratedColumn<int> get ratePerPersonWeekdayCents => $composableBuilder(
    column: $table.ratePerPersonWeekdayCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ratePerPersonWeekendCents => $composableBuilder(
    column: $table.ratePerPersonWeekendCents,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  $$PropertiesTableAnnotationComposer get propertyId {
    final $$PropertiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.propertyId,
      referencedTable: $db.properties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PropertiesTableAnnotationComposer(
            $db: $db,
            $table: $db.properties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoomTypesTableAnnotationComposer get roomTypeId {
    final $$RoomTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomTypeId,
      referencedTable: $db.roomTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.roomTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> reservationRoomsRefs<T extends Object>(
    Expression<T> Function($$ReservationRoomsTableAnnotationComposer a) f,
  ) {
    final $$ReservationRoomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reservationRooms,
      getReferencedColumn: (t) => t.roomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReservationRoomsTableAnnotationComposer(
            $db: $db,
            $table: $db.reservationRooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoomsTable,
          Room,
          $$RoomsTableFilterComposer,
          $$RoomsTableOrderingComposer,
          $$RoomsTableAnnotationComposer,
          $$RoomsTableCreateCompanionBuilder,
          $$RoomsTableUpdateCompanionBuilder,
          (Room, $$RoomsTableReferences),
          Room,
          PrefetchHooks Function({
            bool propertyId,
            bool roomTypeId,
            bool reservationRoomsRefs,
          })
        > {
  $$RoomsTableTableManager(_$AppDatabase db, $RoomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> propertyId = const Value.absent(),
                Value<String> roomTypeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> capacity = const Value.absent(),
                Value<int> ratePerPersonWeekdayCents = const Value.absent(),
                Value<int> ratePerPersonWeekendCents = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoomsCompanion(
                id: id,
                propertyId: propertyId,
                roomTypeId: roomTypeId,
                name: name,
                capacity: capacity,
                ratePerPersonWeekdayCents: ratePerPersonWeekdayCents,
                ratePerPersonWeekendCents: ratePerPersonWeekendCents,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String propertyId,
                required String roomTypeId,
                required String name,
                required int capacity,
                required int ratePerPersonWeekdayCents,
                required int ratePerPersonWeekendCents,
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoomsCompanion.insert(
                id: id,
                propertyId: propertyId,
                roomTypeId: roomTypeId,
                name: name,
                capacity: capacity,
                ratePerPersonWeekdayCents: ratePerPersonWeekdayCents,
                ratePerPersonWeekendCents: ratePerPersonWeekendCents,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$RoomsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                propertyId = false,
                roomTypeId = false,
                reservationRoomsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (reservationRoomsRefs) db.reservationRooms,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (propertyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.propertyId,
                                    referencedTable: $$RoomsTableReferences
                                        ._propertyIdTable(db),
                                    referencedColumn: $$RoomsTableReferences
                                        ._propertyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (roomTypeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.roomTypeId,
                                    referencedTable: $$RoomsTableReferences
                                        ._roomTypeIdTable(db),
                                    referencedColumn: $$RoomsTableReferences
                                        ._roomTypeIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (reservationRoomsRefs)
                        await $_getPrefetchedData<
                          Room,
                          $RoomsTable,
                          ReservationRoom
                        >(
                          currentTable: table,
                          referencedTable: $$RoomsTableReferences
                              ._reservationRoomsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoomsTableReferences(
                                db,
                                table,
                                p0,
                              ).reservationRoomsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.roomId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RoomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoomsTable,
      Room,
      $$RoomsTableFilterComposer,
      $$RoomsTableOrderingComposer,
      $$RoomsTableAnnotationComposer,
      $$RoomsTableCreateCompanionBuilder,
      $$RoomsTableUpdateCompanionBuilder,
      (Room, $$RoomsTableReferences),
      Room,
      PrefetchHooks Function({
        bool propertyId,
        bool roomTypeId,
        bool reservationRoomsRefs,
      })
    >;
typedef $$GuestsTableCreateCompanionBuilder =
    GuestsCompanion Function({
      Value<String> id,
      required String fullName,
      Value<String?> documentId,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$GuestsTableUpdateCompanionBuilder =
    GuestsCompanion Function({
      Value<String> id,
      Value<String> fullName,
      Value<String?> documentId,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$GuestsTableReferences
    extends BaseReferences<_$AppDatabase, $GuestsTable, Guest> {
  $$GuestsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReservationsTable, List<Reservation>>
  _reservationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reservations,
    aliasName: $_aliasNameGenerator(db.guests.id, db.reservations.guestId),
  );

  $$ReservationsTableProcessedTableManager get reservationsRefs {
    final manager = $$ReservationsTableTableManager(
      $_db,
      $_db.reservations,
    ).filter((f) => f.guestId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reservationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GuestsTableFilterComposer
    extends Composer<_$AppDatabase, $GuestsTable> {
  $$GuestsTableFilterComposer({
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

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> reservationsRefs(
    Expression<bool> Function($$ReservationsTableFilterComposer f) f,
  ) {
    final $$ReservationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reservations,
      getReferencedColumn: (t) => t.guestId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReservationsTableFilterComposer(
            $db: $db,
            $table: $db.reservations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GuestsTableOrderingComposer
    extends Composer<_$AppDatabase, $GuestsTable> {
  $$GuestsTableOrderingComposer({
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

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GuestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GuestsTable> {
  $$GuestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> reservationsRefs<T extends Object>(
    Expression<T> Function($$ReservationsTableAnnotationComposer a) f,
  ) {
    final $$ReservationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reservations,
      getReferencedColumn: (t) => t.guestId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReservationsTableAnnotationComposer(
            $db: $db,
            $table: $db.reservations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GuestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GuestsTable,
          Guest,
          $$GuestsTableFilterComposer,
          $$GuestsTableOrderingComposer,
          $$GuestsTableAnnotationComposer,
          $$GuestsTableCreateCompanionBuilder,
          $$GuestsTableUpdateCompanionBuilder,
          (Guest, $$GuestsTableReferences),
          Guest,
          PrefetchHooks Function({bool reservationsRefs})
        > {
  $$GuestsTableTableManager(_$AppDatabase db, $GuestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GuestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GuestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GuestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String?> documentId = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GuestsCompanion(
                id: id,
                fullName: fullName,
                documentId: documentId,
                phone: phone,
                email: email,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String fullName,
                Value<String?> documentId = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GuestsCompanion.insert(
                id: id,
                fullName: fullName,
                documentId: documentId,
                phone: phone,
                email: email,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GuestsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({reservationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (reservationsRefs) db.reservations],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (reservationsRefs)
                    await $_getPrefetchedData<Guest, $GuestsTable, Reservation>(
                      currentTable: table,
                      referencedTable: $$GuestsTableReferences
                          ._reservationsRefsTable(db),
                      managerFromTypedResult: (p0) => $$GuestsTableReferences(
                        db,
                        table,
                        p0,
                      ).reservationsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.guestId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GuestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GuestsTable,
      Guest,
      $$GuestsTableFilterComposer,
      $$GuestsTableOrderingComposer,
      $$GuestsTableAnnotationComposer,
      $$GuestsTableCreateCompanionBuilder,
      $$GuestsTableUpdateCompanionBuilder,
      (Guest, $$GuestsTableReferences),
      Guest,
      PrefetchHooks Function({bool reservationsRefs})
    >;
typedef $$ReservationsTableCreateCompanionBuilder =
    ReservationsCompanion Function({
      Value<String> id,
      required String guestId,
      required DateTime checkInDate,
      required DateTime checkOutDate,
      Value<ReservationStatus> status,
      required int totalPriceCents,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$ReservationsTableUpdateCompanionBuilder =
    ReservationsCompanion Function({
      Value<String> id,
      Value<String> guestId,
      Value<DateTime> checkInDate,
      Value<DateTime> checkOutDate,
      Value<ReservationStatus> status,
      Value<int> totalPriceCents,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ReservationsTableReferences
    extends BaseReferences<_$AppDatabase, $ReservationsTable, Reservation> {
  $$ReservationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GuestsTable _guestIdTable(_$AppDatabase db) => db.guests.createAlias(
    $_aliasNameGenerator(db.reservations.guestId, db.guests.id),
  );

  $$GuestsTableProcessedTableManager get guestId {
    final $_column = $_itemColumn<String>('guest_id')!;

    final manager = $$GuestsTableTableManager(
      $_db,
      $_db.guests,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_guestIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ReservationRoomsTable, List<ReservationRoom>>
  _reservationRoomsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.reservationRooms,
    aliasName: $_aliasNameGenerator(
      db.reservations.id,
      db.reservationRooms.reservationId,
    ),
  );

  $$ReservationRoomsTableProcessedTableManager get reservationRoomsRefs {
    final manager = $$ReservationRoomsTableTableManager(
      $_db,
      $_db.reservationRooms,
    ).filter((f) => f.reservationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _reservationRoomsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: $_aliasNameGenerator(
      db.reservations.id,
      db.payments.reservationId,
    ),
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.reservationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ReservationsTableFilterComposer
    extends Composer<_$AppDatabase, $ReservationsTable> {
  $$ReservationsTableFilterComposer({
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

  ColumnFilters<DateTime> get checkInDate => $composableBuilder(
    column: $table.checkInDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkOutDate => $composableBuilder(
    column: $table.checkOutDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReservationStatus, ReservationStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get totalPriceCents => $composableBuilder(
    column: $table.totalPriceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GuestsTableFilterComposer get guestId {
    final $$GuestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.guestId,
      referencedTable: $db.guests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GuestsTableFilterComposer(
            $db: $db,
            $table: $db.guests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> reservationRoomsRefs(
    Expression<bool> Function($$ReservationRoomsTableFilterComposer f) f,
  ) {
    final $$ReservationRoomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reservationRooms,
      getReferencedColumn: (t) => t.reservationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReservationRoomsTableFilterComposer(
            $db: $db,
            $table: $db.reservationRooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.reservationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReservationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReservationsTable> {
  $$ReservationsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get checkInDate => $composableBuilder(
    column: $table.checkInDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkOutDate => $composableBuilder(
    column: $table.checkOutDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPriceCents => $composableBuilder(
    column: $table.totalPriceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GuestsTableOrderingComposer get guestId {
    final $$GuestsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.guestId,
      referencedTable: $db.guests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GuestsTableOrderingComposer(
            $db: $db,
            $table: $db.guests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReservationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReservationsTable> {
  $$ReservationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get checkInDate => $composableBuilder(
    column: $table.checkInDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get checkOutDate => $composableBuilder(
    column: $table.checkOutDate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ReservationStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get totalPriceCents => $composableBuilder(
    column: $table.totalPriceCents,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GuestsTableAnnotationComposer get guestId {
    final $$GuestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.guestId,
      referencedTable: $db.guests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GuestsTableAnnotationComposer(
            $db: $db,
            $table: $db.guests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> reservationRoomsRefs<T extends Object>(
    Expression<T> Function($$ReservationRoomsTableAnnotationComposer a) f,
  ) {
    final $$ReservationRoomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reservationRooms,
      getReferencedColumn: (t) => t.reservationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReservationRoomsTableAnnotationComposer(
            $db: $db,
            $table: $db.reservationRooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.reservationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReservationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReservationsTable,
          Reservation,
          $$ReservationsTableFilterComposer,
          $$ReservationsTableOrderingComposer,
          $$ReservationsTableAnnotationComposer,
          $$ReservationsTableCreateCompanionBuilder,
          $$ReservationsTableUpdateCompanionBuilder,
          (Reservation, $$ReservationsTableReferences),
          Reservation,
          PrefetchHooks Function({
            bool guestId,
            bool reservationRoomsRefs,
            bool paymentsRefs,
          })
        > {
  $$ReservationsTableTableManager(_$AppDatabase db, $ReservationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReservationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReservationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReservationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> guestId = const Value.absent(),
                Value<DateTime> checkInDate = const Value.absent(),
                Value<DateTime> checkOutDate = const Value.absent(),
                Value<ReservationStatus> status = const Value.absent(),
                Value<int> totalPriceCents = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReservationsCompanion(
                id: id,
                guestId: guestId,
                checkInDate: checkInDate,
                checkOutDate: checkOutDate,
                status: status,
                totalPriceCents: totalPriceCents,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String guestId,
                required DateTime checkInDate,
                required DateTime checkOutDate,
                Value<ReservationStatus> status = const Value.absent(),
                required int totalPriceCents,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReservationsCompanion.insert(
                id: id,
                guestId: guestId,
                checkInDate: checkInDate,
                checkOutDate: checkOutDate,
                status: status,
                totalPriceCents: totalPriceCents,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReservationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                guestId = false,
                reservationRoomsRefs = false,
                paymentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (reservationRoomsRefs) db.reservationRooms,
                    if (paymentsRefs) db.payments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (guestId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.guestId,
                                    referencedTable:
                                        $$ReservationsTableReferences
                                            ._guestIdTable(db),
                                    referencedColumn:
                                        $$ReservationsTableReferences
                                            ._guestIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (reservationRoomsRefs)
                        await $_getPrefetchedData<
                          Reservation,
                          $ReservationsTable,
                          ReservationRoom
                        >(
                          currentTable: table,
                          referencedTable: $$ReservationsTableReferences
                              ._reservationRoomsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ReservationsTableReferences(
                                db,
                                table,
                                p0,
                              ).reservationRoomsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.reservationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (paymentsRefs)
                        await $_getPrefetchedData<
                          Reservation,
                          $ReservationsTable,
                          Payment
                        >(
                          currentTable: table,
                          referencedTable: $$ReservationsTableReferences
                              ._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ReservationsTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.reservationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ReservationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReservationsTable,
      Reservation,
      $$ReservationsTableFilterComposer,
      $$ReservationsTableOrderingComposer,
      $$ReservationsTableAnnotationComposer,
      $$ReservationsTableCreateCompanionBuilder,
      $$ReservationsTableUpdateCompanionBuilder,
      (Reservation, $$ReservationsTableReferences),
      Reservation,
      PrefetchHooks Function({
        bool guestId,
        bool reservationRoomsRefs,
        bool paymentsRefs,
      })
    >;
typedef $$ReservationRoomsTableCreateCompanionBuilder =
    ReservationRoomsCompanion Function({
      Value<String> id,
      required String reservationId,
      required String roomId,
      required int guestsCount,
      required int subtotalCents,
      Value<int> rowid,
    });
typedef $$ReservationRoomsTableUpdateCompanionBuilder =
    ReservationRoomsCompanion Function({
      Value<String> id,
      Value<String> reservationId,
      Value<String> roomId,
      Value<int> guestsCount,
      Value<int> subtotalCents,
      Value<int> rowid,
    });

final class $$ReservationRoomsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ReservationRoomsTable, ReservationRoom> {
  $$ReservationRoomsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ReservationsTable _reservationIdTable(_$AppDatabase db) =>
      db.reservations.createAlias(
        $_aliasNameGenerator(
          db.reservationRooms.reservationId,
          db.reservations.id,
        ),
      );

  $$ReservationsTableProcessedTableManager get reservationId {
    final $_column = $_itemColumn<String>('reservation_id')!;

    final manager = $$ReservationsTableTableManager(
      $_db,
      $_db.reservations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reservationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RoomsTable _roomIdTable(_$AppDatabase db) => db.rooms.createAlias(
    $_aliasNameGenerator(db.reservationRooms.roomId, db.rooms.id),
  );

  $$RoomsTableProcessedTableManager get roomId {
    final $_column = $_itemColumn<String>('room_id')!;

    final manager = $$RoomsTableTableManager(
      $_db,
      $_db.rooms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roomIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReservationRoomsTableFilterComposer
    extends Composer<_$AppDatabase, $ReservationRoomsTable> {
  $$ReservationRoomsTableFilterComposer({
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

  ColumnFilters<int> get guestsCount => $composableBuilder(
    column: $table.guestsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subtotalCents => $composableBuilder(
    column: $table.subtotalCents,
    builder: (column) => ColumnFilters(column),
  );

  $$ReservationsTableFilterComposer get reservationId {
    final $$ReservationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reservationId,
      referencedTable: $db.reservations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReservationsTableFilterComposer(
            $db: $db,
            $table: $db.reservations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoomsTableFilterComposer get roomId {
    final $$RoomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomsTableFilterComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReservationRoomsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReservationRoomsTable> {
  $$ReservationRoomsTableOrderingComposer({
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

  ColumnOrderings<int> get guestsCount => $composableBuilder(
    column: $table.guestsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subtotalCents => $composableBuilder(
    column: $table.subtotalCents,
    builder: (column) => ColumnOrderings(column),
  );

  $$ReservationsTableOrderingComposer get reservationId {
    final $$ReservationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reservationId,
      referencedTable: $db.reservations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReservationsTableOrderingComposer(
            $db: $db,
            $table: $db.reservations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoomsTableOrderingComposer get roomId {
    final $$RoomsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomsTableOrderingComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReservationRoomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReservationRoomsTable> {
  $$ReservationRoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get guestsCount => $composableBuilder(
    column: $table.guestsCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get subtotalCents => $composableBuilder(
    column: $table.subtotalCents,
    builder: (column) => column,
  );

  $$ReservationsTableAnnotationComposer get reservationId {
    final $$ReservationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reservationId,
      referencedTable: $db.reservations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReservationsTableAnnotationComposer(
            $db: $db,
            $table: $db.reservations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoomsTableAnnotationComposer get roomId {
    final $$RoomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomsTableAnnotationComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReservationRoomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReservationRoomsTable,
          ReservationRoom,
          $$ReservationRoomsTableFilterComposer,
          $$ReservationRoomsTableOrderingComposer,
          $$ReservationRoomsTableAnnotationComposer,
          $$ReservationRoomsTableCreateCompanionBuilder,
          $$ReservationRoomsTableUpdateCompanionBuilder,
          (ReservationRoom, $$ReservationRoomsTableReferences),
          ReservationRoom,
          PrefetchHooks Function({bool reservationId, bool roomId})
        > {
  $$ReservationRoomsTableTableManager(
    _$AppDatabase db,
    $ReservationRoomsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReservationRoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReservationRoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReservationRoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> reservationId = const Value.absent(),
                Value<String> roomId = const Value.absent(),
                Value<int> guestsCount = const Value.absent(),
                Value<int> subtotalCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReservationRoomsCompanion(
                id: id,
                reservationId: reservationId,
                roomId: roomId,
                guestsCount: guestsCount,
                subtotalCents: subtotalCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String reservationId,
                required String roomId,
                required int guestsCount,
                required int subtotalCents,
                Value<int> rowid = const Value.absent(),
              }) => ReservationRoomsCompanion.insert(
                id: id,
                reservationId: reservationId,
                roomId: roomId,
                guestsCount: guestsCount,
                subtotalCents: subtotalCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReservationRoomsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({reservationId = false, roomId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (reservationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.reservationId,
                                referencedTable:
                                    $$ReservationRoomsTableReferences
                                        ._reservationIdTable(db),
                                referencedColumn:
                                    $$ReservationRoomsTableReferences
                                        ._reservationIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (roomId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.roomId,
                                referencedTable:
                                    $$ReservationRoomsTableReferences
                                        ._roomIdTable(db),
                                referencedColumn:
                                    $$ReservationRoomsTableReferences
                                        ._roomIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReservationRoomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReservationRoomsTable,
      ReservationRoom,
      $$ReservationRoomsTableFilterComposer,
      $$ReservationRoomsTableOrderingComposer,
      $$ReservationRoomsTableAnnotationComposer,
      $$ReservationRoomsTableCreateCompanionBuilder,
      $$ReservationRoomsTableUpdateCompanionBuilder,
      (ReservationRoom, $$ReservationRoomsTableReferences),
      ReservationRoom,
      PrefetchHooks Function({bool reservationId, bool roomId})
    >;
typedef $$PaymentsTableCreateCompanionBuilder =
    PaymentsCompanion Function({
      Value<String> id,
      required String reservationId,
      required int amountCents,
      required PaymentMethod method,
      Value<DateTime> paidAt,
      Value<int> rowid,
    });
typedef $$PaymentsTableUpdateCompanionBuilder =
    PaymentsCompanion Function({
      Value<String> id,
      Value<String> reservationId,
      Value<int> amountCents,
      Value<PaymentMethod> method,
      Value<DateTime> paidAt,
      Value<int> rowid,
    });

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, Payment> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ReservationsTable _reservationIdTable(_$AppDatabase db) =>
      db.reservations.createAlias(
        $_aliasNameGenerator(db.payments.reservationId, db.reservations.id),
      );

  $$ReservationsTableProcessedTableManager get reservationId {
    final $_column = $_itemColumn<String>('reservation_id')!;

    final manager = $$ReservationsTableTableManager(
      $_db,
      $_db.reservations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reservationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
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

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentMethod, PaymentMethod, String>
  get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ReservationsTableFilterComposer get reservationId {
    final $$ReservationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reservationId,
      referencedTable: $db.reservations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReservationsTableFilterComposer(
            $db: $db,
            $table: $db.reservations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
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

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ReservationsTableOrderingComposer get reservationId {
    final $$ReservationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reservationId,
      referencedTable: $db.reservations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReservationsTableOrderingComposer(
            $db: $db,
            $table: $db.reservations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PaymentMethod, String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  $$ReservationsTableAnnotationComposer get reservationId {
    final $$ReservationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reservationId,
      referencedTable: $db.reservations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReservationsTableAnnotationComposer(
            $db: $db,
            $table: $db.reservations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          Payment,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (Payment, $$PaymentsTableReferences),
          Payment,
          PrefetchHooks Function({bool reservationId})
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> reservationId = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<PaymentMethod> method = const Value.absent(),
                Value<DateTime> paidAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                reservationId: reservationId,
                amountCents: amountCents,
                method: method,
                paidAt: paidAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String reservationId,
                required int amountCents,
                required PaymentMethod method,
                Value<DateTime> paidAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                reservationId: reservationId,
                amountCents: amountCents,
                method: method,
                paidAt: paidAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({reservationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (reservationId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.reservationId,
                                referencedTable: $$PaymentsTableReferences
                                    ._reservationIdTable(db),
                                referencedColumn: $$PaymentsTableReferences
                                    ._reservationIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      Payment,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (Payment, $$PaymentsTableReferences),
      Payment,
      PrefetchHooks Function({bool reservationId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> id,
      Value<String> currency,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> id,
      Value<String> currency,
      Value<int> rowid,
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
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);
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
                Value<String> id = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                currency: currency,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                currency: currency,
                rowid: rowid,
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
  $$PropertiesTableTableManager get properties =>
      $$PropertiesTableTableManager(_db, _db.properties);
  $$RoomTypesTableTableManager get roomTypes =>
      $$RoomTypesTableTableManager(_db, _db.roomTypes);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db, _db.rooms);
  $$GuestsTableTableManager get guests =>
      $$GuestsTableTableManager(_db, _db.guests);
  $$ReservationsTableTableManager get reservations =>
      $$ReservationsTableTableManager(_db, _db.reservations);
  $$ReservationRoomsTableTableManager get reservationRooms =>
      $$ReservationRoomsTableTableManager(_db, _db.reservationRooms);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
