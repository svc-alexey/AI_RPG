// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_collections.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProviderProfileRecordCollection on Isar {
  IsarCollection<ProviderProfileRecord> get providerProfileRecords =>
      this.collection();
}

const ProviderProfileRecordSchema = CollectionSchema(
  name: r'ProviderProfileRecord',
  id: -8816304325882985767,
  properties: {
    r'apiKey': PropertySchema(
      id: 0,
      name: r'apiKey',
      type: IsarType.string,
    ),
    r'baseUrl': PropertySchema(
      id: 1,
      name: r'baseUrl',
      type: IsarType.string,
    ),
    r'contextWindowSize': PropertySchema(
      id: 2,
      name: r'contextWindowSize',
      type: IsarType.long,
    ),
    r'maxResponseTokens': PropertySchema(
      id: 3,
      name: r'maxResponseTokens',
      type: IsarType.long,
    ),
    r'model': PropertySchema(
      id: 4,
      name: r'model',
      type: IsarType.string,
    ),
    r'providerKey': PropertySchema(
      id: 5,
      name: r'providerKey',
      type: IsarType.string,
    ),
    r'runtimeProfile': PropertySchema(
      id: 6,
      name: r'runtimeProfile',
      type: IsarType.string,
    ),
    r'timeoutSeconds': PropertySchema(
      id: 7,
      name: r'timeoutSeconds',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 8,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _providerProfileRecordEstimateSize,
  serialize: _providerProfileRecordSerialize,
  deserialize: _providerProfileRecordDeserialize,
  deserializeProp: _providerProfileRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'providerKey': IndexSchema(
      id: 4830899061330615695,
      name: r'providerKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'providerKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _providerProfileRecordGetId,
  getLinks: _providerProfileRecordGetLinks,
  attach: _providerProfileRecordAttach,
  version: '3.1.0+1',
);

int _providerProfileRecordEstimateSize(
  ProviderProfileRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.apiKey.length * 3;
  bytesCount += 3 + object.baseUrl.length * 3;
  bytesCount += 3 + object.model.length * 3;
  bytesCount += 3 + object.providerKey.length * 3;
  bytesCount += 3 + object.runtimeProfile.length * 3;
  return bytesCount;
}

void _providerProfileRecordSerialize(
  ProviderProfileRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.apiKey);
  writer.writeString(offsets[1], object.baseUrl);
  writer.writeLong(offsets[2], object.contextWindowSize);
  writer.writeLong(offsets[3], object.maxResponseTokens);
  writer.writeString(offsets[4], object.model);
  writer.writeString(offsets[5], object.providerKey);
  writer.writeString(offsets[6], object.runtimeProfile);
  writer.writeLong(offsets[7], object.timeoutSeconds);
  writer.writeDateTime(offsets[8], object.updatedAt);
}

ProviderProfileRecord _providerProfileRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProviderProfileRecord();
  object.apiKey = reader.readString(offsets[0]);
  object.baseUrl = reader.readString(offsets[1]);
  object.contextWindowSize = reader.readLong(offsets[2]);
  object.id = id;
  object.maxResponseTokens = reader.readLong(offsets[3]);
  object.model = reader.readString(offsets[4]);
  object.providerKey = reader.readString(offsets[5]);
  object.runtimeProfile = reader.readString(offsets[6]);
  object.timeoutSeconds = reader.readLong(offsets[7]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[8]);
  return object;
}

P _providerProfileRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _providerProfileRecordGetId(ProviderProfileRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _providerProfileRecordGetLinks(
    ProviderProfileRecord object) {
  return [];
}

void _providerProfileRecordAttach(
    IsarCollection<dynamic> col, Id id, ProviderProfileRecord object) {
  object.id = id;
}

extension ProviderProfileRecordByIndex
    on IsarCollection<ProviderProfileRecord> {
  Future<ProviderProfileRecord?> getByProviderKey(String providerKey) {
    return getByIndex(r'providerKey', [providerKey]);
  }

  ProviderProfileRecord? getByProviderKeySync(String providerKey) {
    return getByIndexSync(r'providerKey', [providerKey]);
  }

  Future<bool> deleteByProviderKey(String providerKey) {
    return deleteByIndex(r'providerKey', [providerKey]);
  }

  bool deleteByProviderKeySync(String providerKey) {
    return deleteByIndexSync(r'providerKey', [providerKey]);
  }

  Future<List<ProviderProfileRecord?>> getAllByProviderKey(
      List<String> providerKeyValues) {
    final values = providerKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'providerKey', values);
  }

  List<ProviderProfileRecord?> getAllByProviderKeySync(
      List<String> providerKeyValues) {
    final values = providerKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'providerKey', values);
  }

  Future<int> deleteAllByProviderKey(List<String> providerKeyValues) {
    final values = providerKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'providerKey', values);
  }

  int deleteAllByProviderKeySync(List<String> providerKeyValues) {
    final values = providerKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'providerKey', values);
  }

  Future<Id> putByProviderKey(ProviderProfileRecord object) {
    return putByIndex(r'providerKey', object);
  }

  Id putByProviderKeySync(ProviderProfileRecord object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'providerKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByProviderKey(List<ProviderProfileRecord> objects) {
    return putAllByIndex(r'providerKey', objects);
  }

  List<Id> putAllByProviderKeySync(List<ProviderProfileRecord> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'providerKey', objects, saveLinks: saveLinks);
  }
}

