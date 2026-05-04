import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/campaign_memory_manager.dart';
import 'package:ai_prg/src/core/services/deterministic_check_service.dart';
import 'package:ai_prg/src/core/services/turn_prompt_builder.dart';

String campaignPromptLockedHeroBlock({
  required CharacterProfile profile,
  required AppLanguage language,
}) =>
    switch (language) {
      AppLanguage.ru =>
        '''

Зафиксированный герой (соблюдай пол и черты в storyPrompt и characterPrompt): имя «${profile.name}», пол ${profile.gender.name}, раса ${profile.race}, класс ${profile.characterClass.name}. Личность: ${profile.personality}. Доп. детали: ${profile.promptFragment}.''',
      AppLanguage.en =>
        '''

Locked protagonist (keep gender and traits consistent in storyPrompt and characterPrompt): name "${profile.name}", gender ${profile.gender.name}, race ${profile.race}, class ${profile.characterClass.name}. Personality: ${profile.personality}. Details: ${profile.promptFragment}.''',
    };

class AiPromptAssembler {
  const AiPromptAssembler({
    required this.turnPromptBuilder,
    required this.memoryManager,
  });

  final TurnPromptBuilder turnPromptBuilder;
  final CampaignMemoryManager memoryManager;

  Map<String, Object?> buildPromptRequestBody({
    required AiSettings settings,
    required AppLanguage language,
    required String metaPrompt,
    int? maxTokensOverride,
  }) => <String, Object?>{
    'model': settings.model,
    'temperature': 0.5,
    'max_tokens': maxTokensOverride ?? settings.maxResponseTokens,
    'messages': <Map<String, String>>[
      <String, String>{
        'role': 'system',
        'content': switch (language) {
          AppLanguage.ru => 'Ты помощник. Отвечай только валидным JSON.',
          AppLanguage.en => 'You are a helper. Reply only with valid JSON.',
        },
      },
      <String, String>{'role': 'user', 'content': metaPrompt},
    ],
  };

  Map<String, Object?> buildTurnRequestBody({
    required AiSettings settings,
    required AppLanguage language,
    required CampaignState state,
    required String playerAction,
    required bool suggestionsOnly,
    required DeterministicTurnContext deterministicContext,
    required bool fastMode,
    int? maxTokensOverride,
    bool stream = false,
  }) => <String, Object?>{
    'model': settings.model,
    'temperature': fastMode ? 0.2 : 0.7,
    'max_tokens': maxTokensOverride ?? settings.maxResponseTokens,
    if (stream) 'stream': true,
    'messages': <Map<String, String>>[
      <String, String>{
        'role': 'system',
        'content': turnPromptBuilder.buildSystemPrompt(
          language: language,
          state: state,
          suggestionsOnly: suggestionsOnly,
          deterministicContext: deterministicContext,
          fastMode: fastMode,
          confirmed18Plus: settings.confirmed18Plus,
        ),
      },
      <String, String>{
        'role': 'user',
        'content': turnPromptBuilder.buildUserPrompt(
          language: language,
          state: state,
          playerAction: playerAction,
          deterministicContext: deterministicContext,
          fastMode: fastMode,
          contextWindowSize: settings.contextWindowSize,
        ),
      },
    ],
  };
}
