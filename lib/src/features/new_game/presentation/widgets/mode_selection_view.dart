import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/features/new_game/application/new_game_controller.dart';
import 'package:ai_prg/src/features/new_game/presentation/widgets/new_game_helpers.dart';
import 'package:flutter/material.dart';

class ModeSelectionView extends StatelessWidget {
  const ModeSelectionView({
    required this.controller,
    super.key,
  });

  final NewGameController controller;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;

    return ListView(
      children: <Widget>[
        Text(
          l10n.howToStart,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
          maxLines: 3,
        ),
        SizedBox(height: context.responsive.blockSpacing + 8),
        ModeCard(
          icon: Icons.flash_on_rounded,
          title: l10n.quickStart,
          subtitle: l10n.quickStartDesc,
          onTap: controller.setQuickStartMode,
        ),
        const SizedBox(height: 16),
        ModeCard(
          icon: Icons.tune_rounded,
          title: l10n.customSetup,
          subtitle: l10n.customSetupDesc,
          onTap: controller.setCustomSetupMode,
        ),
      ],
    );
  }
}
