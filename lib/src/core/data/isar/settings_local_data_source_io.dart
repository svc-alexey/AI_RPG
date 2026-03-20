import 'package:ai_prg/src/core/data/isar/isar_collections.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:isar/isar.dart';

class SettingsLocalDataSource {
  const SettingsLocalDataSource();

  static const String _appLanguageKey = 'settings.app_language';
  static const String _modelControlKey = 'model_control';

  Future<ProviderScopedSettings?> loadProviderScopedSettings(
    final Isar isar,
  ) async {
    final ModelControlRecord? control = await isar.modelControlRecords
        .filter()
        .keyEqualTo(_modelControlKey)
        .findFirst();
    final List<ProviderProfileRecord> profiles = await isar
        .providerProfileRecords
        .where()
        .findAll();

    if (control == null || profiles.isEmpty) {
      return null;
    }

    final Map<AiProviderType, ProviderProfile> mapped =
        <AiProviderType, ProviderProfile>{};
    for (final ProviderProfileRecord record in profiles) {
      final AiProviderType provider = AiProviderType.values.firstWhere(
        (final item) => item.name == record.providerKey,
        orElse: () => AiProviderType.lmStudio,
      );
      mapped[provider] = ProviderProfile(
        baseUrl: record.baseUrl,
        model: record.model,
        apiKey: record.apiKey,
        timeoutSeconds: record.timeoutSeconds,
        runtimeSettings: ModelRuntimeSettings(
          maxResponseTokens: record.maxResponseTokens,
          contextWindowSize: record.contextWindowSize,
          profile: ModelRuntimeProfile.values.firstWhere(
            (final item) => item.name == record.runtimeProfile,
            orElse: () => ModelRuntimeSettings.defaultsFor(provider).profile,
          ),
        ),
      );
    }

    return ProviderScopedSettings(
      activeProvider: AiProviderType.values.firstWhere(
        (final item) => item.name == control.activeProvider,
        orElse: () => AiProviderType.lmStudio,
      ),
      profiles: <AiProviderType, ProviderProfile>{
        for (final AiProviderType provider in AiProviderType.values)
          provider: mapped[provider] ?? ProviderProfile.defaultsFor(provider),
      },
      fastResponses: control.fastResponses,
      confirmed18Plus: control.confirmed18Plus,
    );
  }

  Future<void> saveProviderScopedSettings(
    final Isar isar,
    final ProviderScopedSettings settings,
  ) async {
    await isar.writeTxn(() async {
      await saveProviderScopedSettingsInTxn(isar, settings);
    });
  }

  Future<void> saveProviderScopedSettingsInTxn(
    final Isar isar,
    final ProviderScopedSettings settings,
  ) async {
    await isar.modelControlRecords.put(
      ModelControlRecord()
        ..key = _modelControlKey
        ..activeProvider = settings.activeProvider.name
        ..fastResponses = settings.fastResponses
        ..confirmed18Plus = settings.confirmed18Plus
        ..updatedAt = DateTime.now(),
    );

    final List<ProviderProfileRecord> records = <ProviderProfileRecord>[
      for (final AiProviderType provider in AiProviderType.values)
        ProviderProfileRecord()
          ..providerKey = provider.name
          ..baseUrl = settings.profileFor(provider).baseUrl
          ..model = settings.profileFor(provider).model
          ..apiKey = settings.profileFor(provider).apiKey
          ..timeoutSeconds = settings.profileFor(provider).timeoutSeconds
          ..maxResponseTokens = settings
              .profileFor(provider)
              .runtimeSettings
              .maxResponseTokens
          ..contextWindowSize = settings
              .profileFor(provider)
              .runtimeSettings
              .contextWindowSize
          ..runtimeProfile = settings
              .profileFor(provider)
              .runtimeSettings
              .profile
              .name
          ..updatedAt = DateTime.now(),
    ];
    await isar.providerProfileRecords.putAll(records);
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
