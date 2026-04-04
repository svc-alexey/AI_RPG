// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_collections.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCampaignRecordCollection on Isar {
  IsarCollection<CampaignRecord> get campaignRecords => this.collection();
}

const CampaignRecordSchema = CollectionSchema(
  name: r'CampaignRecord',
  id: -896639911631749669,
  properties: {
    r'activeGoal': PropertySchema(
      id: 0,
      name: r'activeGoal',
      type: IsarType.string,
    ),
    r'activeSituation': PropertySchema(
      id: 1,
      name: r'activeSituation',
      type: IsarType.string,
    ),
    r'campaignId': PropertySchema(
      id: 2,
      name: r'campaignId',
      type: IsarType.string,
    ),
    r'characterJson': PropertySchema(
      id: 3,
      name: r'characterJson',
      type: IsarType.string,
    ),
    r'characterPrompt': PropertySchema(
      id: 4,
      name: r'characterPrompt',
      type: IsarType.string,
    ),
    r'choicesJson': PropertySchema(
      id: 5,
      name: r'choicesJson',
      type: IsarType.string,
    ),
    r'customStoryPrompt': PropertySchema(
      id: 6,
      name: r'customStoryPrompt',
      type: IsarType.string,
    ),
    r'difficulty': PropertySchema(
      id: 7,
      name: r'difficulty',
      type: IsarType.string,
    ),
    r'inventoryJson': PropertySchema(
      id: 8,
      name: r'inventoryJson',
      type: IsarType.string,
    ),
    r'literaryGenre': PropertySchema(
      id: 9,
      name: r'literaryGenre',
      type: IsarType.string,
    ),
    r'location': PropertySchema(
      id: 10,
      name: r'location',
      type: IsarType.string,
    ),
    r'memoryJson': PropertySchema(
      id: 11,
      name: r'memoryJson',
      type: IsarType.string,
    ),
    r'mode': PropertySchema(
      id: 12,
      name: r'mode',
      type: IsarType.string,
    ),
    r'modulesJson': PropertySchema(
      id: 13,
      name: r'modulesJson',
      type: IsarType.string,
    ),
    r'objective': PropertySchema(
      id: 14,
      name: r'objective',
      type: IsarType.string,
    ),
    r'portraitPath': PropertySchema(
      id: 15,
      name: r'portraitPath',
      type: IsarType.string,
    ),
    r'portraitPrompt': PropertySchema(
      id: 16,
      name: r'portraitPrompt',
      type: IsarType.string,
    ),
    r'questLogJson': PropertySchema(
      id: 17,
      name: r'questLogJson',
      type: IsarType.string,
    ),
    r'schemaVersion': PropertySchema(
      id: 18,
      name: r'schemaVersion',
      type: IsarType.long,
    ),
    r'setting': PropertySchema(
      id: 19,
      name: r'setting',
      type: IsarType.string,
    ),
    r'summary': PropertySchema(
      id: 20,
      name: r'summary',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 21,
      name: r'title',
      type: IsarType.string,
    ),
    r'turnNumber': PropertySchema(
      id: 22,
      name: r'turnNumber',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 23,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _campaignRecordEstimateSize,
  serialize: _campaignRecordSerialize,
  deserialize: _campaignRecordDeserialize,
  deserializeProp: _campaignRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'campaignId': IndexSchema(
      id: 2069977803028940998,
      name: r'campaignId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'campaignId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _campaignRecordGetId,
  getLinks: _campaignRecordGetLinks,
  attach: _campaignRecordAttach,
  version: '3.1.0+1',
);

int _campaignRecordEstimateSize(
  CampaignRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.activeGoal.length * 3;
  bytesCount += 3 + object.activeSituation.length * 3;
  bytesCount += 3 + object.campaignId.length * 3;
  bytesCount += 3 + object.characterJson.length * 3;
  bytesCount += 3 + object.characterPrompt.length * 3;
  bytesCount += 3 + object.choicesJson.length * 3;
  bytesCount += 3 + object.customStoryPrompt.length * 3;
  bytesCount += 3 + object.difficulty.length * 3;
  bytesCount += 3 + object.inventoryJson.length * 3;
  {
    final value = object.literaryGenre;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.location.length * 3;
  bytesCount += 3 + object.memoryJson.length * 3;
  bytesCount += 3 + object.mode.length * 3;
  bytesCount += 3 + object.modulesJson.length * 3;
  bytesCount += 3 + object.objective.length * 3;
  bytesCount += 3 + object.portraitPath.length * 3;
  bytesCount += 3 + object.portraitPrompt.length * 3;
  bytesCount += 3 + object.questLogJson.length * 3;
  bytesCount += 3 + object.setting.length * 3;
  bytesCount += 3 + object.summary.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _campaignRecordSerialize(
  CampaignRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.activeGoal);
  writer.writeString(offsets[1], object.activeSituation);
  writer.writeString(offsets[2], object.campaignId);
  writer.writeString(offsets[3], object.characterJson);
  writer.writeString(offsets[4], object.characterPrompt);
  writer.writeString(offsets[5], object.choicesJson);
  writer.writeString(offsets[6], object.customStoryPrompt);
  writer.writeString(offsets[7], object.difficulty);
  writer.writeString(offsets[8], object.inventoryJson);
  writer.writeString(offsets[9], object.literaryGenre);
  writer.writeString(offsets[10], object.location);
  writer.writeString(offsets[11], object.memoryJson);
  writer.writeString(offsets[12], object.mode);
  writer.writeString(offsets[13], object.modulesJson);
  writer.writeString(offsets[14], object.objective);
  writer.writeString(offsets[15], object.portraitPath);
  writer.writeString(offsets[16], object.portraitPrompt);
  writer.writeString(offsets[17], object.questLogJson);
  writer.writeLong(offsets[18], object.schemaVersion);
  writer.writeString(offsets[19], object.setting);
  writer.writeString(offsets[20], object.summary);
  writer.writeString(offsets[21], object.title);
  writer.writeLong(offsets[22], object.turnNumber);
  writer.writeDateTime(offsets[23], object.updatedAt);
}

CampaignRecord _campaignRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CampaignRecord();
  object.activeGoal = reader.readString(offsets[0]);
  object.activeSituation = reader.readString(offsets[1]);
  object.campaignId = reader.readString(offsets[2]);
  object.characterJson = reader.readString(offsets[3]);
  object.characterPrompt = reader.readString(offsets[4]);
  object.choicesJson = reader.readString(offsets[5]);
  object.customStoryPrompt = reader.readString(offsets[6]);
  object.difficulty = reader.readString(offsets[7]);
  object.id = id;
  object.inventoryJson = reader.readString(offsets[8]);
  object.literaryGenre = reader.readStringOrNull(offsets[9]);
  object.location = reader.readString(offsets[10]);
  object.memoryJson = reader.readString(offsets[11]);
  object.mode = reader.readString(offsets[12]);
  object.modulesJson = reader.readString(offsets[13]);
  object.objective = reader.readString(offsets[14]);
  object.portraitPath = reader.readString(offsets[15]);
  object.portraitPrompt = reader.readString(offsets[16]);
  object.questLogJson = reader.readString(offsets[17]);
  object.schemaVersion = reader.readLong(offsets[18]);
  object.setting = reader.readString(offsets[19]);
  object.summary = reader.readString(offsets[20]);
  object.title = reader.readString(offsets[21]);
  object.turnNumber = reader.readLong(offsets[22]);
  object.updatedAt = reader.readDateTime(offsets[23]);
  return object;
}

P _campaignRecordDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readLong(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readLong(offset)) as P;
    case 23:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _campaignRecordGetId(CampaignRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _campaignRecordGetLinks(CampaignRecord object) {
  return [];
}

void _campaignRecordAttach(
    IsarCollection<dynamic> col, Id id, CampaignRecord object) {
  object.id = id;
}

extension CampaignRecordByIndex on IsarCollection<CampaignRecord> {
  Future<CampaignRecord?> getByCampaignId(String campaignId) {
    return getByIndex(r'campaignId', [campaignId]);
  }

  CampaignRecord? getByCampaignIdSync(String campaignId) {
    return getByIndexSync(r'campaignId', [campaignId]);
  }

  Future<bool> deleteByCampaignId(String campaignId) {
    return deleteByIndex(r'campaignId', [campaignId]);
  }

  bool deleteByCampaignIdSync(String campaignId) {
    return deleteByIndexSync(r'campaignId', [campaignId]);
  }

  Future<List<CampaignRecord?>> getAllByCampaignId(
      List<String> campaignIdValues) {
    final values = campaignIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'campaignId', values);
  }

  List<CampaignRecord?> getAllByCampaignIdSync(List<String> campaignIdValues) {
    final values = campaignIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'campaignId', values);
  }

  Future<int> deleteAllByCampaignId(List<String> campaignIdValues) {
    final values = campaignIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'campaignId', values);
  }

  int deleteAllByCampaignIdSync(List<String> campaignIdValues) {
    final values = campaignIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'campaignId', values);
  }

  Future<Id> putByCampaignId(CampaignRecord object) {
    return putByIndex(r'campaignId', object);
  }

  Id putByCampaignIdSync(CampaignRecord object, {bool saveLinks = true}) {
    return putByIndexSync(r'campaignId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCampaignId(List<CampaignRecord> objects) {
    return putAllByIndex(r'campaignId', objects);
  }

  List<Id> putAllByCampaignIdSync(List<CampaignRecord> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'campaignId', objects, saveLinks: saveLinks);
  }
}

