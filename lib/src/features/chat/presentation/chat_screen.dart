import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_scope.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
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
    final AppLocalizations l10n = context.l10n;
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
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ChatMessage message = campaign.messages[index];
              final bool isPlayer = message.role == ChatRole.player;
              final bool isSystem = message.role == ChatRole.system;

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
                        : isSystem
                        ? const Color(0xFFE7DDD0)
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
      ],
    );
  }

  Widget _buildSidebar(final CampaignState campaign) {
    final CharacterStats character = campaign.character;
    final AppLocalizations l10n = context.l10n;
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
          for (final String item in campaign.inventory) Text('• $item'),
          const SizedBox(height: 16),
          Text(l10n.questLog, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final String item in campaign.questLog) Text('• $item'),
          const SizedBox(height: 16),
          Text(l10n.summary, style: Theme.of(context).textTheme.titleMedium),
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
            ? context.l10n.suggestionsUpdated(_settings.isConfigured)
            : context.l10n.turnCompleted(_settings.isConfigured);
        if (!suggestionsOnly) {
          _inputController.clear();
        }
      });
    } on AiTurnException catch (error) {
      await _handleAiTurnException(error);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSending = false;
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
      _status = error.userMessage;
    });
  }
}
