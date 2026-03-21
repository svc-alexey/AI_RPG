import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/features/new_game/presentation/new_game_screen.dart';
import 'package:ai_prg/src/features/saves/presentation/saves_screen.dart';
import 'package:ai_prg/src/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final AppResponsiveData responsive = context.responsive;

    return Scaffold(
      body: AetherBackdrop(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: responsive.dialogMaxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.pagePadding,
                vertical: responsive.pagePadding,
              ),
              child: AetherPageReveal(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'AETHERIS',
                            style: theme.textTheme.displayLarge,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.appTitle,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AetherPalette.textMuted,
                              letterSpacing: responsive.scaleLetterSpacing(4),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: responsive.isCompact ? 10 : 14),
                          Container(
                            width: 88,
                            height: 1,
                            color: AetherPalette.accent.withValues(alpha: 0.45),
                          ),
                          SizedBox(height: responsive.blockSpacing),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: responsive.isMobile ? 360 : 520,
                            ),
                            child: Text(
                              l10n.homeDescription,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AetherPalette.textMuted,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: responsive.blockSpacing),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: l10n.homeFeatureLines
                                .take(4)
                                .map(
                                  (line) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AetherPalette.panelSoft.withValues(
                                        alpha: 0.6,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AetherPalette.panelBorder
                                            .withValues(alpha: 0.55),
                                      ),
                                    ),
                                    child: Text(
                                      line,
                                      style: theme.textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          SizedBox(height: responsive.blockSpacing + 8),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: responsive.isMobile ? 340 : 360,
                            ),
                            child: Column(
                              children: <Widget>[
                                _MenuButton(
                                  icon: Icons.auto_stories_outlined,
                                  label: l10n.newCampaign,
                                  emphasized: true,
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          const NewGameScreen(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _MenuButton(
                                  icon: Icons.save_outlined,
                                  label: l10n.saves,
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (context) => const SavesScreen(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _MenuButton(
                                  icon: Icons.tune_rounded,
                                  label: l10n.aiSettings,
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          const SettingsScreen(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool emphasized;

  @override
  Widget build(final BuildContext context) => AetherCard(
    highlight: emphasized,
    child: SizedBox(
      width: double.infinity,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: context.responsive.isCompact ? 48 : 56,
          ),
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                color: emphasized
                    ? AetherPalette.accent
                    : AetherPalette.textMuted,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
