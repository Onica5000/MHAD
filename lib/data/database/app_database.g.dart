// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DirectivesTable extends Directives
    with TableInfo<$DirectivesTable, Directive> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DirectivesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _formTypeMeta = const VerificationMeta(
    'formType',
  );
  @override
  late final GeneratedColumn<String> formType = GeneratedColumn<String>(
    'form_type',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _executionDateMeta = const VerificationMeta(
    'executionDate',
  );
  @override
  late final GeneratedColumn<int> executionDate = GeneratedColumn<int>(
    'execution_date',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expirationDateMeta = const VerificationMeta(
    'expirationDate',
  );
  @override
  late final GeneratedColumn<int> expirationDate = GeneratedColumn<int>(
    'expiration_date',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<String> dateOfBirth = GeneratedColumn<String>(
    'date_of_birth',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _address2Meta = const VerificationMeta(
    'address2',
  );
  @override
  late final GeneratedColumn<String> address2 = GeneratedColumn<String>(
    'address2',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PA'),
  );
  static const VerificationMeta _zipMeta = const VerificationMeta('zip');
  @override
  late final GeneratedColumn<String> zip = GeneratedColumn<String>(
    'zip',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _effectiveConditionMeta =
      const VerificationMeta('effectiveCondition');
  @override
  late final GeneratedColumn<String> effectiveCondition =
      GeneratedColumn<String>(
        'effective_condition',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _lastStepIndexMeta = const VerificationMeta(
    'lastStepIndex',
  );
  @override
  late final GeneratedColumn<int> lastStepIndex = GeneratedColumn<int>(
    'last_step_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    formType,
    status,
    createdAt,
    updatedAt,
    executionDate,
    expirationDate,
    fullName,
    dateOfBirth,
    address,
    address2,
    city,
    state,
    zip,
    phone,
    effectiveCondition,
    lastStepIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'directives';
  @override
  VerificationContext validateIntegrity(
    Insertable<Directive> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('form_type')) {
      context.handle(
        _formTypeMeta,
        formType.isAcceptableOrUnknown(data['form_type']!, _formTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_formTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('execution_date')) {
      context.handle(
        _executionDateMeta,
        executionDate.isAcceptableOrUnknown(
          data['execution_date']!,
          _executionDateMeta,
        ),
      );
    }
    if (data.containsKey('expiration_date')) {
      context.handle(
        _expirationDateMeta,
        expirationDate.isAcceptableOrUnknown(
          data['expiration_date']!,
          _expirationDateMeta,
        ),
      );
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('address2')) {
      context.handle(
        _address2Meta,
        address2.isAcceptableOrUnknown(data['address2']!, _address2Meta),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('zip')) {
      context.handle(
        _zipMeta,
        zip.isAcceptableOrUnknown(data['zip']!, _zipMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('effective_condition')) {
      context.handle(
        _effectiveConditionMeta,
        effectiveCondition.isAcceptableOrUnknown(
          data['effective_condition']!,
          _effectiveConditionMeta,
        ),
      );
    }
    if (data.containsKey('last_step_index')) {
      context.handle(
        _lastStepIndexMeta,
        lastStepIndex.isAcceptableOrUnknown(
          data['last_step_index']!,
          _lastStepIndexMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Directive map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Directive(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      formType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}form_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      executionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}execution_date'],
      ),
      expirationDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expiration_date'],
      ),
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_of_birth'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      address2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address2'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      zip: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zip'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      effectiveCondition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effective_condition'],
      )!,
      lastStepIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_step_index'],
      )!,
    );
  }

  @override
  $DirectivesTable createAlias(String alias) {
    return $DirectivesTable(attachedDatabase, alias);
  }
}

class Directive extends DataClass implements Insertable<Directive> {
  final int id;
  final String formType;
  final String status;
  final int createdAt;
  final int updatedAt;
  final int? executionDate;
  final int? expirationDate;
  final String fullName;
  final String dateOfBirth;
  final String address;
  final String address2;
  final String city;
  final String state;
  final String zip;
  final String phone;
  final String effectiveCondition;
  final int lastStepIndex;
  const Directive({
    required this.id,
    required this.formType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.executionDate,
    this.expirationDate,
    required this.fullName,
    required this.dateOfBirth,
    required this.address,
    required this.address2,
    required this.city,
    required this.state,
    required this.zip,
    required this.phone,
    required this.effectiveCondition,
    required this.lastStepIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['form_type'] = Variable<String>(formType);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || executionDate != null) {
      map['execution_date'] = Variable<int>(executionDate);
    }
    if (!nullToAbsent || expirationDate != null) {
      map['expiration_date'] = Variable<int>(expirationDate);
    }
    map['full_name'] = Variable<String>(fullName);
    map['date_of_birth'] = Variable<String>(dateOfBirth);
    map['address'] = Variable<String>(address);
    map['address2'] = Variable<String>(address2);
    map['city'] = Variable<String>(city);
    map['state'] = Variable<String>(state);
    map['zip'] = Variable<String>(zip);
    map['phone'] = Variable<String>(phone);
    map['effective_condition'] = Variable<String>(effectiveCondition);
    map['last_step_index'] = Variable<int>(lastStepIndex);
    return map;
  }

  DirectivesCompanion toCompanion(bool nullToAbsent) {
    return DirectivesCompanion(
      id: Value(id),
      formType: Value(formType),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      executionDate: executionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(executionDate),
      expirationDate: expirationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expirationDate),
      fullName: Value(fullName),
      dateOfBirth: Value(dateOfBirth),
      address: Value(address),
      address2: Value(address2),
      city: Value(city),
      state: Value(state),
      zip: Value(zip),
      phone: Value(phone),
      effectiveCondition: Value(effectiveCondition),
      lastStepIndex: Value(lastStepIndex),
    );
  }

  factory Directive.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Directive(
      id: serializer.fromJson<int>(json['id']),
      formType: serializer.fromJson<String>(json['formType']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      executionDate: serializer.fromJson<int?>(json['executionDate']),
      expirationDate: serializer.fromJson<int?>(json['expirationDate']),
      fullName: serializer.fromJson<String>(json['fullName']),
      dateOfBirth: serializer.fromJson<String>(json['dateOfBirth']),
      address: serializer.fromJson<String>(json['address']),
      address2: serializer.fromJson<String>(json['address2']),
      city: serializer.fromJson<String>(json['city']),
      state: serializer.fromJson<String>(json['state']),
      zip: serializer.fromJson<String>(json['zip']),
      phone: serializer.fromJson<String>(json['phone']),
      effectiveCondition: serializer.fromJson<String>(
        json['effectiveCondition'],
      ),
      lastStepIndex: serializer.fromJson<int>(json['lastStepIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'formType': serializer.toJson<String>(formType),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'executionDate': serializer.toJson<int?>(executionDate),
      'expirationDate': serializer.toJson<int?>(expirationDate),
      'fullName': serializer.toJson<String>(fullName),
      'dateOfBirth': serializer.toJson<String>(dateOfBirth),
      'address': serializer.toJson<String>(address),
      'address2': serializer.toJson<String>(address2),
      'city': serializer.toJson<String>(city),
      'state': serializer.toJson<String>(state),
      'zip': serializer.toJson<String>(zip),
      'phone': serializer.toJson<String>(phone),
      'effectiveCondition': serializer.toJson<String>(effectiveCondition),
      'lastStepIndex': serializer.toJson<int>(lastStepIndex),
    };
  }

  Directive copyWith({
    int? id,
    String? formType,
    String? status,
    int? createdAt,
    int? updatedAt,
    Value<int?> executionDate = const Value.absent(),
    Value<int?> expirationDate = const Value.absent(),
    String? fullName,
    String? dateOfBirth,
    String? address,
    String? address2,
    String? city,
    String? state,
    String? zip,
    String? phone,
    String? effectiveCondition,
    int? lastStepIndex,
  }) => Directive(
    id: id ?? this.id,
    formType: formType ?? this.formType,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    executionDate: executionDate.present
        ? executionDate.value
        : this.executionDate,
    expirationDate: expirationDate.present
        ? expirationDate.value
        : this.expirationDate,
    fullName: fullName ?? this.fullName,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    address: address ?? this.address,
    address2: address2 ?? this.address2,
    city: city ?? this.city,
    state: state ?? this.state,
    zip: zip ?? this.zip,
    phone: phone ?? this.phone,
    effectiveCondition: effectiveCondition ?? this.effectiveCondition,
    lastStepIndex: lastStepIndex ?? this.lastStepIndex,
  );
  Directive copyWithCompanion(DirectivesCompanion data) {
    return Directive(
      id: data.id.present ? data.id.value : this.id,
      formType: data.formType.present ? data.formType.value : this.formType,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      executionDate: data.executionDate.present
          ? data.executionDate.value
          : this.executionDate,
      expirationDate: data.expirationDate.present
          ? data.expirationDate.value
          : this.expirationDate,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      dateOfBirth: data.dateOfBirth.present
          ? data.dateOfBirth.value
          : this.dateOfBirth,
      address: data.address.present ? data.address.value : this.address,
      address2: data.address2.present ? data.address2.value : this.address2,
      city: data.city.present ? data.city.value : this.city,
      state: data.state.present ? data.state.value : this.state,
      zip: data.zip.present ? data.zip.value : this.zip,
      phone: data.phone.present ? data.phone.value : this.phone,
      effectiveCondition: data.effectiveCondition.present
          ? data.effectiveCondition.value
          : this.effectiveCondition,
      lastStepIndex: data.lastStepIndex.present
          ? data.lastStepIndex.value
          : this.lastStepIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Directive(')
          ..write('id: $id, ')
          ..write('formType: $formType, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('executionDate: $executionDate, ')
          ..write('expirationDate: $expirationDate, ')
          ..write('fullName: $fullName, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('address: $address, ')
          ..write('address2: $address2, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('zip: $zip, ')
          ..write('phone: $phone, ')
          ..write('effectiveCondition: $effectiveCondition, ')
          ..write('lastStepIndex: $lastStepIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    formType,
    status,
    createdAt,
    updatedAt,
    executionDate,
    expirationDate,
    fullName,
    dateOfBirth,
    address,
    address2,
    city,
    state,
    zip,
    phone,
    effectiveCondition,
    lastStepIndex,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Directive &&
          other.id == this.id &&
          other.formType == this.formType &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.executionDate == this.executionDate &&
          other.expirationDate == this.expirationDate &&
          other.fullName == this.fullName &&
          other.dateOfBirth == this.dateOfBirth &&
          other.address == this.address &&
          other.address2 == this.address2 &&
          other.city == this.city &&
          other.state == this.state &&
          other.zip == this.zip &&
          other.phone == this.phone &&
          other.effectiveCondition == this.effectiveCondition &&
          other.lastStepIndex == this.lastStepIndex);
}

class DirectivesCompanion extends UpdateCompanion<Directive> {
  final Value<int> id;
  final Value<String> formType;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> executionDate;
  final Value<int?> expirationDate;
  final Value<String> fullName;
  final Value<String> dateOfBirth;
  final Value<String> address;
  final Value<String> address2;
  final Value<String> city;
  final Value<String> state;
  final Value<String> zip;
  final Value<String> phone;
  final Value<String> effectiveCondition;
  final Value<int> lastStepIndex;
  const DirectivesCompanion({
    this.id = const Value.absent(),
    this.formType = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.executionDate = const Value.absent(),
    this.expirationDate = const Value.absent(),
    this.fullName = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.address = const Value.absent(),
    this.address2 = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.zip = const Value.absent(),
    this.phone = const Value.absent(),
    this.effectiveCondition = const Value.absent(),
    this.lastStepIndex = const Value.absent(),
  });
  DirectivesCompanion.insert({
    this.id = const Value.absent(),
    required String formType,
    this.status = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.executionDate = const Value.absent(),
    this.expirationDate = const Value.absent(),
    this.fullName = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.address = const Value.absent(),
    this.address2 = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.zip = const Value.absent(),
    this.phone = const Value.absent(),
    this.effectiveCondition = const Value.absent(),
    this.lastStepIndex = const Value.absent(),
  }) : formType = Value(formType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Directive> custom({
    Expression<int>? id,
    Expression<String>? formType,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? executionDate,
    Expression<int>? expirationDate,
    Expression<String>? fullName,
    Expression<String>? dateOfBirth,
    Expression<String>? address,
    Expression<String>? address2,
    Expression<String>? city,
    Expression<String>? state,
    Expression<String>? zip,
    Expression<String>? phone,
    Expression<String>? effectiveCondition,
    Expression<int>? lastStepIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (formType != null) 'form_type': formType,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (executionDate != null) 'execution_date': executionDate,
      if (expirationDate != null) 'expiration_date': expirationDate,
      if (fullName != null) 'full_name': fullName,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (address != null) 'address': address,
      if (address2 != null) 'address2': address2,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (zip != null) 'zip': zip,
      if (phone != null) 'phone': phone,
      if (effectiveCondition != null) 'effective_condition': effectiveCondition,
      if (lastStepIndex != null) 'last_step_index': lastStepIndex,
    });
  }

  DirectivesCompanion copyWith({
    Value<int>? id,
    Value<String>? formType,
    Value<String>? status,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? executionDate,
    Value<int?>? expirationDate,
    Value<String>? fullName,
    Value<String>? dateOfBirth,
    Value<String>? address,
    Value<String>? address2,
    Value<String>? city,
    Value<String>? state,
    Value<String>? zip,
    Value<String>? phone,
    Value<String>? effectiveCondition,
    Value<int>? lastStepIndex,
  }) {
    return DirectivesCompanion(
      id: id ?? this.id,
      formType: formType ?? this.formType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      executionDate: executionDate ?? this.executionDate,
      expirationDate: expirationDate ?? this.expirationDate,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      address2: address2 ?? this.address2,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
      phone: phone ?? this.phone,
      effectiveCondition: effectiveCondition ?? this.effectiveCondition,
      lastStepIndex: lastStepIndex ?? this.lastStepIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (formType.present) {
      map['form_type'] = Variable<String>(formType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (executionDate.present) {
      map['execution_date'] = Variable<int>(executionDate.value);
    }
    if (expirationDate.present) {
      map['expiration_date'] = Variable<int>(expirationDate.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<String>(dateOfBirth.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (address2.present) {
      map['address2'] = Variable<String>(address2.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (zip.present) {
      map['zip'] = Variable<String>(zip.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (effectiveCondition.present) {
      map['effective_condition'] = Variable<String>(effectiveCondition.value);
    }
    if (lastStepIndex.present) {
      map['last_step_index'] = Variable<int>(lastStepIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DirectivesCompanion(')
          ..write('id: $id, ')
          ..write('formType: $formType, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('executionDate: $executionDate, ')
          ..write('expirationDate: $expirationDate, ')
          ..write('fullName: $fullName, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('address: $address, ')
          ..write('address2: $address2, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('zip: $zip, ')
          ..write('phone: $phone, ')
          ..write('effectiveCondition: $effectiveCondition, ')
          ..write('lastStepIndex: $lastStepIndex')
          ..write(')'))
        .toString();
  }
}

class $AgentsTable extends Agents with TableInfo<$AgentsTable, Agent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AgentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _directiveIdMeta = const VerificationMeta(
    'directiveId',
  );
  @override
  late final GeneratedColumn<int> directiveId = GeneratedColumn<int>(
    'directive_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES directives (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _agentTypeMeta = const VerificationMeta(
    'agentType',
  );
  @override
  late final GeneratedColumn<String> agentType = GeneratedColumn<String>(
    'agent_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _relationshipMeta = const VerificationMeta(
    'relationship',
  );
  @override
  late final GeneratedColumn<String> relationship = GeneratedColumn<String>(
    'relationship',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _homePhoneMeta = const VerificationMeta(
    'homePhone',
  );
  @override
  late final GeneratedColumn<String> homePhone = GeneratedColumn<String>(
    'home_phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _workPhoneMeta = const VerificationMeta(
    'workPhone',
  );
  @override
  late final GeneratedColumn<String> workPhone = GeneratedColumn<String>(
    'work_phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cellPhoneMeta = const VerificationMeta(
    'cellPhone',
  );
  @override
  late final GeneratedColumn<String> cellPhone = GeneratedColumn<String>(
    'cell_phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    directiveId,
    agentType,
    fullName,
    relationship,
    address,
    homePhone,
    workPhone,
    cellPhone,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'agents';
  @override
  VerificationContext validateIntegrity(
    Insertable<Agent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('directive_id')) {
      context.handle(
        _directiveIdMeta,
        directiveId.isAcceptableOrUnknown(
          data['directive_id']!,
          _directiveIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_directiveIdMeta);
    }
    if (data.containsKey('agent_type')) {
      context.handle(
        _agentTypeMeta,
        agentType.isAcceptableOrUnknown(data['agent_type']!, _agentTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_agentTypeMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    }
    if (data.containsKey('relationship')) {
      context.handle(
        _relationshipMeta,
        relationship.isAcceptableOrUnknown(
          data['relationship']!,
          _relationshipMeta,
        ),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('home_phone')) {
      context.handle(
        _homePhoneMeta,
        homePhone.isAcceptableOrUnknown(data['home_phone']!, _homePhoneMeta),
      );
    }
    if (data.containsKey('work_phone')) {
      context.handle(
        _workPhoneMeta,
        workPhone.isAcceptableOrUnknown(data['work_phone']!, _workPhoneMeta),
      );
    }
    if (data.containsKey('cell_phone')) {
      context.handle(
        _cellPhoneMeta,
        cellPhone.isAcceptableOrUnknown(data['cell_phone']!, _cellPhoneMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Agent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Agent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      directiveId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}directive_id'],
      )!,
      agentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent_type'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      relationship: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relationship'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      homePhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}home_phone'],
      )!,
      workPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}work_phone'],
      )!,
      cellPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cell_phone'],
      )!,
    );
  }

  @override
  $AgentsTable createAlias(String alias) {
    return $AgentsTable(attachedDatabase, alias);
  }
}

class Agent extends DataClass implements Insertable<Agent> {
  final int id;
  final int directiveId;
  final String agentType;
  final String fullName;
  final String relationship;
  final String address;
  final String homePhone;
  final String workPhone;
  final String cellPhone;
  const Agent({
    required this.id,
    required this.directiveId,
    required this.agentType,
    required this.fullName,
    required this.relationship,
    required this.address,
    required this.homePhone,
    required this.workPhone,
    required this.cellPhone,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['directive_id'] = Variable<int>(directiveId);
    map['agent_type'] = Variable<String>(agentType);
    map['full_name'] = Variable<String>(fullName);
    map['relationship'] = Variable<String>(relationship);
    map['address'] = Variable<String>(address);
    map['home_phone'] = Variable<String>(homePhone);
    map['work_phone'] = Variable<String>(workPhone);
    map['cell_phone'] = Variable<String>(cellPhone);
    return map;
  }

  AgentsCompanion toCompanion(bool nullToAbsent) {
    return AgentsCompanion(
      id: Value(id),
      directiveId: Value(directiveId),
      agentType: Value(agentType),
      fullName: Value(fullName),
      relationship: Value(relationship),
      address: Value(address),
      homePhone: Value(homePhone),
      workPhone: Value(workPhone),
      cellPhone: Value(cellPhone),
    );
  }

  factory Agent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Agent(
      id: serializer.fromJson<int>(json['id']),
      directiveId: serializer.fromJson<int>(json['directiveId']),
      agentType: serializer.fromJson<String>(json['agentType']),
      fullName: serializer.fromJson<String>(json['fullName']),
      relationship: serializer.fromJson<String>(json['relationship']),
      address: serializer.fromJson<String>(json['address']),
      homePhone: serializer.fromJson<String>(json['homePhone']),
      workPhone: serializer.fromJson<String>(json['workPhone']),
      cellPhone: serializer.fromJson<String>(json['cellPhone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'directiveId': serializer.toJson<int>(directiveId),
      'agentType': serializer.toJson<String>(agentType),
      'fullName': serializer.toJson<String>(fullName),
      'relationship': serializer.toJson<String>(relationship),
      'address': serializer.toJson<String>(address),
      'homePhone': serializer.toJson<String>(homePhone),
      'workPhone': serializer.toJson<String>(workPhone),
      'cellPhone': serializer.toJson<String>(cellPhone),
    };
  }

  Agent copyWith({
    int? id,
    int? directiveId,
    String? agentType,
    String? fullName,
    String? relationship,
    String? address,
    String? homePhone,
    String? workPhone,
    String? cellPhone,
  }) => Agent(
    id: id ?? this.id,
    directiveId: directiveId ?? this.directiveId,
    agentType: agentType ?? this.agentType,
    fullName: fullName ?? this.fullName,
    relationship: relationship ?? this.relationship,
    address: address ?? this.address,
    homePhone: homePhone ?? this.homePhone,
    workPhone: workPhone ?? this.workPhone,
    cellPhone: cellPhone ?? this.cellPhone,
  );
  Agent copyWithCompanion(AgentsCompanion data) {
    return Agent(
      id: data.id.present ? data.id.value : this.id,
      directiveId: data.directiveId.present
          ? data.directiveId.value
          : this.directiveId,
      agentType: data.agentType.present ? data.agentType.value : this.agentType,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      relationship: data.relationship.present
          ? data.relationship.value
          : this.relationship,
      address: data.address.present ? data.address.value : this.address,
      homePhone: data.homePhone.present ? data.homePhone.value : this.homePhone,
      workPhone: data.workPhone.present ? data.workPhone.value : this.workPhone,
      cellPhone: data.cellPhone.present ? data.cellPhone.value : this.cellPhone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Agent(')
          ..write('id: $id, ')
          ..write('directiveId: $directiveId, ')
          ..write('agentType: $agentType, ')
          ..write('fullName: $fullName, ')
          ..write('relationship: $relationship, ')
          ..write('address: $address, ')
          ..write('homePhone: $homePhone, ')
          ..write('workPhone: $workPhone, ')
          ..write('cellPhone: $cellPhone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    directiveId,
    agentType,
    fullName,
    relationship,
    address,
    homePhone,
    workPhone,
    cellPhone,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Agent &&
          other.id == this.id &&
          other.directiveId == this.directiveId &&
          other.agentType == this.agentType &&
          other.fullName == this.fullName &&
          other.relationship == this.relationship &&
          other.address == this.address &&
          other.homePhone == this.homePhone &&
          other.workPhone == this.workPhone &&
          other.cellPhone == this.cellPhone);
}

class AgentsCompanion extends UpdateCompanion<Agent> {
  final Value<int> id;
  final Value<int> directiveId;
  final Value<String> agentType;
  final Value<String> fullName;
  final Value<String> relationship;
  final Value<String> address;
  final Value<String> homePhone;
  final Value<String> workPhone;
  final Value<String> cellPhone;
  const AgentsCompanion({
    this.id = const Value.absent(),
    this.directiveId = const Value.absent(),
    this.agentType = const Value.absent(),
    this.fullName = const Value.absent(),
    this.relationship = const Value.absent(),
    this.address = const Value.absent(),
    this.homePhone = const Value.absent(),
    this.workPhone = const Value.absent(),
    this.cellPhone = const Value.absent(),
  });
  AgentsCompanion.insert({
    this.id = const Value.absent(),
    required int directiveId,
    required String agentType,
    this.fullName = const Value.absent(),
    this.relationship = const Value.absent(),
    this.address = const Value.absent(),
    this.homePhone = const Value.absent(),
    this.workPhone = const Value.absent(),
    this.cellPhone = const Value.absent(),
  }) : directiveId = Value(directiveId),
       agentType = Value(agentType);
  static Insertable<Agent> custom({
    Expression<int>? id,
    Expression<int>? directiveId,
    Expression<String>? agentType,
    Expression<String>? fullName,
    Expression<String>? relationship,
    Expression<String>? address,
    Expression<String>? homePhone,
    Expression<String>? workPhone,
    Expression<String>? cellPhone,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (directiveId != null) 'directive_id': directiveId,
      if (agentType != null) 'agent_type': agentType,
      if (fullName != null) 'full_name': fullName,
      if (relationship != null) 'relationship': relationship,
      if (address != null) 'address': address,
      if (homePhone != null) 'home_phone': homePhone,
      if (workPhone != null) 'work_phone': workPhone,
      if (cellPhone != null) 'cell_phone': cellPhone,
    });
  }

  AgentsCompanion copyWith({
    Value<int>? id,
    Value<int>? directiveId,
    Value<String>? agentType,
    Value<String>? fullName,
    Value<String>? relationship,
    Value<String>? address,
    Value<String>? homePhone,
    Value<String>? workPhone,
    Value<String>? cellPhone,
  }) {
    return AgentsCompanion(
      id: id ?? this.id,
      directiveId: directiveId ?? this.directiveId,
      agentType: agentType ?? this.agentType,
      fullName: fullName ?? this.fullName,
      relationship: relationship ?? this.relationship,
      address: address ?? this.address,
      homePhone: homePhone ?? this.homePhone,
      workPhone: workPhone ?? this.workPhone,
      cellPhone: cellPhone ?? this.cellPhone,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (directiveId.present) {
      map['directive_id'] = Variable<int>(directiveId.value);
    }
    if (agentType.present) {
      map['agent_type'] = Variable<String>(agentType.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (relationship.present) {
      map['relationship'] = Variable<String>(relationship.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (homePhone.present) {
      map['home_phone'] = Variable<String>(homePhone.value);
    }
    if (workPhone.present) {
      map['work_phone'] = Variable<String>(workPhone.value);
    }
    if (cellPhone.present) {
      map['cell_phone'] = Variable<String>(cellPhone.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AgentsCompanion(')
          ..write('id: $id, ')
          ..write('directiveId: $directiveId, ')
          ..write('agentType: $agentType, ')
          ..write('fullName: $fullName, ')
          ..write('relationship: $relationship, ')
          ..write('address: $address, ')
          ..write('homePhone: $homePhone, ')
          ..write('workPhone: $workPhone, ')
          ..write('cellPhone: $cellPhone')
          ..write(')'))
        .toString();
  }
}

class $MedicationEntriesTable extends MedicationEntries
    with TableInfo<$MedicationEntriesTable, MedicationEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _directiveIdMeta = const VerificationMeta(
    'directiveId',
  );
  @override
  late final GeneratedColumn<int> directiveId = GeneratedColumn<int>(
    'directive_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES directives (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _entryTypeMeta = const VerificationMeta(
    'entryType',
  );
  @override
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
    'entry_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicationNameMeta = const VerificationMeta(
    'medicationName',
  );
  @override
  late final GeneratedColumn<String> medicationName = GeneratedColumn<String>(
    'medication_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    directiveId,
    entryType,
    medicationName,
    reason,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('directive_id')) {
      context.handle(
        _directiveIdMeta,
        directiveId.isAcceptableOrUnknown(
          data['directive_id']!,
          _directiveIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_directiveIdMeta);
    }
    if (data.containsKey('entry_type')) {
      context.handle(
        _entryTypeMeta,
        entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('medication_name')) {
      context.handle(
        _medicationNameMeta,
        medicationName.isAcceptableOrUnknown(
          data['medication_name']!,
          _medicationNameMeta,
        ),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      directiveId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}directive_id'],
      )!,
      entryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_type'],
      )!,
      medicationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_name'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $MedicationEntriesTable createAlias(String alias) {
    return $MedicationEntriesTable(attachedDatabase, alias);
  }
}

class MedicationEntry extends DataClass implements Insertable<MedicationEntry> {
  final int id;
  final int directiveId;
  final String entryType;
  final String medicationName;
  final String reason;
  final int sortOrder;
  const MedicationEntry({
    required this.id,
    required this.directiveId,
    required this.entryType,
    required this.medicationName,
    required this.reason,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['directive_id'] = Variable<int>(directiveId);
    map['entry_type'] = Variable<String>(entryType);
    map['medication_name'] = Variable<String>(medicationName);
    map['reason'] = Variable<String>(reason);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  MedicationEntriesCompanion toCompanion(bool nullToAbsent) {
    return MedicationEntriesCompanion(
      id: Value(id),
      directiveId: Value(directiveId),
      entryType: Value(entryType),
      medicationName: Value(medicationName),
      reason: Value(reason),
      sortOrder: Value(sortOrder),
    );
  }

  factory MedicationEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationEntry(
      id: serializer.fromJson<int>(json['id']),
      directiveId: serializer.fromJson<int>(json['directiveId']),
      entryType: serializer.fromJson<String>(json['entryType']),
      medicationName: serializer.fromJson<String>(json['medicationName']),
      reason: serializer.fromJson<String>(json['reason']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'directiveId': serializer.toJson<int>(directiveId),
      'entryType': serializer.toJson<String>(entryType),
      'medicationName': serializer.toJson<String>(medicationName),
      'reason': serializer.toJson<String>(reason),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  MedicationEntry copyWith({
    int? id,
    int? directiveId,
    String? entryType,
    String? medicationName,
    String? reason,
    int? sortOrder,
  }) => MedicationEntry(
    id: id ?? this.id,
    directiveId: directiveId ?? this.directiveId,
    entryType: entryType ?? this.entryType,
    medicationName: medicationName ?? this.medicationName,
    reason: reason ?? this.reason,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  MedicationEntry copyWithCompanion(MedicationEntriesCompanion data) {
    return MedicationEntry(
      id: data.id.present ? data.id.value : this.id,
      directiveId: data.directiveId.present
          ? data.directiveId.value
          : this.directiveId,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      medicationName: data.medicationName.present
          ? data.medicationName.value
          : this.medicationName,
      reason: data.reason.present ? data.reason.value : this.reason,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationEntry(')
          ..write('id: $id, ')
          ..write('directiveId: $directiveId, ')
          ..write('entryType: $entryType, ')
          ..write('medicationName: $medicationName, ')
          ..write('reason: $reason, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    directiveId,
    entryType,
    medicationName,
    reason,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationEntry &&
          other.id == this.id &&
          other.directiveId == this.directiveId &&
          other.entryType == this.entryType &&
          other.medicationName == this.medicationName &&
          other.reason == this.reason &&
          other.sortOrder == this.sortOrder);
}

class MedicationEntriesCompanion extends UpdateCompanion<MedicationEntry> {
  final Value<int> id;
  final Value<int> directiveId;
  final Value<String> entryType;
  final Value<String> medicationName;
  final Value<String> reason;
  final Value<int> sortOrder;
  const MedicationEntriesCompanion({
    this.id = const Value.absent(),
    this.directiveId = const Value.absent(),
    this.entryType = const Value.absent(),
    this.medicationName = const Value.absent(),
    this.reason = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  MedicationEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int directiveId,
    required String entryType,
    this.medicationName = const Value.absent(),
    this.reason = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : directiveId = Value(directiveId),
       entryType = Value(entryType);
  static Insertable<MedicationEntry> custom({
    Expression<int>? id,
    Expression<int>? directiveId,
    Expression<String>? entryType,
    Expression<String>? medicationName,
    Expression<String>? reason,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (directiveId != null) 'directive_id': directiveId,
      if (entryType != null) 'entry_type': entryType,
      if (medicationName != null) 'medication_name': medicationName,
      if (reason != null) 'reason': reason,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  MedicationEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? directiveId,
    Value<String>? entryType,
    Value<String>? medicationName,
    Value<String>? reason,
    Value<int>? sortOrder,
  }) {
    return MedicationEntriesCompanion(
      id: id ?? this.id,
      directiveId: directiveId ?? this.directiveId,
      entryType: entryType ?? this.entryType,
      medicationName: medicationName ?? this.medicationName,
      reason: reason ?? this.reason,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (directiveId.present) {
      map['directive_id'] = Variable<int>(directiveId.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(entryType.value);
    }
    if (medicationName.present) {
      map['medication_name'] = Variable<String>(medicationName.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationEntriesCompanion(')
          ..write('id: $id, ')
          ..write('directiveId: $directiveId, ')
          ..write('entryType: $entryType, ')
          ..write('medicationName: $medicationName, ')
          ..write('reason: $reason, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $DirectivePrefsTable extends DirectivePrefs
    with TableInfo<$DirectivePrefsTable, DirectivePref> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DirectivePrefsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _directiveIdMeta = const VerificationMeta(
    'directiveId',
  );
  @override
  late final GeneratedColumn<int> directiveId = GeneratedColumn<int>(
    'directive_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES directives (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _treatmentFacilityPrefMeta =
      const VerificationMeta('treatmentFacilityPref');
  @override
  late final GeneratedColumn<String> treatmentFacilityPref =
      GeneratedColumn<String>(
        'treatment_facility_pref',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('noPreference'),
      );
  static const VerificationMeta _preferredFacilityNameMeta =
      const VerificationMeta('preferredFacilityName');
  @override
  late final GeneratedColumn<String> preferredFacilityName =
      GeneratedColumn<String>(
        'preferred_facility_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _avoidFacilityNameMeta = const VerificationMeta(
    'avoidFacilityName',
  );
  @override
  late final GeneratedColumn<String> avoidFacilityName =
      GeneratedColumn<String>(
        'avoid_facility_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _medicationConsentMeta = const VerificationMeta(
    'medicationConsent',
  );
  @override
  late final GeneratedColumn<String> medicationConsent =
      GeneratedColumn<String>(
        'medication_consent',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('yes'),
      );
  static const VerificationMeta _ectConsentMeta = const VerificationMeta(
    'ectConsent',
  );
  @override
  late final GeneratedColumn<String> ectConsent = GeneratedColumn<String>(
    'ect_consent',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('no'),
  );
  static const VerificationMeta _experimentalConsentMeta =
      const VerificationMeta('experimentalConsent');
  @override
  late final GeneratedColumn<String> experimentalConsent =
      GeneratedColumn<String>(
        'experimental_consent',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('no'),
      );
  static const VerificationMeta _drugTrialConsentMeta = const VerificationMeta(
    'drugTrialConsent',
  );
  @override
  late final GeneratedColumn<String> drugTrialConsent = GeneratedColumn<String>(
    'drug_trial_consent',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('no'),
  );
  static const VerificationMeta _agentCanConsentHospitalizationMeta =
      const VerificationMeta('agentCanConsentHospitalization');
  @override
  late final GeneratedColumn<bool> agentCanConsentHospitalization =
      GeneratedColumn<bool>(
        'agent_can_consent_hospitalization',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("agent_can_consent_hospitalization" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _agentCanConsentMedicationMeta =
      const VerificationMeta('agentCanConsentMedication');
  @override
  late final GeneratedColumn<bool> agentCanConsentMedication =
      GeneratedColumn<bool>(
        'agent_can_consent_medication',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("agent_can_consent_medication" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _agentAuthorityLimitationsMeta =
      const VerificationMeta('agentAuthorityLimitations');
  @override
  late final GeneratedColumn<String> agentAuthorityLimitations =
      GeneratedColumn<String>(
        'agent_authority_limitations',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    directiveId,
    treatmentFacilityPref,
    preferredFacilityName,
    avoidFacilityName,
    medicationConsent,
    ectConsent,
    experimentalConsent,
    drugTrialConsent,
    agentCanConsentHospitalization,
    agentCanConsentMedication,
    agentAuthorityLimitations,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'directive_prefs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DirectivePref> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('directive_id')) {
      context.handle(
        _directiveIdMeta,
        directiveId.isAcceptableOrUnknown(
          data['directive_id']!,
          _directiveIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_directiveIdMeta);
    }
    if (data.containsKey('treatment_facility_pref')) {
      context.handle(
        _treatmentFacilityPrefMeta,
        treatmentFacilityPref.isAcceptableOrUnknown(
          data['treatment_facility_pref']!,
          _treatmentFacilityPrefMeta,
        ),
      );
    }
    if (data.containsKey('preferred_facility_name')) {
      context.handle(
        _preferredFacilityNameMeta,
        preferredFacilityName.isAcceptableOrUnknown(
          data['preferred_facility_name']!,
          _preferredFacilityNameMeta,
        ),
      );
    }
    if (data.containsKey('avoid_facility_name')) {
      context.handle(
        _avoidFacilityNameMeta,
        avoidFacilityName.isAcceptableOrUnknown(
          data['avoid_facility_name']!,
          _avoidFacilityNameMeta,
        ),
      );
    }
    if (data.containsKey('medication_consent')) {
      context.handle(
        _medicationConsentMeta,
        medicationConsent.isAcceptableOrUnknown(
          data['medication_consent']!,
          _medicationConsentMeta,
        ),
      );
    }
    if (data.containsKey('ect_consent')) {
      context.handle(
        _ectConsentMeta,
        ectConsent.isAcceptableOrUnknown(data['ect_consent']!, _ectConsentMeta),
      );
    }
    if (data.containsKey('experimental_consent')) {
      context.handle(
        _experimentalConsentMeta,
        experimentalConsent.isAcceptableOrUnknown(
          data['experimental_consent']!,
          _experimentalConsentMeta,
        ),
      );
    }
    if (data.containsKey('drug_trial_consent')) {
      context.handle(
        _drugTrialConsentMeta,
        drugTrialConsent.isAcceptableOrUnknown(
          data['drug_trial_consent']!,
          _drugTrialConsentMeta,
        ),
      );
    }
    if (data.containsKey('agent_can_consent_hospitalization')) {
      context.handle(
        _agentCanConsentHospitalizationMeta,
        agentCanConsentHospitalization.isAcceptableOrUnknown(
          data['agent_can_consent_hospitalization']!,
          _agentCanConsentHospitalizationMeta,
        ),
      );
    }
    if (data.containsKey('agent_can_consent_medication')) {
      context.handle(
        _agentCanConsentMedicationMeta,
        agentCanConsentMedication.isAcceptableOrUnknown(
          data['agent_can_consent_medication']!,
          _agentCanConsentMedicationMeta,
        ),
      );
    }
    if (data.containsKey('agent_authority_limitations')) {
      context.handle(
        _agentAuthorityLimitationsMeta,
        agentAuthorityLimitations.isAcceptableOrUnknown(
          data['agent_authority_limitations']!,
          _agentAuthorityLimitationsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DirectivePref map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DirectivePref(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      directiveId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}directive_id'],
      )!,
      treatmentFacilityPref: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}treatment_facility_pref'],
      )!,
      preferredFacilityName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_facility_name'],
      )!,
      avoidFacilityName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avoid_facility_name'],
      )!,
      medicationConsent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_consent'],
      )!,
      ectConsent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ect_consent'],
      )!,
      experimentalConsent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}experimental_consent'],
      )!,
      drugTrialConsent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drug_trial_consent'],
      )!,
      agentCanConsentHospitalization: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}agent_can_consent_hospitalization'],
      )!,
      agentCanConsentMedication: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}agent_can_consent_medication'],
      )!,
      agentAuthorityLimitations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent_authority_limitations'],
      )!,
    );
  }

  @override
  $DirectivePrefsTable createAlias(String alias) {
    return $DirectivePrefsTable(attachedDatabase, alias);
  }
}

class DirectivePref extends DataClass implements Insertable<DirectivePref> {
  final int id;
  final int directiveId;
  final String treatmentFacilityPref;
  final String preferredFacilityName;
  final String avoidFacilityName;
  final String medicationConsent;
  final String ectConsent;
  final String experimentalConsent;
  final String drugTrialConsent;
  final bool agentCanConsentHospitalization;
  final bool agentCanConsentMedication;
  final String agentAuthorityLimitations;
  const DirectivePref({
    required this.id,
    required this.directiveId,
    required this.treatmentFacilityPref,
    required this.preferredFacilityName,
    required this.avoidFacilityName,
    required this.medicationConsent,
    required this.ectConsent,
    required this.experimentalConsent,
    required this.drugTrialConsent,
    required this.agentCanConsentHospitalization,
    required this.agentCanConsentMedication,
    required this.agentAuthorityLimitations,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['directive_id'] = Variable<int>(directiveId);
    map['treatment_facility_pref'] = Variable<String>(treatmentFacilityPref);
    map['preferred_facility_name'] = Variable<String>(preferredFacilityName);
    map['avoid_facility_name'] = Variable<String>(avoidFacilityName);
    map['medication_consent'] = Variable<String>(medicationConsent);
    map['ect_consent'] = Variable<String>(ectConsent);
    map['experimental_consent'] = Variable<String>(experimentalConsent);
    map['drug_trial_consent'] = Variable<String>(drugTrialConsent);
    map['agent_can_consent_hospitalization'] = Variable<bool>(
      agentCanConsentHospitalization,
    );
    map['agent_can_consent_medication'] = Variable<bool>(
      agentCanConsentMedication,
    );
    map['agent_authority_limitations'] = Variable<String>(
      agentAuthorityLimitations,
    );
    return map;
  }

  DirectivePrefsCompanion toCompanion(bool nullToAbsent) {
    return DirectivePrefsCompanion(
      id: Value(id),
      directiveId: Value(directiveId),
      treatmentFacilityPref: Value(treatmentFacilityPref),
      preferredFacilityName: Value(preferredFacilityName),
      avoidFacilityName: Value(avoidFacilityName),
      medicationConsent: Value(medicationConsent),
      ectConsent: Value(ectConsent),
      experimentalConsent: Value(experimentalConsent),
      drugTrialConsent: Value(drugTrialConsent),
      agentCanConsentHospitalization: Value(agentCanConsentHospitalization),
      agentCanConsentMedication: Value(agentCanConsentMedication),
      agentAuthorityLimitations: Value(agentAuthorityLimitations),
    );
  }

  factory DirectivePref.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DirectivePref(
      id: serializer.fromJson<int>(json['id']),
      directiveId: serializer.fromJson<int>(json['directiveId']),
      treatmentFacilityPref: serializer.fromJson<String>(
        json['treatmentFacilityPref'],
      ),
      preferredFacilityName: serializer.fromJson<String>(
        json['preferredFacilityName'],
      ),
      avoidFacilityName: serializer.fromJson<String>(json['avoidFacilityName']),
      medicationConsent: serializer.fromJson<String>(json['medicationConsent']),
      ectConsent: serializer.fromJson<String>(json['ectConsent']),
      experimentalConsent: serializer.fromJson<String>(
        json['experimentalConsent'],
      ),
      drugTrialConsent: serializer.fromJson<String>(json['drugTrialConsent']),
      agentCanConsentHospitalization: serializer.fromJson<bool>(
        json['agentCanConsentHospitalization'],
      ),
      agentCanConsentMedication: serializer.fromJson<bool>(
        json['agentCanConsentMedication'],
      ),
      agentAuthorityLimitations: serializer.fromJson<String>(
        json['agentAuthorityLimitations'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'directiveId': serializer.toJson<int>(directiveId),
      'treatmentFacilityPref': serializer.toJson<String>(treatmentFacilityPref),
      'preferredFacilityName': serializer.toJson<String>(preferredFacilityName),
      'avoidFacilityName': serializer.toJson<String>(avoidFacilityName),
      'medicationConsent': serializer.toJson<String>(medicationConsent),
      'ectConsent': serializer.toJson<String>(ectConsent),
      'experimentalConsent': serializer.toJson<String>(experimentalConsent),
      'drugTrialConsent': serializer.toJson<String>(drugTrialConsent),
      'agentCanConsentHospitalization': serializer.toJson<bool>(
        agentCanConsentHospitalization,
      ),
      'agentCanConsentMedication': serializer.toJson<bool>(
        agentCanConsentMedication,
      ),
      'agentAuthorityLimitations': serializer.toJson<String>(
        agentAuthorityLimitations,
      ),
    };
  }

  DirectivePref copyWith({
    int? id,
    int? directiveId,
    String? treatmentFacilityPref,
    String? preferredFacilityName,
    String? avoidFacilityName,
    String? medicationConsent,
    String? ectConsent,
    String? experimentalConsent,
    String? drugTrialConsent,
    bool? agentCanConsentHospitalization,
    bool? agentCanConsentMedication,
    String? agentAuthorityLimitations,
  }) => DirectivePref(
    id: id ?? this.id,
    directiveId: directiveId ?? this.directiveId,
    treatmentFacilityPref: treatmentFacilityPref ?? this.treatmentFacilityPref,
    preferredFacilityName: preferredFacilityName ?? this.preferredFacilityName,
    avoidFacilityName: avoidFacilityName ?? this.avoidFacilityName,
    medicationConsent: medicationConsent ?? this.medicationConsent,
    ectConsent: ectConsent ?? this.ectConsent,
    experimentalConsent: experimentalConsent ?? this.experimentalConsent,
    drugTrialConsent: drugTrialConsent ?? this.drugTrialConsent,
    agentCanConsentHospitalization:
        agentCanConsentHospitalization ?? this.agentCanConsentHospitalization,
    agentCanConsentMedication:
        agentCanConsentMedication ?? this.agentCanConsentMedication,
    agentAuthorityLimitations:
        agentAuthorityLimitations ?? this.agentAuthorityLimitations,
  );
  DirectivePref copyWithCompanion(DirectivePrefsCompanion data) {
    return DirectivePref(
      id: data.id.present ? data.id.value : this.id,
      directiveId: data.directiveId.present
          ? data.directiveId.value
          : this.directiveId,
      treatmentFacilityPref: data.treatmentFacilityPref.present
          ? data.treatmentFacilityPref.value
          : this.treatmentFacilityPref,
      preferredFacilityName: data.preferredFacilityName.present
          ? data.preferredFacilityName.value
          : this.preferredFacilityName,
      avoidFacilityName: data.avoidFacilityName.present
          ? data.avoidFacilityName.value
          : this.avoidFacilityName,
      medicationConsent: data.medicationConsent.present
          ? data.medicationConsent.value
          : this.medicationConsent,
      ectConsent: data.ectConsent.present
          ? data.ectConsent.value
          : this.ectConsent,
      experimentalConsent: data.experimentalConsent.present
          ? data.experimentalConsent.value
          : this.experimentalConsent,
      drugTrialConsent: data.drugTrialConsent.present
          ? data.drugTrialConsent.value
          : this.drugTrialConsent,
      agentCanConsentHospitalization:
          data.agentCanConsentHospitalization.present
          ? data.agentCanConsentHospitalization.value
          : this.agentCanConsentHospitalization,
      agentCanConsentMedication: data.agentCanConsentMedication.present
          ? data.agentCanConsentMedication.value
          : this.agentCanConsentMedication,
      agentAuthorityLimitations: data.agentAuthorityLimitations.present
          ? data.agentAuthorityLimitations.value
          : this.agentAuthorityLimitations,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DirectivePref(')
          ..write('id: $id, ')
          ..write('directiveId: $directiveId, ')
          ..write('treatmentFacilityPref: $treatmentFacilityPref, ')
          ..write('preferredFacilityName: $preferredFacilityName, ')
          ..write('avoidFacilityName: $avoidFacilityName, ')
          ..write('medicationConsent: $medicationConsent, ')
          ..write('ectConsent: $ectConsent, ')
          ..write('experimentalConsent: $experimentalConsent, ')
          ..write('drugTrialConsent: $drugTrialConsent, ')
          ..write(
            'agentCanConsentHospitalization: $agentCanConsentHospitalization, ',
          )
          ..write('agentCanConsentMedication: $agentCanConsentMedication, ')
          ..write('agentAuthorityLimitations: $agentAuthorityLimitations')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    directiveId,
    treatmentFacilityPref,
    preferredFacilityName,
    avoidFacilityName,
    medicationConsent,
    ectConsent,
    experimentalConsent,
    drugTrialConsent,
    agentCanConsentHospitalization,
    agentCanConsentMedication,
    agentAuthorityLimitations,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DirectivePref &&
          other.id == this.id &&
          other.directiveId == this.directiveId &&
          other.treatmentFacilityPref == this.treatmentFacilityPref &&
          other.preferredFacilityName == this.preferredFacilityName &&
          other.avoidFacilityName == this.avoidFacilityName &&
          other.medicationConsent == this.medicationConsent &&
          other.ectConsent == this.ectConsent &&
          other.experimentalConsent == this.experimentalConsent &&
          other.drugTrialConsent == this.drugTrialConsent &&
          other.agentCanConsentHospitalization ==
              this.agentCanConsentHospitalization &&
          other.agentCanConsentMedication == this.agentCanConsentMedication &&
          other.agentAuthorityLimitations == this.agentAuthorityLimitations);
}

class DirectivePrefsCompanion extends UpdateCompanion<DirectivePref> {
  final Value<int> id;
  final Value<int> directiveId;
  final Value<String> treatmentFacilityPref;
  final Value<String> preferredFacilityName;
  final Value<String> avoidFacilityName;
  final Value<String> medicationConsent;
  final Value<String> ectConsent;
  final Value<String> experimentalConsent;
  final Value<String> drugTrialConsent;
  final Value<bool> agentCanConsentHospitalization;
  final Value<bool> agentCanConsentMedication;
  final Value<String> agentAuthorityLimitations;
  const DirectivePrefsCompanion({
    this.id = const Value.absent(),
    this.directiveId = const Value.absent(),
    this.treatmentFacilityPref = const Value.absent(),
    this.preferredFacilityName = const Value.absent(),
    this.avoidFacilityName = const Value.absent(),
    this.medicationConsent = const Value.absent(),
    this.ectConsent = const Value.absent(),
    this.experimentalConsent = const Value.absent(),
    this.drugTrialConsent = const Value.absent(),
    this.agentCanConsentHospitalization = const Value.absent(),
    this.agentCanConsentMedication = const Value.absent(),
    this.agentAuthorityLimitations = const Value.absent(),
  });
  DirectivePrefsCompanion.insert({
    this.id = const Value.absent(),
    required int directiveId,
    this.treatmentFacilityPref = const Value.absent(),
    this.preferredFacilityName = const Value.absent(),
    this.avoidFacilityName = const Value.absent(),
    this.medicationConsent = const Value.absent(),
    this.ectConsent = const Value.absent(),
    this.experimentalConsent = const Value.absent(),
    this.drugTrialConsent = const Value.absent(),
    this.agentCanConsentHospitalization = const Value.absent(),
    this.agentCanConsentMedication = const Value.absent(),
    this.agentAuthorityLimitations = const Value.absent(),
  }) : directiveId = Value(directiveId);
  static Insertable<DirectivePref> custom({
    Expression<int>? id,
    Expression<int>? directiveId,
    Expression<String>? treatmentFacilityPref,
    Expression<String>? preferredFacilityName,
    Expression<String>? avoidFacilityName,
    Expression<String>? medicationConsent,
    Expression<String>? ectConsent,
    Expression<String>? experimentalConsent,
    Expression<String>? drugTrialConsent,
    Expression<bool>? agentCanConsentHospitalization,
    Expression<bool>? agentCanConsentMedication,
    Expression<String>? agentAuthorityLimitations,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (directiveId != null) 'directive_id': directiveId,
      if (treatmentFacilityPref != null)
        'treatment_facility_pref': treatmentFacilityPref,
      if (preferredFacilityName != null)
        'preferred_facility_name': preferredFacilityName,
      if (avoidFacilityName != null) 'avoid_facility_name': avoidFacilityName,
      if (medicationConsent != null) 'medication_consent': medicationConsent,
      if (ectConsent != null) 'ect_consent': ectConsent,
      if (experimentalConsent != null)
        'experimental_consent': experimentalConsent,
      if (drugTrialConsent != null) 'drug_trial_consent': drugTrialConsent,
      if (agentCanConsentHospitalization != null)
        'agent_can_consent_hospitalization': agentCanConsentHospitalization,
      if (agentCanConsentMedication != null)
        'agent_can_consent_medication': agentCanConsentMedication,
      if (agentAuthorityLimitations != null)
        'agent_authority_limitations': agentAuthorityLimitations,
    });
  }

  DirectivePrefsCompanion copyWith({
    Value<int>? id,
    Value<int>? directiveId,
    Value<String>? treatmentFacilityPref,
    Value<String>? preferredFacilityName,
    Value<String>? avoidFacilityName,
    Value<String>? medicationConsent,
    Value<String>? ectConsent,
    Value<String>? experimentalConsent,
    Value<String>? drugTrialConsent,
    Value<bool>? agentCanConsentHospitalization,
    Value<bool>? agentCanConsentMedication,
    Value<String>? agentAuthorityLimitations,
  }) {
    return DirectivePrefsCompanion(
      id: id ?? this.id,
      directiveId: directiveId ?? this.directiveId,
      treatmentFacilityPref:
          treatmentFacilityPref ?? this.treatmentFacilityPref,
      preferredFacilityName:
          preferredFacilityName ?? this.preferredFacilityName,
      avoidFacilityName: avoidFacilityName ?? this.avoidFacilityName,
      medicationConsent: medicationConsent ?? this.medicationConsent,
      ectConsent: ectConsent ?? this.ectConsent,
      experimentalConsent: experimentalConsent ?? this.experimentalConsent,
      drugTrialConsent: drugTrialConsent ?? this.drugTrialConsent,
      agentCanConsentHospitalization:
          agentCanConsentHospitalization ?? this.agentCanConsentHospitalization,
      agentCanConsentMedication:
          agentCanConsentMedication ?? this.agentCanConsentMedication,
      agentAuthorityLimitations:
          agentAuthorityLimitations ?? this.agentAuthorityLimitations,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (directiveId.present) {
      map['directive_id'] = Variable<int>(directiveId.value);
    }
    if (treatmentFacilityPref.present) {
      map['treatment_facility_pref'] = Variable<String>(
        treatmentFacilityPref.value,
      );
    }
    if (preferredFacilityName.present) {
      map['preferred_facility_name'] = Variable<String>(
        preferredFacilityName.value,
      );
    }
    if (avoidFacilityName.present) {
      map['avoid_facility_name'] = Variable<String>(avoidFacilityName.value);
    }
    if (medicationConsent.present) {
      map['medication_consent'] = Variable<String>(medicationConsent.value);
    }
    if (ectConsent.present) {
      map['ect_consent'] = Variable<String>(ectConsent.value);
    }
    if (experimentalConsent.present) {
      map['experimental_consent'] = Variable<String>(experimentalConsent.value);
    }
    if (drugTrialConsent.present) {
      map['drug_trial_consent'] = Variable<String>(drugTrialConsent.value);
    }
    if (agentCanConsentHospitalization.present) {
      map['agent_can_consent_hospitalization'] = Variable<bool>(
        agentCanConsentHospitalization.value,
      );
    }
    if (agentCanConsentMedication.present) {
      map['agent_can_consent_medication'] = Variable<bool>(
        agentCanConsentMedication.value,
      );
    }
    if (agentAuthorityLimitations.present) {
      map['agent_authority_limitations'] = Variable<String>(
        agentAuthorityLimitations.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DirectivePrefsCompanion(')
          ..write('id: $id, ')
          ..write('directiveId: $directiveId, ')
          ..write('treatmentFacilityPref: $treatmentFacilityPref, ')
          ..write('preferredFacilityName: $preferredFacilityName, ')
          ..write('avoidFacilityName: $avoidFacilityName, ')
          ..write('medicationConsent: $medicationConsent, ')
          ..write('ectConsent: $ectConsent, ')
          ..write('experimentalConsent: $experimentalConsent, ')
          ..write('drugTrialConsent: $drugTrialConsent, ')
          ..write(
            'agentCanConsentHospitalization: $agentCanConsentHospitalization, ',
          )
          ..write('agentCanConsentMedication: $agentCanConsentMedication, ')
          ..write('agentAuthorityLimitations: $agentAuthorityLimitations')
          ..write(')'))
        .toString();
  }
}

class $AdditionalInstructionsTableTable extends AdditionalInstructionsTable
    with
        TableInfo<
          $AdditionalInstructionsTableTable,
          AdditionalInstructionsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdditionalInstructionsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _directiveIdMeta = const VerificationMeta(
    'directiveId',
  );
  @override
  late final GeneratedColumn<int> directiveId = GeneratedColumn<int>(
    'directive_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES directives (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _activitiesMeta = const VerificationMeta(
    'activities',
  );
  @override
  late final GeneratedColumn<String> activities = GeneratedColumn<String>(
    'activities',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _crisisInterventionMeta =
      const VerificationMeta('crisisIntervention');
  @override
  late final GeneratedColumn<String> crisisIntervention =
      GeneratedColumn<String>(
        'crisis_intervention',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _healthHistoryMeta = const VerificationMeta(
    'healthHistory',
  );
  @override
  late final GeneratedColumn<String> healthHistory = GeneratedColumn<String>(
    'health_history',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dietaryMeta = const VerificationMeta(
    'dietary',
  );
  @override
  late final GeneratedColumn<String> dietary = GeneratedColumn<String>(
    'dietary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _religiousMeta = const VerificationMeta(
    'religious',
  );
  @override
  late final GeneratedColumn<String> religious = GeneratedColumn<String>(
    'religious',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _childrenCustodyMeta = const VerificationMeta(
    'childrenCustody',
  );
  @override
  late final GeneratedColumn<String> childrenCustody = GeneratedColumn<String>(
    'children_custody',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _familyNotificationMeta =
      const VerificationMeta('familyNotification');
  @override
  late final GeneratedColumn<String> familyNotification =
      GeneratedColumn<String>(
        'family_notification',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _recordsDisclosureMeta = const VerificationMeta(
    'recordsDisclosure',
  );
  @override
  late final GeneratedColumn<String> recordsDisclosure =
      GeneratedColumn<String>(
        'records_disclosure',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _petCustodyMeta = const VerificationMeta(
    'petCustody',
  );
  @override
  late final GeneratedColumn<String> petCustody = GeneratedColumn<String>(
    'pet_custody',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _otherMeta = const VerificationMeta('other');
  @override
  late final GeneratedColumn<String> other = GeneratedColumn<String>(
    'other',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    directiveId,
    activities,
    crisisIntervention,
    healthHistory,
    dietary,
    religious,
    childrenCustody,
    familyNotification,
    recordsDisclosure,
    petCustody,
    other,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'additional_instructions';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdditionalInstructionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('directive_id')) {
      context.handle(
        _directiveIdMeta,
        directiveId.isAcceptableOrUnknown(
          data['directive_id']!,
          _directiveIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_directiveIdMeta);
    }
    if (data.containsKey('activities')) {
      context.handle(
        _activitiesMeta,
        activities.isAcceptableOrUnknown(data['activities']!, _activitiesMeta),
      );
    }
    if (data.containsKey('crisis_intervention')) {
      context.handle(
        _crisisInterventionMeta,
        crisisIntervention.isAcceptableOrUnknown(
          data['crisis_intervention']!,
          _crisisInterventionMeta,
        ),
      );
    }
    if (data.containsKey('health_history')) {
      context.handle(
        _healthHistoryMeta,
        healthHistory.isAcceptableOrUnknown(
          data['health_history']!,
          _healthHistoryMeta,
        ),
      );
    }
    if (data.containsKey('dietary')) {
      context.handle(
        _dietaryMeta,
        dietary.isAcceptableOrUnknown(data['dietary']!, _dietaryMeta),
      );
    }
    if (data.containsKey('religious')) {
      context.handle(
        _religiousMeta,
        religious.isAcceptableOrUnknown(data['religious']!, _religiousMeta),
      );
    }
    if (data.containsKey('children_custody')) {
      context.handle(
        _childrenCustodyMeta,
        childrenCustody.isAcceptableOrUnknown(
          data['children_custody']!,
          _childrenCustodyMeta,
        ),
      );
    }
    if (data.containsKey('family_notification')) {
      context.handle(
        _familyNotificationMeta,
        familyNotification.isAcceptableOrUnknown(
          data['family_notification']!,
          _familyNotificationMeta,
        ),
      );
    }
    if (data.containsKey('records_disclosure')) {
      context.handle(
        _recordsDisclosureMeta,
        recordsDisclosure.isAcceptableOrUnknown(
          data['records_disclosure']!,
          _recordsDisclosureMeta,
        ),
      );
    }
    if (data.containsKey('pet_custody')) {
      context.handle(
        _petCustodyMeta,
        petCustody.isAcceptableOrUnknown(data['pet_custody']!, _petCustodyMeta),
      );
    }
    if (data.containsKey('other')) {
      context.handle(
        _otherMeta,
        other.isAcceptableOrUnknown(data['other']!, _otherMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AdditionalInstructionsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdditionalInstructionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      directiveId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}directive_id'],
      )!,
      activities: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activities'],
      )!,
      crisisIntervention: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crisis_intervention'],
      )!,
      healthHistory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}health_history'],
      )!,
      dietary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dietary'],
      )!,
      religious: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}religious'],
      )!,
      childrenCustody: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}children_custody'],
      )!,
      familyNotification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_notification'],
      )!,
      recordsDisclosure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}records_disclosure'],
      )!,
      petCustody: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pet_custody'],
      )!,
      other: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}other'],
      )!,
    );
  }

  @override
  $AdditionalInstructionsTableTable createAlias(String alias) {
    return $AdditionalInstructionsTableTable(attachedDatabase, alias);
  }
}

class AdditionalInstructionsTableData extends DataClass
    implements Insertable<AdditionalInstructionsTableData> {
  final int id;
  final int directiveId;
  final String activities;
  final String crisisIntervention;
  final String healthHistory;
  final String dietary;
  final String religious;
  final String childrenCustody;
  final String familyNotification;
  final String recordsDisclosure;
  final String petCustody;
  final String other;
  const AdditionalInstructionsTableData({
    required this.id,
    required this.directiveId,
    required this.activities,
    required this.crisisIntervention,
    required this.healthHistory,
    required this.dietary,
    required this.religious,
    required this.childrenCustody,
    required this.familyNotification,
    required this.recordsDisclosure,
    required this.petCustody,
    required this.other,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['directive_id'] = Variable<int>(directiveId);
    map['activities'] = Variable<String>(activities);
    map['crisis_intervention'] = Variable<String>(crisisIntervention);
    map['health_history'] = Variable<String>(healthHistory);
    map['dietary'] = Variable<String>(dietary);
    map['religious'] = Variable<String>(religious);
    map['children_custody'] = Variable<String>(childrenCustody);
    map['family_notification'] = Variable<String>(familyNotification);
    map['records_disclosure'] = Variable<String>(recordsDisclosure);
    map['pet_custody'] = Variable<String>(petCustody);
    map['other'] = Variable<String>(other);
    return map;
  }

  AdditionalInstructionsTableCompanion toCompanion(bool nullToAbsent) {
    return AdditionalInstructionsTableCompanion(
      id: Value(id),
      directiveId: Value(directiveId),
      activities: Value(activities),
      crisisIntervention: Value(crisisIntervention),
      healthHistory: Value(healthHistory),
      dietary: Value(dietary),
      religious: Value(religious),
      childrenCustody: Value(childrenCustody),
      familyNotification: Value(familyNotification),
      recordsDisclosure: Value(recordsDisclosure),
      petCustody: Value(petCustody),
      other: Value(other),
    );
  }

  factory AdditionalInstructionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdditionalInstructionsTableData(
      id: serializer.fromJson<int>(json['id']),
      directiveId: serializer.fromJson<int>(json['directiveId']),
      activities: serializer.fromJson<String>(json['activities']),
      crisisIntervention: serializer.fromJson<String>(
        json['crisisIntervention'],
      ),
      healthHistory: serializer.fromJson<String>(json['healthHistory']),
      dietary: serializer.fromJson<String>(json['dietary']),
      religious: serializer.fromJson<String>(json['religious']),
      childrenCustody: serializer.fromJson<String>(json['childrenCustody']),
      familyNotification: serializer.fromJson<String>(
        json['familyNotification'],
      ),
      recordsDisclosure: serializer.fromJson<String>(json['recordsDisclosure']),
      petCustody: serializer.fromJson<String>(json['petCustody']),
      other: serializer.fromJson<String>(json['other']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'directiveId': serializer.toJson<int>(directiveId),
      'activities': serializer.toJson<String>(activities),
      'crisisIntervention': serializer.toJson<String>(crisisIntervention),
      'healthHistory': serializer.toJson<String>(healthHistory),
      'dietary': serializer.toJson<String>(dietary),
      'religious': serializer.toJson<String>(religious),
      'childrenCustody': serializer.toJson<String>(childrenCustody),
      'familyNotification': serializer.toJson<String>(familyNotification),
      'recordsDisclosure': serializer.toJson<String>(recordsDisclosure),
      'petCustody': serializer.toJson<String>(petCustody),
      'other': serializer.toJson<String>(other),
    };
  }

  AdditionalInstructionsTableData copyWith({
    int? id,
    int? directiveId,
    String? activities,
    String? crisisIntervention,
    String? healthHistory,
    String? dietary,
    String? religious,
    String? childrenCustody,
    String? familyNotification,
    String? recordsDisclosure,
    String? petCustody,
    String? other,
  }) => AdditionalInstructionsTableData(
    id: id ?? this.id,
    directiveId: directiveId ?? this.directiveId,
    activities: activities ?? this.activities,
    crisisIntervention: crisisIntervention ?? this.crisisIntervention,
    healthHistory: healthHistory ?? this.healthHistory,
    dietary: dietary ?? this.dietary,
    religious: religious ?? this.religious,
    childrenCustody: childrenCustody ?? this.childrenCustody,
    familyNotification: familyNotification ?? this.familyNotification,
    recordsDisclosure: recordsDisclosure ?? this.recordsDisclosure,
    petCustody: petCustody ?? this.petCustody,
    other: other ?? this.other,
  );
  AdditionalInstructionsTableData copyWithCompanion(
    AdditionalInstructionsTableCompanion data,
  ) {
    return AdditionalInstructionsTableData(
      id: data.id.present ? data.id.value : this.id,
      directiveId: data.directiveId.present
          ? data.directiveId.value
          : this.directiveId,
      activities: data.activities.present
          ? data.activities.value
          : this.activities,
      crisisIntervention: data.crisisIntervention.present
          ? data.crisisIntervention.value
          : this.crisisIntervention,
      healthHistory: data.healthHistory.present
          ? data.healthHistory.value
          : this.healthHistory,
      dietary: data.dietary.present ? data.dietary.value : this.dietary,
      religious: data.religious.present ? data.religious.value : this.religious,
      childrenCustody: data.childrenCustody.present
          ? data.childrenCustody.value
          : this.childrenCustody,
      familyNotification: data.familyNotification.present
          ? data.familyNotification.value
          : this.familyNotification,
      recordsDisclosure: data.recordsDisclosure.present
          ? data.recordsDisclosure.value
          : this.recordsDisclosure,
      petCustody: data.petCustody.present
          ? data.petCustody.value
          : this.petCustody,
      other: data.other.present ? data.other.value : this.other,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdditionalInstructionsTableData(')
          ..write('id: $id, ')
          ..write('directiveId: $directiveId, ')
          ..write('activities: $activities, ')
          ..write('crisisIntervention: $crisisIntervention, ')
          ..write('healthHistory: $healthHistory, ')
          ..write('dietary: $dietary, ')
          ..write('religious: $religious, ')
          ..write('childrenCustody: $childrenCustody, ')
          ..write('familyNotification: $familyNotification, ')
          ..write('recordsDisclosure: $recordsDisclosure, ')
          ..write('petCustody: $petCustody, ')
          ..write('other: $other')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    directiveId,
    activities,
    crisisIntervention,
    healthHistory,
    dietary,
    religious,
    childrenCustody,
    familyNotification,
    recordsDisclosure,
    petCustody,
    other,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdditionalInstructionsTableData &&
          other.id == this.id &&
          other.directiveId == this.directiveId &&
          other.activities == this.activities &&
          other.crisisIntervention == this.crisisIntervention &&
          other.healthHistory == this.healthHistory &&
          other.dietary == this.dietary &&
          other.religious == this.religious &&
          other.childrenCustody == this.childrenCustody &&
          other.familyNotification == this.familyNotification &&
          other.recordsDisclosure == this.recordsDisclosure &&
          other.petCustody == this.petCustody &&
          other.other == this.other);
}

class AdditionalInstructionsTableCompanion
    extends UpdateCompanion<AdditionalInstructionsTableData> {
  final Value<int> id;
  final Value<int> directiveId;
  final Value<String> activities;
  final Value<String> crisisIntervention;
  final Value<String> healthHistory;
  final Value<String> dietary;
  final Value<String> religious;
  final Value<String> childrenCustody;
  final Value<String> familyNotification;
  final Value<String> recordsDisclosure;
  final Value<String> petCustody;
  final Value<String> other;
  const AdditionalInstructionsTableCompanion({
    this.id = const Value.absent(),
    this.directiveId = const Value.absent(),
    this.activities = const Value.absent(),
    this.crisisIntervention = const Value.absent(),
    this.healthHistory = const Value.absent(),
    this.dietary = const Value.absent(),
    this.religious = const Value.absent(),
    this.childrenCustody = const Value.absent(),
    this.familyNotification = const Value.absent(),
    this.recordsDisclosure = const Value.absent(),
    this.petCustody = const Value.absent(),
    this.other = const Value.absent(),
  });
  AdditionalInstructionsTableCompanion.insert({
    this.id = const Value.absent(),
    required int directiveId,
    this.activities = const Value.absent(),
    this.crisisIntervention = const Value.absent(),
    this.healthHistory = const Value.absent(),
    this.dietary = const Value.absent(),
    this.religious = const Value.absent(),
    this.childrenCustody = const Value.absent(),
    this.familyNotification = const Value.absent(),
    this.recordsDisclosure = const Value.absent(),
    this.petCustody = const Value.absent(),
    this.other = const Value.absent(),
  }) : directiveId = Value(directiveId);
  static Insertable<AdditionalInstructionsTableData> custom({
    Expression<int>? id,
    Expression<int>? directiveId,
    Expression<String>? activities,
    Expression<String>? crisisIntervention,
    Expression<String>? healthHistory,
    Expression<String>? dietary,
    Expression<String>? religious,
    Expression<String>? childrenCustody,
    Expression<String>? familyNotification,
    Expression<String>? recordsDisclosure,
    Expression<String>? petCustody,
    Expression<String>? other,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (directiveId != null) 'directive_id': directiveId,
      if (activities != null) 'activities': activities,
      if (crisisIntervention != null) 'crisis_intervention': crisisIntervention,
      if (healthHistory != null) 'health_history': healthHistory,
      if (dietary != null) 'dietary': dietary,
      if (religious != null) 'religious': religious,
      if (childrenCustody != null) 'children_custody': childrenCustody,
      if (familyNotification != null) 'family_notification': familyNotification,
      if (recordsDisclosure != null) 'records_disclosure': recordsDisclosure,
      if (petCustody != null) 'pet_custody': petCustody,
      if (other != null) 'other': other,
    });
  }

  AdditionalInstructionsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? directiveId,
    Value<String>? activities,
    Value<String>? crisisIntervention,
    Value<String>? healthHistory,
    Value<String>? dietary,
    Value<String>? religious,
    Value<String>? childrenCustody,
    Value<String>? familyNotification,
    Value<String>? recordsDisclosure,
    Value<String>? petCustody,
    Value<String>? other,
  }) {
    return AdditionalInstructionsTableCompanion(
      id: id ?? this.id,
      directiveId: directiveId ?? this.directiveId,
      activities: activities ?? this.activities,
      crisisIntervention: crisisIntervention ?? this.crisisIntervention,
      healthHistory: healthHistory ?? this.healthHistory,
      dietary: dietary ?? this.dietary,
      religious: religious ?? this.religious,
      childrenCustody: childrenCustody ?? this.childrenCustody,
      familyNotification: familyNotification ?? this.familyNotification,
      recordsDisclosure: recordsDisclosure ?? this.recordsDisclosure,
      petCustody: petCustody ?? this.petCustody,
      other: other ?? this.other,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (directiveId.present) {
      map['directive_id'] = Variable<int>(directiveId.value);
    }
    if (activities.present) {
      map['activities'] = Variable<String>(activities.value);
    }
    if (crisisIntervention.present) {
      map['crisis_intervention'] = Variable<String>(crisisIntervention.value);
    }
    if (healthHistory.present) {
      map['health_history'] = Variable<String>(healthHistory.value);
    }
    if (dietary.present) {
      map['dietary'] = Variable<String>(dietary.value);
    }
    if (religious.present) {
      map['religious'] = Variable<String>(religious.value);
    }
    if (childrenCustody.present) {
      map['children_custody'] = Variable<String>(childrenCustody.value);
    }
    if (familyNotification.present) {
      map['family_notification'] = Variable<String>(familyNotification.value);
    }
    if (recordsDisclosure.present) {
      map['records_disclosure'] = Variable<String>(recordsDisclosure.value);
    }
    if (petCustody.present) {
      map['pet_custody'] = Variable<String>(petCustody.value);
    }
    if (other.present) {
      map['other'] = Variable<String>(other.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdditionalInstructionsTableCompanion(')
          ..write('id: $id, ')
          ..write('directiveId: $directiveId, ')
          ..write('activities: $activities, ')
          ..write('crisisIntervention: $crisisIntervention, ')
          ..write('healthHistory: $healthHistory, ')
          ..write('dietary: $dietary, ')
          ..write('religious: $religious, ')
          ..write('childrenCustody: $childrenCustody, ')
          ..write('familyNotification: $familyNotification, ')
          ..write('recordsDisclosure: $recordsDisclosure, ')
          ..write('petCustody: $petCustody, ')
          ..write('other: $other')
          ..write(')'))
        .toString();
  }
}

class $WitnessesTable extends Witnesses
    with TableInfo<$WitnessesTable, WitnessesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WitnessesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _directiveIdMeta = const VerificationMeta(
    'directiveId',
  );
  @override
  late final GeneratedColumn<int> directiveId = GeneratedColumn<int>(
    'directive_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES directives (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _witnessNumberMeta = const VerificationMeta(
    'witnessNumber',
  );
  @override
  late final GeneratedColumn<int> witnessNumber = GeneratedColumn<int>(
    'witness_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _signatureBase64Meta = const VerificationMeta(
    'signatureBase64',
  );
  @override
  late final GeneratedColumn<String> signatureBase64 = GeneratedColumn<String>(
    'signature_base64',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _signatureDateMeta = const VerificationMeta(
    'signatureDate',
  );
  @override
  late final GeneratedColumn<int> signatureDate = GeneratedColumn<int>(
    'signature_date',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    directiveId,
    witnessNumber,
    fullName,
    address,
    signatureBase64,
    signatureDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'witnesses';
  @override
  VerificationContext validateIntegrity(
    Insertable<WitnessesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('directive_id')) {
      context.handle(
        _directiveIdMeta,
        directiveId.isAcceptableOrUnknown(
          data['directive_id']!,
          _directiveIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_directiveIdMeta);
    }
    if (data.containsKey('witness_number')) {
      context.handle(
        _witnessNumberMeta,
        witnessNumber.isAcceptableOrUnknown(
          data['witness_number']!,
          _witnessNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_witnessNumberMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('signature_base64')) {
      context.handle(
        _signatureBase64Meta,
        signatureBase64.isAcceptableOrUnknown(
          data['signature_base64']!,
          _signatureBase64Meta,
        ),
      );
    }
    if (data.containsKey('signature_date')) {
      context.handle(
        _signatureDateMeta,
        signatureDate.isAcceptableOrUnknown(
          data['signature_date']!,
          _signatureDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WitnessesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WitnessesData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      directiveId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}directive_id'],
      )!,
      witnessNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}witness_number'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      signatureBase64: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signature_base64'],
      ),
      signatureDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}signature_date'],
      ),
    );
  }

  @override
  $WitnessesTable createAlias(String alias) {
    return $WitnessesTable(attachedDatabase, alias);
  }
}

class WitnessesData extends DataClass implements Insertable<WitnessesData> {
  final int id;
  final int directiveId;
  final int witnessNumber;
  final String fullName;
  final String address;
  final String? signatureBase64;
  final int? signatureDate;
  const WitnessesData({
    required this.id,
    required this.directiveId,
    required this.witnessNumber,
    required this.fullName,
    required this.address,
    this.signatureBase64,
    this.signatureDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['directive_id'] = Variable<int>(directiveId);
    map['witness_number'] = Variable<int>(witnessNumber);
    map['full_name'] = Variable<String>(fullName);
    map['address'] = Variable<String>(address);
    if (!nullToAbsent || signatureBase64 != null) {
      map['signature_base64'] = Variable<String>(signatureBase64);
    }
    if (!nullToAbsent || signatureDate != null) {
      map['signature_date'] = Variable<int>(signatureDate);
    }
    return map;
  }

  WitnessesCompanion toCompanion(bool nullToAbsent) {
    return WitnessesCompanion(
      id: Value(id),
      directiveId: Value(directiveId),
      witnessNumber: Value(witnessNumber),
      fullName: Value(fullName),
      address: Value(address),
      signatureBase64: signatureBase64 == null && nullToAbsent
          ? const Value.absent()
          : Value(signatureBase64),
      signatureDate: signatureDate == null && nullToAbsent
          ? const Value.absent()
          : Value(signatureDate),
    );
  }

  factory WitnessesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WitnessesData(
      id: serializer.fromJson<int>(json['id']),
      directiveId: serializer.fromJson<int>(json['directiveId']),
      witnessNumber: serializer.fromJson<int>(json['witnessNumber']),
      fullName: serializer.fromJson<String>(json['fullName']),
      address: serializer.fromJson<String>(json['address']),
      signatureBase64: serializer.fromJson<String?>(json['signatureBase64']),
      signatureDate: serializer.fromJson<int?>(json['signatureDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'directiveId': serializer.toJson<int>(directiveId),
      'witnessNumber': serializer.toJson<int>(witnessNumber),
      'fullName': serializer.toJson<String>(fullName),
      'address': serializer.toJson<String>(address),
      'signatureBase64': serializer.toJson<String?>(signatureBase64),
      'signatureDate': serializer.toJson<int?>(signatureDate),
    };
  }

  WitnessesData copyWith({
    int? id,
    int? directiveId,
    int? witnessNumber,
    String? fullName,
    String? address,
    Value<String?> signatureBase64 = const Value.absent(),
    Value<int?> signatureDate = const Value.absent(),
  }) => WitnessesData(
    id: id ?? this.id,
    directiveId: directiveId ?? this.directiveId,
    witnessNumber: witnessNumber ?? this.witnessNumber,
    fullName: fullName ?? this.fullName,
    address: address ?? this.address,
    signatureBase64: signatureBase64.present
        ? signatureBase64.value
        : this.signatureBase64,
    signatureDate: signatureDate.present
        ? signatureDate.value
        : this.signatureDate,
  );
  WitnessesData copyWithCompanion(WitnessesCompanion data) {
    return WitnessesData(
      id: data.id.present ? data.id.value : this.id,
      directiveId: data.directiveId.present
          ? data.directiveId.value
          : this.directiveId,
      witnessNumber: data.witnessNumber.present
          ? data.witnessNumber.value
          : this.witnessNumber,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      address: data.address.present ? data.address.value : this.address,
      signatureBase64: data.signatureBase64.present
          ? data.signatureBase64.value
          : this.signatureBase64,
      signatureDate: data.signatureDate.present
          ? data.signatureDate.value
          : this.signatureDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WitnessesData(')
          ..write('id: $id, ')
          ..write('directiveId: $directiveId, ')
          ..write('witnessNumber: $witnessNumber, ')
          ..write('fullName: $fullName, ')
          ..write('address: $address, ')
          ..write('signatureBase64: $signatureBase64, ')
          ..write('signatureDate: $signatureDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    directiveId,
    witnessNumber,
    fullName,
    address,
    signatureBase64,
    signatureDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WitnessesData &&
          other.id == this.id &&
          other.directiveId == this.directiveId &&
          other.witnessNumber == this.witnessNumber &&
          other.fullName == this.fullName &&
          other.address == this.address &&
          other.signatureBase64 == this.signatureBase64 &&
          other.signatureDate == this.signatureDate);
}

class WitnessesCompanion extends UpdateCompanion<WitnessesData> {
  final Value<int> id;
  final Value<int> directiveId;
  final Value<int> witnessNumber;
  final Value<String> fullName;
  final Value<String> address;
  final Value<String?> signatureBase64;
  final Value<int?> signatureDate;
  const WitnessesCompanion({
    this.id = const Value.absent(),
    this.directiveId = const Value.absent(),
    this.witnessNumber = const Value.absent(),
    this.fullName = const Value.absent(),
    this.address = const Value.absent(),
    this.signatureBase64 = const Value.absent(),
    this.signatureDate = const Value.absent(),
  });
  WitnessesCompanion.insert({
    this.id = const Value.absent(),
    required int directiveId,
    required int witnessNumber,
    this.fullName = const Value.absent(),
    this.address = const Value.absent(),
    this.signatureBase64 = const Value.absent(),
    this.signatureDate = const Value.absent(),
  }) : directiveId = Value(directiveId),
       witnessNumber = Value(witnessNumber);
  static Insertable<WitnessesData> custom({
    Expression<int>? id,
    Expression<int>? directiveId,
    Expression<int>? witnessNumber,
    Expression<String>? fullName,
    Expression<String>? address,
    Expression<String>? signatureBase64,
    Expression<int>? signatureDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (directiveId != null) 'directive_id': directiveId,
      if (witnessNumber != null) 'witness_number': witnessNumber,
      if (fullName != null) 'full_name': fullName,
      if (address != null) 'address': address,
      if (signatureBase64 != null) 'signature_base64': signatureBase64,
      if (signatureDate != null) 'signature_date': signatureDate,
    });
  }

  WitnessesCompanion copyWith({
    Value<int>? id,
    Value<int>? directiveId,
    Value<int>? witnessNumber,
    Value<String>? fullName,
    Value<String>? address,
    Value<String?>? signatureBase64,
    Value<int?>? signatureDate,
  }) {
    return WitnessesCompanion(
      id: id ?? this.id,
      directiveId: directiveId ?? this.directiveId,
      witnessNumber: witnessNumber ?? this.witnessNumber,
      fullName: fullName ?? this.fullName,
      address: address ?? this.address,
      signatureBase64: signatureBase64 ?? this.signatureBase64,
      signatureDate: signatureDate ?? this.signatureDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (directiveId.present) {
      map['directive_id'] = Variable<int>(directiveId.value);
    }
    if (witnessNumber.present) {
      map['witness_number'] = Variable<int>(witnessNumber.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (signatureBase64.present) {
      map['signature_base64'] = Variable<String>(signatureBase64.value);
    }
    if (signatureDate.present) {
      map['signature_date'] = Variable<int>(signatureDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WitnessesCompanion(')
          ..write('id: $id, ')
          ..write('directiveId: $directiveId, ')
          ..write('witnessNumber: $witnessNumber, ')
          ..write('fullName: $fullName, ')
          ..write('address: $address, ')
          ..write('signatureBase64: $signatureBase64, ')
          ..write('signatureDate: $signatureDate')
          ..write(')'))
        .toString();
  }
}

class $GuardianNominationsTable extends GuardianNominations
    with TableInfo<$GuardianNominationsTable, GuardianNomination> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GuardianNominationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _directiveIdMeta = const VerificationMeta(
    'directiveId',
  );
  @override
  late final GeneratedColumn<int> directiveId = GeneratedColumn<int>(
    'directive_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES directives (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nomineeFullNameMeta = const VerificationMeta(
    'nomineeFullName',
  );
  @override
  late final GeneratedColumn<String> nomineeFullName = GeneratedColumn<String>(
    'nominee_full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nomineeAddressMeta = const VerificationMeta(
    'nomineeAddress',
  );
  @override
  late final GeneratedColumn<String> nomineeAddress = GeneratedColumn<String>(
    'nominee_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nomineePhoneMeta = const VerificationMeta(
    'nomineePhone',
  );
  @override
  late final GeneratedColumn<String> nomineePhone = GeneratedColumn<String>(
    'nominee_phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nomineeRelationshipMeta =
      const VerificationMeta('nomineeRelationship');
  @override
  late final GeneratedColumn<String> nomineeRelationship =
      GeneratedColumn<String>(
        'nominee_relationship',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    directiveId,
    nomineeFullName,
    nomineeAddress,
    nomineePhone,
    nomineeRelationship,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'guardian_nominations';
  @override
  VerificationContext validateIntegrity(
    Insertable<GuardianNomination> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('directive_id')) {
      context.handle(
        _directiveIdMeta,
        directiveId.isAcceptableOrUnknown(
          data['directive_id']!,
          _directiveIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_directiveIdMeta);
    }
    if (data.containsKey('nominee_full_name')) {
      context.handle(
        _nomineeFullNameMeta,
        nomineeFullName.isAcceptableOrUnknown(
          data['nominee_full_name']!,
          _nomineeFullNameMeta,
        ),
      );
    }
    if (data.containsKey('nominee_address')) {
      context.handle(
        _nomineeAddressMeta,
        nomineeAddress.isAcceptableOrUnknown(
          data['nominee_address']!,
          _nomineeAddressMeta,
        ),
      );
    }
    if (data.containsKey('nominee_phone')) {
      context.handle(
        _nomineePhoneMeta,
        nomineePhone.isAcceptableOrUnknown(
          data['nominee_phone']!,
          _nomineePhoneMeta,
        ),
      );
    }
    if (data.containsKey('nominee_relationship')) {
      context.handle(
        _nomineeRelationshipMeta,
        nomineeRelationship.isAcceptableOrUnknown(
          data['nominee_relationship']!,
          _nomineeRelationshipMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GuardianNomination map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GuardianNomination(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      directiveId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}directive_id'],
      )!,
      nomineeFullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nominee_full_name'],
      )!,
      nomineeAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nominee_address'],
      )!,
      nomineePhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nominee_phone'],
      )!,
      nomineeRelationship: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nominee_relationship'],
      )!,
    );
  }

  @override
  $GuardianNominationsTable createAlias(String alias) {
    return $GuardianNominationsTable(attachedDatabase, alias);
  }
}

class GuardianNomination extends DataClass
    implements Insertable<GuardianNomination> {
  final int id;
  final int directiveId;
  final String nomineeFullName;
  final String nomineeAddress;
  final String nomineePhone;
  final String nomineeRelationship;
  const GuardianNomination({
    required this.id,
    required this.directiveId,
    required this.nomineeFullName,
    required this.nomineeAddress,
    required this.nomineePhone,
    required this.nomineeRelationship,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['directive_id'] = Variable<int>(directiveId);
    map['nominee_full_name'] = Variable<String>(nomineeFullName);
    map['nominee_address'] = Variable<String>(nomineeAddress);
    map['nominee_phone'] = Variable<String>(nomineePhone);
    map['nominee_relationship'] = Variable<String>(nomineeRelationship);
    return map;
  }

  GuardianNominationsCompanion toCompanion(bool nullToAbsent) {
    return GuardianNominationsCompanion(
      id: Value(id),
      directiveId: Value(directiveId),
      nomineeFullName: Value(nomineeFullName),
      nomineeAddress: Value(nomineeAddress),
      nomineePhone: Value(nomineePhone),
      nomineeRelationship: Value(nomineeRelationship),
    );
  }

  factory GuardianNomination.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GuardianNomination(
      id: serializer.fromJson<int>(json['id']),
      directiveId: serializer.fromJson<int>(json['directiveId']),
      nomineeFullName: serializer.fromJson<String>(json['nomineeFullName']),
      nomineeAddress: serializer.fromJson<String>(json['nomineeAddress']),
      nomineePhone: serializer.fromJson<String>(json['nomineePhone']),
      nomineeRelationship: serializer.fromJson<String>(
        json['nomineeRelationship'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'directiveId': serializer.toJson<int>(directiveId),
      'nomineeFullName': serializer.toJson<String>(nomineeFullName),
      'nomineeAddress': serializer.toJson<String>(nomineeAddress),
      'nomineePhone': serializer.toJson<String>(nomineePhone),
      'nomineeRelationship': serializer.toJson<String>(nomineeRelationship),
    };
  }

  GuardianNomination copyWith({
    int? id,
    int? directiveId,
    String? nomineeFullName,
    String? nomineeAddress,
    String? nomineePhone,
    String? nomineeRelationship,
  }) => GuardianNomination(
    id: id ?? this.id,
    directiveId: directiveId ?? this.directiveId,
    nomineeFullName: nomineeFullName ?? this.nomineeFullName,
    nomineeAddress: nomineeAddress ?? this.nomineeAddress,
    nomineePhone: nomineePhone ?? this.nomineePhone,
    nomineeRelationship: nomineeRelationship ?? this.nomineeRelationship,
  );
  GuardianNomination copyWithCompanion(GuardianNominationsCompanion data) {
    return GuardianNomination(
      id: data.id.present ? data.id.value : this.id,
      directiveId: data.directiveId.present
          ? data.directiveId.value
          : this.directiveId,
      nomineeFullName: data.nomineeFullName.present
          ? data.nomineeFullName.value
          : this.nomineeFullName,
      nomineeAddress: data.nomineeAddress.present
          ? data.nomineeAddress.value
          : this.nomineeAddress,
      nomineePhone: data.nomineePhone.present
          ? data.nomineePhone.value
          : this.nomineePhone,
      nomineeRelationship: data.nomineeRelationship.present
          ? data.nomineeRelationship.value
          : this.nomineeRelationship,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GuardianNomination(')
          ..write('id: $id, ')
          ..write('directiveId: $directiveId, ')
          ..write('nomineeFullName: $nomineeFullName, ')
          ..write('nomineeAddress: $nomineeAddress, ')
          ..write('nomineePhone: $nomineePhone, ')
          ..write('nomineeRelationship: $nomineeRelationship')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    directiveId,
    nomineeFullName,
    nomineeAddress,
    nomineePhone,
    nomineeRelationship,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GuardianNomination &&
          other.id == this.id &&
          other.directiveId == this.directiveId &&
          other.nomineeFullName == this.nomineeFullName &&
          other.nomineeAddress == this.nomineeAddress &&
          other.nomineePhone == this.nomineePhone &&
          other.nomineeRelationship == this.nomineeRelationship);
}

class GuardianNominationsCompanion extends UpdateCompanion<GuardianNomination> {
  final Value<int> id;
  final Value<int> directiveId;
  final Value<String> nomineeFullName;
  final Value<String> nomineeAddress;
  final Value<String> nomineePhone;
  final Value<String> nomineeRelationship;
  const GuardianNominationsCompanion({
    this.id = const Value.absent(),
    this.directiveId = const Value.absent(),
    this.nomineeFullName = const Value.absent(),
    this.nomineeAddress = const Value.absent(),
    this.nomineePhone = const Value.absent(),
    this.nomineeRelationship = const Value.absent(),
  });
  GuardianNominationsCompanion.insert({
    this.id = const Value.absent(),
    required int directiveId,
    this.nomineeFullName = const Value.absent(),
    this.nomineeAddress = const Value.absent(),
    this.nomineePhone = const Value.absent(),
    this.nomineeRelationship = const Value.absent(),
  }) : directiveId = Value(directiveId);
  static Insertable<GuardianNomination> custom({
    Expression<int>? id,
    Expression<int>? directiveId,
    Expression<String>? nomineeFullName,
    Expression<String>? nomineeAddress,
    Expression<String>? nomineePhone,
    Expression<String>? nomineeRelationship,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (directiveId != null) 'directive_id': directiveId,
      if (nomineeFullName != null) 'nominee_full_name': nomineeFullName,
      if (nomineeAddress != null) 'nominee_address': nomineeAddress,
      if (nomineePhone != null) 'nominee_phone': nomineePhone,
      if (nomineeRelationship != null)
        'nominee_relationship': nomineeRelationship,
    });
  }

  GuardianNominationsCompanion copyWith({
    Value<int>? id,
    Value<int>? directiveId,
    Value<String>? nomineeFullName,
    Value<String>? nomineeAddress,
    Value<String>? nomineePhone,
    Value<String>? nomineeRelationship,
  }) {
    return GuardianNominationsCompanion(
      id: id ?? this.id,
      directiveId: directiveId ?? this.directiveId,
      nomineeFullName: nomineeFullName ?? this.nomineeFullName,
      nomineeAddress: nomineeAddress ?? this.nomineeAddress,
      nomineePhone: nomineePhone ?? this.nomineePhone,
      nomineeRelationship: nomineeRelationship ?? this.nomineeRelationship,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (directiveId.present) {
      map['directive_id'] = Variable<int>(directiveId.value);
    }
    if (nomineeFullName.present) {
      map['nominee_full_name'] = Variable<String>(nomineeFullName.value);
    }
    if (nomineeAddress.present) {
      map['nominee_address'] = Variable<String>(nomineeAddress.value);
    }
    if (nomineePhone.present) {
      map['nominee_phone'] = Variable<String>(nomineePhone.value);
    }
    if (nomineeRelationship.present) {
      map['nominee_relationship'] = Variable<String>(nomineeRelationship.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GuardianNominationsCompanion(')
          ..write('id: $id, ')
          ..write('directiveId: $directiveId, ')
          ..write('nomineeFullName: $nomineeFullName, ')
          ..write('nomineeAddress: $nomineeAddress, ')
          ..write('nomineePhone: $nomineePhone, ')
          ..write('nomineeRelationship: $nomineeRelationship')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DirectivesTable directives = $DirectivesTable(this);
  late final $AgentsTable agents = $AgentsTable(this);
  late final $MedicationEntriesTable medicationEntries =
      $MedicationEntriesTable(this);
  late final $DirectivePrefsTable directivePrefs = $DirectivePrefsTable(this);
  late final $AdditionalInstructionsTableTable additionalInstructionsTable =
      $AdditionalInstructionsTableTable(this);
  late final $WitnessesTable witnesses = $WitnessesTable(this);
  late final $GuardianNominationsTable guardianNominations =
      $GuardianNominationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    directives,
    agents,
    medicationEntries,
    directivePrefs,
    additionalInstructionsTable,
    witnesses,
    guardianNominations,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'directives',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('agents', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'directives',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('medication_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'directives',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('directive_prefs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'directives',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('additional_instructions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'directives',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('witnesses', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'directives',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('guardian_nominations', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$DirectivesTableCreateCompanionBuilder =
    DirectivesCompanion Function({
      Value<int> id,
      required String formType,
      Value<String> status,
      required int createdAt,
      required int updatedAt,
      Value<int?> executionDate,
      Value<int?> expirationDate,
      Value<String> fullName,
      Value<String> dateOfBirth,
      Value<String> address,
      Value<String> address2,
      Value<String> city,
      Value<String> state,
      Value<String> zip,
      Value<String> phone,
      Value<String> effectiveCondition,
      Value<int> lastStepIndex,
    });
typedef $$DirectivesTableUpdateCompanionBuilder =
    DirectivesCompanion Function({
      Value<int> id,
      Value<String> formType,
      Value<String> status,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> executionDate,
      Value<int?> expirationDate,
      Value<String> fullName,
      Value<String> dateOfBirth,
      Value<String> address,
      Value<String> address2,
      Value<String> city,
      Value<String> state,
      Value<String> zip,
      Value<String> phone,
      Value<String> effectiveCondition,
      Value<int> lastStepIndex,
    });

final class $$DirectivesTableReferences
    extends BaseReferences<_$AppDatabase, $DirectivesTable, Directive> {
  $$DirectivesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AgentsTable, List<Agent>> _agentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.agents,
    aliasName: $_aliasNameGenerator(db.directives.id, db.agents.directiveId),
  );

  $$AgentsTableProcessedTableManager get agentsRefs {
    final manager = $$AgentsTableTableManager(
      $_db,
      $_db.agents,
    ).filter((f) => f.directiveId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_agentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MedicationEntriesTable, List<MedicationEntry>>
  _medicationEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.medicationEntries,
        aliasName: $_aliasNameGenerator(
          db.directives.id,
          db.medicationEntries.directiveId,
        ),
      );

  $$MedicationEntriesTableProcessedTableManager get medicationEntriesRefs {
    final manager = $$MedicationEntriesTableTableManager(
      $_db,
      $_db.medicationEntries,
    ).filter((f) => f.directiveId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _medicationEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DirectivePrefsTable, List<DirectivePref>>
  _directivePrefsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.directivePrefs,
    aliasName: $_aliasNameGenerator(
      db.directives.id,
      db.directivePrefs.directiveId,
    ),
  );

  $$DirectivePrefsTableProcessedTableManager get directivePrefsRefs {
    final manager = $$DirectivePrefsTableTableManager(
      $_db,
      $_db.directivePrefs,
    ).filter((f) => f.directiveId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_directivePrefsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $AdditionalInstructionsTableTable,
    List<AdditionalInstructionsTableData>
  >
  _additionalInstructionsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.additionalInstructionsTable,
        aliasName: $_aliasNameGenerator(
          db.directives.id,
          db.additionalInstructionsTable.directiveId,
        ),
      );

  $$AdditionalInstructionsTableTableProcessedTableManager
  get additionalInstructionsTableRefs {
    final manager = $$AdditionalInstructionsTableTableTableManager(
      $_db,
      $_db.additionalInstructionsTable,
    ).filter((f) => f.directiveId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _additionalInstructionsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WitnessesTable, List<WitnessesData>>
  _witnessesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.witnesses,
    aliasName: $_aliasNameGenerator(db.directives.id, db.witnesses.directiveId),
  );

  $$WitnessesTableProcessedTableManager get witnessesRefs {
    final manager = $$WitnessesTableTableManager(
      $_db,
      $_db.witnesses,
    ).filter((f) => f.directiveId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_witnessesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $GuardianNominationsTable,
    List<GuardianNomination>
  >
  _guardianNominationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.guardianNominations,
        aliasName: $_aliasNameGenerator(
          db.directives.id,
          db.guardianNominations.directiveId,
        ),
      );

  $$GuardianNominationsTableProcessedTableManager get guardianNominationsRefs {
    final manager = $$GuardianNominationsTableTableManager(
      $_db,
      $_db.guardianNominations,
    ).filter((f) => f.directiveId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _guardianNominationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DirectivesTableFilterComposer
    extends Composer<_$AppDatabase, $DirectivesTable> {
  $$DirectivesTableFilterComposer({
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

  ColumnFilters<String> get formType => $composableBuilder(
    column: $table.formType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get executionDate => $composableBuilder(
    column: $table.executionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expirationDate => $composableBuilder(
    column: $table.expirationDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address2 => $composableBuilder(
    column: $table.address2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zip => $composableBuilder(
    column: $table.zip,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectiveCondition => $composableBuilder(
    column: $table.effectiveCondition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastStepIndex => $composableBuilder(
    column: $table.lastStepIndex,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> agentsRefs(
    Expression<bool> Function($$AgentsTableFilterComposer f) f,
  ) {
    final $$AgentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.agents,
      getReferencedColumn: (t) => t.directiveId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AgentsTableFilterComposer(
            $db: $db,
            $table: $db.agents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> medicationEntriesRefs(
    Expression<bool> Function($$MedicationEntriesTableFilterComposer f) f,
  ) {
    final $$MedicationEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicationEntries,
      getReferencedColumn: (t) => t.directiveId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationEntriesTableFilterComposer(
            $db: $db,
            $table: $db.medicationEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> directivePrefsRefs(
    Expression<bool> Function($$DirectivePrefsTableFilterComposer f) f,
  ) {
    final $$DirectivePrefsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.directivePrefs,
      getReferencedColumn: (t) => t.directiveId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DirectivePrefsTableFilterComposer(
            $db: $db,
            $table: $db.directivePrefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> additionalInstructionsTableRefs(
    Expression<bool> Function(
      $$AdditionalInstructionsTableTableFilterComposer f,
    )
    f,
  ) {
    final $$AdditionalInstructionsTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.additionalInstructionsTable,
          getReferencedColumn: (t) => t.directiveId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AdditionalInstructionsTableTableFilterComposer(
                $db: $db,
                $table: $db.additionalInstructionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> witnessesRefs(
    Expression<bool> Function($$WitnessesTableFilterComposer f) f,
  ) {
    final $$WitnessesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.witnesses,
      getReferencedColumn: (t) => t.directiveId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WitnessesTableFilterComposer(
            $db: $db,
            $table: $db.witnesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> guardianNominationsRefs(
    Expression<bool> Function($$GuardianNominationsTableFilterComposer f) f,
  ) {
    final $$GuardianNominationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.guardianNominations,
      getReferencedColumn: (t) => t.directiveId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GuardianNominationsTableFilterComposer(
            $db: $db,
            $table: $db.guardianNominations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DirectivesTableOrderingComposer
    extends Composer<_$AppDatabase, $DirectivesTable> {
  $$DirectivesTableOrderingComposer({
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

  ColumnOrderings<String> get formType => $composableBuilder(
    column: $table.formType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get executionDate => $composableBuilder(
    column: $table.executionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expirationDate => $composableBuilder(
    column: $table.expirationDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address2 => $composableBuilder(
    column: $table.address2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zip => $composableBuilder(
    column: $table.zip,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectiveCondition => $composableBuilder(
    column: $table.effectiveCondition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastStepIndex => $composableBuilder(
    column: $table.lastStepIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DirectivesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DirectivesTable> {
  $$DirectivesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get formType =>
      $composableBuilder(column: $table.formType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get executionDate => $composableBuilder(
    column: $table.executionDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expirationDate => $composableBuilder(
    column: $table.expirationDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get address2 =>
      $composableBuilder(column: $table.address2, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get zip =>
      $composableBuilder(column: $table.zip, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get effectiveCondition => $composableBuilder(
    column: $table.effectiveCondition,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastStepIndex => $composableBuilder(
    column: $table.lastStepIndex,
    builder: (column) => column,
  );

  Expression<T> agentsRefs<T extends Object>(
    Expression<T> Function($$AgentsTableAnnotationComposer a) f,
  ) {
    final $$AgentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.agents,
      getReferencedColumn: (t) => t.directiveId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AgentsTableAnnotationComposer(
            $db: $db,
            $table: $db.agents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> medicationEntriesRefs<T extends Object>(
    Expression<T> Function($$MedicationEntriesTableAnnotationComposer a) f,
  ) {
    final $$MedicationEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.medicationEntries,
          getReferencedColumn: (t) => t.directiveId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MedicationEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.medicationEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> directivePrefsRefs<T extends Object>(
    Expression<T> Function($$DirectivePrefsTableAnnotationComposer a) f,
  ) {
    final $$DirectivePrefsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.directivePrefs,
      getReferencedColumn: (t) => t.directiveId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DirectivePrefsTableAnnotationComposer(
            $db: $db,
            $table: $db.directivePrefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> additionalInstructionsTableRefs<T extends Object>(
    Expression<T> Function(
      $$AdditionalInstructionsTableTableAnnotationComposer a,
    )
    f,
  ) {
    final $$AdditionalInstructionsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.additionalInstructionsTable,
          getReferencedColumn: (t) => t.directiveId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AdditionalInstructionsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.additionalInstructionsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> witnessesRefs<T extends Object>(
    Expression<T> Function($$WitnessesTableAnnotationComposer a) f,
  ) {
    final $$WitnessesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.witnesses,
      getReferencedColumn: (t) => t.directiveId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WitnessesTableAnnotationComposer(
            $db: $db,
            $table: $db.witnesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> guardianNominationsRefs<T extends Object>(
    Expression<T> Function($$GuardianNominationsTableAnnotationComposer a) f,
  ) {
    final $$GuardianNominationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.guardianNominations,
          getReferencedColumn: (t) => t.directiveId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GuardianNominationsTableAnnotationComposer(
                $db: $db,
                $table: $db.guardianNominations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DirectivesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DirectivesTable,
          Directive,
          $$DirectivesTableFilterComposer,
          $$DirectivesTableOrderingComposer,
          $$DirectivesTableAnnotationComposer,
          $$DirectivesTableCreateCompanionBuilder,
          $$DirectivesTableUpdateCompanionBuilder,
          (Directive, $$DirectivesTableReferences),
          Directive,
          PrefetchHooks Function({
            bool agentsRefs,
            bool medicationEntriesRefs,
            bool directivePrefsRefs,
            bool additionalInstructionsTableRefs,
            bool witnessesRefs,
            bool guardianNominationsRefs,
          })
        > {
  $$DirectivesTableTableManager(_$AppDatabase db, $DirectivesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DirectivesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DirectivesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DirectivesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> formType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> executionDate = const Value.absent(),
                Value<int?> expirationDate = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> dateOfBirth = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> address2 = const Value.absent(),
                Value<String> city = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> zip = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> effectiveCondition = const Value.absent(),
                Value<int> lastStepIndex = const Value.absent(),
              }) => DirectivesCompanion(
                id: id,
                formType: formType,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                executionDate: executionDate,
                expirationDate: expirationDate,
                fullName: fullName,
                dateOfBirth: dateOfBirth,
                address: address,
                address2: address2,
                city: city,
                state: state,
                zip: zip,
                phone: phone,
                effectiveCondition: effectiveCondition,
                lastStepIndex: lastStepIndex,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String formType,
                Value<String> status = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> executionDate = const Value.absent(),
                Value<int?> expirationDate = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> dateOfBirth = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> address2 = const Value.absent(),
                Value<String> city = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String> zip = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> effectiveCondition = const Value.absent(),
                Value<int> lastStepIndex = const Value.absent(),
              }) => DirectivesCompanion.insert(
                id: id,
                formType: formType,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                executionDate: executionDate,
                expirationDate: expirationDate,
                fullName: fullName,
                dateOfBirth: dateOfBirth,
                address: address,
                address2: address2,
                city: city,
                state: state,
                zip: zip,
                phone: phone,
                effectiveCondition: effectiveCondition,
                lastStepIndex: lastStepIndex,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DirectivesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                agentsRefs = false,
                medicationEntriesRefs = false,
                directivePrefsRefs = false,
                additionalInstructionsTableRefs = false,
                witnessesRefs = false,
                guardianNominationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (agentsRefs) db.agents,
                    if (medicationEntriesRefs) db.medicationEntries,
                    if (directivePrefsRefs) db.directivePrefs,
                    if (additionalInstructionsTableRefs)
                      db.additionalInstructionsTable,
                    if (witnessesRefs) db.witnesses,
                    if (guardianNominationsRefs) db.guardianNominations,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (agentsRefs)
                        await $_getPrefetchedData<
                          Directive,
                          $DirectivesTable,
                          Agent
                        >(
                          currentTable: table,
                          referencedTable: $$DirectivesTableReferences
                              ._agentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DirectivesTableReferences(
                                db,
                                table,
                                p0,
                              ).agentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.directiveId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (medicationEntriesRefs)
                        await $_getPrefetchedData<
                          Directive,
                          $DirectivesTable,
                          MedicationEntry
                        >(
                          currentTable: table,
                          referencedTable: $$DirectivesTableReferences
                              ._medicationEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DirectivesTableReferences(
                                db,
                                table,
                                p0,
                              ).medicationEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.directiveId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (directivePrefsRefs)
                        await $_getPrefetchedData<
                          Directive,
                          $DirectivesTable,
                          DirectivePref
                        >(
                          currentTable: table,
                          referencedTable: $$DirectivesTableReferences
                              ._directivePrefsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DirectivesTableReferences(
                                db,
                                table,
                                p0,
                              ).directivePrefsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.directiveId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (additionalInstructionsTableRefs)
                        await $_getPrefetchedData<
                          Directive,
                          $DirectivesTable,
                          AdditionalInstructionsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$DirectivesTableReferences
                              ._additionalInstructionsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DirectivesTableReferences(
                                db,
                                table,
                                p0,
                              ).additionalInstructionsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.directiveId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (witnessesRefs)
                        await $_getPrefetchedData<
                          Directive,
                          $DirectivesTable,
                          WitnessesData
                        >(
                          currentTable: table,
                          referencedTable: $$DirectivesTableReferences
                              ._witnessesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DirectivesTableReferences(
                                db,
                                table,
                                p0,
                              ).witnessesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.directiveId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (guardianNominationsRefs)
                        await $_getPrefetchedData<
                          Directive,
                          $DirectivesTable,
                          GuardianNomination
                        >(
                          currentTable: table,
                          referencedTable: $$DirectivesTableReferences
                              ._guardianNominationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DirectivesTableReferences(
                                db,
                                table,
                                p0,
                              ).guardianNominationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.directiveId == item.id,
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

typedef $$DirectivesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DirectivesTable,
      Directive,
      $$DirectivesTableFilterComposer,
      $$DirectivesTableOrderingComposer,
      $$DirectivesTableAnnotationComposer,
      $$DirectivesTableCreateCompanionBuilder,
      $$DirectivesTableUpdateCompanionBuilder,
      (Directive, $$DirectivesTableReferences),
      Directive,
      PrefetchHooks Function({
        bool agentsRefs,
        bool medicationEntriesRefs,
        bool directivePrefsRefs,
        bool additionalInstructionsTableRefs,
        bool witnessesRefs,
        bool guardianNominationsRefs,
      })
    >;
typedef $$AgentsTableCreateCompanionBuilder =
    AgentsCompanion Function({
      Value<int> id,
      required int directiveId,
      required String agentType,
      Value<String> fullName,
      Value<String> relationship,
      Value<String> address,
      Value<String> homePhone,
      Value<String> workPhone,
      Value<String> cellPhone,
    });
typedef $$AgentsTableUpdateCompanionBuilder =
    AgentsCompanion Function({
      Value<int> id,
      Value<int> directiveId,
      Value<String> agentType,
      Value<String> fullName,
      Value<String> relationship,
      Value<String> address,
      Value<String> homePhone,
      Value<String> workPhone,
      Value<String> cellPhone,
    });

final class $$AgentsTableReferences
    extends BaseReferences<_$AppDatabase, $AgentsTable, Agent> {
  $$AgentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DirectivesTable _directiveIdTable(_$AppDatabase db) =>
      db.directives.createAlias(
        $_aliasNameGenerator(db.agents.directiveId, db.directives.id),
      );

  $$DirectivesTableProcessedTableManager get directiveId {
    final $_column = $_itemColumn<int>('directive_id')!;

    final manager = $$DirectivesTableTableManager(
      $_db,
      $_db.directives,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_directiveIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AgentsTableFilterComposer
    extends Composer<_$AppDatabase, $AgentsTable> {
  $$AgentsTableFilterComposer({
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

  ColumnFilters<String> get agentType => $composableBuilder(
    column: $table.agentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationship => $composableBuilder(
    column: $table.relationship,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homePhone => $composableBuilder(
    column: $table.homePhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workPhone => $composableBuilder(
    column: $table.workPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cellPhone => $composableBuilder(
    column: $table.cellPhone,
    builder: (column) => ColumnFilters(column),
  );

  $$DirectivesTableFilterComposer get directiveId {
    final $$DirectivesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directiveId,
      referencedTable: $db.directives,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DirectivesTableFilterComposer(
            $db: $db,
            $table: $db.directives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AgentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AgentsTable> {
  $$AgentsTableOrderingComposer({
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

  ColumnOrderings<String> get agentType => $composableBuilder(
    column: $table.agentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationship => $composableBuilder(
    column: $table.relationship,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homePhone => $composableBuilder(
    column: $table.homePhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workPhone => $composableBuilder(
    column: $table.workPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cellPhone => $composableBuilder(
    column: $table.cellPhone,
    builder: (column) => ColumnOrderings(column),
  );

  $$DirectivesTableOrderingComposer get directiveId {
    final $$DirectivesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directiveId,
      referencedTable: $db.directives,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DirectivesTableOrderingComposer(
            $db: $db,
            $table: $db.directives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AgentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AgentsTable> {
  $$AgentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get agentType =>
      $composableBuilder(column: $table.agentType, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get relationship => $composableBuilder(
    column: $table.relationship,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get homePhone =>
      $composableBuilder(column: $table.homePhone, builder: (column) => column);

  GeneratedColumn<String> get workPhone =>
      $composableBuilder(column: $table.workPhone, builder: (column) => column);

  GeneratedColumn<String> get cellPhone =>
      $composableBuilder(column: $table.cellPhone, builder: (column) => column);

  $$DirectivesTableAnnotationComposer get directiveId {
    final $$DirectivesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directiveId,
      referencedTable: $db.directives,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DirectivesTableAnnotationComposer(
            $db: $db,
            $table: $db.directives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AgentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AgentsTable,
          Agent,
          $$AgentsTableFilterComposer,
          $$AgentsTableOrderingComposer,
          $$AgentsTableAnnotationComposer,
          $$AgentsTableCreateCompanionBuilder,
          $$AgentsTableUpdateCompanionBuilder,
          (Agent, $$AgentsTableReferences),
          Agent,
          PrefetchHooks Function({bool directiveId})
        > {
  $$AgentsTableTableManager(_$AppDatabase db, $AgentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AgentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AgentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AgentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> directiveId = const Value.absent(),
                Value<String> agentType = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> relationship = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> homePhone = const Value.absent(),
                Value<String> workPhone = const Value.absent(),
                Value<String> cellPhone = const Value.absent(),
              }) => AgentsCompanion(
                id: id,
                directiveId: directiveId,
                agentType: agentType,
                fullName: fullName,
                relationship: relationship,
                address: address,
                homePhone: homePhone,
                workPhone: workPhone,
                cellPhone: cellPhone,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int directiveId,
                required String agentType,
                Value<String> fullName = const Value.absent(),
                Value<String> relationship = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> homePhone = const Value.absent(),
                Value<String> workPhone = const Value.absent(),
                Value<String> cellPhone = const Value.absent(),
              }) => AgentsCompanion.insert(
                id: id,
                directiveId: directiveId,
                agentType: agentType,
                fullName: fullName,
                relationship: relationship,
                address: address,
                homePhone: homePhone,
                workPhone: workPhone,
                cellPhone: cellPhone,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$AgentsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({directiveId = false}) {
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
                    if (directiveId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.directiveId,
                                referencedTable: $$AgentsTableReferences
                                    ._directiveIdTable(db),
                                referencedColumn: $$AgentsTableReferences
                                    ._directiveIdTable(db)
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

typedef $$AgentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AgentsTable,
      Agent,
      $$AgentsTableFilterComposer,
      $$AgentsTableOrderingComposer,
      $$AgentsTableAnnotationComposer,
      $$AgentsTableCreateCompanionBuilder,
      $$AgentsTableUpdateCompanionBuilder,
      (Agent, $$AgentsTableReferences),
      Agent,
      PrefetchHooks Function({bool directiveId})
    >;
typedef $$MedicationEntriesTableCreateCompanionBuilder =
    MedicationEntriesCompanion Function({
      Value<int> id,
      required int directiveId,
      required String entryType,
      Value<String> medicationName,
      Value<String> reason,
      Value<int> sortOrder,
    });
typedef $$MedicationEntriesTableUpdateCompanionBuilder =
    MedicationEntriesCompanion Function({
      Value<int> id,
      Value<int> directiveId,
      Value<String> entryType,
      Value<String> medicationName,
      Value<String> reason,
      Value<int> sortOrder,
    });

final class $$MedicationEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MedicationEntriesTable,
          MedicationEntry
        > {
  $$MedicationEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DirectivesTable _directiveIdTable(_$AppDatabase db) =>
      db.directives.createAlias(
        $_aliasNameGenerator(
          db.medicationEntries.directiveId,
          db.directives.id,
        ),
      );

  $$DirectivesTableProcessedTableManager get directiveId {
    final $_column = $_itemColumn<int>('directive_id')!;

    final manager = $$DirectivesTableTableManager(
      $_db,
      $_db.directives,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_directiveIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MedicationEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationEntriesTable> {
  $$MedicationEntriesTableFilterComposer({
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

  ColumnFilters<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$DirectivesTableFilterComposer get directiveId {
    final $$DirectivesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directiveId,
      referencedTable: $db.directives,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DirectivesTableFilterComposer(
            $db: $db,
            $table: $db.directives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationEntriesTable> {
  $$MedicationEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$DirectivesTableOrderingComposer get directiveId {
    final $$DirectivesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directiveId,
      referencedTable: $db.directives,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DirectivesTableOrderingComposer(
            $db: $db,
            $table: $db.directives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationEntriesTable> {
  $$MedicationEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$DirectivesTableAnnotationComposer get directiveId {
    final $$DirectivesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directiveId,
      referencedTable: $db.directives,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DirectivesTableAnnotationComposer(
            $db: $db,
            $table: $db.directives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationEntriesTable,
          MedicationEntry,
          $$MedicationEntriesTableFilterComposer,
          $$MedicationEntriesTableOrderingComposer,
          $$MedicationEntriesTableAnnotationComposer,
          $$MedicationEntriesTableCreateCompanionBuilder,
          $$MedicationEntriesTableUpdateCompanionBuilder,
          (MedicationEntry, $$MedicationEntriesTableReferences),
          MedicationEntry,
          PrefetchHooks Function({bool directiveId})
        > {
  $$MedicationEntriesTableTableManager(
    _$AppDatabase db,
    $MedicationEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> directiveId = const Value.absent(),
                Value<String> entryType = const Value.absent(),
                Value<String> medicationName = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => MedicationEntriesCompanion(
                id: id,
                directiveId: directiveId,
                entryType: entryType,
                medicationName: medicationName,
                reason: reason,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int directiveId,
                required String entryType,
                Value<String> medicationName = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => MedicationEntriesCompanion.insert(
                id: id,
                directiveId: directiveId,
                entryType: entryType,
                medicationName: medicationName,
                reason: reason,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MedicationEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({directiveId = false}) {
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
                    if (directiveId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.directiveId,
                                referencedTable:
                                    $$MedicationEntriesTableReferences
                                        ._directiveIdTable(db),
                                referencedColumn:
                                    $$MedicationEntriesTableReferences
                                        ._directiveIdTable(db)
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

typedef $$MedicationEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationEntriesTable,
      MedicationEntry,
      $$MedicationEntriesTableFilterComposer,
      $$MedicationEntriesTableOrderingComposer,
      $$MedicationEntriesTableAnnotationComposer,
      $$MedicationEntriesTableCreateCompanionBuilder,
      $$MedicationEntriesTableUpdateCompanionBuilder,
      (MedicationEntry, $$MedicationEntriesTableReferences),
      MedicationEntry,
      PrefetchHooks Function({bool directiveId})
    >;
typedef $$DirectivePrefsTableCreateCompanionBuilder =
    DirectivePrefsCompanion Function({
      Value<int> id,
      required int directiveId,
      Value<String> treatmentFacilityPref,
      Value<String> preferredFacilityName,
      Value<String> avoidFacilityName,
      Value<String> medicationConsent,
      Value<String> ectConsent,
      Value<String> experimentalConsent,
      Value<String> drugTrialConsent,
      Value<bool> agentCanConsentHospitalization,
      Value<bool> agentCanConsentMedication,
      Value<String> agentAuthorityLimitations,
    });
typedef $$DirectivePrefsTableUpdateCompanionBuilder =
    DirectivePrefsCompanion Function({
      Value<int> id,
      Value<int> directiveId,
      Value<String> treatmentFacilityPref,
      Value<String> preferredFacilityName,
      Value<String> avoidFacilityName,
      Value<String> medicationConsent,
      Value<String> ectConsent,
      Value<String> experimentalConsent,
      Value<String> drugTrialConsent,
      Value<bool> agentCanConsentHospitalization,
      Value<bool> agentCanConsentMedication,
      Value<String> agentAuthorityLimitations,
    });

final class $$DirectivePrefsTableReferences
    extends BaseReferences<_$AppDatabase, $DirectivePrefsTable, DirectivePref> {
  $$DirectivePrefsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DirectivesTable _directiveIdTable(_$AppDatabase db) =>
      db.directives.createAlias(
        $_aliasNameGenerator(db.directivePrefs.directiveId, db.directives.id),
      );

  $$DirectivesTableProcessedTableManager get directiveId {
    final $_column = $_itemColumn<int>('directive_id')!;

    final manager = $$DirectivesTableTableManager(
      $_db,
      $_db.directives,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_directiveIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DirectivePrefsTableFilterComposer
    extends Composer<_$AppDatabase, $DirectivePrefsTable> {
  $$DirectivePrefsTableFilterComposer({
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

  ColumnFilters<String> get treatmentFacilityPref => $composableBuilder(
    column: $table.treatmentFacilityPref,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredFacilityName => $composableBuilder(
    column: $table.preferredFacilityName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avoidFacilityName => $composableBuilder(
    column: $table.avoidFacilityName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicationConsent => $composableBuilder(
    column: $table.medicationConsent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ectConsent => $composableBuilder(
    column: $table.ectConsent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get experimentalConsent => $composableBuilder(
    column: $table.experimentalConsent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get drugTrialConsent => $composableBuilder(
    column: $table.drugTrialConsent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get agentCanConsentHospitalization => $composableBuilder(
    column: $table.agentCanConsentHospitalization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get agentCanConsentMedication => $composableBuilder(
    column: $table.agentCanConsentMedication,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agentAuthorityLimitations => $composableBuilder(
    column: $table.agentAuthorityLimitations,
    builder: (column) => ColumnFilters(column),
  );

  $$DirectivesTableFilterComposer get directiveId {
    final $$DirectivesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directiveId,
      referencedTable: $db.directives,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DirectivesTableFilterComposer(
            $db: $db,
            $table: $db.directives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DirectivePrefsTableOrderingComposer
    extends Composer<_$AppDatabase, $DirectivePrefsTable> {
  $$DirectivePrefsTableOrderingComposer({
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

  ColumnOrderings<String> get treatmentFacilityPref => $composableBuilder(
    column: $table.treatmentFacilityPref,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredFacilityName => $composableBuilder(
    column: $table.preferredFacilityName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avoidFacilityName => $composableBuilder(
    column: $table.avoidFacilityName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicationConsent => $composableBuilder(
    column: $table.medicationConsent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ectConsent => $composableBuilder(
    column: $table.ectConsent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get experimentalConsent => $composableBuilder(
    column: $table.experimentalConsent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get drugTrialConsent => $composableBuilder(
    column: $table.drugTrialConsent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get agentCanConsentHospitalization =>
      $composableBuilder(
        column: $table.agentCanConsentHospitalization,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<bool> get agentCanConsentMedication => $composableBuilder(
    column: $table.agentCanConsentMedication,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agentAuthorityLimitations => $composableBuilder(
    column: $table.agentAuthorityLimitations,
    builder: (column) => ColumnOrderings(column),
  );

  $$DirectivesTableOrderingComposer get directiveId {
    final $$DirectivesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directiveId,
      referencedTable: $db.directives,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DirectivesTableOrderingComposer(
            $db: $db,
            $table: $db.directives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DirectivePrefsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DirectivePrefsTable> {
  $$DirectivePrefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get treatmentFacilityPref => $composableBuilder(
    column: $table.treatmentFacilityPref,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preferredFacilityName => $composableBuilder(
    column: $table.preferredFacilityName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avoidFacilityName => $composableBuilder(
    column: $table.avoidFacilityName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get medicationConsent => $composableBuilder(
    column: $table.medicationConsent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ectConsent => $composableBuilder(
    column: $table.ectConsent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get experimentalConsent => $composableBuilder(
    column: $table.experimentalConsent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get drugTrialConsent => $composableBuilder(
    column: $table.drugTrialConsent,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get agentCanConsentHospitalization =>
      $composableBuilder(
        column: $table.agentCanConsentHospitalization,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get agentCanConsentMedication => $composableBuilder(
    column: $table.agentCanConsentMedication,
    builder: (column) => column,
  );

  GeneratedColumn<String> get agentAuthorityLimitations => $composableBuilder(
    column: $table.agentAuthorityLimitations,
    builder: (column) => column,
  );

  $$DirectivesTableAnnotationComposer get directiveId {
    final $$DirectivesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directiveId,
      referencedTable: $db.directives,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DirectivesTableAnnotationComposer(
            $db: $db,
            $table: $db.directives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DirectivePrefsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DirectivePrefsTable,
          DirectivePref,
          $$DirectivePrefsTableFilterComposer,
          $$DirectivePrefsTableOrderingComposer,
          $$DirectivePrefsTableAnnotationComposer,
          $$DirectivePrefsTableCreateCompanionBuilder,
          $$DirectivePrefsTableUpdateCompanionBuilder,
          (DirectivePref, $$DirectivePrefsTableReferences),
          DirectivePref,
          PrefetchHooks Function({bool directiveId})
        > {
  $$DirectivePrefsTableTableManager(
    _$AppDatabase db,
    $DirectivePrefsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DirectivePrefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DirectivePrefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DirectivePrefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> directiveId = const Value.absent(),
                Value<String> treatmentFacilityPref = const Value.absent(),
                Value<String> preferredFacilityName = const Value.absent(),
                Value<String> avoidFacilityName = const Value.absent(),
                Value<String> medicationConsent = const Value.absent(),
                Value<String> ectConsent = const Value.absent(),
                Value<String> experimentalConsent = const Value.absent(),
                Value<String> drugTrialConsent = const Value.absent(),
                Value<bool> agentCanConsentHospitalization =
                    const Value.absent(),
                Value<bool> agentCanConsentMedication = const Value.absent(),
                Value<String> agentAuthorityLimitations = const Value.absent(),
              }) => DirectivePrefsCompanion(
                id: id,
                directiveId: directiveId,
                treatmentFacilityPref: treatmentFacilityPref,
                preferredFacilityName: preferredFacilityName,
                avoidFacilityName: avoidFacilityName,
                medicationConsent: medicationConsent,
                ectConsent: ectConsent,
                experimentalConsent: experimentalConsent,
                drugTrialConsent: drugTrialConsent,
                agentCanConsentHospitalization: agentCanConsentHospitalization,
                agentCanConsentMedication: agentCanConsentMedication,
                agentAuthorityLimitations: agentAuthorityLimitations,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int directiveId,
                Value<String> treatmentFacilityPref = const Value.absent(),
                Value<String> preferredFacilityName = const Value.absent(),
                Value<String> avoidFacilityName = const Value.absent(),
                Value<String> medicationConsent = const Value.absent(),
                Value<String> ectConsent = const Value.absent(),
                Value<String> experimentalConsent = const Value.absent(),
                Value<String> drugTrialConsent = const Value.absent(),
                Value<bool> agentCanConsentHospitalization =
                    const Value.absent(),
                Value<bool> agentCanConsentMedication = const Value.absent(),
                Value<String> agentAuthorityLimitations = const Value.absent(),
              }) => DirectivePrefsCompanion.insert(
                id: id,
                directiveId: directiveId,
                treatmentFacilityPref: treatmentFacilityPref,
                preferredFacilityName: preferredFacilityName,
                avoidFacilityName: avoidFacilityName,
                medicationConsent: medicationConsent,
                ectConsent: ectConsent,
                experimentalConsent: experimentalConsent,
                drugTrialConsent: drugTrialConsent,
                agentCanConsentHospitalization: agentCanConsentHospitalization,
                agentCanConsentMedication: agentCanConsentMedication,
                agentAuthorityLimitations: agentAuthorityLimitations,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DirectivePrefsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({directiveId = false}) {
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
                    if (directiveId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.directiveId,
                                referencedTable: $$DirectivePrefsTableReferences
                                    ._directiveIdTable(db),
                                referencedColumn:
                                    $$DirectivePrefsTableReferences
                                        ._directiveIdTable(db)
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

typedef $$DirectivePrefsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DirectivePrefsTable,
      DirectivePref,
      $$DirectivePrefsTableFilterComposer,
      $$DirectivePrefsTableOrderingComposer,
      $$DirectivePrefsTableAnnotationComposer,
      $$DirectivePrefsTableCreateCompanionBuilder,
      $$DirectivePrefsTableUpdateCompanionBuilder,
      (DirectivePref, $$DirectivePrefsTableReferences),
      DirectivePref,
      PrefetchHooks Function({bool directiveId})
    >;
typedef $$AdditionalInstructionsTableTableCreateCompanionBuilder =
    AdditionalInstructionsTableCompanion Function({
      Value<int> id,
      required int directiveId,
      Value<String> activities,
      Value<String> crisisIntervention,
      Value<String> healthHistory,
      Value<String> dietary,
      Value<String> religious,
      Value<String> childrenCustody,
      Value<String> familyNotification,
      Value<String> recordsDisclosure,
      Value<String> petCustody,
      Value<String> other,
    });
typedef $$AdditionalInstructionsTableTableUpdateCompanionBuilder =
    AdditionalInstructionsTableCompanion Function({
      Value<int> id,
      Value<int> directiveId,
      Value<String> activities,
      Value<String> crisisIntervention,
      Value<String> healthHistory,
      Value<String> dietary,
      Value<String> religious,
      Value<String> childrenCustody,
      Value<String> familyNotification,
      Value<String> recordsDisclosure,
      Value<String> petCustody,
      Value<String> other,
    });

final class $$AdditionalInstructionsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AdditionalInstructionsTableTable,
          AdditionalInstructionsTableData
        > {
  $$AdditionalInstructionsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DirectivesTable _directiveIdTable(_$AppDatabase db) =>
      db.directives.createAlias(
        $_aliasNameGenerator(
          db.additionalInstructionsTable.directiveId,
          db.directives.id,
        ),
      );

  $$DirectivesTableProcessedTableManager get directiveId {
    final $_column = $_itemColumn<int>('directive_id')!;

    final manager = $$DirectivesTableTableManager(
      $_db,
      $_db.directives,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_directiveIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AdditionalInstructionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AdditionalInstructionsTableTable> {
  $$AdditionalInstructionsTableTableFilterComposer({
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

  ColumnFilters<String> get activities => $composableBuilder(
    column: $table.activities,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get crisisIntervention => $composableBuilder(
    column: $table.crisisIntervention,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get healthHistory => $composableBuilder(
    column: $table.healthHistory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dietary => $composableBuilder(
    column: $table.dietary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get religious => $composableBuilder(
    column: $table.religious,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childrenCustody => $composableBuilder(
    column: $table.childrenCustody,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyNotification => $composableBuilder(
    column: $table.familyNotification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordsDisclosure => $composableBuilder(
    column: $table.recordsDisclosure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get petCustody => $composableBuilder(
    column: $table.petCustody,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get other => $composableBuilder(
    column: $table.other,
    builder: (column) => ColumnFilters(column),
  );

  $$DirectivesTableFilterComposer get directiveId {
    final $$DirectivesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directiveId,
      referencedTable: $db.directives,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DirectivesTableFilterComposer(
            $db: $db,
            $table: $db.directives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdditionalInstructionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AdditionalInstructionsTableTable> {
  $$AdditionalInstructionsTableTableOrderingComposer({
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

  ColumnOrderings<String> get activities => $composableBuilder(
    column: $table.activities,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get crisisIntervention => $composableBuilder(
    column: $table.crisisIntervention,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get healthHistory => $composableBuilder(
    column: $table.healthHistory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dietary => $composableBuilder(
    column: $table.dietary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get religious => $composableBuilder(
    column: $table.religious,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childrenCustody => $composableBuilder(
    column: $table.childrenCustody,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyNotification => $composableBuilder(
    column: $table.familyNotification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordsDisclosure => $composableBuilder(
    column: $table.recordsDisclosure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get petCustody => $composableBuilder(
    column: $table.petCustody,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get other => $composableBuilder(
    column: $table.other,
    builder: (column) => ColumnOrderings(column),
  );

  $$DirectivesTableOrderingComposer get directiveId {
    final $$DirectivesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directiveId,
      referencedTable: $db.directives,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DirectivesTableOrderingComposer(
            $db: $db,
            $table: $db.directives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdditionalInstructionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdditionalInstructionsTableTable> {
  $$AdditionalInstructionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get activities => $composableBuilder(
    column: $table.activities,
    builder: (column) => column,
  );

  GeneratedColumn<String> get crisisIntervention => $composableBuilder(
    column: $table.crisisIntervention,
    builder: (column) => column,
  );

  GeneratedColumn<String> get healthHistory => $composableBuilder(
    column: $table.healthHistory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dietary =>
      $composableBuilder(column: $table.dietary, builder: (column) => column);

  GeneratedColumn<String> get religious =>
      $composableBuilder(column: $table.religious, builder: (column) => column);

  GeneratedColumn<String> get childrenCustody => $composableBuilder(
    column: $table.childrenCustody,
    builder: (column) => column,
  );

  GeneratedColumn<String> get familyNotification => $composableBuilder(
    column: $table.familyNotification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recordsDisclosure => $composableBuilder(
    column: $table.recordsDisclosure,
    builder: (column) => column,
  );

  GeneratedColumn<String> get petCustody => $composableBuilder(
    column: $table.petCustody,
    builder: (column) => column,
  );

  GeneratedColumn<String> get other =>
      $composableBuilder(column: $table.other, builder: (column) => column);

  $$DirectivesTableAnnotationComposer get directiveId {
    final $$DirectivesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directiveId,
      referencedTable: $db.directives,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DirectivesTableAnnotationComposer(
            $db: $db,
            $table: $db.directives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AdditionalInstructionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdditionalInstructionsTableTable,
          AdditionalInstructionsTableData,
          $$AdditionalInstructionsTableTableFilterComposer,
          $$AdditionalInstructionsTableTableOrderingComposer,
          $$AdditionalInstructionsTableTableAnnotationComposer,
          $$AdditionalInstructionsTableTableCreateCompanionBuilder,
          $$AdditionalInstructionsTableTableUpdateCompanionBuilder,
          (
            AdditionalInstructionsTableData,
            $$AdditionalInstructionsTableTableReferences,
          ),
          AdditionalInstructionsTableData,
          PrefetchHooks Function({bool directiveId})
        > {
  $$AdditionalInstructionsTableTableTableManager(
    _$AppDatabase db,
    $AdditionalInstructionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdditionalInstructionsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AdditionalInstructionsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AdditionalInstructionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> directiveId = const Value.absent(),
                Value<String> activities = const Value.absent(),
                Value<String> crisisIntervention = const Value.absent(),
                Value<String> healthHistory = const Value.absent(),
                Value<String> dietary = const Value.absent(),
                Value<String> religious = const Value.absent(),
                Value<String> childrenCustody = const Value.absent(),
                Value<String> familyNotification = const Value.absent(),
                Value<String> recordsDisclosure = const Value.absent(),
                Value<String> petCustody = const Value.absent(),
                Value<String> other = const Value.absent(),
              }) => AdditionalInstructionsTableCompanion(
                id: id,
                directiveId: directiveId,
                activities: activities,
                crisisIntervention: crisisIntervention,
                healthHistory: healthHistory,
                dietary: dietary,
                religious: religious,
                childrenCustody: childrenCustody,
                familyNotification: familyNotification,
                recordsDisclosure: recordsDisclosure,
                petCustody: petCustody,
                other: other,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int directiveId,
                Value<String> activities = const Value.absent(),
                Value<String> crisisIntervention = const Value.absent(),
                Value<String> healthHistory = const Value.absent(),
                Value<String> dietary = const Value.absent(),
                Value<String> religious = const Value.absent(),
                Value<String> childrenCustody = const Value.absent(),
                Value<String> familyNotification = const Value.absent(),
                Value<String> recordsDisclosure = const Value.absent(),
                Value<String> petCustody = const Value.absent(),
                Value<String> other = const Value.absent(),
              }) => AdditionalInstructionsTableCompanion.insert(
                id: id,
                directiveId: directiveId,
                activities: activities,
                crisisIntervention: crisisIntervention,
                healthHistory: healthHistory,
                dietary: dietary,
                religious: religious,
                childrenCustody: childrenCustody,
                familyNotification: familyNotification,
                recordsDisclosure: recordsDisclosure,
                petCustody: petCustody,
                other: other,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AdditionalInstructionsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({directiveId = false}) {
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
                    if (directiveId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.directiveId,
                                referencedTable:
                                    $$AdditionalInstructionsTableTableReferences
                                        ._directiveIdTable(db),
                                referencedColumn:
                                    $$AdditionalInstructionsTableTableReferences
                                        ._directiveIdTable(db)
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

typedef $$AdditionalInstructionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdditionalInstructionsTableTable,
      AdditionalInstructionsTableData,
      $$AdditionalInstructionsTableTableFilterComposer,
      $$AdditionalInstructionsTableTableOrderingComposer,
      $$AdditionalInstructionsTableTableAnnotationComposer,
      $$AdditionalInstructionsTableTableCreateCompanionBuilder,
      $$AdditionalInstructionsTableTableUpdateCompanionBuilder,
      (
        AdditionalInstructionsTableData,
        $$AdditionalInstructionsTableTableReferences,
      ),
      AdditionalInstructionsTableData,
      PrefetchHooks Function({bool directiveId})
    >;
typedef $$WitnessesTableCreateCompanionBuilder =
    WitnessesCompanion Function({
      Value<int> id,
      required int directiveId,
      required int witnessNumber,
      Value<String> fullName,
      Value<String> address,
      Value<String?> signatureBase64,
      Value<int?> signatureDate,
    });
typedef $$WitnessesTableUpdateCompanionBuilder =
    WitnessesCompanion Function({
      Value<int> id,
      Value<int> directiveId,
      Value<int> witnessNumber,
      Value<String> fullName,
      Value<String> address,
      Value<String?> signatureBase64,
      Value<int?> signatureDate,
    });

final class $$WitnessesTableReferences
    extends BaseReferences<_$AppDatabase, $WitnessesTable, WitnessesData> {
  $$WitnessesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DirectivesTable _directiveIdTable(_$AppDatabase db) =>
      db.directives.createAlias(
        $_aliasNameGenerator(db.witnesses.directiveId, db.directives.id),
      );

  $$DirectivesTableProcessedTableManager get directiveId {
    final $_column = $_itemColumn<int>('directive_id')!;

    final manager = $$DirectivesTableTableManager(
      $_db,
      $_db.directives,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_directiveIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WitnessesTableFilterComposer
    extends Composer<_$AppDatabase, $WitnessesTable> {
  $$WitnessesTableFilterComposer({
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

  ColumnFilters<int> get witnessNumber => $composableBuilder(
    column: $table.witnessNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signatureBase64 => $composableBuilder(
    column: $table.signatureBase64,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get signatureDate => $composableBuilder(
    column: $table.signatureDate,
    builder: (column) => ColumnFilters(column),
  );

  $$DirectivesTableFilterComposer get directiveId {
    final $$DirectivesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directiveId,
      referencedTable: $db.directives,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DirectivesTableFilterComposer(
            $db: $db,
            $table: $db.directives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WitnessesTableOrderingComposer
    extends Composer<_$AppDatabase, $WitnessesTable> {
  $$WitnessesTableOrderingComposer({
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

  ColumnOrderings<int> get witnessNumber => $composableBuilder(
    column: $table.witnessNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signatureBase64 => $composableBuilder(
    column: $table.signatureBase64,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get signatureDate => $composableBuilder(
    column: $table.signatureDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$DirectivesTableOrderingComposer get directiveId {
    final $$DirectivesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directiveId,
      referencedTable: $db.directives,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DirectivesTableOrderingComposer(
            $db: $db,
            $table: $db.directives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WitnessesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WitnessesTable> {
  $$WitnessesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get witnessNumber => $composableBuilder(
    column: $table.witnessNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get signatureBase64 => $composableBuilder(
    column: $table.signatureBase64,
    builder: (column) => column,
  );

  GeneratedColumn<int> get signatureDate => $composableBuilder(
    column: $table.signatureDate,
    builder: (column) => column,
  );

  $$DirectivesTableAnnotationComposer get directiveId {
    final $$DirectivesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directiveId,
      referencedTable: $db.directives,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DirectivesTableAnnotationComposer(
            $db: $db,
            $table: $db.directives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WitnessesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WitnessesTable,
          WitnessesData,
          $$WitnessesTableFilterComposer,
          $$WitnessesTableOrderingComposer,
          $$WitnessesTableAnnotationComposer,
          $$WitnessesTableCreateCompanionBuilder,
          $$WitnessesTableUpdateCompanionBuilder,
          (WitnessesData, $$WitnessesTableReferences),
          WitnessesData,
          PrefetchHooks Function({bool directiveId})
        > {
  $$WitnessesTableTableManager(_$AppDatabase db, $WitnessesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WitnessesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WitnessesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WitnessesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> directiveId = const Value.absent(),
                Value<int> witnessNumber = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String?> signatureBase64 = const Value.absent(),
                Value<int?> signatureDate = const Value.absent(),
              }) => WitnessesCompanion(
                id: id,
                directiveId: directiveId,
                witnessNumber: witnessNumber,
                fullName: fullName,
                address: address,
                signatureBase64: signatureBase64,
                signatureDate: signatureDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int directiveId,
                required int witnessNumber,
                Value<String> fullName = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String?> signatureBase64 = const Value.absent(),
                Value<int?> signatureDate = const Value.absent(),
              }) => WitnessesCompanion.insert(
                id: id,
                directiveId: directiveId,
                witnessNumber: witnessNumber,
                fullName: fullName,
                address: address,
                signatureBase64: signatureBase64,
                signatureDate: signatureDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WitnessesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({directiveId = false}) {
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
                    if (directiveId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.directiveId,
                                referencedTable: $$WitnessesTableReferences
                                    ._directiveIdTable(db),
                                referencedColumn: $$WitnessesTableReferences
                                    ._directiveIdTable(db)
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

typedef $$WitnessesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WitnessesTable,
      WitnessesData,
      $$WitnessesTableFilterComposer,
      $$WitnessesTableOrderingComposer,
      $$WitnessesTableAnnotationComposer,
      $$WitnessesTableCreateCompanionBuilder,
      $$WitnessesTableUpdateCompanionBuilder,
      (WitnessesData, $$WitnessesTableReferences),
      WitnessesData,
      PrefetchHooks Function({bool directiveId})
    >;
typedef $$GuardianNominationsTableCreateCompanionBuilder =
    GuardianNominationsCompanion Function({
      Value<int> id,
      required int directiveId,
      Value<String> nomineeFullName,
      Value<String> nomineeAddress,
      Value<String> nomineePhone,
      Value<String> nomineeRelationship,
    });
typedef $$GuardianNominationsTableUpdateCompanionBuilder =
    GuardianNominationsCompanion Function({
      Value<int> id,
      Value<int> directiveId,
      Value<String> nomineeFullName,
      Value<String> nomineeAddress,
      Value<String> nomineePhone,
      Value<String> nomineeRelationship,
    });

final class $$GuardianNominationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GuardianNominationsTable,
          GuardianNomination
        > {
  $$GuardianNominationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DirectivesTable _directiveIdTable(_$AppDatabase db) =>
      db.directives.createAlias(
        $_aliasNameGenerator(
          db.guardianNominations.directiveId,
          db.directives.id,
        ),
      );

  $$DirectivesTableProcessedTableManager get directiveId {
    final $_column = $_itemColumn<int>('directive_id')!;

    final manager = $$DirectivesTableTableManager(
      $_db,
      $_db.directives,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_directiveIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GuardianNominationsTableFilterComposer
    extends Composer<_$AppDatabase, $GuardianNominationsTable> {
  $$GuardianNominationsTableFilterComposer({
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

  ColumnFilters<String> get nomineeFullName => $composableBuilder(
    column: $table.nomineeFullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nomineeAddress => $composableBuilder(
    column: $table.nomineeAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nomineePhone => $composableBuilder(
    column: $table.nomineePhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nomineeRelationship => $composableBuilder(
    column: $table.nomineeRelationship,
    builder: (column) => ColumnFilters(column),
  );

  $$DirectivesTableFilterComposer get directiveId {
    final $$DirectivesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directiveId,
      referencedTable: $db.directives,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DirectivesTableFilterComposer(
            $db: $db,
            $table: $db.directives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GuardianNominationsTableOrderingComposer
    extends Composer<_$AppDatabase, $GuardianNominationsTable> {
  $$GuardianNominationsTableOrderingComposer({
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

  ColumnOrderings<String> get nomineeFullName => $composableBuilder(
    column: $table.nomineeFullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nomineeAddress => $composableBuilder(
    column: $table.nomineeAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nomineePhone => $composableBuilder(
    column: $table.nomineePhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nomineeRelationship => $composableBuilder(
    column: $table.nomineeRelationship,
    builder: (column) => ColumnOrderings(column),
  );

  $$DirectivesTableOrderingComposer get directiveId {
    final $$DirectivesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directiveId,
      referencedTable: $db.directives,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DirectivesTableOrderingComposer(
            $db: $db,
            $table: $db.directives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GuardianNominationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GuardianNominationsTable> {
  $$GuardianNominationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nomineeFullName => $composableBuilder(
    column: $table.nomineeFullName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nomineeAddress => $composableBuilder(
    column: $table.nomineeAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nomineePhone => $composableBuilder(
    column: $table.nomineePhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nomineeRelationship => $composableBuilder(
    column: $table.nomineeRelationship,
    builder: (column) => column,
  );

  $$DirectivesTableAnnotationComposer get directiveId {
    final $$DirectivesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.directiveId,
      referencedTable: $db.directives,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DirectivesTableAnnotationComposer(
            $db: $db,
            $table: $db.directives,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GuardianNominationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GuardianNominationsTable,
          GuardianNomination,
          $$GuardianNominationsTableFilterComposer,
          $$GuardianNominationsTableOrderingComposer,
          $$GuardianNominationsTableAnnotationComposer,
          $$GuardianNominationsTableCreateCompanionBuilder,
          $$GuardianNominationsTableUpdateCompanionBuilder,
          (GuardianNomination, $$GuardianNominationsTableReferences),
          GuardianNomination,
          PrefetchHooks Function({bool directiveId})
        > {
  $$GuardianNominationsTableTableManager(
    _$AppDatabase db,
    $GuardianNominationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GuardianNominationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GuardianNominationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$GuardianNominationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> directiveId = const Value.absent(),
                Value<String> nomineeFullName = const Value.absent(),
                Value<String> nomineeAddress = const Value.absent(),
                Value<String> nomineePhone = const Value.absent(),
                Value<String> nomineeRelationship = const Value.absent(),
              }) => GuardianNominationsCompanion(
                id: id,
                directiveId: directiveId,
                nomineeFullName: nomineeFullName,
                nomineeAddress: nomineeAddress,
                nomineePhone: nomineePhone,
                nomineeRelationship: nomineeRelationship,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int directiveId,
                Value<String> nomineeFullName = const Value.absent(),
                Value<String> nomineeAddress = const Value.absent(),
                Value<String> nomineePhone = const Value.absent(),
                Value<String> nomineeRelationship = const Value.absent(),
              }) => GuardianNominationsCompanion.insert(
                id: id,
                directiveId: directiveId,
                nomineeFullName: nomineeFullName,
                nomineeAddress: nomineeAddress,
                nomineePhone: nomineePhone,
                nomineeRelationship: nomineeRelationship,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GuardianNominationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({directiveId = false}) {
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
                    if (directiveId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.directiveId,
                                referencedTable:
                                    $$GuardianNominationsTableReferences
                                        ._directiveIdTable(db),
                                referencedColumn:
                                    $$GuardianNominationsTableReferences
                                        ._directiveIdTable(db)
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

typedef $$GuardianNominationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GuardianNominationsTable,
      GuardianNomination,
      $$GuardianNominationsTableFilterComposer,
      $$GuardianNominationsTableOrderingComposer,
      $$GuardianNominationsTableAnnotationComposer,
      $$GuardianNominationsTableCreateCompanionBuilder,
      $$GuardianNominationsTableUpdateCompanionBuilder,
      (GuardianNomination, $$GuardianNominationsTableReferences),
      GuardianNomination,
      PrefetchHooks Function({bool directiveId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DirectivesTableTableManager get directives =>
      $$DirectivesTableTableManager(_db, _db.directives);
  $$AgentsTableTableManager get agents =>
      $$AgentsTableTableManager(_db, _db.agents);
  $$MedicationEntriesTableTableManager get medicationEntries =>
      $$MedicationEntriesTableTableManager(_db, _db.medicationEntries);
  $$DirectivePrefsTableTableManager get directivePrefs =>
      $$DirectivePrefsTableTableManager(_db, _db.directivePrefs);
  $$AdditionalInstructionsTableTableTableManager
  get additionalInstructionsTable =>
      $$AdditionalInstructionsTableTableTableManager(
        _db,
        _db.additionalInstructionsTable,
      );
  $$WitnessesTableTableManager get witnesses =>
      $$WitnessesTableTableManager(_db, _db.witnesses);
  $$GuardianNominationsTableTableManager get guardianNominations =>
      $$GuardianNominationsTableTableManager(_db, _db.guardianNominations);
}