extension ProviderProfileRecordQueryWhereSort
    on QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QWhere> {
  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProviderProfileRecordQueryWhere on QueryBuilder<ProviderProfileRecord,
    ProviderProfileRecord, QWhereClause> {
  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterWhereClause>
      providerKeyEqualTo(String providerKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'providerKey',
        value: [providerKey],
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterWhereClause>
      providerKeyNotEqualTo(String providerKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerKey',
              lower: [],
              upper: [providerKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerKey',
              lower: [providerKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerKey',
              lower: [providerKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'providerKey',
              lower: [],
              upper: [providerKey],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ProviderProfileRecordQueryFilter on QueryBuilder<
    ProviderProfileRecord, ProviderProfileRecord, QFilterCondition> {
  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> apiKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'apiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> apiKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'apiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> apiKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'apiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> apiKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'apiKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> apiKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'apiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> apiKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'apiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
          QAfterFilterCondition>
      apiKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'apiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
          QAfterFilterCondition>
      apiKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'apiKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> apiKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'apiKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> apiKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'apiKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> baseUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> baseUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> baseUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> baseUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baseUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> baseUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'baseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> baseUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'baseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
          QAfterFilterCondition>
      baseUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'baseUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
          QAfterFilterCondition>
      baseUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'baseUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> baseUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> baseUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'baseUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> contextWindowSizeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contextWindowSize',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> contextWindowSizeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contextWindowSize',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> contextWindowSizeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contextWindowSize',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> contextWindowSizeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contextWindowSize',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> maxResponseTokensEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxResponseTokens',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> maxResponseTokensGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxResponseTokens',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> maxResponseTokensLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxResponseTokens',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> maxResponseTokensBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxResponseTokens',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> modelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> modelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> modelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> modelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'model',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> modelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> modelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
          QAfterFilterCondition>
      modelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'model',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
          QAfterFilterCondition>
      modelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'model',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> modelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'model',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> modelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'model',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> providerKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> providerKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'providerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> providerKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'providerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> providerKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'providerKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> providerKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'providerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> providerKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'providerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
          QAfterFilterCondition>
      providerKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'providerKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
          QAfterFilterCondition>
      providerKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'providerKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> providerKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'providerKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> providerKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'providerKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> runtimeProfileEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'runtimeProfile',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> runtimeProfileGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'runtimeProfile',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> runtimeProfileLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'runtimeProfile',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> runtimeProfileBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'runtimeProfile',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> runtimeProfileStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'runtimeProfile',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> runtimeProfileEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'runtimeProfile',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
          QAfterFilterCondition>
      runtimeProfileContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'runtimeProfile',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
          QAfterFilterCondition>
      runtimeProfileMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'runtimeProfile',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> runtimeProfileIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'runtimeProfile',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> runtimeProfileIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'runtimeProfile',
        value: '',
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> timeoutSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timeoutSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> timeoutSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timeoutSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> timeoutSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timeoutSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> timeoutSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timeoutSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord,
      QAfterFilterCondition> updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProviderProfileRecordQueryObject on QueryBuilder<
    ProviderProfileRecord, ProviderProfileRecord, QFilterCondition> {}

extension ProviderProfileRecordQueryLinks on QueryBuilder<ProviderProfileRecord,
    ProviderProfileRecord, QFilterCondition> {}

extension ProviderProfileRecordQuerySortBy
    on QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QSortBy> {
  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      sortByApiKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiKey', Sort.asc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      sortByApiKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiKey', Sort.desc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      sortByBaseUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseUrl', Sort.asc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      sortByBaseUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseUrl', Sort.desc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      sortByContextWindowSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextWindowSize', Sort.asc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      sortByContextWindowSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextWindowSize', Sort.desc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      sortByMaxResponseTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxResponseTokens', Sort.asc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      sortByMaxResponseTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxResponseTokens', Sort.desc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      sortByModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.asc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      sortByModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.desc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      sortByProviderKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerKey', Sort.asc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      sortByProviderKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerKey', Sort.desc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      sortByRuntimeProfile() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runtimeProfile', Sort.asc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      sortByRuntimeProfileDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runtimeProfile', Sort.desc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      sortByTimeoutSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeoutSeconds', Sort.asc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      sortByTimeoutSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeoutSeconds', Sort.desc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ProviderProfileRecordQuerySortThenBy
    on QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QSortThenBy> {
  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      thenByApiKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiKey', Sort.asc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      thenByApiKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apiKey', Sort.desc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      thenByBaseUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseUrl', Sort.asc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      thenByBaseUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseUrl', Sort.desc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      thenByContextWindowSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextWindowSize', Sort.asc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      thenByContextWindowSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contextWindowSize', Sort.desc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      thenByMaxResponseTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxResponseTokens', Sort.asc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      thenByMaxResponseTokensDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxResponseTokens', Sort.desc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      thenByModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.asc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      thenByModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'model', Sort.desc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      thenByProviderKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerKey', Sort.asc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      thenByProviderKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'providerKey', Sort.desc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      thenByRuntimeProfile() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runtimeProfile', Sort.asc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      thenByRuntimeProfileDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'runtimeProfile', Sort.desc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      thenByTimeoutSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeoutSeconds', Sort.asc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      thenByTimeoutSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timeoutSeconds', Sort.desc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ProviderProfileRecordQueryWhereDistinct
    on QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QDistinct> {
  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QDistinct>
      distinctByApiKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'apiKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QDistinct>
      distinctByBaseUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baseUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QDistinct>
      distinctByContextWindowSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contextWindowSize');
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QDistinct>
      distinctByMaxResponseTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxResponseTokens');
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QDistinct>
      distinctByModel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'model', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QDistinct>
      distinctByProviderKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'providerKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QDistinct>
      distinctByRuntimeProfile({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'runtimeProfile',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QDistinct>
      distinctByTimeoutSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timeoutSeconds');
    });
  }

  QueryBuilder<ProviderProfileRecord, ProviderProfileRecord, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ProviderProfileRecordQueryProperty on QueryBuilder<
    ProviderProfileRecord, ProviderProfileRecord, QQueryProperty> {
  QueryBuilder<ProviderProfileRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProviderProfileRecord, String, QQueryOperations>
      apiKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'apiKey');
    });
  }

  QueryBuilder<ProviderProfileRecord, String, QQueryOperations>
      baseUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baseUrl');
    });
  }

  QueryBuilder<ProviderProfileRecord, int, QQueryOperations>
      contextWindowSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contextWindowSize');
    });
  }

  QueryBuilder<ProviderProfileRecord, int, QQueryOperations>
      maxResponseTokensProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxResponseTokens');
    });
  }

  QueryBuilder<ProviderProfileRecord, String, QQueryOperations>
      modelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'model');
    });
  }

  QueryBuilder<ProviderProfileRecord, String, QQueryOperations>
      providerKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'providerKey');
    });
  }

  QueryBuilder<ProviderProfileRecord, String, QQueryOperations>
      runtimeProfileProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'runtimeProfile');
    });
  }

  QueryBuilder<ProviderProfileRecord, int, QQueryOperations>
      timeoutSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timeoutSeconds');
    });
  }

  QueryBuilder<ProviderProfileRecord, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetModelControlRecordCollection on Isar {
  IsarCollection<ModelControlRecord> get modelControlRecords =>
      this.collection();
}

