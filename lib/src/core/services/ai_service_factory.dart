import 'package:ai_prg/src/core/models/ai_settings.dart';
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
    required final CampaignState state,
    required final String playerAction,
    required final bool suggestionsOnly,
  }) async {
    final String action = playerAction.trim().isEmpty
        ? 'замереть и осмотреться'
        : playerAction.trim();
    final String narration = suggestionsOnly
        ? 'Мир на миг замирает. Можно рискнуть, сыграть осторожно или сначала внимательно изучить обстановку.'
        : 'Без настроенной модели игра работает в демо-режиме. ${state.character.name} решает: $action. Сцена меняется ровно настолько, чтобы история продолжала двигаться вперед.';

    return TurnResult(
      narration: narration,
      choices: const <String>[
        'Осмотреться внимательнее',
        'Сделать решительный шаг к цели',
        'Открыть настройки и подключить LM Studio',
      ],
      stateChanges: suggestionsOnly
          ? const StateChanges.empty()
          : const StateChanges(
              hpDelta: 0,
              energyDelta: -1,
              inventoryAdd: <String>[],
              inventoryRemove: <String>[],
              questNote: 'Ход записан в демо-режиме.',
            ),
      memoryEntry: 'Использован демо-ответ для действия: $action',
    );
  }
}