extension CampaignRecordQueryWhereSort
    on QueryBuilder<CampaignRecord, CampaignRecord, QWhere> {
  QueryBuilder<CampaignRecord, CampaignRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CampaignRecordQueryWhere
    on QueryBuilder<CampaignRecord, CampaignRecord, QWhereClause> {
  QueryBuilder<CampaignRecord, CampaignRecord, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterWhereClause> idBetween(
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

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterWhereClause>
      campaignIdEqualTo(String campaignId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'campaignId',
        value: [campaignId],
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterWhereClause>
      campaignIdNotEqualTo(String campaignId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'campaignId',
              lower: [],
              upper: [campaignId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'campaignId',
              lower: [campaignId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'campaignId',
              lower: [campaignId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'campaignId',
              lower: [],
              upper: [campaignId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CampaignRecordQueryFilter
    on QueryBuilder<CampaignRecord, CampaignRecord, QFilterCondition> {
  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      activeGoalEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      activeGoalGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      activeGoalLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      activeGoalBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      activeGoalStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activeGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      activeGoalEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activeGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      activeGoalContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activeGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      activeGoalMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activeGoal',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      activeGoalIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeGoal',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      activeGoalIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activeGoal',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      activeSituationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeSituation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      activeSituationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeSituation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      activeSituationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeSituation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      activeSituationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeSituation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      activeSituationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activeSituation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      activeSituationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activeSituation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      activeSituationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activeSituation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      activeSituationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activeSituation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      activeSituationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeSituation',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      activeSituationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activeSituation',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      campaignIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      campaignIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      campaignIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      campaignIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'campaignId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      campaignIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      campaignIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      campaignIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      campaignIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'campaignId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      campaignIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'campaignId',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      campaignIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'campaignId',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      characterJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'characterJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      characterJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'characterJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      characterJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'characterJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      characterJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'characterJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      characterJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'characterJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      characterJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'characterJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      characterJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'characterJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      characterJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'characterJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      characterJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'characterJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      characterJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'characterJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      characterPromptEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'characterPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      characterPromptGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'characterPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      characterPromptLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'characterPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      characterPromptBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'characterPrompt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      characterPromptStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'characterPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      characterPromptEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'characterPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      characterPromptContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'characterPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      characterPromptMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'characterPrompt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      characterPromptIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'characterPrompt',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      characterPromptIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'characterPrompt',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      choicesJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'choicesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      choicesJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'choicesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      choicesJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'choicesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      choicesJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'choicesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      choicesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'choicesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      choicesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'choicesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      choicesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'choicesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      choicesJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'choicesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      choicesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'choicesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      choicesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'choicesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      customStoryPromptEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customStoryPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      customStoryPromptGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customStoryPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      customStoryPromptLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customStoryPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      customStoryPromptBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customStoryPrompt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      customStoryPromptStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'customStoryPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      customStoryPromptEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'customStoryPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      customStoryPromptContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'customStoryPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      customStoryPromptMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'customStoryPrompt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      customStoryPromptIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customStoryPrompt',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      customStoryPromptIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'customStoryPrompt',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      difficultyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'difficulty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      difficultyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'difficulty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      difficultyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'difficulty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      difficultyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'difficulty',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      difficultyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'difficulty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      difficultyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'difficulty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      difficultyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'difficulty',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      difficultyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'difficulty',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      difficultyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'difficulty',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      difficultyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'difficulty',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
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

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
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

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition> idBetween(
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

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      inventoryJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inventoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      inventoryJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'inventoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      inventoryJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'inventoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      inventoryJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'inventoryJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      inventoryJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'inventoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      inventoryJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'inventoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      inventoryJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'inventoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      inventoryJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'inventoryJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      inventoryJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inventoryJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      inventoryJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'inventoryJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      literaryGenreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'literaryGenre',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      literaryGenreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'literaryGenre',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      literaryGenreEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'literaryGenre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      literaryGenreGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'literaryGenre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      literaryGenreLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'literaryGenre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      literaryGenreBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'literaryGenre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      literaryGenreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'literaryGenre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      literaryGenreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'literaryGenre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      literaryGenreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'literaryGenre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      literaryGenreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'literaryGenre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      literaryGenreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'literaryGenre',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      literaryGenreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'literaryGenre',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      locationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      locationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      locationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      locationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'location',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      locationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      locationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      locationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      locationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'location',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      locationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'location',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      locationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'location',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      memoryJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'memoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      memoryJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'memoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      memoryJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'memoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      memoryJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'memoryJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      memoryJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'memoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      memoryJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'memoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      memoryJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'memoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      memoryJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'memoryJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      memoryJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'memoryJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      memoryJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'memoryJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      modeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      modeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      modeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      modeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      modeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      modeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      modeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      modeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      modeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mode',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      modeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mode',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      modulesJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'modulesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      modulesJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'modulesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      modulesJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'modulesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      modulesJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'modulesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      modulesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'modulesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      modulesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'modulesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      modulesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'modulesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      modulesJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'modulesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      modulesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'modulesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      modulesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'modulesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      objectiveEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'objective',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      objectiveGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'objective',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      objectiveLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'objective',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      objectiveBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'objective',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      objectiveStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'objective',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      objectiveEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'objective',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      objectiveContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'objective',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      objectiveMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'objective',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      objectiveIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'objective',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      objectiveIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'objective',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      portraitPathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'portraitPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      portraitPathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'portraitPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      portraitPathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'portraitPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      portraitPathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'portraitPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      portraitPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'portraitPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      portraitPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'portraitPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      portraitPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'portraitPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      portraitPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'portraitPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      portraitPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'portraitPath',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      portraitPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'portraitPath',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      portraitPromptEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'portraitPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      portraitPromptGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'portraitPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      portraitPromptLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'portraitPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      portraitPromptBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'portraitPrompt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      portraitPromptStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'portraitPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      portraitPromptEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'portraitPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      portraitPromptContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'portraitPrompt',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      portraitPromptMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'portraitPrompt',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      portraitPromptIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'portraitPrompt',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      portraitPromptIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'portraitPrompt',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      questLogJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'questLogJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      questLogJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'questLogJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      questLogJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'questLogJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      questLogJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'questLogJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      questLogJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'questLogJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      questLogJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'questLogJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      questLogJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'questLogJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      questLogJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'questLogJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      questLogJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'questLogJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      questLogJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'questLogJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      schemaVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      schemaVersionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      schemaVersionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      schemaVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schemaVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      settingEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'setting',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      settingGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'setting',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      settingLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'setting',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      settingBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'setting',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      settingStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'setting',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      settingEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'setting',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      settingContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'setting',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      settingMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'setting',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      settingIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'setting',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      settingIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'setting',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      summaryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      summaryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      summaryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      summaryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'summary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      summaryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      summaryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      summaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      summaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'summary',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      summaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'summary',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      summaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'summary',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      turnNumberEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'turnNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      turnNumberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'turnNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      turnNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'turnNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      turnNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'turnNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
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

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
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

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
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

extension CampaignRecordQueryObject
    on QueryBuilder<CampaignRecord, CampaignRecord, QFilterCondition> {}

extension CampaignRecordQueryLinks
    on QueryBuilder<CampaignRecord, CampaignRecord, QFilterCondition> {}

extension CampaignRecordQuerySortBy
    on QueryBuilder<CampaignRecord, CampaignRecord, QSortBy> {
  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByActiveGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeGoal', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByActiveGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeGoal', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByActiveSituation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeSituation', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByActiveSituationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeSituation', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByCampaignId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignId', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByCampaignIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignId', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByCharacterJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterJson', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByCharacterJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterJson', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByCharacterPrompt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterPrompt', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByCharacterPromptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterPrompt', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByChoicesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'choicesJson', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByChoicesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'choicesJson', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByCustomStoryPrompt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customStoryPrompt', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByCustomStoryPromptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customStoryPrompt', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByDifficultyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByInventoryJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventoryJson', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByInventoryJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventoryJson', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByLiteraryGenre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'literaryGenre', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByLiteraryGenreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'literaryGenre', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy> sortByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByMemoryJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memoryJson', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByMemoryJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memoryJson', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy> sortByMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy> sortByModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByModulesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modulesJson', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByModulesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modulesJson', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy> sortByObjective() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objective', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByObjectiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objective', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByPortraitPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portraitPath', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByPortraitPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portraitPath', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByPortraitPrompt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portraitPrompt', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByPortraitPromptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portraitPrompt', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByQuestLogJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questLogJson', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByQuestLogJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questLogJson', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy> sortBySetting() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'setting', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortBySettingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'setting', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy> sortBySummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortBySummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByTurnNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turnNumber', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByTurnNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turnNumber', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension CampaignRecordQuerySortThenBy
    on QueryBuilder<CampaignRecord, CampaignRecord, QSortThenBy> {
  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByActiveGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeGoal', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByActiveGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeGoal', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByActiveSituation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeSituation', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByActiveSituationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeSituation', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByCampaignId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignId', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByCampaignIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignId', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByCharacterJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterJson', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByCharacterJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterJson', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByCharacterPrompt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterPrompt', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByCharacterPromptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterPrompt', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByChoicesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'choicesJson', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByChoicesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'choicesJson', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByCustomStoryPrompt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customStoryPrompt', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByCustomStoryPromptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customStoryPrompt', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByDifficulty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByDifficultyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficulty', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByInventoryJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventoryJson', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByInventoryJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inventoryJson', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByLiteraryGenre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'literaryGenre', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByLiteraryGenreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'literaryGenre', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy> thenByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByMemoryJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memoryJson', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByMemoryJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memoryJson', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy> thenByMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy> thenByModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mode', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByModulesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modulesJson', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByModulesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modulesJson', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy> thenByObjective() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objective', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByObjectiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objective', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByPortraitPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portraitPath', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByPortraitPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portraitPath', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByPortraitPrompt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portraitPrompt', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByPortraitPromptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'portraitPrompt', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByQuestLogJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questLogJson', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByQuestLogJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questLogJson', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy> thenBySetting() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'setting', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenBySettingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'setting', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy> thenBySummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenBySummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByTurnNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turnNumber', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByTurnNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turnNumber', Sort.desc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension CampaignRecordQueryWhereDistinct
    on QueryBuilder<CampaignRecord, CampaignRecord, QDistinct> {
  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct> distinctByActiveGoal(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeGoal', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct>
      distinctByActiveSituation({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeSituation',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct> distinctByCampaignId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'campaignId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct>
      distinctByCharacterJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'characterJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct>
      distinctByCharacterPrompt({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'characterPrompt',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct> distinctByChoicesJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'choicesJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct>
      distinctByCustomStoryPrompt({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customStoryPrompt',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct> distinctByDifficulty(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'difficulty', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct>
      distinctByInventoryJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inventoryJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct>
      distinctByLiteraryGenre({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'literaryGenre',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct> distinctByLocation(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'location', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct> distinctByMemoryJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'memoryJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct> distinctByMode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct> distinctByModulesJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'modulesJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct> distinctByObjective(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'objective', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct>
      distinctByPortraitPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'portraitPath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct>
      distinctByPortraitPrompt({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'portraitPrompt',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct>
      distinctByQuestLogJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'questLogJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct>
      distinctBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schemaVersion');
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct> distinctBySetting(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'setting', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct> distinctBySummary(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'summary', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct>
      distinctByTurnNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'turnNumber');
    });
  }

  QueryBuilder<CampaignRecord, CampaignRecord, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension CampaignRecordQueryProperty
    on QueryBuilder<CampaignRecord, CampaignRecord, QQueryProperty> {
  QueryBuilder<CampaignRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CampaignRecord, String, QQueryOperations> activeGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeGoal');
    });
  }

  QueryBuilder<CampaignRecord, String, QQueryOperations>
      activeSituationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeSituation');
    });
  }

  QueryBuilder<CampaignRecord, String, QQueryOperations> campaignIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'campaignId');
    });
  }

  QueryBuilder<CampaignRecord, String, QQueryOperations>
      characterJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'characterJson');
    });
  }

  QueryBuilder<CampaignRecord, String, QQueryOperations>
      characterPromptProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'characterPrompt');
    });
  }

  QueryBuilder<CampaignRecord, String, QQueryOperations> choicesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'choicesJson');
    });
  }

  QueryBuilder<CampaignRecord, String, QQueryOperations>
      customStoryPromptProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customStoryPrompt');
    });
  }

  QueryBuilder<CampaignRecord, String, QQueryOperations> difficultyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'difficulty');
    });
  }

  QueryBuilder<CampaignRecord, String, QQueryOperations>
      inventoryJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inventoryJson');
    });
  }

  QueryBuilder<CampaignRecord, String?, QQueryOperations>
      literaryGenreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'literaryGenre');
    });
  }

  QueryBuilder<CampaignRecord, String, QQueryOperations> locationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'location');
    });
  }

  QueryBuilder<CampaignRecord, String, QQueryOperations> memoryJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'memoryJson');
    });
  }

  QueryBuilder<CampaignRecord, String, QQueryOperations> modeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mode');
    });
  }

  QueryBuilder<CampaignRecord, String, QQueryOperations> modulesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'modulesJson');
    });
  }

  QueryBuilder<CampaignRecord, String, QQueryOperations> objectiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'objective');
    });
  }

  QueryBuilder<CampaignRecord, String, QQueryOperations>
      portraitPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'portraitPath');
    });
  }

  QueryBuilder<CampaignRecord, String, QQueryOperations>
      portraitPromptProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'portraitPrompt');
    });
  }

  QueryBuilder<CampaignRecord, String, QQueryOperations>
      questLogJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'questLogJson');
    });
  }

  QueryBuilder<CampaignRecord, int, QQueryOperations> schemaVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schemaVersion');
    });
  }

  QueryBuilder<CampaignRecord, String, QQueryOperations> settingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'setting');
    });
  }

  QueryBuilder<CampaignRecord, String, QQueryOperations> summaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'summary');
    });
  }

  QueryBuilder<CampaignRecord, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<CampaignRecord, int, QQueryOperations> turnNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'turnNumber');
    });
  }

  QueryBuilder<CampaignRecord, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWorldStateRecordCollection on Isar {
  IsarCollection<WorldStateRecord> get worldStateRecords => this.collection();
}

