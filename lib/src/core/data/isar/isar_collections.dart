import 'package:isar/isar.dart';

part 'isar_collections.g.dart';

@collection
class ProviderProfileRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String providerKey;

  late String baseUrl;
  late String model;
  late String apiKey;
  late int timeoutSeconds;
  late int maxResponseTokens;
  late int contextWindowSize;
  late String runtimeProfile;
  DateTime? updatedAt;
}

@collection
class ModelControlRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String key;

  late String activeProvider;
  late bool fastResponses;
  late bool confirmed18Plus;
  DateTime? updatedAt;
}

@collection
class AppSettingRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String key;

  String? stringValue;
  String? jsonValue;
  DateTime? updatedAt;
}
