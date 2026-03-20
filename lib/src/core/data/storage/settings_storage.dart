import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';

abstract class SettingsStorage {
  Future<ProviderScopedSettings> loadProviderScopedSettings();

  Future<void> saveProviderScopedSettings(ProviderScopedSettings settings);

  Future<AppLanguage> loadAppLanguage();

  Future<void> saveAppLanguage(AppLanguage language);
}