const WorldStateRecordSchema = CollectionSchema(
  name: r'WorldStateRecord',
  id: -8370299922894467952,
  properties: {
    r'activeGoal': PropertySchema(
      id: 0,
      name: r'activeGoal',
      type: IsarType.string,
    ),
    r'activeSituation': PropertySchema(
      id: 1,
      name: r'activeSituation',
      type: IsarType.string,
    ),
    r'campaignId': PropertySchema(
      id: 2,
      name: r'campaignId',
      type: IsarType.string,
    ),
    r'characterJson': PropertySchema(
      id: 3,
      name: r'characterJson',
      type: IsarType.string,
    ),
    r'checksJson': PropertySchema(
      id: 4,
      name: r'checksJson',
      type: IsarType.string,
    ),
    r'choicesJson': PropertySchema(
      id: 5,
      name: r'choicesJson',
      type: IsarType.string,
    ),
    r'location': PropertySchema(
      id: 6,
      name: r'location',
      type: IsarType.string,
    ),
    r'memoryJson': PropertySchema(
      id: 7,
      name: r'memoryJson',
      type: IsarType.string,
    ),
    r'notesJson': PropertySchema(
      id: 8,
      name: r'notesJson',
      type: IsarType.string,
    ),
    r'objective': PropertySchema(
      id: 9,
      name: r'objective',
      type: IsarType.string,
    ),
    r'progressionJson': PropertySchema(
      id: 10,
      name: r'progressionJson',
      type: IsarType.string,
    ),
    r'questLogJson': PropertySchema(
      id: 11,
      name: r'questLogJson',
      type: IsarType.string,
    ),
    r'resourcesJson': PropertySchema(
      id: 12,
      name: r'resourcesJson',
      type: IsarType.string,
    ),
    r'summary': PropertySchema(
      id: 13,
      name: r'summary',
      type: IsarType.string,
    ),
    r'turnNumber': PropertySchema(
      id: 14,
      name: r'turnNumber',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 15,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _worldStateRecordEstimateSize,
  serialize: _worldStateRecordSerialize,
  deserialize: _worldStateRecordDeserialize,
  deserializeProp: _worldStateRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'campaignId': IndexSchema(
      id: 2069977803028940998,
      name: r'campaignId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'campaignId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _worldStateRecordGetId,
  getLinks: _worldStateRecordGetLinks,
  attach: _worldStateRecordAttach,
  version: '3.1.0+1',
);

int _worldStateRecordEstimateSize(
  WorldStateRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.activeGoal.length * 3;
  bytesCount += 3 + object.activeSituation.length * 3;
  bytesCount += 3 + object.campaignId.length * 3;
  bytesCount += 3 + object.characterJson.length * 3;
  bytesCount += 3 + object.checksJson.length * 3;
  bytesCount += 3 + object.choicesJson.length * 3;
  bytesCount += 3 + object.location.length * 3;
  bytesCount += 3 + object.memoryJson.length * 3;
  bytesCount += 3 + object.notesJson.length * 3;
  bytesCount += 3 + object.objective.length * 3;
  bytesCount += 3 + object.progressionJson.length * 3;
  bytesCount += 3 + object.questLogJson.length * 3;
  bytesCount += 3 + object.resourcesJson.length * 3;
  bytesCount += 3 + object.summary.length * 3;
  return bytesCount;
}

void _worldStateRecordSerialize(
  WorldStateRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.activeGoal);
  writer.writeString(offsets[1], object.activeSituation);
  writer.writeString(offsets[2], object.campaignId);
  writer.writeString(offsets[3], object.characterJson);
  writer.writeString(offsets[4], object.checksJson);
  writer.writeString(offsets[5], object.choicesJson);
  writer.writeString(offsets[6], object.location);
  writer.writeString(offsets[7], object.memoryJson);
  writer.writeString(offsets[8], object.notesJson);
  writer.writeString(offsets[9], object.objective);
  writer.writeString(offsets[10], object.progressionJson);
  writer.writeString(offsets[11], object.questLogJson);
  writer.writeString(offsets[12], object.resourcesJson);
  writer.writeString(offsets[13], object.summary);
  writer.writeLong(offsets[14], object.turnNumber);
  writer.writeDateTime(offsets[15], object.updatedAt);
}

WorldStateRecord _worldStateRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WorldStateRecord();
  object.activeGoal = reader.readString(offsets[0]);
  object.activeSituation = reader.readString(offsets[1]);
  object.campaignId = reader.readString(offsets[2]);
  object.characterJson = reader.readString(offsets[3]);
  object.checksJson = reader.readString(offsets[4]);
  object.choicesJson = reader.readString(offsets[5]);
  object.id = id;
  object.location = reader.readString(offsets[6]);
  object.memoryJson = reader.readString(offsets[7]);
  object.notesJson = reader.readString(offsets[8]);
  object.objective = reader.readString(offsets[9]);
  object.progressionJson = reader.readString(offsets[10]);
  object.questLogJson = reader.readString(offsets[11]);
  object.resourcesJson = reader.readString(offsets[12]);
  object.summary = reader.readString(offsets[13]);
  object.turnNumber = reader.readLong(offsets[14]);
  object.updatedAt = reader.readDateTime(offsets[15]);
  return object;
}

P _worldStateRecordDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _worldStateRecordGetId(WorldStateRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _worldStateRecordGetLinks(WorldStateRecord object) {
  return [];
}

void _worldStateRecordAttach(
    IsarCollection<dynamic> col, Id id, WorldStateRecord object) {
  object.id = id;
}

extension WorldStateRecordByIndex on IsarCollection<WorldStateRecord> {
  Future<WorldStateRecord?> getByCampaignId(String campaignId) {
    return getByIndex(r'campaignId', [campaignId]);
  }

  WorldStateRecord? getByCampaignIdSync(String campaignId) {
    return getByIndexSync(r'campaignId', [campaignId]);
  }

  Future<bool> deleteByCampaignId(String campaignId) {
    return deleteByIndex(r'campaignId', [campaignId]);
  }

  bool deleteByCampaignIdSync(String campaignId) {
    return deleteByIndexSync(r'campaignId', [campaignId]);
  }

  Future<List<WorldStateRecord?>> getAllByCampaignId(
      List<String> campaignIdValues) {
    final values = campaignIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'campaignId', values);
  }

  List<WorldStateRecord?> getAllByCampaignIdSync(
      List<String> campaignIdValues) {
    final values = campaignIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'campaignId', values);
  }

  Future<int> deleteAllByCampaignId(List<String> campaignIdValues) {
    final values = campaignIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'campaignId', values);
  }

  int deleteAllByCampaignIdSync(List<String> campaignIdValues) {
    final values = campaignIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'campaignId', values);
  }

  Future<Id> putByCampaignId(WorldStateRecord object) {
    return putByIndex(r'campaignId', object);
  }

  Id putByCampaignIdSync(WorldStateRecord object, {bool saveLinks = true}) {
    return putByIndexSync(r'campaignId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCampaignId(List<WorldStateRecord> objects) {
    return putAllByIndex(r'campaignId', objects);
  }

  List<Id> putAllByCampaignIdSync(List<WorldStateRecord> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'campaignId', objects, saveLinks: saveLinks);
  }
}

