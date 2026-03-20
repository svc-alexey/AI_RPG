import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/features/chat/application/chat_controller.dart';
import 'package:ai_prg/src/features/chat/widgets/overlay_choice_stack.dart';
import 'package:ai_prg/src/features/chat/widgets/state_change_overlay_stack.dart';
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
                child: SafeArea(
                  child: _buildSidebar(
                    campaign: campaign,
                    highlightedModules: chatState.highlightedModules,
                    newlyUnlockedModules: chatState.newlyUnlockedModules,
                  ),
                ),
              ),
            ),
      body: AetherBackdrop(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: wide
              ? Row(
                  children: <Widget>[
                    SizedBox(
                      width: 240,
                      child: _buildSidebar(
                        campaign: campaign,
                        highlightedModules: chatState.highlightedModules,
                        newlyUnlockedModules: chatState.newlyUnlockedModules,
                      ),
                    ),
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
          child: Stack(
            children: <Widget>[
              AetherCard(
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
                                ? AetherPalette.accentSoft.withValues(
                                    alpha: 0.42,
                                  )
                                : isSystem
                                ? AetherPalette.panelSoft.withValues(
                                    alpha: 0.92,
                                  )
                                : AetherPalette.panel.withValues(alpha: 0.96),
                            borderRadius: BorderRadius.circular(
                              isNarrow ? 16 : 20,
                            ),
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
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
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
              StateChangeOverlayStack(
                notifications: chatState.transientNotifications,
              ),
            ],
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

  Widget _buildSidebar({
    required final CampaignState campaign,
    required final List<CampaignModule> highlightedModules,
    required final List<CampaignModule> newlyUnlockedModules,
  }) {
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
          if (campaign.modules.isNotEmpty) ...<Widget>[
            Text(
              l10n.activeSystemsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: campaign.activeModules.map((final item) {
                final _ModuleHighlightState highlightState =
                    _resolveModuleHighlightState(
                      campaign: campaign,
                      module: item,
                      highlightedModules: highlightedModules,
                      newlyUnlockedModules: newlyUnlockedModules,
                    );
                return Chip(
                  backgroundColor: switch (highlightState) {
                    _ModuleHighlightState.newlyUnlocked =>
                      AetherPalette.accentSoft.withValues(alpha: 0.42),
                    _ModuleHighlightState.updated =>
                      AetherPalette.panelSoft.withValues(alpha: 0.92),
                    _ModuleHighlightState.none => null,
                  },
                  side: BorderSide(
                    color: switch (highlightState) {
                      _ModuleHighlightState.newlyUnlocked =>
                        AetherPalette.accent.withValues(alpha: 0.45),
                      _ModuleHighlightState.updated =>
                        AetherPalette.accentSoft.withValues(alpha: 0.6),
                      _ModuleHighlightState.none =>
                        AetherPalette.panelBorder.withValues(alpha: 0.35),
                    },
                  ),
                  label: Text(
                    l10n.campaignModuleLabel(item),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: highlightState == _ModuleHighlightState.none
                          ? null
                          : AetherPalette.accent,
                      fontWeight: highlightState == _ModuleHighlightState.none
                          ? FontWeight.w500
                          : FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          if (campaign.isModuleActive(CampaignModule.vitality)) ...<Widget>[
            _ModuleHeader(
              title: l10n.campaignModuleLabel(CampaignModule.vitality),
              reason: l10n.campaignModuleReasonLabel(
                campaign
                        .moduleState(CampaignModule.vitality)
                        ?.activationReason ??
                    '',
              ),
              highlightState: _resolveModuleHighlightState(
                campaign: campaign,
                module: CampaignModule.vitality,
                highlightedModules: highlightedModules,
                newlyUnlockedModules: newlyUnlockedModules,
              ),
            ),
            const SizedBox(height: 8),
            Text(l10n.healthLabel(character)),
            Text(l10n.energyLabel(character)),
            Text(l10n.statsLabel(character)),
            const SizedBox(height: 16),
          ],
          if (campaign.isModuleActive(CampaignModule.inventory)) ...<Widget>[
            _ModuleHeader(
              title: l10n.campaignModuleLabel(CampaignModule.inventory),
              reason: l10n.campaignModuleReasonLabel(
                campaign
                        .moduleState(CampaignModule.inventory)
                        ?.activationReason ??
                    '',
              ),
              highlightState: _resolveModuleHighlightState(
                campaign: campaign,
                module: CampaignModule.inventory,
                highlightedModules: highlightedModules,
                newlyUnlockedModules: newlyUnlockedModules,
              ),
            ),
            const SizedBox(height: 8),
            if (campaign.inventory.isEmpty) Text(l10n.nothingTrackedYet),
            for (final String item in campaign.inventory) Text('- $item'),
            const SizedBox(height: 16),
          ],
          if (campaign.isModuleActive(CampaignModule.notes)) ...<Widget>[
            _ModuleHeader(
              title: l10n.campaignModuleLabel(CampaignModule.notes),
              reason: l10n.campaignModuleReasonLabel(
                campaign.moduleState(CampaignModule.notes)?.activationReason ??
                    '',
              ),
              highlightState: _resolveModuleHighlightState(
                campaign: campaign,
                module: CampaignModule.notes,
                highlightedModules: highlightedModules,
                newlyUnlockedModules: newlyUnlockedModules,
              ),
            ),
            const SizedBox(height: 8),
            if (campaign.notes.isEmpty) Text(l10n.nothingTrackedYet),
            for (final String item in campaign.notes) Text('- $item'),
            const SizedBox(height: 16),
          ],
          if (campaign.isModuleActive(CampaignModule.companions)) ...<Widget>[
            _ModuleHeader(
              title: l10n.campaignModuleLabel(CampaignModule.companions),
              reason: l10n.campaignModuleReasonLabel(
                campaign
                        .moduleState(CampaignModule.companions)
                        ?.activationReason ??
                    '',
              ),
              highlightState: _resolveModuleHighlightState(
                campaign: campaign,
                module: CampaignModule.companions,
                highlightedModules: highlightedModules,
                newlyUnlockedModules: newlyUnlockedModules,
              ),
            ),
            const SizedBox(height: 8),
            if (campaign.companions.isEmpty) Text(l10n.nothingTrackedYet),
            for (final CampaignCompanion item in campaign.companions)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '- ${item.name} (${item.status})${item.notes.trim().isEmpty ? '' : ' • ${item.notes}'}',
                ),
              ),
            const SizedBox(height: 16),
          ],
          if (campaign.isModuleActive(CampaignModule.resources)) ...<Widget>[
            _ModuleHeader(
              title: l10n.campaignModuleLabel(CampaignModule.resources),
              reason: l10n.campaignModuleReasonLabel(
                campaign
                        .moduleState(CampaignModule.resources)
                        ?.activationReason ??
                    '',
              ),
              highlightState: _resolveModuleHighlightState(
                campaign: campaign,
                module: CampaignModule.resources,
                highlightedModules: highlightedModules,
                newlyUnlockedModules: newlyUnlockedModules,
              ),
            ),
            const SizedBox(height: 8),
            if (campaign.resources.isEmpty) Text(l10n.nothingTrackedYet),
            for (final CampaignResource item in campaign.resources)
              Text(
                '- ${item.label}: ${item.value}${item.maxValue == null ? '' : '/${item.maxValue}'}',
              ),
            const SizedBox(height: 16),
          ],
          if (campaign.isModuleActive(CampaignModule.progression)) ...<Widget>[
            _ModuleHeader(
              title: l10n.campaignModuleLabel(CampaignModule.progression),
              reason: l10n.campaignModuleReasonLabel(
                campaign
                        .moduleState(CampaignModule.progression)
                        ?.activationReason ??
                    '',
              ),
              highlightState: _resolveModuleHighlightState(
                campaign: campaign,
                module: CampaignModule.progression,
                highlightedModules: highlightedModules,
                newlyUnlockedModules: newlyUnlockedModules,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              campaign.progression == null
                  ? l10n.nothingTrackedYet
                  : l10n.progressionLabel(campaign.progression!),
            ),
            const SizedBox(height: 16),
          ],
          if (campaign.isModuleActive(CampaignModule.checks)) ...<Widget>[
            _ModuleHeader(
              title: l10n.campaignModuleLabel(CampaignModule.checks),
              reason: l10n.campaignModuleReasonLabel(
                campaign.moduleState(CampaignModule.checks)?.activationReason ??
                    '',
              ),
              highlightState: _resolveModuleHighlightState(
                campaign: campaign,
                module: CampaignModule.checks,
                highlightedModules: highlightedModules,
                newlyUnlockedModules: newlyUnlockedModules,
              ),
            ),
            const SizedBox(height: 8),
            if (campaign.checks.isEmpty) Text(l10n.nothingTrackedYet),
            for (final CampaignCheck item in campaign.checks.reversed)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('- ${l10n.campaignCheckLabel(item)}'),
              ),
            const SizedBox(height: 16),
          ],
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

  bool _isRecentlyActivated(final CampaignModuleState? moduleState) {
    final DateTime? activatedAt = moduleState?.activatedAt;
    if (activatedAt == null) {
      return false;
    }
    return DateTime.now().difference(activatedAt) <= const Duration(minutes: 5);
  }

  _ModuleHighlightState _resolveModuleHighlightState({
    required final CampaignState campaign,
    required final CampaignModule module,
    required final List<CampaignModule> highlightedModules,
    required final List<CampaignModule> newlyUnlockedModules,
  }) {
    if (newlyUnlockedModules.contains(module)) {
      return _ModuleHighlightState.newlyUnlocked;
    }
    if (highlightedModules.contains(module)) {
      return _ModuleHighlightState.updated;
    }
    if (_isRecentlyActivated(campaign.moduleState(module))) {
      return _ModuleHighlightState.newlyUnlocked;
    }
    return _ModuleHighlightState.none;
  }
}

class _ModuleHeader extends StatelessWidget {
  const _ModuleHeader({
    required this.title,
    required this.reason,
    required this.highlightState,
  });

  final String title;
  final String reason;
  final _ModuleHighlightState highlightState;

  @override
  Widget build(final BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: highlightState == _ModuleHighlightState.none
                    ? null
                    : AetherPalette.accent,
              ),
            ),
          ),
          if (highlightState != _ModuleHighlightState.none)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: highlightState == _ModuleHighlightState.newlyUnlocked
                    ? AetherPalette.accentSoft.withValues(alpha: 0.45)
                    : AetherPalette.panelSoft.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AetherPalette.accentSoft.withValues(alpha: 0.55),
                ),
              ),
              child: Text(
                highlightState == _ModuleHighlightState.newlyUnlocked
                    ? context.l10n.newlyUnlockedLabel
                    : context.l10n.updatedLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AetherPalette.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 2),
      Text(
        reason,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AetherPalette.textMuted),
      ),
    ],
  );
}

enum _ModuleHighlightState { none, updated, newlyUnlocked }