const ModelControlRecordSchema = CollectionSchema(
  name: r'ModelControlRecord',
  id: -1132577316338683052,
  properties: {
    r'activeProvider': PropertySchema(
      id: 0,
      name: r'activeProvider',
      type: IsarType.string,
    ),
    r'confirmed18Plus': PropertySchema(
      id: 1,
      name: r'confirmed18Plus',
      type: IsarType.bool,
    ),
    r'fastResponses': PropertySchema(
      id: 2,
      name: r'fastResponses',
      type: IsarType.bool,
    ),
    r'key': PropertySchema(
      id: 3,
      name: r'key',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 4,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _modelControlRecordEstimateSize,
  serialize: _modelControlRecordSerialize,
  deserialize: _modelControlRecordDeserialize,
  deserializeProp: _modelControlRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'key': IndexSchema(
      id: -4906094122524121629,
      name: r'key',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'key',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _modelControlRecordGetId,
  getLinks: _modelControlRecordGetLinks,
  attach: _modelControlRecordAttach,
  version: '3.1.0+1',
);

int _modelControlRecordEstimateSize(
  ModelControlRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.activeProvider.length * 3;
  bytesCount += 3 + object.key.length * 3;
  return bytesCount;
}

void _modelControlRecordSerialize(
  ModelControlRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.activeProvider);
  writer.writeBool(offsets[1], object.confirmed18Plus);
  writer.writeBool(offsets[2], object.fastResponses);
  writer.writeString(offsets[3], object.key);
  writer.writeDateTime(offsets[4], object.updatedAt);
}

ModelControlRecord _modelControlRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ModelControlRecord();
  object.activeProvider = reader.readString(offsets[0]);
  object.confirmed18Plus = reader.readBool(offsets[1]);
  object.fastResponses = reader.readBool(offsets[2]);
  object.id = id;
  object.key = reader.readString(offsets[3]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[4]);
  return object;
}

P _modelControlRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _modelControlRecordGetId(ModelControlRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _modelControlRecordGetLinks(
    ModelControlRecord object) {
  return [];
}

void _modelControlRecordAttach(
    IsarCollection<dynamic> col, Id id, ModelControlRecord object) {
  object.id = id;
}

extension ModelControlRecordByIndex on IsarCollection<ModelControlRecord> {
  Future<ModelControlRecord?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  ModelControlRecord? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<ModelControlRecord?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<ModelControlRecord?> getAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'key', values);
  }

  Future<int> deleteAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'key', values);
  }

  int deleteAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'key', values);
  }

  Future<Id> putByKey(ModelControlRecord object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(ModelControlRecord object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<ModelControlRecord> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(List<ModelControlRecord> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension ModelControlRecordQueryWhereSort
    on QueryBuilder<ModelControlRecord, ModelControlRecord, QWhere> {
  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ModelControlRecordQueryWhere
    on QueryBuilder<ModelControlRecord, ModelControlRecord, QWhereClause> {
  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterWhereClause>
      keyEqualTo(String key) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'key',
        value: [key],
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterWhereClause>
      keyNotEqualTo(String key) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [],
              upper: [key],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [key],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [key],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [],
              upper: [key],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ModelControlRecordQueryFilter
    on QueryBuilder<ModelControlRecord, ModelControlRecord, QFilterCondition> {
  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      activeProviderEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      activeProviderGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      activeProviderLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      activeProviderBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeProvider',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      activeProviderStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activeProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      activeProviderEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activeProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      activeProviderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activeProvider',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      activeProviderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activeProvider',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      activeProviderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeProvider',
        value: '',
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      activeProviderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activeProvider',
        value: '',
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      confirmed18PlusEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confirmed18Plus',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      fastResponsesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fastResponses',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      keyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      keyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      keyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      keyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'key',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      keyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      keyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'key',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterFilterCondition>
      updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ModelControlRecordQueryObject
    on QueryBuilder<ModelControlRecord, ModelControlRecord, QFilterCondition> {}

extension ModelControlRecordQueryLinks
    on QueryBuilder<ModelControlRecord, ModelControlRecord, QFilterCondition> {}

extension ModelControlRecordQuerySortBy
    on QueryBuilder<ModelControlRecord, ModelControlRecord, QSortBy> {
  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      sortByActiveProvider() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeProvider', Sort.asc);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      sortByActiveProviderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeProvider', Sort.desc);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      sortByConfirmed18Plus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmed18Plus', Sort.asc);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      sortByConfirmed18PlusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmed18Plus', Sort.desc);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      sortByFastResponses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fastResponses', Sort.asc);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      sortByFastResponsesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fastResponses', Sort.desc);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ModelControlRecordQuerySortThenBy
    on QueryBuilder<ModelControlRecord, ModelControlRecord, QSortThenBy> {
  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      thenByActiveProvider() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeProvider', Sort.asc);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      thenByActiveProviderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeProvider', Sort.desc);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      thenByConfirmed18Plus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmed18Plus', Sort.asc);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      thenByConfirmed18PlusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confirmed18Plus', Sort.desc);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      thenByFastResponses() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fastResponses', Sort.asc);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      thenByFastResponsesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fastResponses', Sort.desc);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ModelControlRecordQueryWhereDistinct
    on QueryBuilder<ModelControlRecord, ModelControlRecord, QDistinct> {
  QueryBuilder<ModelControlRecord, ModelControlRecord, QDistinct>
      distinctByActiveProvider({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeProvider',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QDistinct>
      distinctByConfirmed18Plus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confirmed18Plus');
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QDistinct>
      distinctByFastResponses() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fastResponses');
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QDistinct> distinctByKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ModelControlRecord, ModelControlRecord, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ModelControlRecordQueryProperty
    on QueryBuilder<ModelControlRecord, ModelControlRecord, QQueryProperty> {
  QueryBuilder<ModelControlRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ModelControlRecord, String, QQueryOperations>
      activeProviderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeProvider');
    });
  }

  QueryBuilder<ModelControlRecord, bool, QQueryOperations>
      confirmed18PlusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confirmed18Plus');
    });
  }

  QueryBuilder<ModelControlRecord, bool, QQueryOperations>
      fastResponsesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fastResponses');
    });
  }

  QueryBuilder<ModelControlRecord, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<ModelControlRecord, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppSettingRecordCollection on Isar {
  IsarCollection<AppSettingRecord> get appSettingRecords => this.collection();
}