extension WorldStateRecordQueryWhereSort
    on QueryBuilder<WorldStateRecord, WorldStateRecord, QWhere> {
  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension WorldStateRecordQueryWhere
    on QueryBuilder<WorldStateRecord, WorldStateRecord, QWhereClause> {
  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterWhereClause>
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

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterWhereClause> idBetween(
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

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterWhereClause>
      campaignIdEqualTo(String campaignId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'campaignId',
        value: [campaignId],
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterWhereClause>
      campaignIdNotEqualTo(String campaignId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'campaignId',
              lower: [],
              upper: [campaignId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'campaignId',
              lower: [campaignId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'campaignId',
              lower: [campaignId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'campaignId',
              lower: [],
              upper: [campaignId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension WorldStateRecordQueryFilter
    on QueryBuilder<WorldStateRecord, WorldStateRecord, QFilterCondition> {
  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      activeGoalEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      activeGoalGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      activeGoalLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      activeGoalBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      activeGoalStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activeGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      activeGoalEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activeGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      activeGoalContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activeGoal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      activeGoalMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activeGoal',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      activeGoalIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeGoal',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      activeGoalIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activeGoal',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      activeSituationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeSituation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      activeSituationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activeSituation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      activeSituationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activeSituation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      activeSituationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activeSituation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      activeSituationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activeSituation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      activeSituationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activeSituation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      activeSituationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activeSituation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      activeSituationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activeSituation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      activeSituationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activeSituation',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      activeSituationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activeSituation',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      campaignIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      campaignIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      campaignIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      campaignIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'campaignId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      campaignIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      campaignIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      campaignIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      campaignIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'campaignId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      campaignIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'campaignId',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      campaignIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'campaignId',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      characterJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'characterJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      characterJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'characterJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      characterJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'characterJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      characterJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'characterJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      characterJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'characterJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      characterJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'characterJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      characterJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'characterJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      characterJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'characterJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      characterJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'characterJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      characterJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'characterJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      checksJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'checksJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      checksJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'checksJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      checksJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'checksJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      checksJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'checksJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      checksJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'checksJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      checksJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'checksJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      checksJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'checksJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      checksJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'checksJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      checksJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'checksJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      checksJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'checksJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      choicesJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'choicesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      choicesJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'choicesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      choicesJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'choicesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      choicesJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'choicesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      choicesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'choicesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      choicesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'choicesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      choicesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'choicesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      choicesJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'choicesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      choicesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'choicesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      choicesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'choicesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
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

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
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

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
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

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      locationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      locationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      locationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      locationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'location',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      locationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      locationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      locationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      locationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'location',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      locationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'location',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      locationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'location',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      memoryJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'memoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      memoryJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'memoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      memoryJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'memoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      memoryJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'memoryJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      memoryJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'memoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      memoryJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'memoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      memoryJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'memoryJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      memoryJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'memoryJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      memoryJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'memoryJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      memoryJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'memoryJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      notesJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      notesJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      notesJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      notesJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      notesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      notesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      notesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      notesJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      notesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      notesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      objectiveEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'objective',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      objectiveGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'objective',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      objectiveLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'objective',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      objectiveBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'objective',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      objectiveStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'objective',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      objectiveEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'objective',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      objectiveContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'objective',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      objectiveMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'objective',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      objectiveIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'objective',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      objectiveIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'objective',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      progressionJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progressionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      progressionJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'progressionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      progressionJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'progressionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      progressionJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'progressionJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      progressionJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'progressionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      progressionJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'progressionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      progressionJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'progressionJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      progressionJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'progressionJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      progressionJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progressionJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      progressionJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'progressionJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      questLogJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'questLogJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      questLogJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'questLogJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      questLogJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'questLogJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      questLogJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'questLogJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      questLogJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'questLogJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      questLogJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'questLogJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      questLogJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'questLogJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      questLogJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'questLogJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      questLogJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'questLogJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      questLogJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'questLogJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      resourcesJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resourcesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      resourcesJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'resourcesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      resourcesJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'resourcesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      resourcesJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'resourcesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      resourcesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'resourcesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      resourcesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'resourcesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      resourcesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'resourcesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      resourcesJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'resourcesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      resourcesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resourcesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      resourcesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'resourcesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      summaryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      summaryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      summaryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      summaryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'summary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      summaryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      summaryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      summaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'summary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      summaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'summary',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      summaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'summary',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      summaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'summary',
        value: '',
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      turnNumberEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'turnNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      turnNumberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'turnNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      turnNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'turnNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      turnNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'turnNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
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

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
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

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
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

extension WorldStateRecordQueryObject
    on QueryBuilder<WorldStateRecord, WorldStateRecord, QFilterCondition> {}

extension WorldStateRecordQueryLinks
    on QueryBuilder<WorldStateRecord, WorldStateRecord, QFilterCondition> {}

extension WorldStateRecordQuerySortBy
    on QueryBuilder<WorldStateRecord, WorldStateRecord, QSortBy> {
  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByActiveGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeGoal', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByActiveGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeGoal', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByActiveSituation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeSituation', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByActiveSituationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeSituation', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByCampaignId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignId', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByCampaignIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignId', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByCharacterJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterJson', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByCharacterJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterJson', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByChecksJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checksJson', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByChecksJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checksJson', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByChoicesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'choicesJson', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByChoicesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'choicesJson', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByMemoryJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memoryJson', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByMemoryJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memoryJson', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByNotesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notesJson', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByNotesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notesJson', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByObjective() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objective', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByObjectiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objective', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByProgressionJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressionJson', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByProgressionJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressionJson', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByQuestLogJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questLogJson', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByQuestLogJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questLogJson', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByResourcesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourcesJson', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByResourcesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourcesJson', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortBySummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortBySummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByTurnNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turnNumber', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByTurnNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turnNumber', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension WorldStateRecordQuerySortThenBy
    on QueryBuilder<WorldStateRecord, WorldStateRecord, QSortThenBy> {
  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByActiveGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeGoal', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByActiveGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeGoal', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByActiveSituation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeSituation', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByActiveSituationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activeSituation', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByCampaignId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignId', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByCampaignIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignId', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByCharacterJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterJson', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByCharacterJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterJson', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByChecksJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checksJson', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByChecksJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'checksJson', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByChoicesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'choicesJson', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByChoicesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'choicesJson', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByMemoryJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memoryJson', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByMemoryJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'memoryJson', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByNotesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notesJson', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByNotesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notesJson', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByObjective() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objective', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByObjectiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'objective', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByProgressionJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressionJson', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByProgressionJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressionJson', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByQuestLogJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questLogJson', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByQuestLogJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questLogJson', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByResourcesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourcesJson', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByResourcesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourcesJson', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenBySummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenBySummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByTurnNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turnNumber', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByTurnNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'turnNumber', Sort.desc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension WorldStateRecordQueryWhereDistinct
    on QueryBuilder<WorldStateRecord, WorldStateRecord, QDistinct> {
  QueryBuilder<WorldStateRecord, WorldStateRecord, QDistinct>
      distinctByActiveGoal({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeGoal', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QDistinct>
      distinctByActiveSituation({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activeSituation',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QDistinct>
      distinctByCampaignId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'campaignId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QDistinct>
      distinctByCharacterJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'characterJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QDistinct>
      distinctByChecksJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'checksJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QDistinct>
      distinctByChoicesJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'choicesJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QDistinct>
      distinctByLocation({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'location', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QDistinct>
      distinctByMemoryJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'memoryJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QDistinct>
      distinctByNotesJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notesJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QDistinct>
      distinctByObjective({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'objective', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QDistinct>
      distinctByProgressionJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progressionJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QDistinct>
      distinctByQuestLogJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'questLogJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QDistinct>
      distinctByResourcesJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resourcesJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QDistinct> distinctBySummary(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'summary', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QDistinct>
      distinctByTurnNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'turnNumber');
    });
  }

  QueryBuilder<WorldStateRecord, WorldStateRecord, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension WorldStateRecordQueryProperty
    on QueryBuilder<WorldStateRecord, WorldStateRecord, QQueryProperty> {
  QueryBuilder<WorldStateRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WorldStateRecord, String, QQueryOperations>
      activeGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeGoal');
    });
  }

  QueryBuilder<WorldStateRecord, String, QQueryOperations>
      activeSituationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activeSituation');
    });
  }

  QueryBuilder<WorldStateRecord, String, QQueryOperations>
      campaignIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'campaignId');
    });
  }

  QueryBuilder<WorldStateRecord, String, QQueryOperations>
      characterJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'characterJson');
    });
  }

  QueryBuilder<WorldStateRecord, String, QQueryOperations>
      checksJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'checksJson');
    });
  }

  QueryBuilder<WorldStateRecord, String, QQueryOperations>
      choicesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'choicesJson');
    });
  }

  QueryBuilder<WorldStateRecord, String, QQueryOperations> locationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'location');
    });
  }

  QueryBuilder<WorldStateRecord, String, QQueryOperations>
      memoryJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'memoryJson');
    });
  }

  QueryBuilder<WorldStateRecord, String, QQueryOperations> notesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notesJson');
    });
  }

  QueryBuilder<WorldStateRecord, String, QQueryOperations> objectiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'objective');
    });
  }

  QueryBuilder<WorldStateRecord, String, QQueryOperations>
      progressionJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progressionJson');
    });
  }

  QueryBuilder<WorldStateRecord, String, QQueryOperations>
      questLogJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'questLogJson');
    });
  }

  QueryBuilder<WorldStateRecord, String, QQueryOperations>
      resourcesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resourcesJson');
    });
  }

  QueryBuilder<WorldStateRecord, String, QQueryOperations> summaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'summary');
    });
  }

  QueryBuilder<WorldStateRecord, int, QQueryOperations> turnNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'turnNumber');
    });
  }

  QueryBuilder<WorldStateRecord, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMessageRecordCollection on Isar {
  IsarCollection<MessageRecord> get messageRecords => this.collection();
}

