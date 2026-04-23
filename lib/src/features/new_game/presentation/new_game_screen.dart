import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/features/chat/presentation/chat_screen.dart';
import 'package:ai_prg/src/features/new_game/application/new_game_controller.dart';
import 'package:ai_prg/src/features/new_game/presentation/widgets/custom_setup_view.dart';
import 'package:ai_prg/src/features/new_game/presentation/widgets/mode_selection_view.dart';
import 'package:ai_prg/src/features/new_game/presentation/widgets/quick_start_view.dart';
import 'package:ai_prg/src/features/new_game/presentation/widgets/story_template_length_selection_view.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewGameScreen extends ConsumerStatefulWidget {
  const NewGameScreen({super.key, this.storyTemplateId});

  /// When set, loads the template from Symmetry and prefills the library flow.
  final String? storyTemplateId;

  @override
  ConsumerState<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends ConsumerState<NewGameScreen> {
  bool _didApplyStoryTemplate = false;
  final TextEditingController _heroController = TextEditingController();
  final TextEditingController _storyPromptController = TextEditingController();
  final TextEditingController _characterPromptController =
      TextEditingController();
  final TextEditingController _personalityController = TextEditingController();

  NewGameController get _controller =>
      ref.read(newGameControllerProvider.notifier);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String? id = widget.storyTemplateId;
    if (id == null || id.trim().isEmpty || _didApplyStoryTemplate) {
      return;
    }
    _didApplyStoryTemplate = true;
    final String templateId = id.trim();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final template = await ref
            .read(storyLibraryRepositoryProvider)
            .loadTemplate(templateId);
        if (!mounted) {
          return;
        }
        ref
            .read(newGameControllerProvider.notifier)
            .applyStoryTemplate(template);
      } catch (_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(context.l10n.storyLibraryLoadFailed)),
          );
      }
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _storyPromptController.dispose();
    _characterPromptController.dispose();
    _personalityController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppResponsiveData responsive = context.responsive;
    final NewGameViewState gameState = ref.watch(newGameControllerProvider);
    final NewGameController controller = ref.read(
      newGameControllerProvider.notifier,
    );

    ref.listen<NewGameViewState>(newGameControllerProvider, (
      final previous,
      final next,
    ) {
      if (next.formRevision != (previous?.formRevision ?? 0)) {
        _heroController.text = next.heroName;
        _storyPromptController.text = next.customStoryPrompt.trim().isEmpty
            ? next.storyWish
            : next.customStoryPrompt;
        _characterPromptController.text = next.characterPrompt;
        _personalityController.text = next.personality;
      }
    });

    final Widget modeChild = switch (gameState.mode) {
      NewGameWizardMode.modeSelection => ModeSelectionView(
        controller: controller,
      ),
      NewGameWizardMode.storyLengthSelection =>
        StoryTemplateLengthSelectionView(
          state: gameState,
          controller: controller,
        ),
      NewGameWizardMode.quickStart => QuickStartView(
        state: gameState,
        controller: controller,
        heroController: _heroController,
        onCreateQuickCampaign: _createQuickCampaign,
      ),
      NewGameWizardMode.customSetup => CustomSetupView(
        state: gameState,
        controller: controller,
        heroController: _heroController,
        storyPromptController: _storyPromptController,
        characterPromptController: _characterPromptController,
        personalityController: _personalityController,
        onCreateCampaign: _createCampaign,
        onGeneratePrompts: _generatePrompts,
      ),
    };

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: gameState.mode == NewGameWizardMode.customSetup
          ? null
          : AppBar(title: Text(l10n.newCampaign)),
      body: gameState.mode == NewGameWizardMode.customSetup
            ? SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: responsive.isWide ? 820 : double.infinity,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.pagePadding,
                      ),
                      child: AetherPageReveal(child: modeChild),
                    ),
                  ),
                ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: responsive.dialogMaxWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(responsive.pagePadding),
                    child: AetherPageReveal(child: modeChild),
                  ),
                ),
              ),
    );
  }

  Future<void> _generatePrompts() async {
    await _controller.generatePrompts();
  }

  Future<void> _createQuickCampaign() async {
    try {
      final CampaignState campaign = await _controller.createQuickCampaign();
      if (!mounted) {
        return;
      }
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (final context) => ChatScreen(campaignId: campaign.id),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      final AppLocalizations l10n = context.l10n;
      final String message = l10n.symmetryFriendlyError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: kIsWeb
              ? const Duration(seconds: 8)
              : const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _createCampaign() async {
    try {
      final CampaignState campaign = await _controller.createCampaign();
      if (!mounted) {
        return;
      }
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (final context) => ChatScreen(campaignId: campaign.id),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      final AppLocalizations l10n = context.l10n;
      final String message =
          e is StateError && e.message == 'story_prompt_required'
          ? l10n.storyPromptRequired
          : l10n.symmetryFriendlyError(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
