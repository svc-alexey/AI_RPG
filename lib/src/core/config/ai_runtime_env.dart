/// Compile-time AI connection defaults.
///
/// **API key:** not stored in git. Copy `tool/ai_local_defines.example.json` to
/// `tool/ai_local_defines.json` (gitignored), set `AI_PRG_API_KEY`, then run via
/// `.cursor/skills/flutter-restart/scripts/restart.ps1` or
/// `tool/flutter_build_with_local_defines.ps1`, or pass manually:
/// `flutter run --dart-define-from-file=tool/ai_local_defines.json`
abstract final class AiRuntimeEnv {
  static const String defaultBaseUrl = String.fromEnvironment(
    'AI_PRG_BASE_URL',
    defaultValue: 'https://api.deepseek.com',
  );

  static const String defaultModel = String.fromEnvironment(
    'AI_PRG_MODEL',
    defaultValue: 'deepseek-chat',
  );

  static const String defaultApiKey = String.fromEnvironment('AI_PRG_API_KEY');
}