const AppSettingRecordSchema = CollectionSchema(
  name: r'AppSettingRecord',
  id: -6897423751675572856,
  properties: {
    r'jsonValue': PropertySchema(
      id: 0,
      name: r'jsonValue',
      type: IsarType.string,
    ),
    r'key': PropertySchema(
      id: 1,
      name: r'key',
      type: IsarType.string,
    ),
    r'stringValue': PropertySchema(
      id: 2,
      name: r'stringValue',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 3,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _appSettingRecordEstimateSize,
  serialize: _appSettingRecordSerialize,
  deserialize: _appSettingRecordDeserialize,
  deserializeProp: _appSettingRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'key': IndexSchema(
      id: -4906094122524121629,
      name: r'key',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'key',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _appSettingRecordGetId,
  getLinks: _appSettingRecordGetLinks,
  attach: _appSettingRecordAttach,
  version: '3.1.0+1',
);

int _appSettingRecordEstimateSize(
  AppSettingRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.jsonValue;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.key.length * 3;
  {
    final value = object.stringValue;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _appSettingRecordSerialize(
  AppSettingRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.jsonValue);
  writer.writeString(offsets[1], object.key);
  writer.writeString(offsets[2], object.stringValue);
  writer.writeDateTime(offsets[3], object.updatedAt);
}

AppSettingRecord _appSettingRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppSettingRecord();
  object.id = id;
  object.jsonValue = reader.readStringOrNull(offsets[0]);
  object.key = reader.readString(offsets[1]);
  object.stringValue = reader.readStringOrNull(offsets[2]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[3]);
  return object;
}

P _appSettingRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appSettingRecordGetId(AppSettingRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appSettingRecordGetLinks(AppSettingRecord object) {
  return [];
}

void _appSettingRecordAttach(
    IsarCollection<dynamic> col, Id id, AppSettingRecord object) {
  object.id = id;
}

extension AppSettingRecordByIndex on IsarCollection<AppSettingRecord> {
  Future<AppSettingRecord?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  AppSettingRecord? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<AppSettingRecord?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<AppSettingRecord?> getAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'key', values);
  }

  Future<int> deleteAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'key', values);
  }

  int deleteAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'key', values);
  }

  Future<Id> putByKey(AppSettingRecord object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(AppSettingRecord object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<AppSettingRecord> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(List<AppSettingRecord> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension AppSettingRecordQueryWhereSort
    on QueryBuilder<AppSettingRecord, AppSettingRecord, QWhere> {
  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppSettingRecordQueryWhere
    on QueryBuilder<AppSettingRecord, AppSettingRecord, QWhereClause> {
  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterWhereClause>
      keyEqualTo(String key) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'key',
        value: [key],
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterWhereClause>
      keyNotEqualTo(String key) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [],
              upper: [key],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [key],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [key],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [],
              upper: [key],
              includeUpper: false,
            ));
      }
    });
  }
}

