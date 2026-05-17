import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/services/app_logger.dart';
import 'package:ai_prg/src/features/auth/presentation/auth_screen.dart';
import 'package:ai_prg/src/features/billing/presentation/billing_screen.dart';
import 'package:ai_prg/src/features/chat/application/chat_controller.dart';
import 'package:ai_prg/src/features/chat/presentation/widgets/chat_app_bar.dart';
import 'package:ai_prg/src/features/chat/presentation/widgets/chat_body.dart';
import 'package:ai_prg/src/features/chat/presentation/widgets/chat_composer.dart';
import 'package:ai_prg/src/features/chat/presentation/widgets/chat_sidebar.dart';
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
  late final FocusNode _composerFocusNode;
  final ScrollController _scrollController = ScrollController();

  bool _didTriggerIntro = false;

  @override
  void initState() {
    super.initState();
    _composerFocusNode = FocusNode();
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      FocusManager.instance.primaryFocus?.unfocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(animated: false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final responsive = context.responsive;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final chatState = ref.watch(chatControllerProvider(widget.campaignId));
    final controller = ref.read(chatControllerProvider(widget.campaignId).notifier);

    ref.listen<ChatViewState>(chatControllerProvider(widget.campaignId), (
      previous,
      next,
    ) {
      if (next.clearInputRevision != (previous?.clearInputRevision ?? 0)) {
        _inputController.clear();
      }

      final scrollMode = _resolveScrollMode(previous, next);
      if (scrollMode != _ScrollMode.none) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToBottom(animated: scrollMode == _ScrollMode.animate),
        );
      }

      final nextStatus = next.status;
      if (nextStatus != null &&
          nextStatus != previous?.status &&
          !_isPassiveTurnStatus(nextStatus, l10n)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
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

    ref.listen<String?>(lowEssenceWarningProvider, (final previous, final next) {
      if (next != null && next != previous) {
        WidgetsBinding.instance.addPostFrameCallback((final _) {
          if (!mounted) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(l10n.chatLowEssenceWarning(int.tryParse(next ?? '0') ?? 0)),
                backgroundColor: const Color(0xFFBFA76F).withAlpha(220),
                duration: const Duration(seconds: 6),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
        });
      }
    });

    ref.listen<String?>(paymentRequiredProvider, (final previous, final next) {
      if (next != null && next != previous) {
        WidgetsBinding.instance.addPostFrameCallback((final _) {
          if (!mounted) return;
          if (next.startsWith('guest_register:')) {
            final l10n = context.l10n;
            showDialog<void>(
              context: context,
              builder: (final ctx) => AlertDialog(
                backgroundColor: const Color(0xFF0F0D0B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC87941).withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.token, size: 32, color: Color(0xFFC87941)),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.billingGuestRegisterTitle,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, fontFamily: 'Playfair Display', color: Color(0xFFE8E4E0)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.billingGuestRegisterBody,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF7A7570), fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).push<bool>(
                            MaterialPageRoute<bool>(
                              builder: (final routeContext) => AuthScreen(
                                onAuthenticated: () => Navigator.of(routeContext).pop(true),
                              ),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFC87941),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(l10n.billingGuestRegisterAction, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(l10n.billingNotNowAction, style: const TextStyle(color: Color(0xFF7A7570))),
                    ),
                  ],
                ),
              ),
            );
          } else {
            showPaywallOverlay(context, campaignName: next);
          }
          ref.read(paymentRequiredProvider.notifier).state = null;
        });
      }
    });

    final campaign = chatState.campaign;
    if (chatState.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (campaign == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(l10n.campaignNotFound)),
        body: Center(child: Text(l10n.campaignOpenFailed)),
      );
    }

    final wide = responsive.isWide;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      appBar: responsive.isPhoneSmall
          ? null
          : ChatAppBar(
              campaignId: widget.campaignId,
              wide: wide,
              scaffoldKey: _scaffoldKey,
              onMenu: wide
                  ? null
                  : () => _scaffoldKey.currentState?.openDrawer(),
              onHome: _exitToMainMenu,
              onSave: () => controller.save(l10n: l10n),
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
                  child: ChatSidebar(
                    campaignId: widget.campaignId,
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
                      builder: (_) => const SettingsScreen(),
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
                          child: ChatSidebar(
                            campaignId: widget.campaignId,
                            campaign: campaign,
                            highlightedModules: chatState.highlightedModules,
                            newlyUnlockedModules: chatState.newlyUnlockedModules,
                            worldRumors: chatState.worldRumors,
                          ),
                        ),
                        SizedBox(width: responsive.sectionSpacing + 4),
                        Expanded(
                          child: _buildChatArea(
                            keyboardVisible: keyboardVisible,
                          ),
                        ),
                      ],
                    )
                  : _buildChatArea(keyboardVisible: keyboardVisible),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatArea({required bool keyboardVisible}) => Column(
    children: <Widget>[
      Expanded(
        child: ChatBody(
          campaignId: widget.campaignId,
          scrollController: _scrollController,
          onChoiceSelected: (choice) => _submitAction(action: choice),
        ),
      ),
      SizedBox(
        height: keyboardVisible &&
                context.responsive.isPhoneSmall
            ? 8
            : context.responsive.sectionSpacing,
      ),
      ChatComposer(
        campaignId: widget.campaignId,
        inputController: _inputController,
        composerFocusNode: _composerFocusNode,
        onSubmit: () => _submitAction(action: _inputController.text),
      ),
    ],
  );

  Future<void> _showCompactCampaignSheet({
    required CampaignState campaign,
    required List<CampaignModule> highlightedModules,
    required List<CampaignModule> newlyUnlockedModules,
    required List<SymmetryWorldRumor> worldRumors,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.86,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AetherPalette.appWindowBackdrop,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(context.responsive.pagePadding),
            child: ChatSidebar(
              campaignId: widget.campaignId,
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

  void _exitToMainMenu() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  void _submitAction({required String action}) {
    if (!mounted) return;
    FocusManager.instance.primaryFocus?.unfocus();
    ref.read(chatControllerProvider(widget.campaignId).notifier).runTurn(
      l10n: context.l10n,
      action: action,
      suggestionsOnly: false,
    );
  }

  bool _isPassiveTurnStatus(String status, AppLocalizations l10n) =>
      <String>{
        l10n.turnCompleted(true),
        l10n.turnCompleted(false),
        l10n.suggestionsUpdated(true),
        l10n.suggestionsUpdated(false),
      }.contains(status);

  _ScrollMode _resolveScrollMode(ChatViewState? previous, ChatViewState next) {
    if (previous == null) {
      return next.isLoading ? _ScrollMode.none : _ScrollMode.animate;
    }
    final pendingPlayerAdded =
        previous.pendingPlayerMessage == null &&
        next.pendingPlayerMessage != null;
    final initialMessagesLoaded =
        previous.campaign == null &&
        next.campaign != null &&
        next.visibleMessages.isNotEmpty;
    if (pendingPlayerAdded || initialMessagesLoaded) {
      return _ScrollMode.animate;
    }
    return _ScrollMode.none;
  }

  void _scrollToBottom({required bool animated}) {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        final offset = _scrollController.position.maxScrollExtent;
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
  Widget build(BuildContext context) => AetherCard(
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
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AetherPalette.backgroundElevated,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AetherPalette.panelBorderSolid),
        ),
        child: Icon(icon, size: 20),
      ),
    ),
  );
}

enum _ScrollMode { none, animate }
