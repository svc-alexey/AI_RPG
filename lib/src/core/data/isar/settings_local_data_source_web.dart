import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';

class SettingsLocalDataSource {
  const SettingsLocalDataSource();

  Never _unsupported() =>
      throw UnsupportedError('SettingsLocalDataSource is not used on web.');

  Future<ProviderScopedSettings?> loadProviderScopedSettings(
    final Object isar,
  ) async => _unsupported();

  Future<void> saveProviderScopedSettings(
    final Object isar,
    final ProviderScopedSettings settings,
  ) async => _unsupported();

  Future<void> saveProviderScopedSettingsInTxn(
    final Object isar,
    final ProviderScopedSettings settings,
  ) async => _unsupported();

  Future<AppLanguage?> loadAppLanguage(final Object isar) async =>
      _unsupported();

  Future<void> saveAppLanguage(
    final Object isar,
    final AppLanguage language,
  ) async => _unsupported();

  Future<void> saveAppLanguageInTxn(
    final Object isar,
    final AppLanguage language,
  ) async => _unsupported();
}
