class SymmetryRuntimeEnv {
  const SymmetryRuntimeEnv._();

  static const String defaultBaseUrl = String.fromEnvironment(
    'AI_PRG_SYMMETRY_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080/v1',
  );
}