const MessageRecordSchema = CollectionSchema(
  name: r'MessageRecord',
  id: 6640242592323881024,
  properties: {
    r'campaignId': PropertySchema(
      id: 0,
      name: r'campaignId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'messageId': PropertySchema(
      id: 2,
      name: r'messageId',
      type: IsarType.string,
    ),
    r'role': PropertySchema(
      id: 3,
      name: r'role',
      type: IsarType.string,
    ),
    r'sortOrder': PropertySchema(
      id: 4,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'text': PropertySchema(
      id: 5,
      name: r'text',
      type: IsarType.string,
    )
  },
  estimateSize: _messageRecordEstimateSize,
  serialize: _messageRecordSerialize,
  deserialize: _messageRecordDeserialize,
  deserializeProp: _messageRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'campaignId': IndexSchema(
      id: 2069977803028940998,
      name: r'campaignId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'campaignId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'messageId': IndexSchema(
      id: -635287409172016016,
      name: r'messageId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'messageId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _messageRecordGetId,
  getLinks: _messageRecordGetLinks,
  attach: _messageRecordAttach,
  version: '3.1.0+1',
);

int _messageRecordEstimateSize(
  MessageRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.campaignId.length * 3;
  bytesCount += 3 + object.messageId.length * 3;
  bytesCount += 3 + object.role.length * 3;
  bytesCount += 3 + object.text.length * 3;
  return bytesCount;
}

void _messageRecordSerialize(
  MessageRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.campaignId);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.messageId);
  writer.writeString(offsets[3], object.role);
  writer.writeLong(offsets[4], object.sortOrder);
  writer.writeString(offsets[5], object.text);
}

MessageRecord _messageRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MessageRecord();
  object.campaignId = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.messageId = reader.readString(offsets[2]);
  object.role = reader.readString(offsets[3]);
  object.sortOrder = reader.readLong(offsets[4]);
  object.text = reader.readString(offsets[5]);
  return object;
}

