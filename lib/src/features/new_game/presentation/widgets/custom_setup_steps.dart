import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/data/character_templates.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/features/new_game/application/new_game_controller.dart';
import 'package:ai_prg/src/features/new_game/presentation/widgets/new_game_helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LiteraryGenreStep extends StatelessWidget {
  const LiteraryGenreStep({
    required this.state,
    required this.controller,
    super.key,
  });

  final NewGameViewState state;
  final NewGameController controller;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    
    return Column(
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
                (item) => GenreSelectPill(
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
  }
}

class WorldSettingStep extends StatelessWidget {
  const WorldSettingStep({
    required this.state,
    required this.controller,
    super.key,
  });

  final NewGameViewState state;
  final NewGameController controller;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    
    return Column(
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
                (item) => GenreSelectPill(
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
  }
}

class FoundationStep extends StatelessWidget {
  const FoundationStep({
    required this.state,
    required this.controller,
    required this.heroController,
    super.key,
  });

  final NewGameViewState state;
  final NewGameController controller;
  final TextEditingController heroController;

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionLabel(title: l10n.storyModeTitle),
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
        SectionLabel(title: l10n.difficultyTitle),
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
          controller: heroController,
          onChanged: controller.setHeroName,
          decoration: InputDecoration(
            labelText: l10n.heroName,
            hintText: l10n.heroNameHint,
          ),
        ),
      ],
    );
  }
}

class StoryStep extends StatelessWidget {
  const StoryStep({
    required this.state,
    required this.controller,
    required this.storyPromptController,
    required this.onGeneratePrompts,
    super.key,
  });

  final NewGameViewState state;
  final NewGameController controller;
  final TextEditingController storyPromptController;
  final VoidCallback onGeneratePrompts;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionLabel(title: l10n.storyWishTitle),
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
          controller: storyPromptController,
          onChanged: controller.setStoryInput,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: l10n.storyWishHint,
            alignLabelWithHint: true,
          ),
        ),
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
              onPressed: !state.isGenerating ? onGeneratePrompts : null,
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
  }
}

class CharacterStep extends StatelessWidget {
  const CharacterStep({
    required this.state,
    required this.controller,
    required this.personalityController,
    required this.characterPromptController,
    super.key,
  });

  final NewGameViewState state;
  final NewGameController controller;
  final TextEditingController personalityController;
  final TextEditingController characterPromptController;

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final CharacterProfile profile = controller.effectiveCharacterProfile();
    final List<CharacterClass> classes = classesBySetting[state.setting]!;
    final List<String> races =
        racesBySetting[state.setting] ?? <String>['human'];
    final bool showClass = settingUsesCharacterClass(state.setting);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionLabel(title: l10n.characterSectionTitle),
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
          controller: personalityController,
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
          controller: characterPromptController,
          onChanged: controller.setCharacterPrompt,
          maxLines: 3,
          decoration: InputDecoration(labelText: l10n.editCharacterPrompt),
        ),
      ],
    );
  }
}

class ReviewStep extends StatelessWidget {
  const ReviewStep({
    required this.state,
    super.key,
  });

  final NewGameViewState state;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final CharacterProfile? profile = state.characterProfile;
    final List<CampaignModuleState> plannedModules = state.plannedModules;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionLabel(title: l10n.reviewTitle),
        SizedBox(height: context.responsive.sectionSpacing),
        AetherCard(
          padding: EdgeInsets.all(context.responsive.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ReviewItem(
                label: l10n.literaryGenreTitle,
                value: l10n.literaryGenreLabel(state.literaryGenre),
                icon: Icons.menu_book_outlined,
              ),
              const SizedBox(height: 12),
              ReviewItem(
                label: l10n.settingTitle,
                value: l10n.settingLabel(state.setting),
                icon: Icons.public_rounded,
              ),
              const SizedBox(height: 12),
              ReviewItem(
                label: l10n.storyModeTitle,
                value: l10n.storyModeLabel(state.storyMode),
                icon: Icons.menu_book_outlined,
              ),
              const SizedBox(height: 12),
              ReviewItem(
                label: l10n.difficultyTitle,
                value: l10n.difficultyLabel(state.difficulty),
                icon: Icons.show_chart_rounded,
              ),
              const SizedBox(height: 12),
              ReviewItem(
                label: l10n.heroName,
                value: state.heroName.trim().isEmpty
                    ? l10n.heroNameHint
                    : state.heroName.trim(),
                icon: Icons.person_outline_rounded,
              ),
              if (state.customStoryPrompt.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                ReviewItem(
                  label: l10n.customStoryPromptTitle,
                  value: state.customStoryPrompt.trim().length > 100
                      ? '${state.customStoryPrompt.trim().substring(0, 100)}...'
                      : state.customStoryPrompt.trim(),
                  icon: Icons.edit_note_rounded,
                ),
              ],
              if (profile != null) ...<Widget>[
                const SizedBox(height: 12),
                ReviewItem(
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
                ReviewItem(
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
}
