import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/features/chat/application/chat_controller.dart';
import 'package:ai_prg/src/features/chat/widgets/overlay_choice_stack.dart';
import 'package:ai_prg/src/features/home/presentation/home_screen.dart';
import 'package:ai_prg/src/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({required this.campaignId, super.key});

  final String campaignId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _didTriggerIntro = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ChatViewState chatState = ref.watch(
      chatControllerProvider(widget.campaignId),
    );
    final ChatController controller = ref.read(
      chatControllerProvider(widget.campaignId).notifier,
    );

    ref.listen<ChatViewState>(chatControllerProvider(widget.campaignId), (
      final previous,
      final next,
    ) {
      if (next.clearInputRevision != (previous?.clearInputRevision ?? 0)) {
        _inputController.clear();
      }

      if (_shouldScroll(previous, next)) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }

      if (!_didTriggerIntro &&
          !next.isLoading &&
          next.campaign != null &&
          next.campaign!.messages.isEmpty &&
          !next.isSending) {
        _didTriggerIntro = true;
        controller.runTurn(
          l10n: l10n,
          action: '',
          suggestionsOnly: false,
          isIntro: true,
        );
      }
    });

    final CampaignState? campaign = chatState.campaign;
    if (chatState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (campaign == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.campaignNotFound)),
        body: Center(child: Text(l10n.campaignOpenFailed)),
      );
    }

    const double wideBreakpoint = 760;
    final bool wide = MediaQuery.sizeOf(context).width >= wideBreakpoint;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(campaign.title),
        leading: wide
            ? null
            : IconButton(
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                icon: const Icon(Icons.menu),
                tooltip: l10n.campaignInfo,
              ),
        actions: <Widget>[
          IconButton(
            onPressed: () => controller.save(l10n: l10n),
            icon: const Icon(Icons.save_outlined),
            tooltip: l10n.saveTooltip,
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (final context) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.tune_rounded),
            tooltip: l10n.aiSettings,
          ),
          IconButton(
            onPressed: _exitToMainMenu,
            icon: const Icon(Icons.home_outlined),
            tooltip: l10n.exitToMainMenu,
          ),
        ],
      ),
      drawer: wide
          ? null
          : Drawer(
              child: AetherBackdrop(
                child: SafeArea(child: _buildSidebar(campaign)),
              ),
            ),
      body: AetherBackdrop(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: wide
              ? Row(
                  children: <Widget>[
                    SizedBox(width: 240, child: _buildSidebar(campaign)),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildChatColumn(
                        campaign: campaign,
                        chatState: chatState,
                        controller: controller,
                      ),
                    ),
                  ],
                )
              : _buildChatColumn(
                  campaign: campaign,
                  chatState: chatState,
                  controller: controller,
                ),
        ),
      ),
    );
  }

  Widget _buildChatColumn({
    required final CampaignState campaign,
    required final ChatViewState chatState,
    required final ChatController controller,
  }) {
    final AppLocalizations l10n = context.l10n;
    final List<ChatMessage> visibleMessages = chatState.visibleMessages;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrow = screenWidth < 400;

    return Column(
      children: <Widget>[
        if (chatState.status != null)
          AetherCard(
            padding: EdgeInsets.symmetric(
              horizontal: isNarrow ? 12 : 18,
              vertical: isNarrow ? 10 : 14,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                chatState.status!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: isNarrow ? 13 : 14),
              ),
            ),
          ),
        if (chatState.status != null) const SizedBox(height: 12),
        Expanded(
          child: AetherCard(
            padding: EdgeInsets.all(isNarrow ? 12 : 16),
            child: ListView.builder(
              controller: _scrollController,
              itemCount:
                  visibleMessages.length +
                  (campaign.choices.isNotEmpty ? 1 : 0),
              itemBuilder: (final context, final index) {
                if (index == visibleMessages.length) {
                  return IgnorePointer(
                    ignoring: chatState.isSending,
                    child: OverlayChoiceStack(
                      choices: campaign.choices.take(3).toList(),
                      onChoiceSelected: (final choice) {
                        _inputController.text = choice;
                      },
                      enabled: !chatState.isSending,
                    ),
                  );
                }

                final ChatMessage message = visibleMessages[index];
                final bool isPlayer = message.role == ChatRole.player;
                final bool isSystem = message.role == ChatRole.system;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == visibleMessages.length - 1
                        ? 0
                        : (isNarrow ? 10 : 14),
                  ),
                  child: Align(
                    alignment: isPlayer
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isNarrow ? screenWidth * 0.85 : 640,
                      ),
                      padding: EdgeInsets.all(isNarrow ? 12 : 18),
                      decoration: BoxDecoration(
                        color: isPlayer
                            ? AetherPalette.accentSoft.withValues(alpha: 0.42)
                            : isSystem
                            ? AetherPalette.panelSoft.withValues(alpha: 0.92)
                            : AetherPalette.panel.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(isNarrow ? 16 : 20),
                        border: Border.all(
                          color:
                              (isPlayer
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
                          fontSize: isNarrow ? 14 : 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AetherPalette.panel.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AetherPalette.panelBorder.withValues(alpha: 0.68),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (chatState.isSending)
                const LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AetherPalette.accent,
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: l10n.chatInputHint,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (chatState.isSending)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextButton(
                          onPressed: controller.cancelGeneration,
                          child: Text(l10n.cancel),
                        ),
                      ],
                    )
                  else
                    IconButton.filled(
                      onPressed: () => controller.runTurn(
                        l10n: l10n,
                        action: _inputController.text,
                        suggestionsOnly: false,
                      ),
                      icon: const Icon(Icons.send_rounded),
                      tooltip: l10n.send,
                    ),
                ],
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
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: Text(l10n.exitToMainMenu),
            onTap: _exitToMainMenu,
          ),
        ],
      ),
    );
  }

  void _exitToMainMenu() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  bool _shouldScroll(final ChatViewState? previous, final ChatViewState next) {
    if (previous == null) {
      return !next.isLoading;
    }

    final bool visibleCountChanged =
        previous.visibleMessages.length != next.visibleMessages.length;
    final bool narratorChanged =
        previous.pendingNarratorMessage?.text !=
        next.pendingNarratorMessage?.text;
    final bool finishedSending = previous.isSending && !next.isSending;

    return visibleCountChanged || narratorChanged || finishedSending;
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
