import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/core/data/character_templates.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/features/chat/presentation/chat_screen.dart';
import 'package:ai_prg/src/features/new_game/application/new_game_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewGameScreen extends ConsumerStatefulWidget {
  const NewGameScreen({super.key});

  @override
  ConsumerState<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends ConsumerState<NewGameScreen> {
  final TextEditingController _heroController = TextEditingController();
  final TextEditingController _storyWishController = TextEditingController();
  final TextEditingController _customStoryController = TextEditingController();
  final TextEditingController _characterPromptController =
      TextEditingController();
  final TextEditingController _personalityController = TextEditingController();

  NewGameController get _controller =>
      ref.read(newGameControllerProvider.notifier);

  @override
  void dispose() {
    _heroController.dispose();
    _storyWishController.dispose();
    _customStoryController.dispose();
    _characterPromptController.dispose();
    _personalityController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
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
        _storyWishController.text = next.storyWish;
        _customStoryController.text = next.customStoryPrompt;
        _characterPromptController.text = next.characterPrompt;
        _personalityController.text = next.personality;
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newCampaign)),
      body: AetherBackdrop(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AetherPageReveal(
                child: switch (gameState.mode) {
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
                },
              ),
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
      ),
      const SizedBox(height: 32),
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
      _SectionLabel(title: l10n.settingTitle),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: CampaignSetting.values
            .map(
              (final item) => ChoiceChip(
                label: Text(l10n.settingLabel(item)),
                selected: state.setting == item,
                onSelected: (_) => controller.setSetting(item),
                avatar: Icon(switch (item) {
                  CampaignSetting.fantasy => Icons.auto_awesome_rounded,
                  CampaignSetting.detective => Icons.search_rounded,
                  CampaignSetting.sciFi => Icons.rocket_launch_outlined,
                }, size: 18),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 24),
      TextField(
        controller: _heroController,
        onChanged: controller.setHeroName,
        decoration: InputDecoration(
          labelText: l10n.heroName,
          hintText: l10n.heroNameHint,
        ),
      ),
      const SizedBox(height: 24),
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
      const SizedBox(height: 32),
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
  }) => Column(
    children: <Widget>[
      Row(
        children: <Widget>[
          IconButton(
            onPressed: state.currentStep == NewGameCustomSetupStep.foundation
                ? controller.setModeSelection
                : null,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Text(
              l10n.customSetup,
              style: theme.textTheme.headlineMedium,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _StepIndicator(currentIndex: state.currentStep.index),
      const SizedBox(height: 8),
      Text(
        l10n.stepXOfY(state.currentStep.index + 1, 4),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AetherPalette.textMuted,
        ),
      ),
      const SizedBox(height: 24),
      Expanded(
        child: ListView(
          children: <Widget>[
            switch (state.currentStep) {
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
          ],
        ),
      ),
      const SizedBox(height: 16),
      _buildWizardNavigation(l10n: l10n, state: state, controller: controller),
    ],
  );

  Widget _buildFoundationStep({
    required final AppLocalizations l10n,
    required final NewGameViewState state,
    required final NewGameController controller,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      _SectionLabel(title: l10n.settingTitle),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: CampaignSetting.values
            .map(
              (final item) => ChoiceChip(
                label: Text(l10n.settingLabel(item)),
                selected: state.setting == item,
                onSelected: (_) => controller.setSetting(item),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 24),
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
      const SizedBox(height: 24),
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
      const SizedBox(height: 24),
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
        l10n.storyWishOptional,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AetherPalette.textMuted,
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _storyWishController,
        onChanged: controller.setStoryWish,
        maxLines: 3,
        decoration: InputDecoration(hintText: l10n.storyWishHint),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: <Widget>[
          OutlinedButton(
            onPressed: () {
              final String text = _storyWishController.text.trim();
              if (text.isNotEmpty) {
                _customStoryController.text = text;
                controller.setCustomStoryPrompt(text);
              }
            },
            child: Text(l10n.insertTextPrompt),
          ),
          FilledButton(
            onPressed:
                state.aiConfigured &&
                    !state.isGenerating &&
                    state.storyWish.trim().isNotEmpty
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
      if (!state.aiConfigured) ...<Widget>[
        const SizedBox(height: 12),
        Text(
          l10n.configureAiFirst,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AetherPalette.textMuted,
          ),
        ),
      ],
      const SizedBox(height: 24),
      _SectionLabel(title: l10n.customStoryPromptTitle),
      const SizedBox(height: 12),
      TextField(
        controller: _customStoryController,
        onChanged: controller.setCustomStoryPrompt,
        maxLines: 4,
        decoration: const InputDecoration(hintText: ''),
      ),
    ],
  );

  Widget _buildCharacterStep({
    required final AppLocalizations l10n,
    required final NewGameViewState state,
    required final NewGameController controller,
  }) {
    final CharacterProfile profile = controller.effectiveCharacterProfile();
    final List<CharacterClass> classes =
        classesBySetting[state.setting] ??
        <CharacterClass>[CharacterClass.warrior];
    final List<String> races =
        racesBySetting[state.setting] ?? <String>['human'];

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
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
        TextField(
          controller: _personalityController,
          onChanged: controller.setPersonality,
          decoration: InputDecoration(
            labelText: l10n.characterPersonalityTitle,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: controller.randomizeCharacter,
          icon: const Icon(Icons.shuffle_rounded, size: 18),
          label: Text(l10n.randomCharacter),
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
        AetherCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
                  value:
                      '${l10n.characterClassLabel(profile.characterClass)} • ${l10n.raceLabel(profile.race, state.setting)} • ${l10n.characterGenderLabel(profile.gender)}',
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
          const SizedBox(height: 16),
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
        const SizedBox(height: 24),
        Text(
          l10n.readyToStart,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AetherPalette.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildWizardNavigation({
    required final AppLocalizations l10n,
    required final NewGameViewState state,
    required final NewGameController controller,
  }) {
    final bool isLastStep = state.currentStep == NewGameCustomSetupStep.review;
    final bool canGoBack =
        state.currentStep != NewGameCustomSetupStep.foundation;
    if (MediaQuery.of(context).viewInsets.bottom > 0) {
      return const SizedBox.shrink();
    }

    return Row(
      children: <Widget>[
        if (canGoBack)
          OutlinedButton.icon(
            onPressed: controller.previousStep,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: Text(l10n.backButton),
          ),
        const Spacer(),
        FilledButton(
          onPressed: state.isSaving
              ? null
              : (isLastStep ? _createCampaign : controller.nextStep),
          child: state.isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      isLastStep ? l10n.createCampaignButton : l10n.nextButton,
                    ),
                    if (!isLastStep) ...<Widget>[
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _generatePrompts() async {
    await _controller.generatePrompts();
  }

  Future<void> _createQuickCampaign() async {
    final CampaignState campaign = await _controller.createQuickCampaign();
    if (!mounted) {
      return;
    }

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (final context) => ChatScreen(campaignId: campaign.id),
      ),
    );
  }

  Future<void> _createCampaign() async {
    final CampaignState campaign = await _controller.createCampaign();
    if (!mounted) {
      return;
    }

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (final context) => ChatScreen(campaignId: campaign.id),
      ),
    );
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
      letterSpacing: 2,
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
    child: SizedBox(
      width: double.infinity,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: AetherPalette.accent, size: 32),
              const SizedBox(height: 12),
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

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(final BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List<Widget>.generate(4, (final index) {
      final bool isCurrent = index == currentIndex;
      final bool isPast = index < currentIndex;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: isCurrent ? 32 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: isCurrent || isPast
              ? AetherPalette.accent
              : AetherPalette.textMuted.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }),
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
  Widget build(final BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Icon(icon, size: 18, color: AetherPalette.textMuted),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AetherPalette.textMuted),
            ),
            const SizedBox(height: 2),
            Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    ],
  );
}
