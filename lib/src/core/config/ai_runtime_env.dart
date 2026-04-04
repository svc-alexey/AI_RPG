/// Compile-time AI connection defaults.
///
/// At runtime, `AiSettings.withEnvFallbacks` fills only empty persisted fields
/// from these values. The settings UI shows persisted URL/model/key only;
/// build-time values are not copied into the form so presets stay hidden.
///
/// **API key:** not stored in git. Copy `tool/ai_local_defines.example.json` to
/// `tool/ai_local_defines.json` (gitignored), set `AI_PRG_API_KEY`, then run via
/// `.cursor/skills/flutter-restart/scripts/restart.ps1` or
/// `tool/flutter_build_with_local_defines.ps1`, or pass manually:
/// `flutter run --dart-define-from-file=tool/ai_local_defines.json`
abstract final class AiRuntimeEnv {
  static const String defaultBaseUrl = String.fromEnvironment(
    'AI_PRG_BASE_URL',
    defaultValue: 'https://api.deepseek.com/v1',
  );

  static const String defaultModel = String.fromEnvironment(
    'AI_PRG_MODEL',
    defaultValue: 'deepseek-chat',
  );

  static const String defaultApiKey = String.fromEnvironment('AI_PRG_API_KEY');

  static bool get hasCompileTimeBaseUrl => defaultBaseUrl.trim().isNotEmpty;

  static bool get hasCompileTimeModel => defaultModel.trim().isNotEmpty;

  static bool get hasCompileTimeApiKey => defaultApiKey.trim().isNotEmpty;
}
