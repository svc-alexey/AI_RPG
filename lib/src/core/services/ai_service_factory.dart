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

    const List<Choice> defaultChoicesRu = <Choice>[
      Choice(id: 'look-closer', label: 'Осмотреться внимательнее'),
      Choice(id: 'decisive-step', label: 'Сделать решительный шаг к цели'),
      Choice(id: 'open-settings', label: 'Открыть настройки и настроить endpoint'),
    ];
    const List<Choice> defaultChoicesEn = <Choice>[
      Choice(id: 'look-closer', label: 'Look around more carefully'),
      Choice(id: 'decisive-step', label: 'Take a decisive step toward the goal'),
      Choice(id: 'open-settings', label: 'Open settings and configure endpoint'),
    ];

    final TurnResult result = TurnResult(
      narration: narration,
      choices: switch (language) {
        AppLanguage.ru => defaultChoicesRu,
        AppLanguage.en => defaultChoicesEn,
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
  Future<GeneratedPrompts> generateCampaignPrompts({
    required final AiSettings settings,
    required final AppLanguage language,
    required final CampaignPromptGenerationRequest request,
    final CancelToken? cancelToken,
  }) async => const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
}
