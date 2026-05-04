import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';

class AiUserMessages {
  const AiUserMessages();

  String providerLabel(
    AiSettings settings,
    AppLanguage language,
  ) => 'AI endpoint';

  String friendlyAiEndpointError({
    required AiSettings settings,
    required AppLanguage language,
    required int statusCode,
    required String? detail,
  }) {
    final String provider = providerLabel(settings, language);
    final String suffix = switch (language) {
      AppLanguage.ru =>
        'Состояние кампании не изменено.',
      AppLanguage.en => 'The campaign state was not changed.',
    };
    final String detailText = detail == null || detail.isEmpty
        ? ''
        : ' $detail';

    return switch (language) {
      AppLanguage.ru =>
        '$provider вернул ошибку $statusCode.$detailText $suffix',
      AppLanguage.en =>
        '$provider returned error $statusCode.$detailText $suffix',
    };
  }

  String timeoutError({
    required AiSettings settings,
    required AppLanguage language,
  }) {
    final String provider = providerLabel(settings, language);
    final int seconds = settings.timeoutSeconds;

    return switch (language) {
      AppLanguage.ru =>
        '$provider не ответил за $seconds сек. Попробуйте увеличить таймаут в настройках.',
      AppLanguage.en =>
        '$provider did not respond within $seconds seconds. Try increasing the timeout in settings.',
    };
  }

  String providerUnexpectedFormat(AppLanguage language) => switch (language) {
    AppLanguage.ru =>
      'Провайдер вернул неожиданный формат ответа.\n\n'
          'Попробуйте снова. Если проблема повторяется, проверьте настройки ИИ.',
    AppLanguage.en =>
      'The provider returned an unexpected response format.\n\n'
          'Try again. If the problem persists, check AI settings.',
  };

  String providerNoChoices(AppLanguage language) => switch (language) {
    AppLanguage.ru =>
      'Провайдер не вернул ни одного варианта ответа.\n\n'
          'Попробуйте снова или проверьте подключение к AI.',
    AppLanguage.en =>
      'The provider returned no answer choices.\n\n'
          'Try again or check your AI connection.',
  };

  String invalidJson(AppLanguage language) => switch (language) {
    AppLanguage.ru =>
      'Модель вернула невалидный JSON.\n\n'
          'Обычно это временная проблема. Попробуйте снова.',
    AppLanguage.en =>
      'The model returned invalid JSON.\n\n'
          'This is usually temporary. Try again.',
  };

  String modelDidNotReturnJson(AppLanguage language) => switch (language) {
    AppLanguage.ru =>
      'Модель не вернула JSON в ожидаемом формате.\n\n'
          'Попробуйте снова. Если проблема не исчезает, возможно модель не поддерживает structured output.',
    AppLanguage.en =>
      'The model did not return JSON in the expected format.\n\n'
          'Try again. If the problem persists, the model may not support structured output.',
  };
}
