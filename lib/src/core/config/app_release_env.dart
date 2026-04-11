class AppReleaseEnv {
  const AppReleaseEnv._();

  static const String appVersion = String.fromEnvironment(
    'AI_PRG_APP_VERSION',
    defaultValue: '1.0.0+1',
  );

  static const String assetVersion = String.fromEnvironment(
    'AI_PRG_ASSET_VERSION',
    defaultValue: 'dev-local',
  );

  static const String releaseId = String.fromEnvironment(
    'AI_PRG_RELEASE_ID',
    defaultValue: 'dev-local',
  );
}
