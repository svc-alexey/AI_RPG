import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/app_logger.dart';
import 'package:ai_prg/src/features/chat/application/chat_controller.dart';
import 'package:ai_prg/src/features/chat/widgets/overlay_choice_stack.dart';
import 'package:ai_prg/src/features/chat/widgets/portrait_image.dart';
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

class _ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver {
  static final Set<String> _introTriggeredCampaignIds = <String>{};

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _didTriggerIntro = false;

  @override
  void initState() {
    super.initState();
    _didTriggerIntro = _introTriggeredCampaignIds.contains(widget.campaignId);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    AppLogger.logDiagnostic(
      level: 'INFO',
      event: 'chat_screen_dispose',
      message: 'ChatScreen disposed.',
      campaignId: widget.campaignId,
      screenMounted: false,
    );
    WidgetsBinding.instance.removeObserver(this);
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      FocusManager.instance.primaryFocus?.unfocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(animated: false);
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppResponsiveData responsive = context.responsive;
    final bool keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
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

      final _ScrollMode scrollMode = _resolveScrollMode(previous, next);
      if (scrollMode != _ScrollMode.none) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToBottom(animated: scrollMode == _ScrollMode.animate),
        );
      }

      final String? nextStatus = next.status;
      if (nextStatus != null &&
          nextStatus != previous?.status &&
          !_isPassiveTurnStatus(nextStatus, l10n)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(nextStatus)));
        });
      }

      if (!_didTriggerIntro &&
          !_introTriggeredCampaignIds.contains(widget.campaignId) &&
          !next.isLoading &&
          next.campaign != null &&
          next.campaign!.messages.isEmpty &&
          !next.isSending) {
        _didTriggerIntro = true;
        _introTriggeredCampaignIds.add(widget.campaignId);
        AppLogger.logDiagnostic(
          level: 'INFO',
          event: 'intro_turn_triggered',
          message: 'Auto-starting intro turn for empty campaign.',
          campaignId: widget.campaignId,
          triggerSource: 'intro',
          screenMounted: mounted,
        );
        controller.runTurn(
          l10n: l10n,
          action: '',
          suggestionsOnly: false,
          isIntro: true,
          triggerSource: 'intro',
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

    final bool wide = responsive.isWide;

    return Scaffold(
      key: _scaffoldKey,
      appBar: responsive.isPhoneSmall
          ? null
          : AppBar(
              title: Text(
                campaign.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
      drawer: wide || responsive.isPhoneSmall
          ? null
          : Drawer(
              width: responsive.width * 0.84,
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
          padding: EdgeInsets.all(responsive.pagePadding),
          child: Column(
            children: <Widget>[
              if (responsive.isPhoneSmall && !keyboardVisible) ...<Widget>[
                _CompactChatToolbar(
                  title: campaign.title,
                  onMenu: wide
                      ? null
                      : () => _showCompactCampaignSheet(
                          campaign: campaign,
                          highlightedModules: chatState.highlightedModules,
                          newlyUnlockedModules: chatState.newlyUnlockedModules,
                        ),
                  onSave: () => controller.save(l10n: l10n),
                  onSettings: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (final context) => const SettingsScreen(),
                      ),
                    );
                  },
                  onHome: _exitToMainMenu,
                ),
                SizedBox(height: responsive.sectionSpacing),
              ],
              Expanded(
                child: wide
                    ? Row(
                        children: <Widget>[
                          SizedBox(
                            width: responsive.sidebarWidth,
                            child: _buildSidebar(
                              campaign: campaign,
                              highlightedModules: chatState.highlightedModules,
                              newlyUnlockedModules:
                                  chatState.newlyUnlockedModules,
                            ),
                          ),
                          SizedBox(width: responsive.sectionSpacing + 4),
                          Expanded(
                            child: _buildChatColumn(
                              campaign: campaign,
                              chatState: chatState,
                              controller: controller,
                              keyboardVisible: keyboardVisible,
                            ),
                          ),
                        ],
                      )
                    : _buildChatColumn(
                        campaign: campaign,
                        chatState: chatState,
                        controller: controller,
                        keyboardVisible: keyboardVisible,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatColumn({
    required final CampaignState campaign,
    required final ChatViewState chatState,
    required final ChatController controller,
    required final bool keyboardVisible,
  }) {
    final AppLocalizations l10n = context.l10n;
    final List<ChatMessage> visibleMessages = chatState.visibleMessages;
    final AppResponsiveData responsive = context.responsive;
    final double screenWidth = responsive.width;
    final bool isNarrow = responsive.isCompact;
    final bool compactMobileComposer =
        responsive.isPhoneSmall && keyboardVisible;

    return Column(
      children: <Widget>[
        Expanded(
          child: Stack(
            children: <Widget>[
              AetherCard(
                padding: EdgeInsets.all(isNarrow ? 8 : 14),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    bottom: compactMobileComposer ? 6 : 0,
                  ),
                  itemCount:
                      visibleMessages.length +
                      (campaign.choices.isNotEmpty && !responsive.isPhoneSmall
                          ? 1
                          : 0),
                  itemBuilder: (final context, final index) {
                    if (index == visibleMessages.length) {
                      return IgnorePointer(
                        ignoring: chatState.isSending,
                        child: OverlayChoiceStack(
                          choices: campaign.choices.take(3).toList(),
                          onChoiceSelected: (final choice) {
                            _submitAction(
                              controller: controller,
                              action: choice,
                            );
                          },
                          enabled: !chatState.isSending,
                        ),
                      );
                    }

                    final ChatMessage message = visibleMessages[index];
                    final bool isPlayer = message.role == ChatRole.player;
                    final bool isSystem = message.role == ChatRole.system;
                    final bool isPendingNarrator =
                        chatState.isSending &&
                        message.id == 'pending_narrator' &&
                        message.role == ChatRole.narrator;

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == visibleMessages.length - 1
                            ? 0
                            : (isNarrow ? 8 : 12),
                      ),
                      child: Align(
                        alignment: isPlayer
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: isNarrow ? screenWidth * 0.9 : 680,
                          ),
                          padding: EdgeInsets.all(isNarrow ? 10 : 16),
                          decoration: BoxDecoration(
                            color: isPlayer
                                ? AetherPalette.accentSoft.withValues(
                                    alpha: 0.42,
                                  )
                                : isSystem
                                ? AetherPalette.panelSoft.withValues(
                                    alpha: 0.92,
                                  )
                                : isPendingNarrator
                                ? AetherPalette.panelSoft.withValues(
                                    alpha: 0.98,
                                  )
                                : AetherPalette.panel.withValues(alpha: 0.96),
                            borderRadius: BorderRadius.circular(
                              isNarrow ? 14 : 18,
                            ),
                            border: Border.all(
                              color:
                                  (isPlayer
                                          ? AetherPalette.accent
                                          : isPendingNarrator
                                          ? AetherPalette.accentSoft
                                          : AetherPalette.panelBorder)
                                      .withValues(alpha: 0.45),
                            ),
                            boxShadow: isPendingNarrator
                                ? <BoxShadow>[
                                    BoxShadow(
                                      color: AetherPalette.accent.withValues(
                                        alpha: 0.12,
                                      ),
                                      blurRadius: 22,
                                      spreadRadius: -8,
                                      offset: const Offset(0, 10),
                                    ),
                                  ]
                                : const <BoxShadow>[],
                          ),
                          child: isPendingNarrator
                              ? _StreamingNarrationContent(
                                  text: message.text,
                                  placeholder: l10n.generatingResponse,
                                  isNarrow: isNarrow,
                                )
                              : message.role == ChatRole.narrator
                              ? _AnimatedNarrationMessage(
                                  key: ValueKey<String>(message.id),
                                  text: message.text,
                                  isNarrow: isNarrow,
                                )
                              : Text(
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
        SizedBox(height: compactMobileComposer ? 8 : responsive.sectionSpacing),
        Container(
          decoration: BoxDecoration(
            color: AetherPalette.panel.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(isNarrow ? 14 : 18),
            border: Border.all(
              color: AetherPalette.panelBorder.withValues(alpha: 0.56),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? (compactMobileComposer ? 6 : 8) : 10,
            vertical: isNarrow ? (compactMobileComposer ? 3 : 5) : 6,
          ),
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
              if (responsive.isPhoneSmall)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextField(
                      controller: _inputController,
                      minLines: 1,
                      maxLines: compactMobileComposer ? 3 : 4,
                      onSubmitted: (_) => _submitAction(
                        controller: controller,
                        action: _inputController.text,
                      ),
                      decoration: const InputDecoration(
                        hintText: '',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                      ).copyWith(hintText: l10n.chatInputHint),
                    ),
                    SizedBox(height: compactMobileComposer ? 4 : 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: chatState.isSending
                          ? TextButton(
                              onPressed: controller.cancelGeneration,
                              child: Text(l10n.cancel),
                            )
                          : IconButton.filled(
                              onPressed: () => _submitAction(
                                controller: controller,
                                action: _inputController.text,
                              ),
                              icon: const Icon(Icons.send_rounded),
                              tooltip: l10n.send,
                            ),
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        minLines: 1,
                        maxLines: 4,
                        onSubmitted: (_) => _submitAction(
                          controller: controller,
                          action: _inputController.text,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.chatInputHint,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: responsive.isCompact ? 12 : 14,
                            vertical: responsive.isCompact ? 8 : 10,
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
                        onPressed: () => _submitAction(
                          controller: controller,
                          action: _inputController.text,
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

  Future<void> _showCompactCampaignSheet({
    required final CampaignState campaign,
    required final List<CampaignModule> highlightedModules,
    required final List<CampaignModule> newlyUnlockedModules,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (final context) => FractionallySizedBox(
      heightFactor: 0.86,
      child: AetherBackdrop(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(context.responsive.pagePadding),
            child: _buildSidebar(
              campaign: campaign,
              highlightedModules: highlightedModules,
              newlyUnlockedModules: newlyUnlockedModules,
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildSidebar({
    required final CampaignState campaign,
    required final List<CampaignModule> highlightedModules,
    required final List<CampaignModule> newlyUnlockedModules,
  }) {
    final CharacterStats character = campaign.character;
    final AppLocalizations l10n = context.l10n;
    final AppResponsiveData responsive = context.responsive;
    return AetherCard(
      padding: EdgeInsets.all(responsive.isCompact ? 8 : 14),
      child: ListView(
        padding: EdgeInsets.all(
          responsive.isCompact ? 8 : responsive.cardPadding - 2,
        ),
        children: <Widget>[
          _CharacterPortraitCard(campaign: campaign),
          SizedBox(height: responsive.sectionSpacing),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _SidebarMetaChip(label: '${l10n.turn}: ${campaign.turnNumber}'),
              _SidebarMetaChip(label: l10n.settingLabel(campaign.setting)),
            ],
          ),
          SizedBox(height: responsive.sectionSpacing),
          if (campaign.activeModules.isNotEmpty) ...<Widget>[
            _ModuleIconStrip(
              campaign: campaign,
              highlightedModules: highlightedModules,
              newlyUnlockedModules: newlyUnlockedModules,
            ),
            SizedBox(height: responsive.sectionSpacing),
          ],
          _SidebarInfoLine(label: l10n.location, value: campaign.location),
          SizedBox(height: responsive.isCompact ? 8 : 6),
          _SidebarInfoLine(label: l10n.objective, value: campaign.objective),
          SizedBox(height: responsive.sectionSpacing),
          if (campaign.isModuleActive(CampaignModule.vitality)) ...<Widget>[
            _SidebarSectionTitle(
              title: l10n.campaignModuleLabel(CampaignModule.vitality),
            ),
            const SizedBox(height: 8),
            Text(l10n.healthLabel(character)),
            Text(l10n.energyLabel(character)),
            Text(l10n.statsLabel(character)),
            SizedBox(height: responsive.sectionSpacing),
          ],
          if (campaign.isModuleActive(CampaignModule.inventory)) ...<Widget>[
            _SidebarSectionTitle(
              title: l10n.campaignModuleLabel(CampaignModule.inventory),
            ),
            const SizedBox(height: 8),
            if (campaign.inventory.isEmpty) Text(l10n.nothingTrackedYet),
            for (final String item in campaign.inventory) Text('- $item'),
            SizedBox(height: responsive.sectionSpacing),
          ],
          if (campaign.isModuleActive(CampaignModule.notes)) ...<Widget>[
            _SidebarSectionTitle(
              title: l10n.campaignModuleLabel(CampaignModule.notes),
            ),
            const SizedBox(height: 8),
            if (campaign.notes.isEmpty) Text(l10n.nothingTrackedYet),
            for (final String item in campaign.notes) Text('- $item'),
            SizedBox(height: responsive.sectionSpacing),
          ],
          if (campaign.isModuleActive(CampaignModule.companions)) ...<Widget>[
            _SidebarSectionTitle(
              title: l10n.campaignModuleLabel(CampaignModule.companions),
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
            SizedBox(height: responsive.sectionSpacing),
          ],
          if (campaign.isModuleActive(CampaignModule.resources)) ...<Widget>[
            _SidebarSectionTitle(
              title: l10n.campaignModuleLabel(CampaignModule.resources),
            ),
            const SizedBox(height: 8),
            if (campaign.resources.isEmpty) Text(l10n.nothingTrackedYet),
            for (final CampaignResource item in campaign.resources)
              Text(
                '- ${item.label}: ${item.value}${item.maxValue == null ? '' : '/${item.maxValue}'}',
              ),
            SizedBox(height: responsive.sectionSpacing),
          ],
          if (campaign.isModuleActive(CampaignModule.progression)) ...<Widget>[
            _SidebarSectionTitle(
              title: l10n.campaignModuleLabel(CampaignModule.progression),
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
            _SidebarSectionTitle(
              title: l10n.campaignModuleLabel(CampaignModule.checks),
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

  void _submitAction({
    required final ChatController controller,
    required final String action,
  }) {
    if (!mounted) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    controller.runTurn(
      l10n: context.l10n,
      action: action,
      suggestionsOnly: false,
    );
  }

  bool _isPassiveTurnStatus(final String status, final AppLocalizations l10n) =>
      <String>{
        l10n.turnCompleted(true),
        l10n.turnCompleted(false),
        l10n.suggestionsUpdated(true),
        l10n.suggestionsUpdated(false),
      }.contains(status);

  _ScrollMode _resolveScrollMode(
    final ChatViewState? previous,
    final ChatViewState next,
  ) {
    if (previous == null) {
      return next.isLoading ? _ScrollMode.none : _ScrollMode.animate;
    }

    final bool visibleCountChanged =
        previous.visibleMessages.length != next.visibleMessages.length;
    final bool narratorChanged =
        previous.pendingNarratorMessage?.text !=
        next.pendingNarratorMessage?.text;
    final bool finishedSending = previous.isSending && !next.isSending;

    if (visibleCountChanged || finishedSending) {
      return _ScrollMode.animate;
    }
    if (narratorChanged) {
      return _ScrollMode.animate;
    }
    return _ScrollMode.none;
  }

  void _scrollToBottom({required final bool animated}) {
    if (!_scrollController.hasClients) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (_scrollController.hasClients) {
        final double offset = _scrollController.position.maxScrollExtent;
        if (animated) {
          _scrollController.animateTo(
            offset,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
          return;
        }
        _scrollController.jumpTo(offset);
      }
    });
  }
}

class _SidebarSectionTitle extends StatelessWidget {
  const _SidebarSectionTitle({required this.title});

  final String title;

  @override
  Widget build(final BuildContext context) =>
      Text(title, style: Theme.of(context).textTheme.titleMedium);
}

class _CompactChatToolbar extends StatelessWidget {
  const _CompactChatToolbar({
    required this.title,
    required this.onMenu,
    required this.onSave,
    required this.onSettings,
    required this.onHome,
  });

  final String title;
  final VoidCallback? onMenu;
  final VoidCallback onSave;
  final VoidCallback onSettings;
  final VoidCallback onHome;

  @override
  Widget build(final BuildContext context) => AetherCard(
    padding: EdgeInsets.all(context.responsive.cardPadding),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            if (onMenu != null)
              _CompactToolbarButton(
                icon: Icons.menu,
                tooltip: context.l10n.campaignInfo,
                onPressed: onMenu!,
              ),
            _CompactToolbarButton(
              icon: Icons.save_outlined,
              tooltip: context.l10n.saveTooltip,
              onPressed: onSave,
            ),
            _CompactToolbarButton(
              icon: Icons.tune_rounded,
              tooltip: context.l10n.aiSettings,
              onPressed: onSettings,
            ),
            _CompactToolbarButton(
              icon: Icons.home_outlined,
              tooltip: context.l10n.exitToMainMenu,
              onPressed: onHome,
            ),
          ],
        ),
      ],
    ),
  );
}

class _CompactToolbarButton extends StatelessWidget {
  const _CompactToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(final BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AetherPalette.panelSoft.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AetherPalette.panelBorder.withValues(alpha: 0.62),
          ),
        ),
        child: Icon(icon, size: 18),
      ),
    ),
  );
}

class _CharacterPortraitCard extends StatelessWidget {
  const _CharacterPortraitCard({required this.campaign});

  final CampaignState campaign;

  @override
  Widget build(final BuildContext context) {
    final AppResponsiveData responsive = context.responsive;
    final String imagePath = campaign.portraitPath.trim().isNotEmpty
        ? campaign.portraitPath.trim()
        : _portraitAssetForCampaign(campaign);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AetherPalette.panelSoft.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(responsive.isCompact ? 16 : 20),
        border: Border.all(
          color: AetherPalette.panelBorder.withValues(alpha: 0.58),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(responsive.isCompact ? 16 : 20),
            ),
            child: buildPortraitImage(
              portraitPath: imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: responsive.isCompact ? 190 : 220,
              errorBuilder: (context, error, stackTrace) =>
                  _PortraitFallbackLabel(label: campaign.character.name),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              responsive.isCompact ? 12 : 14,
              10,
              responsive.isCompact ? 12 : 14,
              responsive.isCompact ? 12 : 14,
            ),
            child: Text(
              campaign.character.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AetherPalette.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortraitFallbackLabel extends StatelessWidget {
  const _PortraitFallbackLabel({required this.label});

  final String label;

  @override
  Widget build(final BuildContext context) => Container(
    height: 180,
    color: AetherPalette.panel.withValues(alpha: 0.94),
    alignment: Alignment.center,
    child: Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(color: AetherPalette.textMuted),
      textAlign: TextAlign.center,
    ),
  );
}

class _ModuleIconStrip extends StatelessWidget {
  const _ModuleIconStrip({
    required this.campaign,
    required this.highlightedModules,
    required this.newlyUnlockedModules,
  });

  final CampaignState campaign;
  final List<CampaignModule> highlightedModules;
  final List<CampaignModule> newlyUnlockedModules;

  @override
  Widget build(final BuildContext context) => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: campaign.activeModules.map((final module) {
      final _ModuleHighlightState highlightState = _resolveHighlight(
        campaign: campaign,
        module: module,
      );
      return Tooltip(
        message: context.l10n.campaignModuleLabel(module),
        waitDuration: const Duration(milliseconds: 250),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AetherPalette.panelSoft.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: switch (highlightState) {
                _ModuleHighlightState.newlyUnlocked =>
                  AetherPalette.accent.withValues(alpha: 0.75),
                _ModuleHighlightState.updated =>
                  AetherPalette.accentSoft.withValues(alpha: 0.78),
                _ModuleHighlightState.none =>
                  AetherPalette.panelBorder.withValues(alpha: 0.55),
              },
            ),
            boxShadow: highlightState == _ModuleHighlightState.none
                ? const <BoxShadow>[]
                : <BoxShadow>[
                    BoxShadow(
                      color: AetherPalette.accent.withValues(
                        alpha:
                            highlightState ==
                                _ModuleHighlightState.newlyUnlocked
                            ? 0.22
                            : 0.12,
                      ),
                      blurRadius: 20,
                      spreadRadius: -6,
                    ),
                  ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Icon(
                _iconForModule(module),
                size: 18,
                color: highlightState == _ModuleHighlightState.none
                    ? AetherPalette.textMuted
                    : AetherPalette.textPrimary,
              ),
              if (highlightState != _ModuleHighlightState.none)
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color:
                          highlightState == _ModuleHighlightState.newlyUnlocked
                          ? AetherPalette.accent
                          : AetherPalette.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList(),
  );

  _ModuleHighlightState _resolveHighlight({
    required final CampaignState campaign,
    required final CampaignModule module,
  }) {
    if (newlyUnlockedModules.contains(module)) {
      return _ModuleHighlightState.newlyUnlocked;
    }
    if (highlightedModules.contains(module)) {
      return _ModuleHighlightState.updated;
    }
    final DateTime? activatedAt = campaign.moduleState(module)?.activatedAt;
    if (activatedAt == null) {
      return _ModuleHighlightState.none;
    }
    return DateTime.now().difference(activatedAt) <= const Duration(minutes: 5)
        ? _ModuleHighlightState.newlyUnlocked
        : _ModuleHighlightState.none;
  }
}

class _SidebarMetaChip extends StatelessWidget {
  const _SidebarMetaChip({required this.label});

  final String label;

  @override
  Widget build(final BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: context.responsive.isCompact ? 10 : 12,
      vertical: context.responsive.isCompact ? 6 : 8,
    ),
    decoration: BoxDecoration(
      color: AetherPalette.panelSoft.withValues(alpha: 0.82),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: AetherPalette.panelBorder.withValues(alpha: 0.5),
      ),
    ),
    child: Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: AetherPalette.textPrimary),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

class _SidebarInfoLine extends StatelessWidget {
  const _SidebarInfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(final BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        '$label:',
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: AetherPalette.textMuted),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: context.responsive.isCompact ? 4 : 3,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

String _portraitAssetForCampaign(final CampaignState campaign) =>
    switch (campaign.setting) {
      CampaignSetting.fantasy => 'assets/images/portraits/fantasy_guardian.png',
      CampaignSetting.detective =>
        'assets/images/portraits/detective_shadow.png',
      CampaignSetting.sciFi => 'assets/images/portraits/scifi_oracle.png',
    };

IconData _iconForModule(final CampaignModule module) => switch (module) {
  CampaignModule.inventory => Icons.backpack_outlined,
  CampaignModule.companions => Icons.groups_2_outlined,
  CampaignModule.notes => Icons.menu_book_outlined,
  CampaignModule.vitality => Icons.favorite_border_rounded,
  CampaignModule.resources => Icons.diamond_outlined,
  CampaignModule.progression => Icons.insights_outlined,
  CampaignModule.checks => Icons.casino_outlined,
};

enum _ModuleHighlightState { none, updated, newlyUnlocked }

enum _ScrollMode { none, jump, animate }

class _StreamingNarrationContent extends StatelessWidget {
  const _StreamingNarrationContent({
    required this.text,
    required this.placeholder,
    required this.isNarrow,
  });

  final String text;
  final String placeholder;
  final bool isNarrow;

  @override
  Widget build(final BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String resolvedText = text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.auto_awesome_rounded,
              size: isNarrow ? 14 : 16,
              color: AetherPalette.accent,
            ),
            const SizedBox(width: 8),
            Text(
              placeholder,
              style: textTheme.labelLarge?.copyWith(
                color: AetherPalette.accent.withValues(alpha: 0.92),
                fontSize: isNarrow ? 11 : 12,
                letterSpacing: 0.9,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          resolvedText.isEmpty ? placeholder : resolvedText,
          style: textTheme.bodyLarge?.copyWith(
            color: resolvedText.isEmpty
                ? AetherPalette.textMuted
                : AetherPalette.textPrimary,
            fontSize: isNarrow ? 14 : 16,
            height: 1.3,
          ),
          strutStyle: StrutStyle(
            fontSize: isNarrow ? 14 : 16,
            height: 1.3,
            forceStrutHeight: true,
          ),
        ),
        const SizedBox(height: 10),
        const _TypingPulseIndicator(),
      ],
    );
  }
}

class _AnimatedNarrationMessage extends StatefulWidget {
  const _AnimatedNarrationMessage({
    required this.text,
    required this.isNarrow,
    super.key,
  });

  final String text;
  final bool isNarrow;

  @override
  State<_AnimatedNarrationMessage> createState() =>
      _AnimatedNarrationMessageState();
}

class _AnimatedNarrationMessageState extends State<_AnimatedNarrationMessage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  )..forward();

  @override
  void didUpdateWidget(covariant final _AnimatedNarrationMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final TextStyle style = Theme.of(context).textTheme.bodyLarge!.copyWith(
      color: AetherPalette.textPrimary,
      fontSize: widget.isNarrow ? 14 : 16,
      height: 1.3,
    );

    final Animation<double> animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.12, 1.0, curve: Curves.easeOutCubic),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.018),
          end: Offset.zero,
        ).animate(animation),
        child: Text(
          widget.text,
          style: style,
          strutStyle: StrutStyle(
            fontSize: widget.isNarrow ? 14 : 16,
            height: 1.3,
            forceStrutHeight: true,
          ),
        ),
      ),
    );
  }
}

class _TypingPulseIndicator extends StatefulWidget {
  const _TypingPulseIndicator();

  @override
  State<_TypingPulseIndicator> createState() => _TypingPulseIndicatorState();
}

class _TypingPulseIndicatorState extends State<_TypingPulseIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => SizedBox(
    width: 34,
    child: AnimatedBuilder(
      animation: _controller,
      builder: (final context, _) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List<Widget>.generate(3, (final index) {
          final double phase = _wrappedPhase(
            _controller.value - (index * 0.16),
          );
          final double intensity = (1 - ((phase * 2) - 1).abs()).clamp(
            0.2,
            1.0,
          );

          return Container(
            width: 6,
            height: 6 + (2 * intensity),
            decoration: BoxDecoration(
              color: AetherPalette.accent.withValues(
                alpha: 0.35 + (0.55 * intensity),
              ),
              borderRadius: BorderRadius.circular(999),
            ),
          );
        }),
      ),
    ),
  );

  double _wrappedPhase(final double value) {
    if (value >= 0) {
      return value % 1.0;
    }
    return 1.0 - ((-value) % 1.0);
  }
}
