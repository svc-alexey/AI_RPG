import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
import 'package:ai_prg/src/core/services/openai_compatible_ai_client.dart';

class AiServiceFactory {
  const AiServiceFactory();

  AiClient create(final AiSettings settings) {
    if (!settings.isConfigured) {
      return const _DemoAiClient();
    }
    return const OpenAiCompatibleAiClient();
  }
}

class _DemoAiClient implements AiClient {
  const _DemoAiClient();

  @override
  Future<void> checkConnection({required final AiSettings settings}) async {
    return;
  }

  @override
  Future<TurnResult> generateTurn({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final bool suggestionsOnly,
    final CancelToken? cancelToken,
  }) async {
    final String action = playerAction.trim().isEmpty
        ? switch (language) {
            AppLanguage.ru => 'замереть и осмотреться',
            AppLanguage.en => 'pause and look around',
          }
        : playerAction.trim();
    final String narration = suggestionsOnly
        ? switch (language) {
            AppLanguage.ru =>
              'Мир на миг замирает. Можно рискнуть, сыграть осторожно или сначала внимательно изучить обстановку.',
            AppLanguage.en =>
              'The world pauses for a moment. You can take a risk, proceed carefully, or study the situation first.',
          }
        : switch (language) {
            AppLanguage.ru =>
              'Без настроенной модели игра работает в демо-режиме. ${state.character.name} решает: $action. Сцена меняется ровно настолько, чтобы история продолжала двигаться вперед.',
            AppLanguage.en =>
              'Without a configured model, the game runs in demo mode. ${state.character.name} decides to: $action. The scene changes just enough to keep the story moving forward.',
          };

    return TurnResult(
      narration: narration,
      choices: switch (language) {
        AppLanguage.ru => const <String>[
            'Осмотреться внимательнее',
            'Сделать решительный шаг к цели',
            'Открыть настройки и подключить LM Studio',
          ],
        AppLanguage.en => const <String>[
            'Look around more carefully',
            'Take a decisive step toward the goal',
            'Open settings and connect LM Studio',
          ],
      },
      stateChanges: suggestionsOnly
          ? const StateChanges.empty()
          : StateChanges(
              hpDelta: 0,
              energyDelta: -1,
              inventoryAdd: const <String>[],
              inventoryRemove: const <String>[],
              questNote: switch (language) {
                AppLanguage.ru => 'Ход записан в демо-режиме.',
                AppLanguage.en => 'The turn was recorded in demo mode.',
              },
              location: '',
            ),
      memoryEntry: switch (language) {
        AppLanguage.ru => 'Использован демо-ответ для действия: $action',
        AppLanguage.en => 'A demo answer was used for action: $action',
      },
    );
  }

  @override
  Future<GeneratedPrompts> generatePromptsFromStoryWish({
    required final AiSettings settings,
    required final AppLanguage language,
    required final String storyWish,
    required final CampaignSetting setting,
    final CancelToken? cancelToken,
  }) async =>
      const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
}
