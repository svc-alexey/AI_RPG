import 'package:ai_prg/src/core/data/isar/isar_collections.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:isar/isar.dart';

class SettingsLocalDataSource {
  const SettingsLocalDataSource();

  static const String _appLanguageKey = 'settings.app_language';
  static const String _modelControlKey = 'model_control';
  static const String _profileKey = 'openAiCompatible';

  Future<AiSettings?> loadAiSettings(final Isar isar) async {
    final ModelControlRecord? control = await isar.modelControlRecords
        .filter()
        .keyEqualTo(_modelControlKey)
        .findFirst();
    final ProviderProfileRecord? profile = await isar.providerProfileRecords
        .filter()
        .providerKeyEqualTo(_profileKey)
        .findFirst();

    if (control == null || profile == null) {
      return null;
    }

    return AiSettings(
      baseUrl: profile.baseUrl,
      model: profile.model,
      apiKey: profile.apiKey,
      timeoutSeconds: profile.timeoutSeconds,
      runtimeSettings: ModelRuntimeSettings(
        maxResponseTokens: profile.maxResponseTokens,
        contextWindowSize: profile.contextWindowSize,
        profile: ModelRuntimeProfile.values.firstWhere(
          (final item) => item.name == profile.runtimeProfile,
          orElse: () => ModelRuntimeSettings.defaults.profile,
        ),
      ),
      confirmed18Plus: control.confirmed18Plus,
    );
  }

  Future<void> saveAiSettings(final Isar isar, final AiSettings settings) async {
    await isar.writeTxn(() async {
      await saveAiSettingsInTxn(isar, settings);
    });
  }

  Future<void> saveAiSettingsInTxn(
    final Isar isar,
    final AiSettings settings,
  ) async {
    await isar.modelControlRecords.put(
      ModelControlRecord()
        ..key = _modelControlKey
        ..activeProvider = AiProviderType.openAiCompatible.name
        ..fastResponses = false
        ..confirmed18Plus = settings.confirmed18Plus
        ..updatedAt = DateTime.now(),
    );

    await isar.providerProfileRecords.put(
      ProviderProfileRecord()
        ..providerKey = _profileKey
        ..baseUrl = settings.baseUrl
        ..model = settings.model
        ..apiKey = settings.apiKey
        ..timeoutSeconds = settings.timeoutSeconds
        ..maxResponseTokens = settings.runtimeSettings.maxResponseTokens
        ..contextWindowSize = settings.runtimeSettings.contextWindowSize
        ..runtimeProfile = settings.runtimeSettings.profile.name
        ..updatedAt = DateTime.now(),
    );
  }

  Future<AppLanguage?> loadAppLanguage(final Isar isar) async {
    final AppSettingRecord? record = await isar.appSettingRecords
        .filter()
        .keyEqualTo(_appLanguageKey)
        .findFirst();
    final String raw = record?.stringValue ?? '';
    if (raw.isEmpty) {
      return null;
    }
    return AppLanguage.values.firstWhere(
      (final item) => item.code == raw,
      orElse: () => AppLanguage.ru,
    );
  }

  Future<void> saveAppLanguage(
    final Isar isar,
    final AppLanguage language,
  ) async {
    await isar.writeTxn(() async {
      await saveAppLanguageInTxn(isar, language);
    });
  }

  Future<void> saveAppLanguageInTxn(
    final Isar isar,
    final AppLanguage language,
  ) async {
    await isar.appSettingRecords.put(
      AppSettingRecord()
        ..key = _appLanguageKey
        ..stringValue = language.code
        ..updatedAt = DateTime.now(),
    );
  }
}