P _messageRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _messageRecordGetId(MessageRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _messageRecordGetLinks(MessageRecord object) {
  return [];
}

void _messageRecordAttach(
    IsarCollection<dynamic> col, Id id, MessageRecord object) {
  object.id = id;
}

extension MessageRecordByIndex on IsarCollection<MessageRecord> {
  Future<MessageRecord?> getByMessageId(String messageId) {
    return getByIndex(r'messageId', [messageId]);
  }

  MessageRecord? getByMessageIdSync(String messageId) {
    return getByIndexSync(r'messageId', [messageId]);
  }

  Future<bool> deleteByMessageId(String messageId) {
    return deleteByIndex(r'messageId', [messageId]);
  }

  bool deleteByMessageIdSync(String messageId) {
    return deleteByIndexSync(r'messageId', [messageId]);
  }

  Future<List<MessageRecord?>> getAllByMessageId(List<String> messageIdValues) {
    final values = messageIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'messageId', values);
  }

  List<MessageRecord?> getAllByMessageIdSync(List<String> messageIdValues) {
    final values = messageIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'messageId', values);
  }

  Future<int> deleteAllByMessageId(List<String> messageIdValues) {
    final values = messageIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'messageId', values);
  }

  int deleteAllByMessageIdSync(List<String> messageIdValues) {
    final values = messageIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'messageId', values);
  }

  Future<Id> putByMessageId(MessageRecord object) {
    return putByIndex(r'messageId', object);
  }

  Id putByMessageIdSync(MessageRecord object, {bool saveLinks = true}) {
    return putByIndexSync(r'messageId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMessageId(List<MessageRecord> objects) {
    return putAllByIndex(r'messageId', objects);
  }

  List<Id> putAllByMessageIdSync(List<MessageRecord> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'messageId', objects, saveLinks: saveLinks);
  }
}

extension MessageRecordQueryWhereSort
    on QueryBuilder<MessageRecord, MessageRecord, QWhere> {
  QueryBuilder<MessageRecord, MessageRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MessageRecordQueryWhere
    on QueryBuilder<MessageRecord, MessageRecord, QWhereClause> {
  QueryBuilder<MessageRecord, MessageRecord, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<MessageRecord, MessageRecord, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterWhereClause> idBetween(
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

  QueryBuilder<MessageRecord, MessageRecord, QAfterWhereClause>
      campaignIdEqualTo(String campaignId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'campaignId',
        value: [campaignId],
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterWhereClause>
      campaignIdNotEqualTo(String campaignId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'campaignId',
              lower: [],
              upper: [campaignId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'campaignId',
              lower: [campaignId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'campaignId',
              lower: [campaignId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'campaignId',
              lower: [],
              upper: [campaignId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterWhereClause>
      messageIdEqualTo(String messageId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'messageId',
        value: [messageId],
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterWhereClause>
      messageIdNotEqualTo(String messageId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'messageId',
              lower: [],
              upper: [messageId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'messageId',
              lower: [messageId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'messageId',
              lower: [messageId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'messageId',
              lower: [],
              upper: [messageId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MessageRecordQueryFilter
    on QueryBuilder<MessageRecord, MessageRecord, QFilterCondition> {
  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      campaignIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      campaignIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      campaignIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      campaignIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'campaignId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      campaignIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      campaignIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      campaignIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      campaignIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'campaignId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      campaignIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'campaignId',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      campaignIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'campaignId',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
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

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      messageIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'messageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      messageIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'messageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      messageIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'messageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      messageIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'messageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      messageIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'messageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      messageIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'messageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      messageIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'messageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      messageIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'messageId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      messageIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'messageId',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      messageIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'messageId',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition> roleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      roleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      roleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition> roleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'role',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      roleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      roleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      roleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'role',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition> roleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'role',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      roleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'role',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      roleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'role',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      sortOrderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      sortOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      sortOrderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      sortOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sortOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition> textEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      textGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      textLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition> textBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'text',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      textStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      textEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      textContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'text',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition> textMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'text',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      textIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'text',
        value: '',
      ));
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterFilterCondition>
      textIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'text',
        value: '',
      ));
    });
  }
}

extension MessageRecordQueryObject
    on QueryBuilder<MessageRecord, MessageRecord, QFilterCondition> {}

extension MessageRecordQueryLinks
    on QueryBuilder<MessageRecord, MessageRecord, QFilterCondition> {}

extension MessageRecordQuerySortBy
    on QueryBuilder<MessageRecord, MessageRecord, QSortBy> {
  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy> sortByCampaignId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignId', Sort.asc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy>
      sortByCampaignIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignId', Sort.desc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy> sortByMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.asc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy>
      sortByMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.desc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy> sortByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.asc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy> sortByRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.desc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy> sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy>
      sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy> sortByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy> sortByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }
}

extension MessageRecordQuerySortThenBy
    on QueryBuilder<MessageRecord, MessageRecord, QSortThenBy> {
  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy> thenByCampaignId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignId', Sort.asc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy>
      thenByCampaignIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignId', Sort.desc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy> thenByMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.asc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy>
      thenByMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageId', Sort.desc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy> thenByRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.asc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy> thenByRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'role', Sort.desc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy> thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy>
      thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy> thenByText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.asc);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QAfterSortBy> thenByTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'text', Sort.desc);
    });
  }
}

extension MessageRecordQueryWhereDistinct
    on QueryBuilder<MessageRecord, MessageRecord, QDistinct> {
  QueryBuilder<MessageRecord, MessageRecord, QDistinct> distinctByCampaignId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'campaignId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QDistinct> distinctByMessageId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'messageId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QDistinct> distinctByRole(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'role', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QDistinct> distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<MessageRecord, MessageRecord, QDistinct> distinctByText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'text', caseSensitive: caseSensitive);
    });
  }
}

