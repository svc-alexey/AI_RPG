import 'package:ai_prg/src/app/app_scope.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({required this.campaignId, super.key});

  final String campaignId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  bool _isLoading = true;
  bool _isSending = false;
  bool _didLoad = false;
  CampaignState? _campaign;
  AiSettings _settings = const AiSettings.defaults();
  String? _status;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) {
      return;
    }
    _didLoad = true;
    _load();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final CampaignState? campaign = _campaign;
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (campaign == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Кампания не найдена')),
        body: const Center(child: Text('Не удалось открыть кампанию.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(campaign.title),
        actions: <Widget>[
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Сохранить',
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Настройки ИИ',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool wide = constraints.maxWidth >= 980;
            if (wide) {
              return Row(
                children: <Widget>[
                  Expanded(flex: 5, child: _buildChatColumn(campaign)),
                  const SizedBox(width: 16),
                  SizedBox(width: 300, child: _buildSidebar(campaign)),
                ],
              );
            }

            return Column(
              children: <Widget>[
                Expanded(child: _buildChatColumn(campaign)),
                const SizedBox(height: 12),
                SizedBox(height: 220, child: _buildSidebar(campaign)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildChatColumn(final CampaignState campaign) {
    return Column(
      children: <Widget>[
        if (_status != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_status!),
            ),
          ),
        Expanded(
          child: ListView.separated(
            itemCount: campaign.messages.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ChatMessage message = campaign.messages[index];
              final bool isPlayer = message.role == ChatRole.player;
              return Align(
                alignment: isPlayer
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 720),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isPlayer
                        ? const Color(0xFF2F4A3C)
                        : const Color(0xFFF4EAD7),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isPlayer ? Colors.white : const Color(0xFF241F1A),
                      height: 1.45,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: campaign.choices.take(3).map((choice) {
            return ActionChip(
              label: Text(choice),
              onPressed: _isSending
                  ? null
                  : () {
                      _inputController.text = choice;
                    },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _inputController,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Что делает герой дальше?',
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: _isSending
                  ? null
                  : () => _runTurn(suggestionsOnly: false),
              child: _isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Отправить'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _isSending
                  ? null
                  : () => _runTurn(suggestionsOnly: true),
              child: const Text('Подсказать'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSidebar(final CampaignState campaign) {
    final CharacterStats character = campaign.character;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF6EEDC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Text(
            character.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text('Локация: ${campaign.location}'),
          Text('Цель: ${campaign.objective}'),
          Text('Ход: ${campaign.turnNumber}'),
          const SizedBox(height: 16),
          Text('Здоровье ${character.hp}/${character.maxHp}'),
          Text('Энергия ${character.energy}/${character.maxEnergy}'),
          Text(
            'Сила ${character.might} • Ум ${character.wit} • Дух ${character.spirit}',
          ),
          const SizedBox(height: 16),
          Text('Инвентарь', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final String item in campaign.inventory) Text('• $item'),
          const SizedBox(height: 16),
          Text('Журнал задач', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final String item in campaign.questLog) Text('• $item'),
          const SizedBox(height: 16),
          Text('Сводка', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(campaign.summary),
        ],
      ),
    );
  }

  Future<void> _load() async {
    final AppScope scope = AppScope.of(context);
    final CampaignState? campaign = await scope.campaignRepository.loadCampaign(
      widget.campaignId,
    );
    final AiSettings settings = await scope.settingsRepository.loadAiSettings();

    if (!mounted) {
      return;
    }

    setState(() {
      _campaign = campaign;
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    final CampaignState? campaign = _campaign;
    if (campaign == null) {
      return;
    }

    final AppScope scope = AppScope.of(context);
    await scope.campaignRepository.saveCampaign(campaign);
    if (!mounted) {
      return;
    }
    setState(() => _status = 'Кампания сохранена.');
  }

  Future<void> _runTurn({required final bool suggestionsOnly}) async {
    final CampaignState? campaign = _campaign;
    if (campaign == null) {
      return;
    }

    final String action = _inputController.text.trim();
    if (!suggestionsOnly && action.isEmpty) {
      setState(() => _status = 'Сначала введи действие героя.');
      return;
    }

    setState(() {
      _isSending = true;
      _status = null;
    });

    try {
      final AppScope scope = AppScope.of(context);
      final AiSettings settings = await scope.settingsRepository
          .loadAiSettings();
      final client = scope.aiServiceFactory.create(settings);
      final TurnResult result = await client.generateTurn(
        settings: settings,
        state: campaign,
        playerAction: action,
        suggestionsOnly: suggestionsOnly,
      );

      final CampaignState nextState = suggestionsOnly
          ? campaign.copyWith(
              choices: result.choices,
              summary: result.memoryEntry.isEmpty
                  ? campaign.summary
                  : result.memoryEntry,
              updatedAt: DateTime.now(),
            )
          : scope.gameEngine.applyTurn(
              state: campaign,
              playerAction: action,
              result: result,
            );

      await scope.campaignRepository.saveCampaign(nextState);

      if (!mounted) {
        return;
      }

      setState(() {
        _campaign = nextState;
        _settings = settings;
        _isSending = false;
        _status = suggestionsOnly
            ? 'Варианты действий обновлены.'
            : 'Ход завершен ${_settings.isConfigured ? 'через ИИ' : 'в демо-режиме'}.';
        if (!suggestionsOnly) {
          _inputController.clear();
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSending = false;
        _status = 'Ошибка хода: $error';
      });
    }
  }
}
