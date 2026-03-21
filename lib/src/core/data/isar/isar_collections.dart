import 'package:isar/isar.dart';

part 'isar_collections.g.dart';

@collection
class CampaignRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String campaignId;

  late int schemaVersion;
  late String title;
  late String setting;
  late String mode;
  late String difficulty;
  late String location;
  late String objective;
  late int turnNumber;
  late DateTime updatedAt;
  late String characterJson;
  late String memoryJson;
  late String modulesJson;
  late String inventoryJson;
  late String questLogJson;
  late String choicesJson;
  late String customStoryPrompt;
  late String characterPrompt;
  late String portraitPath;
  late String portraitPrompt;
  late String summary;
  late String activeGoal;
  late String activeSituation;
}

@collection
class WorldStateRecord {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String campaignId;

  late String characterJson;
  late String location;
  late String objective;
  late int turnNumber;
  late String questLogJson;
  late String choicesJson;
  late String summary;
  late String activeGoal;
  late String activeSituation;
  late String memoryJson;
  late String notesJson;
  late String resourcesJson;
  late String progressionJson;
  late String checksJson;
  late DateTime updatedAt;
}

@collection
class MessageRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late String campaignId;

  @Index(unique: true, replace: true)
  late String messageId;

  late String role;
  late String text;
  late DateTime createdAt;
  late int sortOrder;
}

@collection
class InventoryItemRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late String campaignId;

  @Index(unique: true, replace: true)
  late String itemId;

  late String title;
  late int quantity;
  late int sortOrder;
}

@collection
class CompanionRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late String campaignId;

  @Index(unique: true, replace: true)
  late String companionId;

  late String name;
  late String status;
  String? notes;
  late int sortOrder;
}

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
