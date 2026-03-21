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
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: responsive.dialogMaxWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.pagePadding,
                  vertical: responsive.pagePadding,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      AetherPageReveal(
                        child: Container(
                          width: 120,
                          height: 1,
                          color: AetherPalette.accent.withValues(alpha: 0.35),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AetherPageReveal(
                        delay: const Duration(milliseconds: 80),
                        child: Text(
                          l10n.brandName,
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: responsive.isCompact ? 52 : null,
                            letterSpacing: responsive.scaleLetterSpacing(7),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(height: 14),
                      AetherPageReveal(
                        delay: const Duration(milliseconds: 140),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Text(
                            l10n.homeHeroTitle,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: AetherPalette.textPrimary,
                              fontSize: responsive.isCompact ? 28 : 34,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      AetherPageReveal(
                        delay: const Duration(milliseconds: 220),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: responsive.isMobile ? 360 : 620,
                          ),
                          child: Text(
                            l10n.homeDescription,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AetherPalette.textMuted,
                              height: 1.7,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: responsive.blockSpacing),
                      AetherPageReveal(
                        delay: const Duration(milliseconds: 300),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: l10n.homeFeatureLines
                              .map(
                                (line) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AetherPalette.panelSoft.withValues(
                                      alpha: 0.72,
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: AetherPalette.panelBorder
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                  child: Text(
                                    line,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AetherPalette.textPrimary,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      SizedBox(height: responsive.blockSpacing + 12),
                      AetherPageReveal(
                        delay: const Duration(milliseconds: 380),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: responsive.isMobile ? 360 : 420,
                          ),
                          child: Column(
                            children: <Widget>[
                              _HeroButton(
                                icon: Icons.auto_stories_outlined,
                                label: l10n.homePrimaryCta,
                                emphasized: true,
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) => const NewGameScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _HeroButton(
                                icon: Icons.history_edu_outlined,
                                label: l10n.homeSecondaryCta,
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) => const SavesScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _HeroButton(
                                icon: Icons.tune_rounded,
                                label: l10n.homeTertiaryCta,
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
                      ),
                    ],
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

class _HeroButton extends StatefulWidget {
  const _HeroButton({
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
  State<_HeroButton> createState() => _HeroButtonState();
}

class _HeroButtonState extends State<_HeroButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  bool get _animationsEnabled {
    final String bindingName = WidgetsBinding.instance.runtimeType.toString();
    return bindingName != 'AutomatedTestWidgetsFlutterBinding' &&
        bindingName != 'LiveTestWidgetsFlutterBinding';
  }

  @override
  void initState() {
    super.initState();
    if (widget.emphasized && _animationsEnabled) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) {
      final double glow = widget.emphasized
          ? (0.18 + (_controller.value * 0.2))
          : 0;

      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: glow == 0
              ? const <BoxShadow>[]
              : <BoxShadow>[
                  BoxShadow(
                    color: AetherPalette.accent.withValues(alpha: glow),
                    blurRadius: 28,
                    spreadRadius: -10,
                    offset: const Offset(0, 12),
                  ),
                ],
        ),
        child: AetherCard(
          highlight: widget.emphasized,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: <Widget>[
                    Icon(
                      widget.icon,
                      color: widget.emphasized
                          ? AetherPalette.accent
                          : AetherPalette.textMuted,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: widget.emphasized
                          ? AetherPalette.accent
                          : AetherPalette.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
