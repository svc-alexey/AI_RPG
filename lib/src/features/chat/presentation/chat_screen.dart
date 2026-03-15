import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_scope.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
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
  ChatMessage? _pendingPlayerMessage;
  ChatMessage? _pendingNarratorMessage;

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
    final AppLocalizations l10n = context.l10n;
    final CampaignState? campaign = _campaign;
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (campaign == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.campaignNotFound)),
        body: Center(child: Text(l10n.campaignOpenFailed)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(campaign.title),
        actions: <Widget>[
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            tooltip: l10n.saveTooltip,
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
            tooltip: l10n.aiSettings,
          ),
        ],
      ),
      body: AetherBackdrop(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool wide = constraints.maxWidth >= 760;
              if (wide) {
                return Row(
                  children: <Widget>[
                    SizedBox(width: 260, child: _buildSidebar(campaign)),
                    const SizedBox(width: 20),
                    Expanded(child: _buildChatColumn(campaign)),
                  ],
                );
              }

              return Column(
                children: <Widget>[
                  Expanded(child: _buildChatColumn(campaign)),
                  const SizedBox(height: 12),
                  SizedBox(height: 240, child: _buildSidebar(campaign)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChatColumn(final CampaignState campaign) {
    final AppLocalizations l10n = context.l10n;
    final List<ChatMessage> visibleMessages = _visibleMessages(campaign);
    return Column(
      children: <Widget>[
        if (_status != null)
          AetherCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _status!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        if (_status != null) const SizedBox(height: 12),
        Expanded(
          child: AetherCard(
            child: ListView.separated(
              itemCount: visibleMessages.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final ChatMessage message = visibleMessages[index];
                final bool isPlayer = message.role == ChatRole.player;
                final bool isSystem = message.role == ChatRole.system;

                return Align(
                  alignment: isPlayer
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 720),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isPlayer
                          ? AetherPalette.accentSoft.withValues(alpha: 0.42)
                          : isSystem
                          ? AetherPalette.panelSoft.withValues(alpha: 0.92)
                          : AetherPalette.panel.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (isPlayer
                                ? AetherPalette.accent
                                : AetherPalette.panelBorder)
                            .withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      message.text,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isSystem
                            ? AetherPalette.textMuted
                            : AetherPalette.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: campaign.choices.take(3).map((choice) => ActionChip(
              label: Text(choice),
              onPressed: _isSending
                  ? null
                  : () {
                      _inputController.text = choice;
                    },
            )).toList(),
        ),
        const SizedBox(height: 16),
        AetherCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _inputController,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: l10n.chatInputHint,
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
                    : Text(l10n.send),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _isSending
                    ? null
                    : () => _runTurn(suggestionsOnly: true),
                child: Text(l10n.suggest),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar(final CampaignState campaign) {
    final CharacterStats character = campaign.character;
    final AppLocalizations l10n = context.l10n;
    return AetherCard(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Text(
            character.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text('${l10n.location}: ${campaign.location}'),
          Text('${l10n.objective}: ${campaign.objective}'),
          Text('${l10n.turn}: ${campaign.turnNumber}'),
          const SizedBox(height: 16),
          Text(l10n.healthLabel(character)),
          Text(l10n.energyLabel(character)),
          Text(l10n.statsLabel(character)),
          const SizedBox(height: 16),
          Text(l10n.inventory, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final String item in campaign.inventory) Text('- $item'),
          const SizedBox(height: 16),
          Text(l10n.questLog, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final String item in campaign.questLog) Text('- $item'),
          const SizedBox(height: 16),
          Text(l10n.summary, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(campaign.summary),
          const SizedBox(height: 16),
          Text(
            l10n.activeGoalTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(campaign.activeGoal),
          const SizedBox(height: 16),
          Text(
            l10n.recentEventsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final RecentTurnSummary item in campaign.recentTurns)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('- ${item.playerAction} -> ${item.outcome}'),
            ),
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
    setState(() => _status = context.l10n.campaignSaved);
  }

  Future<void> _runTurn({required final bool suggestionsOnly}) async {
    final CampaignState? campaign = _campaign;
    if (campaign == null) {
      return;
    }

    final String action = _inputController.text.trim();
    if (!suggestionsOnly && action.isEmpty) {
      setState(() => _status = context.l10n.actionRequired);
      return;
    }

    setState(() {
      _isSending = true;
      _status = null;
      if (!suggestionsOnly) {
        final DateTime now = DateTime.now();
        _pendingPlayerMessage = ChatMessage(
          id: 'pending_player',
          role: ChatRole.player,
          text: action,
          createdAt: now,
        );
        _pendingNarratorMessage = ChatMessage(
          id: 'pending_narrator',
          role: ChatRole.narrator,
          text: '...',
          createdAt: now,
        );
      }
    });

    try {
      final AppScope scope = AppScope.of(context);
      final AppLanguage language = scope.appLanguageListenable.value;
      final AiSettings settings = await scope.settingsRepository
          .loadAiSettings();
      final AiClient client = scope.aiServiceFactory.create(settings);
      final TurnResult result = await client.generateTurn(
        settings: settings,
        language: language,
        state: campaign,
        playerAction: action,
        suggestionsOnly: suggestionsOnly,
      );

      if (!suggestionsOnly) {
        await _animatePendingNarration(result.narration);
      }

      final CampaignState nextState = suggestionsOnly
          ? campaign.copyWith(
              choices: result.choices,
              memory: campaign.memory.copyWith(
                activeSituation: result.narration,
              ),
              updatedAt: DateTime.now(),
            )
          : scope.gameEngine.applyTurn(
              language: language,
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
        _pendingPlayerMessage = null;
        _pendingNarratorMessage = null;
        _status = suggestionsOnly
            ? context.l10n.suggestionsUpdated(_settings.isConfigured)
            : context.l10n.turnCompleted(_settings.isConfigured);
        if (!suggestionsOnly) {
          _inputController.clear();
        }
      });
    } on AiTurnException catch (error) {
      _clearPendingMessages();
      await _handleAiTurnException(error);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSending = false;
        _pendingPlayerMessage = null;
        _pendingNarratorMessage = null;
        _status = context.l10n.turnError(error);
      });
    }
  }

  Future<void> _handleAiTurnException(final AiTurnException error) async {
    final CampaignState? campaign = _campaign;
    if (campaign == null) {
      return;
    }

    final AppScope scope = AppScope.of(context);
    CampaignState nextState = scope.gameEngine.appendSystemMessage(
      state: campaign,
      text: error.userMessage,
    );

    if ((error.rawResponse ?? '').trim().isNotEmpty) {
      nextState = scope.gameEngine.appendSystemMessage(
        state: nextState,
        text: context.l10n.rawModelResponseSaved,
      );
    }

    await scope.campaignRepository.saveCampaign(nextState);

    if (!mounted) {
      return;
    }

    setState(() {
      _campaign = nextState;
      _isSending = false;
      _pendingPlayerMessage = null;
      _pendingNarratorMessage = null;
      _status = error.userMessage;
    });
  }

  List<ChatMessage> _visibleMessages(final CampaignState campaign) {
    final List<ChatMessage> messages = List<ChatMessage>.from(campaign.messages);
    if (_pendingPlayerMessage != null) {
      messages.add(_pendingPlayerMessage!);
    }
    if (_pendingNarratorMessage != null) {
      messages.add(_pendingNarratorMessage!);
    }
    return messages;
  }

  Future<void> _animatePendingNarration(final String narration) async {
    final List<String> words = narration
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty || !mounted) {
      return;
    }

    String buffer = '';
    for (int i = 0; i < words.length; i += 2) {
      final int end = (i + 2 < words.length) ? i + 2 : words.length;
      final String chunk = words.sublist(i, end).join(' ');
      buffer = buffer.isEmpty ? chunk : '$buffer $chunk';
      if (!mounted) {
        return;
      }
      setState(() {
        _pendingNarratorMessage = ChatMessage(
          id: 'pending_narrator',
          role: ChatRole.narrator,
          text: buffer,
          createdAt: _pendingNarratorMessage?.createdAt ?? DateTime.now(),
        );
      });
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }
  }

  void _clearPendingMessages() {
    if (!mounted) {
      return;
    }
    setState(() {
      _pendingPlayerMessage = null;
      _pendingNarratorMessage = null;
    });
  }
}
