import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/features/new_game/application/new_game_controller.dart';
import 'package:ai_prg/src/features/new_game/presentation/widgets/new_game_helpers.dart';
import 'package:flutter/material.dart';

class QuickStartView extends StatelessWidget {
  const QuickStartView({
    required this.state,
    required this.controller,
    required this.heroController,
    required this.onCreateQuickCampaign,
    super.key,
  });

  final NewGameViewState state;
  final NewGameController controller;
  final TextEditingController heroController;
  final VoidCallback onCreateQuickCampaign;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;

    return ListView(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            IconButton(
              onPressed: state.storyTemplateSeed == null
                  ? controller.setModeSelection
                  : controller.setStoryLengthSelection,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                l10n.quickStart,
                style: theme.textTheme.headlineMedium,
              ),
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
        SizedBox(height: context.responsive.blockSpacing),
        TextField(
          controller: heroController,
          onChanged: controller.setHeroName,
          decoration: InputDecoration(
            labelText: l10n.heroName,
            hintText: l10n.heroNameHint,
          ),
        ),
        SizedBox(height: context.responsive.blockSpacing),
        SectionLabel(title: l10n.characterGenderTitle),
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
            onPressed: state.isSaving ? null : onCreateQuickCampaign,
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
  }
}
