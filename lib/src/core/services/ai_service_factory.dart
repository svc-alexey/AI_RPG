import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
import 'package:ai_prg/src/core/services/deterministic_check_service.dart';
import 'package:ai_prg/src/core/services/openai_compatible_ai_client.dart';

class AiServiceFactory {
  const AiServiceFactory();

  AiClient create(final AiSettings settings) {
    if (!settings.isConfigured) {
      return const _DemoAiClient();
    }
    return OpenAiCompatibleAiClient();
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
    required final DeterministicTurnContext deterministicContext,
    final AiRequestMetadata? metadata,
    final NarrationDeltaCallback? onNarrationDelta,
    final CancelToken? cancelToken,
  }) async {
    final String action = playerAction.trim().isEmpty
        ? switch (language) {
            AppLanguage.ru => 'замереть и осмотреться',
            AppLanguage.en => 'pause and look around',
          }
        : playerAction.trim();
    final CampaignCheck? resolvedCheck = deterministicContext.resolvedCheck;
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
              resolvedCheck == null
                  ? 'Without a configured model, the game runs in demo mode. ${state.character.name} decides to: $action. The scene changes just enough to keep the story moving forward.'
                  : 'Without a configured model, the game runs in demo mode. ${state.character.name} attempts to: $action. ${resolvedCheck.summary}. The scene now follows that known outcome.',
          };

    final TurnResult result = TurnResult(
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
        AppLanguage.en =>
          resolvedCheck == null
              ? 'A demo answer was used for action: $action'
              : 'A demo answer was used for action: $action. ${resolvedCheck.summary}',
      },
    );
    if (!suggestionsOnly) {
      onNarrationDelta?.call(result.narration);
    }
    return result;
  }

  @override
  Future<GeneratedPrompts> generatePromptsFromStoryWish({
    required final AiSettings settings,
    required final AppLanguage language,
    required final String storyWish,
    required final CampaignSetting setting,
    final CancelToken? cancelToken,
  }) async => const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
}