extension MessageRecordQueryProperty
    on QueryBuilder<MessageRecord, MessageRecord, QQueryProperty> {
  QueryBuilder<MessageRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MessageRecord, String, QQueryOperations> campaignIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'campaignId');
    });
  }

  QueryBuilder<MessageRecord, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MessageRecord, String, QQueryOperations> messageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'messageId');
    });
  }

  QueryBuilder<MessageRecord, String, QQueryOperations> roleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'role');
    });
  }

  QueryBuilder<MessageRecord, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<MessageRecord, String, QQueryOperations> textProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'text');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInventoryItemRecordCollection on Isar {
  IsarCollection<InventoryItemRecord> get inventoryItemRecords =>
      this.collection();
}

const InventoryItemRecordSchema = CollectionSchema(
  name: r'InventoryItemRecord',
  id: -9061103845483089054,
  properties: {
    r'campaignId': PropertySchema(
      id: 0,
      name: r'campaignId',
      type: IsarType.string,
    ),
    r'itemId': PropertySchema(
      id: 1,
      name: r'itemId',
      type: IsarType.string,
    ),
    r'quantity': PropertySchema(
      id: 2,
      name: r'quantity',
      type: IsarType.long,
    ),
    r'sortOrder': PropertySchema(
      id: 3,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'title': PropertySchema(
      id: 4,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _inventoryItemRecordEstimateSize,
  serialize: _inventoryItemRecordSerialize,
  deserialize: _inventoryItemRecordDeserialize,
  deserializeProp: _inventoryItemRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'campaignId': IndexSchema(
      id: 2069977803028940998,
      name: r'campaignId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'campaignId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'itemId': IndexSchema(
      id: -5342806140158601489,
      name: r'itemId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'itemId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _inventoryItemRecordGetId,
  getLinks: _inventoryItemRecordGetLinks,
  attach: _inventoryItemRecordAttach,
  version: '3.1.0+1',
);

int _inventoryItemRecordEstimateSize(
  InventoryItemRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.campaignId.length * 3;
  bytesCount += 3 + object.itemId.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _inventoryItemRecordSerialize(
  InventoryItemRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.campaignId);
  writer.writeString(offsets[1], object.itemId);
  writer.writeLong(offsets[2], object.quantity);
  writer.writeLong(offsets[3], object.sortOrder);
  writer.writeString(offsets[4], object.title);
}

InventoryItemRecord _inventoryItemRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InventoryItemRecord();
  object.campaignId = reader.readString(offsets[0]);
  object.id = id;
  object.itemId = reader.readString(offsets[1]);
  object.quantity = reader.readLong(offsets[2]);
  object.sortOrder = reader.readLong(offsets[3]);
  object.title = reader.readString(offsets[4]);
  return object;
}

P _inventoryItemRecordDeserializeProp<P>(
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
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _inventoryItemRecordGetId(InventoryItemRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _inventoryItemRecordGetLinks(
    InventoryItemRecord object) {
  return [];
}

void _inventoryItemRecordAttach(
    IsarCollection<dynamic> col, Id id, InventoryItemRecord object) {
  object.id = id;
}

extension InventoryItemRecordByIndex on IsarCollection<InventoryItemRecord> {
  Future<InventoryItemRecord?> getByItemId(String itemId) {
    return getByIndex(r'itemId', [itemId]);
  }

  InventoryItemRecord? getByItemIdSync(String itemId) {
    return getByIndexSync(r'itemId', [itemId]);
  }

  Future<bool> deleteByItemId(String itemId) {
    return deleteByIndex(r'itemId', [itemId]);
  }

  bool deleteByItemIdSync(String itemId) {
    return deleteByIndexSync(r'itemId', [itemId]);
  }

  Future<List<InventoryItemRecord?>> getAllByItemId(List<String> itemIdValues) {
    final values = itemIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'itemId', values);
  }

  List<InventoryItemRecord?> getAllByItemIdSync(List<String> itemIdValues) {
    final values = itemIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'itemId', values);
  }

  Future<int> deleteAllByItemId(List<String> itemIdValues) {
    final values = itemIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'itemId', values);
  }

  int deleteAllByItemIdSync(List<String> itemIdValues) {
    final values = itemIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'itemId', values);
  }

  Future<Id> putByItemId(InventoryItemRecord object) {
    return putByIndex(r'itemId', object);
  }

  Id putByItemIdSync(InventoryItemRecord object, {bool saveLinks = true}) {
    return putByIndexSync(r'itemId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByItemId(List<InventoryItemRecord> objects) {
    return putAllByIndex(r'itemId', objects);
  }

  List<Id> putAllByItemIdSync(List<InventoryItemRecord> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'itemId', objects, saveLinks: saveLinks);
  }
}

extension InventoryItemRecordQueryWhereSort
    on QueryBuilder<InventoryItemRecord, InventoryItemRecord, QWhere> {
  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension InventoryItemRecordQueryWhere
    on QueryBuilder<InventoryItemRecord, InventoryItemRecord, QWhereClause> {
  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterWhereClause>
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

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterWhereClause>
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

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterWhereClause>
      campaignIdEqualTo(String campaignId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'campaignId',
        value: [campaignId],
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterWhereClause>
      campaignIdNotEqualTo(String campaignId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'campaignId',
              lower: [],
              upper: [campaignId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'campaignId',
              lower: [campaignId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'campaignId',
              lower: [campaignId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'campaignId',
              lower: [],
              upper: [campaignId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterWhereClause>
      itemIdEqualTo(String itemId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'itemId',
        value: [itemId],
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterWhereClause>
      itemIdNotEqualTo(String itemId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [],
              upper: [itemId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [itemId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [itemId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [],
              upper: [itemId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension InventoryItemRecordQueryFilter on QueryBuilder<InventoryItemRecord,
    InventoryItemRecord, QFilterCondition> {
  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      campaignIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      campaignIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      campaignIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      campaignIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'campaignId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      campaignIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      campaignIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      campaignIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      campaignIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'campaignId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      campaignIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'campaignId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      campaignIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'campaignId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
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

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
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

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
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

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      itemIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      itemIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      itemIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      itemIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      itemIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      itemIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      itemIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'itemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      itemIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'itemId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      itemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      itemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'itemId',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      quantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      quantityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      quantityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      quantityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      sortOrderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      sortOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      sortOrderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      sortOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sortOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension InventoryItemRecordQueryObject on QueryBuilder<InventoryItemRecord,
    InventoryItemRecord, QFilterCondition> {}

extension InventoryItemRecordQueryLinks on QueryBuilder<InventoryItemRecord,
    InventoryItemRecord, QFilterCondition> {}

extension InventoryItemRecordQuerySortBy
    on QueryBuilder<InventoryItemRecord, InventoryItemRecord, QSortBy> {
  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      sortByCampaignId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignId', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      sortByCampaignIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignId', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      sortByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      sortByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension InventoryItemRecordQuerySortThenBy
    on QueryBuilder<InventoryItemRecord, InventoryItemRecord, QSortThenBy> {
  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      thenByCampaignId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignId', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      thenByCampaignIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignId', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      thenByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      thenByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension InventoryItemRecordQueryWhereDistinct
    on QueryBuilder<InventoryItemRecord, InventoryItemRecord, QDistinct> {
  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QDistinct>
      distinctByCampaignId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'campaignId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QDistinct>
      distinctByItemId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QDistinct>
      distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QDistinct>
      distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<InventoryItemRecord, InventoryItemRecord, QDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension InventoryItemRecordQueryProperty
    on QueryBuilder<InventoryItemRecord, InventoryItemRecord, QQueryProperty> {
  QueryBuilder<InventoryItemRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InventoryItemRecord, String, QQueryOperations>
      campaignIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'campaignId');
    });
  }

  QueryBuilder<InventoryItemRecord, String, QQueryOperations> itemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemId');
    });
  }

  QueryBuilder<InventoryItemRecord, int, QQueryOperations> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<InventoryItemRecord, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<InventoryItemRecord, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCompanionRecordCollection on Isar {
  IsarCollection<CompanionRecord> get companionRecords => this.collection();
}

const CompanionRecordSchema = CollectionSchema(
  name: r'CompanionRecord',
  id: -2901230640346953784,
  properties: {
    r'campaignId': PropertySchema(
      id: 0,
      name: r'campaignId',
      type: IsarType.string,
    ),
    r'companionId': PropertySchema(
      id: 1,
      name: r'companionId',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 2,
      name: r'name',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 3,
      name: r'notes',
      type: IsarType.string,
    ),
    r'sortOrder': PropertySchema(
      id: 4,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 5,
      name: r'status',
      type: IsarType.string,
    )
  },
  estimateSize: _companionRecordEstimateSize,
  serialize: _companionRecordSerialize,
  deserialize: _companionRecordDeserialize,
  deserializeProp: _companionRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'campaignId': IndexSchema(
      id: 2069977803028940998,
      name: r'campaignId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'campaignId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'companionId': IndexSchema(
      id: 7614647696974036121,
      name: r'companionId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'companionId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _companionRecordGetId,
  getLinks: _companionRecordGetLinks,
  attach: _companionRecordAttach,
  version: '3.1.0+1',
);

int _companionRecordEstimateSize(
  CompanionRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.campaignId.length * 3;
  bytesCount += 3 + object.companionId.length * 3;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  return bytesCount;
}

void _companionRecordSerialize(
  CompanionRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.campaignId);
  writer.writeString(offsets[1], object.companionId);
  writer.writeString(offsets[2], object.name);
  writer.writeString(offsets[3], object.notes);
  writer.writeLong(offsets[4], object.sortOrder);
  writer.writeString(offsets[5], object.status);
}

CompanionRecord _companionRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CompanionRecord();
  object.campaignId = reader.readString(offsets[0]);
  object.companionId = reader.readString(offsets[1]);
  object.id = id;
  object.name = reader.readString(offsets[2]);
  object.notes = reader.readStringOrNull(offsets[3]);
  object.sortOrder = reader.readLong(offsets[4]);
  object.status = reader.readString(offsets[5]);
  return object;
}

P _companionRecordDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _companionRecordGetId(CompanionRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _companionRecordGetLinks(CompanionRecord object) {
  return [];
}

void _companionRecordAttach(
    IsarCollection<dynamic> col, Id id, CompanionRecord object) {
  object.id = id;
}

extension CompanionRecordByIndex on IsarCollection<CompanionRecord> {
  Future<CompanionRecord?> getByCompanionId(String companionId) {
    return getByIndex(r'companionId', [companionId]);
  }

  CompanionRecord? getByCompanionIdSync(String companionId) {
    return getByIndexSync(r'companionId', [companionId]);
  }

  Future<bool> deleteByCompanionId(String companionId) {
    return deleteByIndex(r'companionId', [companionId]);
  }

  bool deleteByCompanionIdSync(String companionId) {
    return deleteByIndexSync(r'companionId', [companionId]);
  }

  Future<List<CompanionRecord?>> getAllByCompanionId(
      List<String> companionIdValues) {
    final values = companionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'companionId', values);
  }

  List<CompanionRecord?> getAllByCompanionIdSync(
      List<String> companionIdValues) {
    final values = companionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'companionId', values);
  }

  Future<int> deleteAllByCompanionId(List<String> companionIdValues) {
    final values = companionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'companionId', values);
  }

  int deleteAllByCompanionIdSync(List<String> companionIdValues) {
    final values = companionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'companionId', values);
  }

  Future<Id> putByCompanionId(CompanionRecord object) {
    return putByIndex(r'companionId', object);
  }

  Id putByCompanionIdSync(CompanionRecord object, {bool saveLinks = true}) {
    return putByIndexSync(r'companionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCompanionId(List<CompanionRecord> objects) {
    return putAllByIndex(r'companionId', objects);
  }

  List<Id> putAllByCompanionIdSync(List<CompanionRecord> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'companionId', objects, saveLinks: saveLinks);
  }
}

extension CompanionRecordQueryWhereSort
    on QueryBuilder<CompanionRecord, CompanionRecord, QWhere> {
  QueryBuilder<CompanionRecord, CompanionRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CompanionRecordQueryWhere
    on QueryBuilder<CompanionRecord, CompanionRecord, QWhereClause> {
  QueryBuilder<CompanionRecord, CompanionRecord, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterWhereClause>
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

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterWhereClause> idBetween(
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

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterWhereClause>
      campaignIdEqualTo(String campaignId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'campaignId',
        value: [campaignId],
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterWhereClause>
      campaignIdNotEqualTo(String campaignId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'campaignId',
              lower: [],
              upper: [campaignId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'campaignId',
              lower: [campaignId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'campaignId',
              lower: [campaignId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'campaignId',
              lower: [],
              upper: [campaignId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterWhereClause>
      companionIdEqualTo(String companionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'companionId',
        value: [companionId],
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterWhereClause>
      companionIdNotEqualTo(String companionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'companionId',
              lower: [],
              upper: [companionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'companionId',
              lower: [companionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'companionId',
              lower: [companionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'companionId',
              lower: [],
              upper: [companionId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CompanionRecordQueryFilter
    on QueryBuilder<CompanionRecord, CompanionRecord, QFilterCondition> {
  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      campaignIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      campaignIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      campaignIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      campaignIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'campaignId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      campaignIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      campaignIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      campaignIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'campaignId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      campaignIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'campaignId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      campaignIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'campaignId',
        value: '',
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      campaignIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'campaignId',
        value: '',
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      companionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'companionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      companionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'companionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      companionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'companionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      companionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'companionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      companionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'companionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      companionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'companionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      companionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'companionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      companionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'companionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      companionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'companionId',
        value: '',
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      companionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'companionId',
        value: '',
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
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

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
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

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
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

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      sortOrderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      sortOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      sortOrderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      sortOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sortOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }
}

extension CompanionRecordQueryObject
    on QueryBuilder<CompanionRecord, CompanionRecord, QFilterCondition> {}

extension CompanionRecordQueryLinks
    on QueryBuilder<CompanionRecord, CompanionRecord, QFilterCondition> {}

extension CompanionRecordQuerySortBy
    on QueryBuilder<CompanionRecord, CompanionRecord, QSortBy> {
  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy>
      sortByCampaignId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignId', Sort.asc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy>
      sortByCampaignIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignId', Sort.desc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy>
      sortByCompanionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companionId', Sort.asc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy>
      sortByCompanionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companionId', Sort.desc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy>
      sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy>
      sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension CompanionRecordQuerySortThenBy
    on QueryBuilder<CompanionRecord, CompanionRecord, QSortThenBy> {
  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy>
      thenByCampaignId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignId', Sort.asc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy>
      thenByCampaignIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campaignId', Sort.desc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy>
      thenByCompanionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companionId', Sort.asc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy>
      thenByCompanionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companionId', Sort.desc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy>
      thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy>
      thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension CompanionRecordQueryWhereDistinct
    on QueryBuilder<CompanionRecord, CompanionRecord, QDistinct> {
  QueryBuilder<CompanionRecord, CompanionRecord, QDistinct>
      distinctByCampaignId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'campaignId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QDistinct>
      distinctByCompanionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'companionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QDistinct>
      distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<CompanionRecord, CompanionRecord, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }
}

extension CompanionRecordQueryProperty
    on QueryBuilder<CompanionRecord, CompanionRecord, QQueryProperty> {
  QueryBuilder<CompanionRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CompanionRecord, String, QQueryOperations> campaignIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'campaignId');
    });
  }

  QueryBuilder<CompanionRecord, String, QQueryOperations>
      companionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'companionId');
    });
  }

  QueryBuilder<CompanionRecord, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<CompanionRecord, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<CompanionRecord, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<CompanionRecord, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}

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
