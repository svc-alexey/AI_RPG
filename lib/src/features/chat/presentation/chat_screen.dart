import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/services/app_logger.dart';
import 'package:ai_prg/src/features/chat/application/chat_controller.dart';
import 'package:ai_prg/src/features/chat/widgets/overlay_choice_stack.dart';
import 'package:ai_prg/src/features/chat/widgets/portrait_image.dart';
import 'package:ai_prg/src/features/chat/widgets/state_change_overlay_stack.dart';
import 'package:ai_prg/src/features/home/presentation/home_screen.dart';
import 'package:ai_prg/src/features/settings/presentation/settings_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
  late final FocusNode _composerFocusNode;
  final ScrollController _scrollController = ScrollController();

  bool _didTriggerIntro = false;

  @override
  void initState() {
    super.initState();
    _composerFocusNode = FocusNode(onKeyEvent: _onComposerFocusKeyEvent);
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
    _composerFocusNode.dispose();
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
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (campaign == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(l10n.campaignNotFound)),
        body: Center(child: Text(l10n.campaignOpenFailed)),
      );
    }

    final bool wide = responsive.isWide;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      appBar: responsive.isPhoneSmall
          ? null
          : AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    campaign.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: AetherPalette.textPrimary,
                    ),
                  ),
                  Text(
                    l10n.settingLabel(campaign.setting),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AetherPalette.textDim,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AetherPalette.panelBorderSolid,
                ),
              ),
              leading: wide
                  ? null
                  : _ChatChromeIconButton(
                      icon: Icons.menu_rounded,
                      tooltip: l10n.campaignInfo,
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
              actions: <Widget>[
                _ChatChromeIconButton(
                  icon: Icons.bookmark_add_outlined,
                  tooltip: l10n.saveTooltip,
                  onPressed: () => controller.save(l10n: l10n),
                ),
                _ChatChromeIconButton(
                  icon: Icons.tune_rounded,
                  tooltip: l10n.aiSettings,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (final context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                _ChatChromeIconButton(
                  icon: Icons.home_outlined,
                  tooltip: l10n.exitToMainMenu,
                  onPressed: _exitToMainMenu,
                ),
              ],
            ),
      drawer: wide || responsive.isPhoneSmall
          ? null
          : Drawer(
              backgroundColor: Colors.transparent,
              width: responsive.width * 0.84,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: AetherPalette.appWindowBackdrop,
                ),
                child: SafeArea(
                  child: _buildSidebar(
                    campaign: campaign,
                    highlightedModules: chatState.highlightedModules,
                    newlyUnlockedModules: chatState.newlyUnlockedModules,
                    worldRumors: chatState.worldRumors,
                  ),
                ),
              ),
            ),
      body: Padding(
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
                        worldRumors: chatState.worldRumors,
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
                            worldRumors: chatState.worldRumors,
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
                                ? AetherPalette.accent.withValues(alpha: 0.10)
                                : isSystem
                                ? AetherPalette.panelSoft.withValues(
                                    alpha: 0.95,
                                  )
                                : isPendingNarrator
                                ? AetherPalette.backgroundElevated.withValues(
                                    alpha: 0.98,
                                  )
                                : AetherPalette.backgroundElevated.withValues(
                                    alpha: 0.96,
                                  ),
                            borderRadius: BorderRadius.circular(
                              isNarrow ? 14 : 16,
                            ),
                            border: Border.all(
                              color: isPlayer
                                  ? AetherPalette.accent.withValues(alpha: 0.32)
                                  : isPendingNarrator
                                  ? AetherPalette.accent.withValues(alpha: 0.22)
                                  : AetherPalette.panelBorderSolid,
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
                                            : isPlayer
                                            ? AetherPalette.accentHover
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
            color: AetherPalette.backgroundElevated,
            borderRadius: BorderRadius.circular(isNarrow ? 12 : 14),
            border: Border.all(color: AetherPalette.panelBorderSolid),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? (compactMobileComposer ? 6 : 8) : 10,
            vertical: isNarrow ? (compactMobileComposer ? 3 : 5) : 6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 2,
                child: chatState.isSending
                    ? const LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AetherPalette.accent,
                        ),
                      )
                    : null,
              ),
              if (responsive.isPhoneSmall)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildChatComposerTextField(
                      controller: controller,
                      maxLines: compactMobileComposer ? 3 : 4,
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
                      child: _buildChatComposerTextField(
                        controller: controller,
                        maxLines: 4,
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

  Widget _buildChatComposerTextField({
    required final ChatController controller,
    required final int maxLines,
    required final InputDecoration decoration,
  }) => TextField(
    controller: _inputController,
    focusNode: _composerFocusNode,
    minLines: 1,
    maxLines: maxLines,
    textInputAction: TextInputAction.newline,
    onSubmitted: (_) =>
        _submitAction(controller: controller, action: _inputController.text),
    decoration: decoration,
  );

  KeyEventResult _onComposerFocusKeyEvent(
    final FocusNode node,
    final KeyEvent event,
  ) {
    if (!mounted) {
      return KeyEventResult.ignored;
    }
    final ChatController controller = ref.read(
      chatControllerProvider(widget.campaignId).notifier,
    );
    final ChatViewState chatState = ref.read(
      chatControllerProvider(widget.campaignId),
    );
    return _handleComposerKeyEvent(
      controller: controller,
      isSending: chatState.isSending,
      event: event,
    );
  }

  KeyEventResult _handleComposerKeyEvent({
    required final ChatController controller,
    required final bool isSending,
    required final KeyEvent event,
  }) {
    if (isSending) {
      return KeyEventResult.ignored;
    }
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final bool isPlainEnter =
        event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;
    if (!isPlainEnter) {
      return KeyEventResult.ignored;
    }
    if (HardwareKeyboard.instance.isShiftPressed) {
      return KeyEventResult.ignored;
    }
    _submitAction(controller: controller, action: _inputController.text);
    return KeyEventResult.handled;
  }

  Future<void> _showCompactCampaignSheet({
    required final CampaignState campaign,
    required final List<CampaignModule> highlightedModules,
    required final List<CampaignModule> newlyUnlockedModules,
    required final List<SymmetryWorldRumor> worldRumors,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (final context) => FractionallySizedBox(
      heightFactor: 0.86,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AetherPalette.appWindowBackdrop,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(context.responsive.pagePadding),
            child: _buildSidebar(
              campaign: campaign,
              highlightedModules: highlightedModules,
              newlyUnlockedModules: newlyUnlockedModules,
              worldRumors: worldRumors,
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
    required final List<SymmetryWorldRumor> worldRumors,
  }) {
    final CharacterStats character = campaign.character;
    final AppLocalizations l10n = context.l10n;
    final AppResponsiveData responsive = context.responsive;
    final bool showVitality =
        campaign.isModuleActive(CampaignModule.vitality) &&
        (character.maxHp > 0 ||
            character.maxEnergy > 0 ||
            character.might > 0 ||
            character.wit > 0 ||
            character.spirit > 0);
    final List<SymmetryWorldRumor> latestWorldRumors =
        List<SymmetryWorldRumor>.from(worldRumors)
          ..sort((final a, final b) => b.createdAt.compareTo(a.createdAt));
    final List<RecentTurnSummary> latestRecentTurns =
        List<RecentTurnSummary>.from(
          campaign.recentTurns.reversed,
        ).take(5).toList();
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
          if (campaign.hasDisplayObjective) ...<Widget>[
            _SidebarInfoLine(
              label: l10n.objective,
              value: campaign.displayObjectiveLine,
            ),
            SizedBox(height: responsive.isCompact ? 8 : 6),
          ],
          SizedBox(height: responsive.sectionSpacing),
          if (showVitality) ...<Widget>[
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
            l10n.worldRumorsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (latestWorldRumors.isEmpty)
            Text(l10n.worldRumorsEmpty)
          else
            for (final SymmetryWorldRumor item in latestWorldRumors.take(5))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('- ${item.eventText}'),
                    if ((item.locationTitle ?? '').trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item.locationTitle!.trim(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AetherPalette.textDim),
                        ),
                      ),
                  ],
                ),
              ),
          const SizedBox(height: 16),
          Text(
            l10n.recentEventsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final RecentTurnSummary item in latestRecentTurns)
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

    final bool pendingPlayerAdded =
        previous.pendingPlayerMessage == null &&
        next.pendingPlayerMessage != null;
    final bool initialMessagesLoaded =
        previous.campaign == null &&
        next.campaign != null &&
        next.visibleMessages.isNotEmpty;

    if (pendingPlayerAdded || initialMessagesLoaded) {
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

class _ChatChromeIconButton extends StatefulWidget {
  const _ChatChromeIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  State<_ChatChromeIconButton> createState() => _ChatChromeIconButtonState();
}

class _ChatChromeIconButtonState extends State<_ChatChromeIconButton> {
  bool _hover = false;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 2),
    child: Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _hover
                      ? AetherPalette.accent.withValues(alpha: 0.35)
                      : AetherPalette.panelBorderSolid,
                ),
                color: AetherPalette.backgroundElevated,
              ),
              child: Icon(
                widget.icon,
                size: 18,
                color: _hover
                    ? AetherPalette.accentHover
                    : AetherPalette.textMuted,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _SidebarSectionTitle extends StatelessWidget {
  const _SidebarSectionTitle({required this.title});

  final String title;

  @override
  Widget build(final BuildContext context) => Text(
    title.toUpperCase(),
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      letterSpacing: 2.2,
      color: AetherPalette.textDim,
      fontWeight: FontWeight.w600,
      fontSize: 10,
    ),
  );
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
          color: AetherPalette.backgroundElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AetherPalette.panelBorderSolid),
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
        color: AetherPalette.backgroundElevated,
        borderRadius: BorderRadius.circular(responsive.isCompact ? 16 : 20),
        border: Border.all(color: AetherPalette.accent.withValues(alpha: 0.28)),
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
            color: AetherPalette.backgroundElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: switch (highlightState) {
                _ModuleHighlightState.newlyUnlocked =>
                  AetherPalette.accent.withValues(alpha: 0.75),
                _ModuleHighlightState.updated =>
                  AetherPalette.accentSoft.withValues(alpha: 0.78),
                _ModuleHighlightState.none => AetherPalette.panelBorderSolid,
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
      color: AetherPalette.panelSoft,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: AetherPalette.panelBorderSolid),
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
      CampaignSetting.cozyCrime =>
        'assets/images/portraits/detective_shadow.png',
      CampaignSetting.postApocalypse || CampaignSetting.nearFutureSciFi =>
        'assets/images/portraits/scifi_oracle.png',
      _ => 'assets/images/portraits/fantasy_guardian.png',
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

enum _ScrollMode { none, animate }

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
                : AetherPalette.narrativeText,
            fontSize: isNarrow ? 15 : 17,
            height: 1.75,
            fontWeight: FontWeight.w400,
          ),
          strutStyle: StrutStyle(
            fontSize: isNarrow ? 15 : 17,
            height: 1.75,
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
    // Убрали перезапуск анимации при обновлении текста.
    // Иначе при потоковой генерации (streaming) каждый новый токен
    // заставлял весь текст снова мигать (opacity 0) и прыгать (slide).
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final TextTheme themeText = Theme.of(context).textTheme;
    final TextStyle baseStyle =
        themeText.bodyLarge ?? themeText.bodyMedium ?? const TextStyle();
    final TextStyle style = baseStyle.copyWith(
      color: AetherPalette.narrativeText,
      fontSize: widget.isNarrow ? 15 : 17,
      height: 1.75,
      fontWeight: FontWeight.w400,
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
            fontSize: widget.isNarrow ? 15 : 17,
            height: 1.75,
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
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1100),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    if (kIsWeb) {
      return RepaintBoundary(
        child: SizedBox(
          width: 34,
          height: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List<Widget>.generate(3, (final int index) {
              return Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AetherPalette.accent.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ),
      );
    }
    return RepaintBoundary(
      child: SizedBox(
        width: 34,
        height:
            12, // Фиксируем высоту, чтобы не вызывать перерасчет layout списка каждый кадр
        child: AnimatedBuilder(
          animation: _controller!,
          builder: (final context, _) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List<Widget>.generate(3, (final index) {
              final double phase = _wrappedPhase(
                _controller!.value - (index * 0.16),
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
      ),
    );
  }

  double _wrappedPhase(final double value) {
    if (value >= 0) {
      return value % 1.0;
    }
    return 1.0 - ((-value) % 1.0);
  }
}
