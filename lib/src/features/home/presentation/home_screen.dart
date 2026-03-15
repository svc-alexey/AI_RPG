import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/features/new_game/presentation/new_game_screen.dart';
import 'package:ai_prg/src/features/saves/presentation/saves_screen.dart';
import 'package:ai_prg/src/features/settings/presentation/settings_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;

    if (defaultTargetPlatform == TargetPlatform.windows) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.appTitle)),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'AETHERIS',
                    style: theme.textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.homeDescription,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const NewGameScreen(),
                      ),
                    ),
                    child: Text(l10n.newCampaign),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const SavesScreen(),
                      ),
                    ),
                    child: Text(l10n.saves),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const SettingsScreen(),
                      ),
                    ),
                    child: Text(l10n.aiSettings),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: AetherBackdrop(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: AetherPageReveal(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                    Text(
                      'AETHERIS',
                      style: theme.textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.appTitle,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AetherPalette.textMuted,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: 88,
                      height: 1,
                      color: AetherPalette.accent.withValues(alpha: 0.45),
                    ),
                    const SizedBox(height: 32),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Text(
                        l10n.homeDescription,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AetherPalette.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Column(
                        children: <Widget>[
                          _MenuButton(
                            icon: Icons.auto_stories_outlined,
                            label: l10n.newCampaign,
                            emphasized: true,
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => const NewGameScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _MenuButton(
                            icon: Icons.save_outlined,
                            label: l10n.saves,
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => const SavesScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _MenuButton(
                            icon: Icons.tune_rounded,
                            label: l10n.aiSettings,
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => const SettingsScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: l10n.homeFeatureLines
                              .take(4)
                              .map(
                                (line) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AetherPalette.panelSoft.withValues(
                                      alpha: 0.6,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AetherPalette.panelBorder.withValues(
                                        alpha: 0.55,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    line,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              )
                              .toList(),
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
            constraints: const BoxConstraints(minHeight: 56),
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
