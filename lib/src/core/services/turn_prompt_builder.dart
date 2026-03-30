import 'dart:convert';

import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/campaign_memory_manager.dart';
import 'package:ai_prg/src/core/services/deterministic_check_service.dart';

class TurnPromptBuilder {
  const TurnPromptBuilder();

  static const CampaignMemoryManager _memoryManager = CampaignMemoryManager();

  String buildSystemPrompt({
    required final AppLanguage language,
    required final CampaignState state,
    required final bool suggestionsOnly,
    required final DeterministicTurnContext deterministicContext,
    required final bool fastMode,
    required final bool confirmed18Plus,
  }) {
    final String fastPrefix = fastMode ? '/no_think\n' : '';
    final String contentRule = confirmed18Plus
        ? ''
        : switch (language) {
            AppLanguage.ru =>
              '\nВажно: избегай сексуального и откровенного контента. Повествование должно быть подходящим для общей аудитории.\n',
            AppLanguage.en =>
              '\nImportant: avoid sexual or explicit adult content. Keep narration suitable for general audiences.\n',
          };
    final String deterministicRule =
        !suggestionsOnly && deterministicContext.hasResolvedCheck
        ? switch (language) {
            AppLanguage.ru =>
              '\nВ контексте может прийти deterministic_resolution. Это уже разрешённый на клиенте исход проверки. Не перебрасывай кубик, не меняй и не оспаривай этот результат.\n',
            AppLanguage.en =>
              '\nIf deterministic_resolution appears in the campaign context, it was already resolved on the client. Do not reroll it, change it, or contradict it.\n',
          }
        : '';

    String base = '';
    if (suggestionsOnly) {
      base = switch (language) {
        AppLanguage.ru =>
          '''
$fastPrefixТы повествовательный ИИ для детерминированной RPG.
Отвечай только JSON с ключами: narration, choices, state_changes, memory_entry.
Все тексты, narration, choices и memory_entry пиши только на русском языке.
Для режима подсказок:
- narration должен быть коротким продолжением сцены
- choices: не более 3 вариантов, каждый 2-3 слова (например: «Бежать», «Атаковать», «Договориться»)
- state_changes должен содержать нулевые изменения и пустые списки
- memory_entry должен быть кратким
Не добавляй markdown или пояснения вне JSON.
''',
        AppLanguage.en =>
          '''
${fastPrefix}You are a narrative AI for a deterministic RPG.
Reply only with JSON using the keys: narration, choices, state_changes, memory_entry.
Write all texts, narration, choices, and memory_entry only in English.
For suggestion mode:
- narration must be a short continuation of the scene
- choices: up to 3 options, each 2-3 words max (e.g. "Run away", "Attack", "Negotiate")
- state_changes must contain zero deltas and empty lists
- memory_entry must be brief
Do not add markdown or explanations outside JSON.
''',
      };
    } else {
      base = switch (language) {
        AppLanguage.ru =>
          '''
$fastPrefixТы повествовательный ИИ для детерминированной RPG.
Отвечай только JSON с ключами: narration, choices, state_changes, memory_entry.
Все тексты, narration, choices, questNote, location и memory_entry пиши только на русском языке.
Правила:
- narration: 1-2 абзаца. Включай атмосферу сцены, эмоции персонажей, короткие диалоги в потоке, сенсорные детали (звук, свет, запах) в меру.
- choices: не более 3 вариантов, каждый 2-3 слова
- state_changes: { "hpDelta": int, "energyDelta": int, "inventoryAdd": [string], "inventoryRemove": [string], "questNote": string, "location": string }
- location в state_changes: укажи текущую локацию (особенно важно в первом ходе). Если локация не меняется, оставь пустым "".
- изменения должны быть умеренными для MVP
- не ломай целостность мира
- не добавляй markdown fences
''',
        AppLanguage.en =>
          '''
${fastPrefix}You are a narrative AI for a deterministic RPG.
Reply only with JSON using the keys: narration, choices, state_changes, memory_entry.
Write all texts, narration, choices, questNote, location, and memory_entry only in English.
Rules:
- narration: 1-2 paragraphs. Include scene atmosphere, character emotions, short in-flow dialogues, sensory details (sound, light, smell) in moderation.
- choices: up to 3 options, each 2-3 words max
- state_changes: { "hpDelta": int, "energyDelta": int, "inventoryAdd": [string], "inventoryRemove": [string], "questNote": string, "location": string }
- location in state_changes: specify current location (especially important on first turn). If location doesn't change, leave empty "".
- changes must stay moderate for the MVP
- do not break world continuity
- if deterministic_resolution is present in the campaign context, it is already resolved on the client; do not reroll it or contradict it
- do not add markdown fences
''',
      };
    }

    final List<String> parts = <String>[base, contentRule, deterministicRule];
    if (state.customStoryPrompt.trim().isNotEmpty) {
      parts.add(
        '\n\n--- Story context ---\n${state.customStoryPrompt.trim()}\n',
      );
    }
    if (state.characterPrompt.trim().isNotEmpty) {
      parts.add('\n\n--- Character ---\n${state.characterPrompt.trim()}\n');
    }
    return parts.join();
  }

  String buildUserPrompt({
    required final AppLanguage language,
    required final CampaignState state,
    required final String playerAction,
    required final DeterministicTurnContext deterministicContext,
    required final bool fastMode,
    required final int contextWindowSize,
  }) {
    final Map<String, Object?> contextPayload = fastMode
        ? _memoryManager.buildFastAiContext(
            state,
            contextWindowSize: contextWindowSize,
          )
        : _memoryManager.buildAiContext(
            state,
            contextWindowSize: contextWindowSize,
          );
    if (deterministicContext.hasResolvedCheck) {
      contextPayload['deterministic_resolution'] = deterministicContext
          .toJson();
    }

    final String actionText = playerAction.trim().isEmpty
        ? switch (language) {
            AppLanguage.ru =>
              '(Начало игры. Придумай интересную стартовую локацию, завязку и цель в рамках текущего сеттинга. Начни повествование.)',
            AppLanguage.en =>
              '(Game start. Invent an interesting starting location, hook, and objective within the current setting. Begin the narration.)',
          }
        : playerAction;

    return switch (language) {
      AppLanguage.ru =>
        '''
Контекст кампании:
${jsonEncode(contextPayload)}

Действие игрока:
$actionText
''',
      AppLanguage.en =>
        '''
Campaign context:
${jsonEncode(contextPayload)}

Player action:
$actionText
''',
    };
  }
}
