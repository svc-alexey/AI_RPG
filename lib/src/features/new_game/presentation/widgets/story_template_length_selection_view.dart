import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/features/new_game/application/new_game_controller.dart';
import 'package:ai_prg/src/features/new_game/presentation/widgets/new_game_helpers.dart';
import 'package:flutter/material.dart';

class StoryTemplateLengthSelectionView extends StatelessWidget {
  const StoryTemplateLengthSelectionView({
    required this.state,
    required this.controller,
    super.key,
  });

  final NewGameViewState state;
  final NewGameController controller;

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final StoryTemplateSeed? seed = state.storyTemplateSeed;
    final String title = seed?.title.trim().isNotEmpty == true
        ? seed!.title.trim()
        : l10n.storyTemplateSelectedFallbackTitle;
    final String summary = seed?.summary.trim().isNotEmpty == true
        ? seed!.summary.trim()
        : seed?.promptText.trim() ?? '';

    return ListView(
      children: <Widget>[
        Text(
          l10n.storyTemplateLengthTitle,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
          maxLines: 3,
        ),
        SizedBox(height: context.responsive.blockSpacing),
        AetherCard(
          padding: EdgeInsets.all(context.responsive.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SectionLabel(title: l10n.storyTemplateSelectedLabel),
              const SizedBox(height: 10),
              Text(title, style: theme.textTheme.titleLarge),
              if (summary.trim().isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  summary,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AetherPalette.textMuted,
                    height: 1.45,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: context.responsive.blockSpacing + 8),
        ModeCard(
          icon: Icons.bolt_rounded,
          title: l10n.storyModeLabel(StoryMode.shortStory),
          subtitle: l10n.storyTemplateShortStoryDesc,
          onTap: controller.startTemplateShortStory,
        ),
        const SizedBox(height: 16),
        ModeCard(
          icon: Icons.route_rounded,
          title: l10n.storyModeLabel(StoryMode.longCampaign),
          subtitle: l10n.storyTemplateLongCampaignDesc,
          onTap: controller.startTemplateLongCampaign,
        ),
      ],
    );
  }
}
