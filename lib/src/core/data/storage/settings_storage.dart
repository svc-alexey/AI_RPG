import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';

abstract class SettingsStorage {
  Future<AiSettings> loadAiSettings();

  /// Persisted values only (no compile-time env merge). Used for settings UI.
  Future<AiSettings> loadAiSettingsPersisted();

  Future<void> saveAiSettings(AiSettings settings);

  Future<AppLanguage> loadAppLanguage();

  Future<void> saveAppLanguage(AppLanguage language);
}
