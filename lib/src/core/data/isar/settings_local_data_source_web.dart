import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';

class SettingsLocalDataSource {
  const SettingsLocalDataSource();

  Never _unsupported() =>
      throw UnsupportedError('SettingsLocalDataSource is not used on web.');

  Future<AiSettings?> loadAiSettings(final Object isar) async => _unsupported();

  Future<void> saveAiSettings(
    final Object isar,
    final AiSettings settings,
  ) async => _unsupported();

  Future<void> saveAiSettingsInTxn(
    final Object isar,
    final AiSettings settings,
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

  Future<String?> loadSymmetryBaseUrl(final Object isar) async =>
      _unsupported();

  Future<void> saveSymmetryBaseUrl(
    final Object isar,
    final String baseUrl,
  ) async => _unsupported();

  Future<SymmetrySession?> loadSymmetrySession(final Object isar) async =>
      _unsupported();

  Future<void> saveSymmetrySession(
    final Object isar,
    final SymmetrySession? session,
  ) async => _unsupported();
}
