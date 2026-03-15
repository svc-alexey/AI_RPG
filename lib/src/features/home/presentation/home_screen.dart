import 'package:ai_prg/src/features/new_game/presentation/new_game_screen.dart';
import 'package:ai_prg/src/features/saves/presentation/saves_screen.dart';
import 'package:ai_prg/src/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFFF5E7CC),
              Color(0xFFE7C9A1),
              Color(0xFF2F4A3C),
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 420,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'AI RPG MVP',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: const Color(0xFF1B1B18),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Минимальный desktop-first клиент: чат, настройки провайдера, локальные сохранения и интеграция с LM Studio.',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF2E2A23),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 28),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => const NewGameScreen(),
                              ),
                            );
                          },
                          child: const Text('Новая кампания'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => const SavesScreen(),
                              ),
                            );
                          },
                          child: const Text('Сохранения'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                          child: const Text('Настройки ИИ'),
                        ),
                      ],
                    ),
                  ),
                  const _InfoCard(
                    width: 360,
                    title: 'Что уже есть',
                    lines: <String>[
                      'Локальная история кампаний',
                      'Один полный игровой ход через ИИ',
                      'Демо-режим без модели',
                      'Совместимый с OpenAI endpoint для LM Studio',
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.width,
    required this.title,
    required this.lines,
  });

  final double width;
  final String title;
  final List<String> lines;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: width,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          for (final String line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(Icons.adjust_rounded, size: 12),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(line, style: theme.textTheme.bodyLarge)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
