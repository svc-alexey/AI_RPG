enum AppLanguage { ru, en }

extension AppLanguageX on AppLanguage {
  String get code => name;

  String get jsonLabel => switch (this) {
    AppLanguage.ru => 'русском',
    AppLanguage.en => 'English',
  };
}
