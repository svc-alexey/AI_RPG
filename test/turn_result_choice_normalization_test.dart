import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TurnResult normalizes object choices into button labels', () {
    final TurnResult result = TurnResult.fromJson(<String, Object?>{
      'narration': 'Мир ненадолго замирает в тишине.',
      'choices': <Object?>[
        <String, Object?>{'label': 'Войти', 'next': 'inside'},
        <String, Object?>{'title': 'Осмотреться'},
        'Отступить',
      ],
      'state_changes': <String, Object?>{},
      'memory_entry': 'test',
    });

    expect(result.choices, <String>['Войти', 'Осмотреться', 'Отступить']);
  });

  test('TurnResult accepts alternate narration fields', () {
    final TurnResult result = TurnResult.fromJson(<String, Object?>{
      'scene': 'Туман стелется по дороге к старому лагерю.',
      'options': <Object?>['Исследовать лагерь', 'Осмотреть окрестности'],
      'state_changes': <String, Object?>{},
      'memory_entry': 'scene-test',
    });

    expect(result.narration, 'Туман стелется по дороге к старому лагерю.');
    expect(result.choices, <String>[
      'Исследовать лагерь',
      'Осмотреть окрестности',
    ]);
  });
  test('TurnResult resolves alternate location containers', () {
    final TurnResult result = TurnResult.fromJson(<String, Object?>{
      'narration': 'Cold air rolls down the corridor.',
      'choices': <Object?>['Step forward'],
      'state': <String, Object?>{'current_location': 'Observation deck'},
      'memory_entry': <String, Object?>{'text': 'The deck is silent.'},
    });

    expect(result.stateChanges.location, 'Observation deck');
    expect(result.memoryEntry, 'The deck is silent.');
  });

  test('TurnResult resolves top-level location and variants alias', () {
    final TurnResult result = TurnResult.fromJson(<String, Object?>{
      'response': 'The chapel doors stand open.',
      'variants': <Object?>[
        <String, Object?>{'name': 'Enter the chapel'},
        <String, Object?>{'text': 'Circle the ruins'},
      ],
      'location': 'Moon chapel',
    });

    expect(result.stateChanges.location, 'Moon chapel');
    expect(result.choices, <String>['Enter the chapel', 'Circle the ruins']);
  });
}
