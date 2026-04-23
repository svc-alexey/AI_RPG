import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/features/new_game/application/new_game_controller.dart';
import 'package:ai_prg/src/features/new_game/presentation/widgets/custom_setup_steps.dart';
import 'package:ai_prg/src/features/new_game/presentation/widgets/new_game_helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSetupView extends StatelessWidget {
  const CustomSetupView({
    required this.state,
    required this.controller,
    required this.heroController,
    required this.storyPromptController,
    required this.characterPromptController,
    required this.personalityController,
    required this.onCreateCampaign,
    required this.onGeneratePrompts,
    super.key,
  });

  final NewGameViewState state;
  final NewGameController controller;
  final TextEditingController heroController;
  final TextEditingController storyPromptController;
  final TextEditingController characterPromptController;
  final TextEditingController personalityController;
  final VoidCallback onCreateCampaign;
  final VoidCallback onGeneratePrompts;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;

    final List<NewGameCustomSetupStep> visibleSteps =
        state.storyTemplateSeed == null
        ? NewGameCustomSetupStep.values
        : NewGameCustomSetupStep.values
              .where(
                (final step) =>
                    step != NewGameCustomSetupStep.literaryGenre &&
                    step != NewGameCustomSetupStep.worldSetting,
              )
              .toList();
    final int stepCount = visibleSteps.length;
    final int currentStepIndex = visibleSteps.indexOf(state.currentStep);
    final bool isFirstStep = currentStepIndex <= 0;
    final bool isLastStep = state.currentStep == NewGameCustomSetupStep.review;
    final VoidCallback onBack = isFirstStep
        ? state.storyTemplateSeed == null
              ? controller.setModeSelection
              : controller.setStoryLengthSelection
        : controller.previousStep;
    final bool primaryBusy = state.isSaving || state.isGenerating;

    void onPrimary() {
      if (isLastStep) {
        onCreateCampaign();
      } else {
        controller.nextStep();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            WizardCircleIconButton(
              tooltip: l10n.backButton,
              icon: Icons.arrow_back_rounded,
              onPressed: onBack,
            ),
            Expanded(
              child: Text(
                l10n.worldCreationTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: context.responsive.isCompact ? 20 : 24,
                  fontWeight: FontWeight.w400,
                  color: AetherPalette.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 44),
          ],
        ),
        SizedBox(height: context.responsive.sectionSpacing + 4),
        WizardSegmentProgress(
          currentIndex: currentStepIndex < 0 ? 0 : currentStepIndex,
          segmentCount: stepCount,
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            l10n.stepXOfY(
              (currentStepIndex < 0 ? 0 : currentStepIndex) + 1,
              stepCount,
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AetherPalette.textDim,
              fontSize: 12,
              letterSpacing: 0.2,
            ),
          ),
        ),
        SizedBox(height: context.responsive.blockSpacing),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 12),
            child: switch (state.currentStep) {
              NewGameCustomSetupStep.literaryGenre => LiteraryGenreStep(
                state: state,
                controller: controller,
              ),
              NewGameCustomSetupStep.worldSetting => WorldSettingStep(
                state: state,
                controller: controller,
              ),
              NewGameCustomSetupStep.foundation => FoundationStep(
                state: state,
                controller: controller,
                heroController: heroController,
              ),
              NewGameCustomSetupStep.character => CharacterStep(
                state: state,
                controller: controller,
                personalityController: personalityController,
                characterPromptController: characterPromptController,
              ),
              NewGameCustomSetupStep.story => StoryStep(
                state: state,
                controller: controller,
                storyPromptController: storyPromptController,
                onGeneratePrompts: onGeneratePrompts,
              ),
              NewGameCustomSetupStep.review => ReviewStep(state: state),
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: Row(
            children: <Widget>[
              if (!isFirstStep)
                TextButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: Text(l10n.backButton),
                  style: TextButton.styleFrom(
                    foregroundColor: AetherPalette.textMuted,
                  ),
                ),
              const Spacer(),
              FilledButton(
                onPressed: primaryBusy ? null : onPrimary,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 14,
                  ),
                  shape: const StadiumBorder(),
                ),
                child: state.isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AetherPalette.background,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            isLastStep
                                ? l10n.createCampaignButton
                                : l10n.nextButton,
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            isLastStep
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
