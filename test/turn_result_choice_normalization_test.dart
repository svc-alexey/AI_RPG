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
}
