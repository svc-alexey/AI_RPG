import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime.now();

void main() {
  test('ChatMessage.fromJson with dice_roll parses correctly', () {
    const json = <String, Object?>{
      'id': 'msg-1',
      'role': 'narrator',
      'text': 'You strike true!',
      'createdAt': '2026-05-10T12:00:00.000Z',
      'dice_roll': 17,
    };

    final message = ChatMessage.fromJson(json);

    expect(message.id, 'msg-1');
    expect(message.role, ChatRole.narrator);
    expect(message.text, 'You strike true!');
    expect(message.diceRoll, 17);
  });

  test('ChatMessage.fromJson without dice_roll — diceRoll is null', () {
    const json = <String, Object?>{
      'id': 'msg-2',
      'role': 'narrator',
      'text': 'The fog clears...',
      'createdAt': '2026-05-10T12:01:00.000Z',
    };

    final message = ChatMessage.fromJson(json);

    expect(message.diceRoll, isNull);
  });

  test('ChatMessage.fromJson with dice_roll as double parses to int', () {
    const json = <String, Object?>{
      'id': 'msg-3',
      'role': 'narrator',
      'text': 'Test',
      'createdAt': '2026-05-10T12:02:00.000Z',
      'dice_roll': 20.0,
    };

    final message = ChatMessage.fromJson(json);

    expect(message.diceRoll, 20);
  });

  test('toJson with diceRoll includes dice_roll', () {
    final message = ChatMessage(
      id: 'msg-4',
      role: ChatRole.narrator,
      text: 'Critical hit!',
      createdAt: _now,
      diceRoll: 20,
    );

    final json = message.toJson();

    expect(json['dice_roll'], 20);
  });

  test('toJson without diceRoll excludes dice_roll', () {
    final message = ChatMessage(
      id: 'msg-5',
      role: ChatRole.narrator,
      text: 'No roll needed.',
      createdAt: _now,
    );

    final json = message.toJson();

    expect(json.containsKey('dice_roll'), isFalse);
  });

  test('ChatMessage with diceRoll preserves fields', () {
    final message = ChatMessage(
      id: 'eq-1',
      role: ChatRole.narrator,
      text: 'Test',
      createdAt: _now,
      diceRoll: 12,
    );

    expect(message.diceRoll, 12);
    expect(message.text, 'Test');
    expect(message.role, ChatRole.narrator);
  });
}
