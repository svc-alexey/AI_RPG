import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/services/openai_compatible_ai_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Plain text model output is recovered into narration and choices', () {
    final OpenAiCompatibleAiClient client = OpenAiCompatibleAiClient();

    final result = client.parseTurnContentForTesting(
      rawContent: '''
Туман висит над лагерем, а вдалеке потрескивает костер.
В воздухе пахнет мокрой хвоей и золой.

Варианты:
1. Исследовать лагерь
2. Осмотреть окрестности
3. Подойти к костру
''',
      language: AppLanguage.ru,
    );

    expect(result.narration, contains('Туман висит над лагерем'));
    expect(result.choices, <String>[
      'Исследовать лагерь',
      'Осмотреть окрестности',
      'Подойти к костру',
    ]);
  });

  test('Broken JSON-like output is recovered into narration and labels', () {
    final OpenAiCompatibleAiClient client = OpenAiCompatibleAiClient();

    final result = client.parseTurnContentForTesting(
      rawContent: '''
{
  "choices": [
    {"label": "Осмотреться", "next": "look"},
    {"label": "Действовать осторожно", "next": "careful"},
    {"label": "Сделать шаг", "next": 1}
  ],
  "state_changes": {},
  "memory_entry": {
    "text": "На полу храма найдена записка с просьбой прочитать ее."
  },
  "location": "Храм исследователей"
''',
      language: AppLanguage.ru,
    );

    expect(
      result.narration,
      'На полу храма найдена записка с просьбой прочитать ее.',
    );
    expect(result.choices, <String>[
      'Осмотреться',
      'Действовать осторожно',
      'Сделать шаг',
    ]);
  });

  test('Numeric content values do not crash parsing', () {
    final OpenAiCompatibleAiClient client = OpenAiCompatibleAiClient();

    final result = client.parseTurnContentForTesting(
      rawContent: '''
1. Move forward
2. Wait
''',
      language: AppLanguage.en,
    );

    expect(result.choices, <String>['Move forward', 'Wait']);
  });

  test('Structured recovery preserves alternate location field', () {
    final OpenAiCompatibleAiClient client = OpenAiCompatibleAiClient();

    final result = client.parseTurnContentForTesting(
      rawContent: '''
{
  "scene": "The station wakes with a metallic groan.",
  "variants": [
    {"title": "Check the console"},
    {"label": "Open the hatch"}
  ],
  "game_state": {
    "current_location": "Maintenance shaft"
  }
''',
      language: AppLanguage.en,
    );

    expect(result.narration, 'The station wakes with a metallic groan.');
    expect(result.choices, <String>['Check the console', 'Open the hatch']);
    expect(result.stateChanges.location, 'Maintenance shaft');
  });
}