extension AppSettingRecordQueryFilter
    on QueryBuilder<AppSettingRecord, AppSettingRecord, QFilterCondition> {
  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      jsonValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'jsonValue',
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      jsonValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'jsonValue',
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      jsonValueEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jsonValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      jsonValueGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'jsonValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      jsonValueLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'jsonValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      jsonValueBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'jsonValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      jsonValueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'jsonValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      jsonValueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'jsonValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      jsonValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'jsonValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      jsonValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'jsonValue',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      jsonValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'jsonValue',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      jsonValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'jsonValue',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      keyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      keyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      keyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      keyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'key',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      keyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      keyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'key',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      stringValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stringValue',
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      stringValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stringValue',
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      stringValueEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stringValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      stringValueGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stringValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      stringValueLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stringValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      stringValueBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stringValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      stringValueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stringValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      stringValueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stringValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      stringValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stringValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      stringValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stringValue',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      stringValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stringValue',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      stringValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stringValue',
        value: '',
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterFilterCondition>
      updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AppSettingRecordQueryObject
    on QueryBuilder<AppSettingRecord, AppSettingRecord, QFilterCondition> {}

extension AppSettingRecordQueryLinks
    on QueryBuilder<AppSettingRecord, AppSettingRecord, QFilterCondition> {}

extension AppSettingRecordQuerySortBy
    on QueryBuilder<AppSettingRecord, AppSettingRecord, QSortBy> {
  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterSortBy>
      sortByJsonValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonValue', Sort.asc);
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterSortBy>
      sortByJsonValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonValue', Sort.desc);
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterSortBy> sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterSortBy>
      sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterSortBy>
      sortByStringValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringValue', Sort.asc);
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterSortBy>
      sortByStringValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringValue', Sort.desc);
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AppSettingRecordQuerySortThenBy
    on QueryBuilder<AppSettingRecord, AppSettingRecord, QSortThenBy> {
  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterSortBy>
      thenByJsonValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonValue', Sort.asc);
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterSortBy>
      thenByJsonValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jsonValue', Sort.desc);
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterSortBy> thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterSortBy>
      thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterSortBy>
      thenByStringValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringValue', Sort.asc);
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterSortBy>
      thenByStringValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringValue', Sort.desc);
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AppSettingRecordQueryWhereDistinct
    on QueryBuilder<AppSettingRecord, AppSettingRecord, QDistinct> {
  QueryBuilder<AppSettingRecord, AppSettingRecord, QDistinct>
      distinctByJsonValue({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'jsonValue', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QDistinct> distinctByKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QDistinct>
      distinctByStringValue({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stringValue', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingRecord, AppSettingRecord, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension AppSettingRecordQueryProperty
    on QueryBuilder<AppSettingRecord, AppSettingRecord, QQueryProperty> {
  QueryBuilder<AppSettingRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppSettingRecord, String?, QQueryOperations>
      jsonValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'jsonValue');
    });
  }

  QueryBuilder<AppSettingRecord, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<AppSettingRecord, String?, QQueryOperations>
      stringValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stringValue');
    });
  }

  QueryBuilder<AppSettingRecord, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
