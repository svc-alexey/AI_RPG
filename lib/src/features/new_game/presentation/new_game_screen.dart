import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/data/character_templates.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/features/chat/presentation/chat_screen.dart';
import 'package:ai_prg/src/features/new_game/application/new_game_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class NewGameScreen extends ConsumerStatefulWidget {
  const NewGameScreen({super.key});

  @override
  ConsumerState<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends ConsumerState<NewGameScreen> {
  final TextEditingController _heroController = TextEditingController();
  final TextEditingController _storyPromptController = TextEditingController();
  final TextEditingController _characterPromptController =
      TextEditingController();
  final TextEditingController _personalityController = TextEditingController();

  NewGameController get _controller =>
      ref.read(newGameControllerProvider.notifier);

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
    final ThemeData theme = Theme.of(context);
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
      NewGameWizardMode.modeSelection => _buildModeSelection(
          theme: theme,
          l10n: l10n,
          controller: controller,
        ),
      NewGameWizardMode.quickStart => _buildQuickStart(
          theme: theme,
          l10n: l10n,
          state: gameState,
          controller: controller,
        ),
      NewGameWizardMode.customSetup => _buildCustomSetup(
          theme: theme,
          l10n: l10n,
          state: gameState,
          controller: controller,
        ),
    };

    return Scaffold(
      appBar: gameState.mode == NewGameWizardMode.customSetup
          ? null
          : AppBar(title: Text(l10n.newCampaign)),
      body: AetherBackdrop(
        child: gameState.mode == NewGameWizardMode.customSetup
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
      ),
    );
  }

  Widget _buildModeSelection({
    required final ThemeData theme,
    required final AppLocalizations l10n,
    required final NewGameController controller,
  }) => ListView(
    children: <Widget>[
      Text(
        l10n.howToStart,
        style: theme.textTheme.headlineMedium,
        textAlign: TextAlign.center,
        maxLines: 3,
      ),
      SizedBox(height: context.responsive.blockSpacing + 8),
      _ModeCard(
        icon: Icons.flash_on_rounded,
        title: l10n.quickStart,
        subtitle: l10n.quickStartDesc,
        onTap: controller.setQuickStartMode,
      ),
      const SizedBox(height: 16),
      _ModeCard(
        icon: Icons.tune_rounded,
        title: l10n.customSetup,
        subtitle: l10n.customSetupDesc,
        onTap: controller.setCustomSetupMode,
      ),
    ],
  );

  Widget _buildQuickStart({
    required final ThemeData theme,
    required final AppLocalizations l10n,
    required final NewGameViewState state,
    required final NewGameController controller,
  }) => ListView(
    children: <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IconButton(
            onPressed: controller.setModeSelection,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Text(l10n.quickStart, style: theme.textTheme.headlineMedium),
          ),
        ],
      ),
      const SizedBox(height: 24),
      SizedBox(height: context.responsive.blockSpacing),
      Text(
        l10n.quickStartAiBlurb,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AetherPalette.textMuted,
        ),
      ),
      if (!state.aiConfigured) ...<Widget>[
        SizedBox(height: context.responsive.blockSpacing),
        Text(
          l10n.quickStartNeedsAi,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ],
      SizedBox(height: context.responsive.blockSpacing),
      TextField(
        controller: _heroController,
        onChanged: controller.setHeroName,
        decoration: InputDecoration(
          labelText: l10n.heroName,
          hintText: l10n.heroNameHint,
        ),
      ),
      SizedBox(height: context.responsive.blockSpacing),
      _SectionLabel(title: l10n.characterGenderTitle),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: CharacterGender.values
            .map(
              (final gender) => ChoiceChip(
                label: Text(l10n.characterGenderLabel(gender)),
                selected: state.gender == gender,
                onSelected: (_) => controller.setGender(gender),
              ),
            )
            .toList(),
      ),
      SizedBox(height: context.responsive.blockSpacing + 8),
      if (MediaQuery.of(context).viewInsets.bottom == 0)
        FilledButton(
          onPressed: state.isSaving ? null : _createQuickCampaign,
          child: state.isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.startAdventure),
        ),
    ],
  );

  Widget _buildCustomSetup({
    required final ThemeData theme,
    required final AppLocalizations l10n,
    required final NewGameViewState state,
    required final NewGameController controller,
  }) {
    final int stepCount = NewGameCustomSetupStep.values.length;
    final bool isLastStep = state.currentStep == NewGameCustomSetupStep.review;
    final VoidCallback onBack =
        state.currentStep == NewGameCustomSetupStep.foundation
        ? controller.setModeSelection
        : controller.previousStep;
    final bool primaryBusy = state.isSaving || state.isGenerating;

    void onPrimary() {
      if (isLastStep) {
        _createCampaign();
      } else {
        controller.nextStep();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            _WizardCircleIconButton(
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
        _WizardSegmentProgress(
          currentIndex: state.currentStep.index,
          segmentCount: stepCount,
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            l10n.stepXOfY(state.currentStep.index + 1, stepCount),
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
              NewGameCustomSetupStep.literaryGenre => _buildLiteraryGenreStep(
                theme: theme,
                l10n: l10n,
                state: state,
                controller: controller,
              ),
              NewGameCustomSetupStep.worldSetting => _buildWorldSettingStep(
                theme: theme,
                l10n: l10n,
                state: state,
                controller: controller,
              ),
              NewGameCustomSetupStep.foundation => _buildFoundationStep(
                l10n: l10n,
                state: state,
                controller: controller,
              ),
              NewGameCustomSetupStep.story => _buildStoryStep(
                l10n: l10n,
                theme: theme,
                state: state,
                controller: controller,
              ),
              NewGameCustomSetupStep.character => _buildCharacterStep(
                l10n: l10n,
                state: state,
                controller: controller,
              ),
              NewGameCustomSetupStep.review => _buildReviewStep(
                l10n: l10n,
                theme: theme,
                state: state,
              ),
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: Text(l10n.backButton),
                style: TextButton.styleFrom(
                  foregroundColor: AetherPalette.textMuted,
                ),
              ),
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

  Widget _buildLiteraryGenreStep({
    required final ThemeData theme,
    required final AppLocalizations l10n,
    required final NewGameViewState state,
    required final NewGameController controller,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Text(
              l10n.chooseGenreWizardTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: context.responsive.isCompact ? 24 : 28,
                fontWeight: FontWeight.w400,
                height: 1.15,
                color: AetherPalette.textPrimary,
              ),
            ),
          ),
          SizedBox(height: context.responsive.blockSpacing + 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: LiteraryGenre.values
                .map(
                  (item) => _GenreSelectPill(
                    label: l10n.literaryGenreLabel(item),
                    selected: state.literaryGenre == item,
                    onTap: () => controller.setLiteraryGenre(item),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: context.responsive.sectionSpacing + 6),
          Center(
            child: TextButton.icon(
              onPressed: controller.randomizeLiteraryGenre,
              icon: const Icon(
                Icons.shuffle_rounded,
                size: 20,
                color: AetherPalette.textMuted,
              ),
              label: Text(
                l10n.randomGenreButton,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AetherPalette.textMuted,
                ),
              ),
            ),
          ),
        ],
      );

  Widget _buildWorldSettingStep({
    required final ThemeData theme,
    required final AppLocalizations l10n,
    required final NewGameViewState state,
    required final NewGameController controller,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Text(
              l10n.chooseSettingWizardTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: context.responsive.isCompact ? 24 : 28,
                fontWeight: FontWeight.w400,
                height: 1.15,
                color: AetherPalette.textPrimary,
              ),
            ),
          ),
          SizedBox(height: context.responsive.blockSpacing + 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: CampaignSetting.values
                .map(
                  (item) => _GenreSelectPill(
                    label: l10n.settingLabel(item),
                    selected: state.setting == item,
                    onTap: () => controller.setSetting(item),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: context.responsive.sectionSpacing + 6),
          Center(
            child: TextButton.icon(
              onPressed: controller.randomizeSetting,
              icon: const Icon(
                Icons.shuffle_rounded,
                size: 20,
                color: AetherPalette.textMuted,
              ),
              label: Text(
                l10n.randomSettingButton,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AetherPalette.textMuted,
                ),
              ),
            ),
          ),
        ],
      );

  Widget _buildFoundationStep({
    required final AppLocalizations l10n,
    required final NewGameViewState state,
    required final NewGameController controller,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      _SectionLabel(title: l10n.storyModeTitle),
      const SizedBox(height: 12),
      DropdownButtonFormField<StoryMode>(
        initialValue: state.storyMode,
        decoration: InputDecoration(
          filled: true,
          fillColor: AetherPalette.panelSoft.withValues(alpha: 0.3),
        ),
        items: StoryMode.values
            .map(
              (final mode) => DropdownMenuItem(
                value: mode,
                child: Text(l10n.storyModeLabel(mode)),
              ),
            )
            .toList(),
        onChanged: (final value) {
          if (value != null) {
            controller.setStoryMode(value);
          }
        },
      ),
      SizedBox(height: context.responsive.blockSpacing),
      _SectionLabel(title: l10n.difficultyTitle),
      const SizedBox(height: 12),
      DropdownButtonFormField<DifficultyLevel>(
        initialValue: state.difficulty,
        decoration: InputDecoration(
          filled: true,
          fillColor: AetherPalette.panelSoft.withValues(alpha: 0.3),
        ),
        items: DifficultyLevel.values
            .map(
              (final diff) => DropdownMenuItem(
                value: diff,
                child: Text(l10n.difficultyLabel(diff)),
              ),
            )
            .toList(),
        onChanged: (final value) {
          if (value != null) {
            controller.setDifficulty(value);
          }
        },
      ),
      SizedBox(height: context.responsive.blockSpacing),
      TextField(
        controller: _heroController,
        onChanged: controller.setHeroName,
        decoration: InputDecoration(
          labelText: l10n.heroName,
          hintText: l10n.heroNameHint,
        ),
      ),
    ],
  );

  Widget _buildStoryStep({
    required final AppLocalizations l10n,
    required final ThemeData theme,
    required final NewGameViewState state,
    required final NewGameController controller,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      _SectionLabel(title: l10n.storyWishTitle),
      const SizedBox(height: 8),
      Text(
        l10n.storyPromptHelp,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AetherPalette.textMuted,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        l10n.storyWishOptional,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AetherPalette.textMuted,
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _storyPromptController,
        onChanged: controller.setStoryInput,
        maxLines: 6,
        decoration: InputDecoration(
          hintText: l10n.storyWishHint,
          alignLabelWithHint: true,
        ),
      ),
      const SizedBox(height: 12),
      if (!state.aiConfigured) ...<Widget>[
        const SizedBox(height: 12),
        Text(
          l10n.configureAiFirst,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AetherPalette.textMuted,
          ),
        ),
      ],
      const SizedBox(height: 12),
      Text(
        l10n.portraitAutoGenerateHint,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AetherPalette.textMuted,
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: <Widget>[
          FilledButton(
            onPressed: state.aiConfigured && !state.isGenerating
                ? _generatePrompts
                : null,
            child: state.isGenerating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.generatePrompts),
          ),
          if (state.isGenerating)
            OutlinedButton(
              onPressed: controller.cancelGeneration,
              child: Text(l10n.cancel),
            ),
        ],
      ),
    ],
  );

  Widget _buildCharacterStep({
    required final AppLocalizations l10n,
    required final NewGameViewState state,
    required final NewGameController controller,
  }) {
    final CharacterProfile profile = controller.effectiveCharacterProfile();
    final List<CharacterClass> classes = classesBySetting[state.setting]!;
    final List<String> races =
        racesBySetting[state.setting] ?? <String>['human'];
    final bool showClass = settingUsesCharacterClass(state.setting);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionLabel(title: l10n.characterSectionTitle),
        const SizedBox(height: 8),
        Text(
          l10n.characterOptional,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AetherPalette.textMuted),
        ),
        SizedBox(height: context.responsive.sectionSpacing),
        if (showClass) ...<Widget>[
          DropdownButtonFormField<CharacterClass>(
            initialValue: classes.contains(profile.characterClass)
                ? profile.characterClass
                : classes.first,
            decoration: InputDecoration(
              labelText: l10n.characterClassTitle,
              filled: true,
              fillColor: AetherPalette.panelSoft.withValues(alpha: 0.3),
            ),
            items: classes
                .map(
                  (final item) => DropdownMenuItem(
                    value: item,
                    child: Text(l10n.characterClassLabel(item)),
                  ),
                )
                .toList(),
            onChanged: (final value) {
              if (value != null) {
                controller.setCharacterClass(value);
              }
            },
          ),
          SizedBox(height: context.responsive.sectionSpacing),
        ],
        DropdownButtonFormField<String>(
          initialValue: profile.race.isEmpty || !races.contains(profile.race)
              ? races.first
              : profile.race,
          decoration: InputDecoration(
            labelText: l10n.characterRaceTitle,
            filled: true,
            fillColor: AetherPalette.panelSoft.withValues(alpha: 0.3),
          ),
          items: races
              .map(
                (final race) => DropdownMenuItem(
                  value: race,
                  child: Text(l10n.raceLabel(race, state.setting)),
                ),
              )
              .toList(),
          onChanged: (final value) {
            if (value != null) {
              controller.setRace(value);
            }
          },
        ),
        SizedBox(height: context.responsive.sectionSpacing),
        DropdownButtonFormField<CharacterGender>(
          initialValue: profile.gender,
          decoration: InputDecoration(
            labelText: l10n.characterGenderTitle,
            filled: true,
            fillColor: AetherPalette.panelSoft.withValues(alpha: 0.3),
          ),
          items: CharacterGender.values
              .map(
                (final gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(l10n.characterGenderLabel(gender)),
                ),
              )
              .toList(),
          onChanged: (final value) {
            if (value != null) {
              controller.setGender(value);
            }
          },
        ),
        SizedBox(height: context.responsive.sectionSpacing),
        TextField(
          controller: _personalityController,
          onChanged: controller.setPersonality,
          decoration: InputDecoration(
            labelText: l10n.characterPersonalityTitle,
          ),
        ),
        SizedBox(height: context.responsive.sectionSpacing),
        OutlinedButton.icon(
          onPressed: controller.randomizeCharacter,
          icon: const Icon(Icons.shuffle_rounded, size: 18),
          label: Text(l10n.randomCharacter),
        ),
        SizedBox(height: context.responsive.sectionSpacing),
        Text(
          l10n.characterPromptHelp,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AetherPalette.textMuted),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _characterPromptController,
          onChanged: controller.setCharacterPrompt,
          maxLines: 3,
          decoration: InputDecoration(labelText: l10n.editCharacterPrompt),
        ),
      ],
    );
  }

  Widget _buildReviewStep({
    required final AppLocalizations l10n,
    required final ThemeData theme,
    required final NewGameViewState state,
  }) {
    final CharacterProfile? profile = state.characterProfile;
    final List<CampaignModuleState> plannedModules = state.plannedModules;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionLabel(title: l10n.reviewTitle),
        SizedBox(height: context.responsive.sectionSpacing),
        AetherCard(
          padding: EdgeInsets.all(context.responsive.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _ReviewItem(
                label: l10n.literaryGenreTitle,
                value: l10n.literaryGenreLabel(state.literaryGenre),
                icon: Icons.menu_book_outlined,
              ),
              const SizedBox(height: 12),
              _ReviewItem(
                label: l10n.settingTitle,
                value: l10n.settingLabel(state.setting),
                icon: Icons.public_rounded,
              ),
              const SizedBox(height: 12),
              _ReviewItem(
                label: l10n.storyModeTitle,
                value: l10n.storyModeLabel(state.storyMode),
                icon: Icons.menu_book_outlined,
              ),
              const SizedBox(height: 12),
              _ReviewItem(
                label: l10n.difficultyTitle,
                value: l10n.difficultyLabel(state.difficulty),
                icon: Icons.show_chart_rounded,
              ),
              const SizedBox(height: 12),
              _ReviewItem(
                label: l10n.heroName,
                value: state.heroName.trim().isEmpty
                    ? l10n.heroNameHint
                    : state.heroName.trim(),
                icon: Icons.person_outline_rounded,
              ),
              if (state.customStoryPrompt.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                _ReviewItem(
                  label: l10n.customStoryPromptTitle,
                  value: state.customStoryPrompt.trim().length > 100
                      ? '${state.customStoryPrompt.trim().substring(0, 100)}...'
                      : state.customStoryPrompt.trim(),
                  icon: Icons.edit_note_rounded,
                ),
              ],
              if (profile != null) ...<Widget>[
                const SizedBox(height: 12),
                _ReviewItem(
                  label: l10n.characterSectionTitle,
                  value: () {
                    final List<String> bits = <String>[
                      if (profile.characterClass != CharacterClass.unspecified)
                        l10n.characterClassLabel(profile.characterClass),
                      l10n.raceLabel(profile.race, state.setting),
                      l10n.characterGenderLabel(profile.gender),
                    ];
                    return bits.join(' • ');
                  }(),
                  icon: Icons.badge_outlined,
                ),
              ],
              if (plannedModules.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                _ReviewItem(
                  label: l10n.activeSystemsTitle,
                  value: plannedModules
                      .map(
                        (final item) => l10n.campaignModuleLabel(item.module),
                      )
                      .join(' • '),
                  icon: Icons.widgets_outlined,
                ),
              ],
            ],
          ),
        ),
        if (plannedModules.isNotEmpty) ...<Widget>[
          SizedBox(height: context.responsive.sectionSpacing),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: plannedModules
                .map(
                  (final item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Chip(
                          label: Text(l10n.campaignModuleLabel(item.module)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              l10n.campaignModuleReasonLabel(
                                item.activationReason,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AetherPalette.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
        SizedBox(height: context.responsive.blockSpacing),
        Text(
          l10n.readyToStart,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AetherPalette.textMuted,
          ),
        ),
      ],
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
      final String message = e is StateError && e.message == 'ai_not_configured'
          ? l10n.quickStartNeedsAi
          : l10n.promptGenerationFailed;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
      final String message = e is StateError && e.message == 'story_prompt_required'
          ? l10n.storyPromptRequired
          : l10n.promptGenerationFailed;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(final BuildContext context) => Text(
    title.toUpperCase(),
    style: Theme.of(context).textTheme.labelLarge?.copyWith(
      color: AetherPalette.textMuted,
      letterSpacing: context.responsive.scaleLetterSpacing(2),
    ),
  );
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => AetherCard(
    padding: EdgeInsets.all(context.responsive.cardPadding),
    child: SizedBox(
      width: double.infinity,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: context.responsive.isCompact ? 82 : 100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                icon,
                color: AetherPalette.accent,
                size: context.responsive.isCompact ? 28 : 32,
              ),
              SizedBox(height: context.responsive.sectionSpacing),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AetherPalette.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Горизонтальные сегменты прогресса (как в макете «Создание мира»).
class _WizardSegmentProgress extends StatelessWidget {
  const _WizardSegmentProgress({
    required this.currentIndex,
    required this.segmentCount,
  });

  final int currentIndex;
  final int segmentCount;

  @override
  Widget build(final BuildContext context) => Row(
        children: List<Widget>.generate(segmentCount, (index) {
          final bool filled = index <= currentIndex;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == segmentCount - 1 ? 0 : 6,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: filled
                      ? AetherPalette.accent
                      : AetherPalette.panelSoft,
                ),
              ),
            ),
          );
        }),
      );
}

class _WizardCircleIconButton extends StatelessWidget {
  const _WizardCircleIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(final BuildContext context) {
    final Widget child = Material(
      color: AetherPalette.backgroundElevated,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            size: 22,
            color: AetherPalette.textPrimary,
          ),
        ),
      ),
    );
    if (tooltip == null) {
      return child;
    }
    return Tooltip(message: tooltip!, child: child);
  }
}

class _GenreSelectPill extends StatelessWidget {
  const _GenreSelectPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AetherPalette.backgroundElevated.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? AetherPalette.accent
                    : AetherPalette.panelBorderSolid,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (selected) ...<Widget>[
                  const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AetherPalette.accent,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: selected
                            ? AetherPalette.textPrimary
                            : AetherPalette.textMuted,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(final BuildContext context) {
    final AppResponsiveData responsive = context.responsive;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 18, color: AetherPalette.textMuted),
        SizedBox(width: responsive.isCompact ? 10 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AetherPalette.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
