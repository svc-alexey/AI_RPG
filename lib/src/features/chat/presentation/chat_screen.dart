import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/responsive.dart';
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

class _ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _didTriggerIntro = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
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
              width: responsive.isPhoneSmall ? responsive.width * 0.92 : null,
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
              if (responsive.isPhoneSmall) ...<Widget>[
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
  }) {
    final AppLocalizations l10n = context.l10n;
    final List<ChatMessage> visibleMessages = chatState.visibleMessages;
    final AppResponsiveData responsive = context.responsive;
    final double screenWidth = responsive.width;
    final bool isNarrow = responsive.isCompact;

    return Column(
      children: <Widget>[
        if (responsive.isMobile) _CampaignSummaryBanner(campaign: campaign),
        if (responsive.isMobile) SizedBox(height: responsive.sectionSpacing),
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
        if (chatState.status != null)
          SizedBox(height: responsive.sectionSpacing),
        Expanded(
          child: Stack(
            children: <Widget>[
              AetherCard(
                padding: EdgeInsets.all(isNarrow ? 12 : 16),
                child: ListView.builder(
                  controller: _scrollController,
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
                            _inputController.text = choice;
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
                                : isPendingNarrator
                                ? AetherPalette.panelSoft.withValues(
                                    alpha: 0.98,
                                  )
                                : AetherPalette.panel.withValues(alpha: 0.96),
                            borderRadius: BorderRadius.circular(
                              isNarrow ? 16 : 20,
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
        SizedBox(height: responsive.sectionSpacing),
        Container(
          decoration: BoxDecoration(
            color: AetherPalette.panel.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(isNarrow ? 16 : 20),
            border: Border.all(
              color: AetherPalette.panelBorder.withValues(alpha: 0.68),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? 10 : 12,
            vertical: isNarrow ? 6 : 8,
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
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: '',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ).copyWith(hintText: l10n.chatInputHint),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: chatState.isSending
                          ? TextButton(
                              onPressed: controller.cancelGeneration,
                              child: Text(l10n.cancel),
                            )
                          : IconButton.filled(
                              onPressed: () => controller.runTurn(
                                l10n: l10n,
                                action: _inputController.text,
                                suggestionsOnly: false,
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
                        decoration: InputDecoration(
                          hintText: l10n.chatInputHint,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: responsive.isCompact ? 14 : 16,
                            vertical: responsive.isCompact ? 10 : 12,
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
      child: ListView(
        padding: EdgeInsets.all(responsive.cardPadding),
        children: <Widget>[
          Text(
            character.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: responsive.isCompact ? 22 : null,
            ),
            maxLines: responsive.isCompact ? 3 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          _CharacterPortraitCard(campaign: campaign),
          const SizedBox(height: 12),
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
      return _ScrollMode.jump;
    }
    return _ScrollMode.none;
  }

  void _scrollToBottom({required final bool animated}) {
    if (!_scrollController.hasClients) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
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

class _CampaignSummaryBanner extends StatelessWidget {
  const _CampaignSummaryBanner({required this.campaign});

  final CampaignState campaign;

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppResponsiveData responsive = context.responsive;

    return AetherCard(
      padding: EdgeInsets.all(responsive.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _CharacterPortraitThumbnail(campaign: campaign),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      campaign.character.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: responsive.isCompact ? 18 : 20,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _SidebarMetaChip(
                          label: l10n.settingLabel(campaign.setting),
                        ),
                        _SidebarMetaChip(
                          label: '${l10n.turn}: ${campaign.turnNumber}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.sectionSpacing),
          _ModuleIconStrip(
            campaign: campaign,
            highlightedModules: const <CampaignModule>[],
            newlyUnlockedModules: const <CampaignModule>[],
          ),
          SizedBox(height: responsive.sectionSpacing),
          _SidebarInfoLine(label: l10n.location, value: campaign.location),
        ],
      ),
    );
  }
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
    final AppLocalizations l10n = context.l10n;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AetherPalette.panelSoft.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AetherPalette.panelBorder.withValues(alpha: 0.72),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Image.asset(
              _portraitAssetForCampaign(campaign),
              fit: BoxFit.cover,
              width: double.infinity,
              height: context.responsive.isCompact ? 190 : 220,
              errorBuilder: (context, error, stackTrace) =>
                  _PortraitFallbackLabel(label: l10n.portraitPlaceholderLabel),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.portraitPlaceholderLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AetherPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.portraitAiHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AetherPalette.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterPortraitThumbnail extends StatelessWidget {
  const _CharacterPortraitThumbnail({required this.campaign});

  final CampaignState campaign;

  @override
  Widget build(final BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Image.asset(
      _portraitAssetForCampaign(campaign),
      fit: BoxFit.cover,
      width: 64,
      height: 64,
      errorBuilder: (context, error, stackTrace) =>
          const _PortraitFallbackLabel(label: 'Hero', compact: true),
    ),
  );
}

class _PortraitFallbackLabel extends StatelessWidget {
  const _PortraitFallbackLabel({required this.label, this.compact = false});

  final String label;
  final bool compact;

  @override
  Widget build(final BuildContext context) => Container(
    height: compact ? 64 : 180,
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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (final child, final animation) =>
              FadeTransition(opacity: animation, child: child),
          child: Text(
            resolvedText.isEmpty ? placeholder : resolvedText,
            key: ValueKey<String>(resolvedText),
            style: textTheme.bodyLarge?.copyWith(
              color: resolvedText.isEmpty
                  ? AetherPalette.textMuted
                  : AetherPalette.textPrimary,
              fontSize: isNarrow ? 14 : 16,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const _TypingPulseIndicator(),
      ],
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
