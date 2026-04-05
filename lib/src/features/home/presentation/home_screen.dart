import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/features/new_game/presentation/new_game_screen.dart';
import 'package:ai_prg/src/features/saves/presentation/saves_screen.dart';
import 'package:ai_prg/src/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Web/desktop [MaterialScrollBehavior] adds a [RawScrollbar] around scrollables.
/// On the home landing the column usually fits the viewport; the track then reads
/// like a misplaced vertical stripe, so we disable scrollbars here only.
class _HomeLandingScrollBehavior extends MaterialScrollBehavior {
  const _HomeLandingScrollBehavior();

  @override
  Widget buildScrollbar(
    final BuildContext context,
    final Widget child,
    final ScrollableDetails details,
  ) => child;
}

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(
                  responsive.pagePadding + 4,
                  8,
                  responsive.pagePadding + 4,
                  0,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        l10n.homeTagline.toUpperCase(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          letterSpacing: 3.2,
                          color: AetherPalette.textMuted,
                          fontWeight: FontWeight.w500,
                          fontSize: responsive.isCompact ? 9 : 10,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const SettingsScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.settings_outlined, size: 22),
                      tooltip: l10n.homeTertiaryCta,
                      style: IconButton.styleFrom(
                        foregroundColor: AetherPalette.textMuted,
                        hoverColor: AetherPalette.panelSoft,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: responsive.isWide
                          ? 920
                          : responsive.dialogMaxWidth,
                    ),
                    child: ScrollConfiguration(
                      behavior: const _HomeLandingScrollBehavior(),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.pagePadding,
                          vertical: responsive.blockSpacing,
                        ),
                        child: Column(
                          children: <Widget>[
                            _HomeHeroBlock(
                              l10n: l10n,
                              theme: theme,
                              responsive: responsive,
                            ),
                            SizedBox(height: responsive.blockSpacing + 8),
                            _HomeBentoRow(
                              l10n: l10n,
                              theme: theme,
                              responsive: responsive,
                            ),
                            SizedBox(height: responsive.blockSpacing + 20),
                            _HomeFeatureTags(
                              lines: l10n.homeFeatureLines,
                              theme: theme,
                              responsive: responsive,
                            ),
                            SizedBox(height: responsive.blockSpacing + 12),
                            Text(
                              l10n.homeTagline.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                letterSpacing: 3.6,
                                color: const Color(0xFF3A3530),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeroBlock extends StatelessWidget {
  const _HomeHeroBlock({
    required this.l10n,
    required this.theme,
    required this.responsive,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final AppResponsiveData responsive;

  @override
  Widget build(final BuildContext context) {
    final double line2Size = responsive.isCompact ? 48 : 72;

    return Column(
      children: <Widget>[
        AetherPageReveal(
          child: Text(
            l10n.brandNameLine1,
            textAlign: TextAlign.center,
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: responsive.isCompact
                  ? 44
                  : (responsive.isWide ? 88 : 64),
              fontWeight: FontWeight.w300,
              letterSpacing: -2,
              height: 0.92,
            ),
          ),
        ),
        const SizedBox(height: 4),
        AetherPageReveal(
          delay: const Duration(milliseconds: 60),
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AetherPalette.textPrimary,
                AetherPalette.accentHover,
                AetherPalette.gold,
              ],
              stops: <double>[0.0, 0.52, 1.0],
            ).createShader(bounds),
            child: Text(
              l10n.brandNameLine2,
              textAlign: TextAlign.center,
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: responsive.isCompact
                    ? line2Size
                    : (responsive.isWide ? 96 : 74),
                fontWeight: FontWeight.w300,
                letterSpacing: -2,
                height: 0.92,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: responsive.isCompact ? 16 : 22),
        AetherPageReveal(
          delay: const Duration(milliseconds: 120),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              l10n.homeHeroTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: responsive.isCompact ? 17 : 20,
                fontStyle: FontStyle.italic,
                color: AetherPalette.textMuted,
                height: 1.35,
              ),
            ),
          ),
        ),
        SizedBox(height: responsive.isCompact ? 20 : 28),
        AetherPageReveal(
          delay: const Duration(milliseconds: 180),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _GradientLine(
                alignRight: true,
                width: responsive.isCompact ? 40 : 56,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: _WarmFlickerSparkle(),
              ),
              _GradientLine(
                alignRight: false,
                width: responsive.isCompact ? 40 : 56,
              ),
            ],
          ),
        ),
        SizedBox(height: responsive.isCompact ? 18 : 24),
        AetherPageReveal(
          delay: const Duration(milliseconds: 240),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: responsive.isMobile ? 360 : 560,
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
      ],
    );
  }
}

class _GradientLine extends StatelessWidget {
  const _GradientLine({required this.alignRight, required this.width});

  final bool alignRight;
  final double width;

  @override
  Widget build(final BuildContext context) => SizedBox(
    width: width,
    height: 1,
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: alignRight
              ? const <Color>[Colors.transparent, Color(0x80C87941)]
              : const <Color>[Color(0x80C87941), Colors.transparent],
        ),
      ),
    ),
  );
}

class _WarmFlickerSparkle extends StatefulWidget {
  const _WarmFlickerSparkle();

  @override
  State<_WarmFlickerSparkle> createState() => _WarmFlickerSparkleState();
}

class _WarmFlickerSparkleState extends State<_WarmFlickerSparkle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );

  bool get _animationsEnabled {
    final String bindingName = WidgetsBinding.instance.runtimeType.toString();
    return bindingName != 'AutomatedTestWidgetsFlutterBinding' &&
        bindingName != 'LiveTestWidgetsFlutterBinding';
  }

  @override
  void initState() {
    super.initState();
    if (_animationsEnabled) {
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
      final double t = _controller.value;
      final double flicker = 1.0 - (t - 0.5).abs() * 0.12;
      return Opacity(
        opacity: (0.88 + 0.1 * flicker).clamp(0.75, 1.0),
        child: const Icon(
          Icons.auto_awesome_rounded,
          size: 18,
          color: AetherPalette.accent,
        ),
      );
    },
  );
}

class _HomeBentoRow extends StatelessWidget {
  const _HomeBentoRow({
    required this.l10n,
    required this.theme,
    required this.responsive,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final AppResponsiveData responsive;

  @override
  Widget build(final BuildContext context) {
    if (responsive.isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: _HomeBentoPrimaryCard(
              l10n: l10n,
              theme: theme,
              responsive: responsive,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const NewGameScreen(),
                ),
              ),
            ),
          ),
          SizedBox(width: responsive.sectionSpacing + 4),
          Expanded(
            child: _HomeBentoSecondaryCard(
              l10n: l10n,
              theme: theme,
              responsive: responsive,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const SavesScreen(),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _HomeBentoPrimaryCard(
          l10n: l10n,
          theme: theme,
          responsive: responsive,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const NewGameScreen(),
            ),
          ),
        ),
        SizedBox(height: responsive.sectionSpacing + 4),
        _HomeBentoSecondaryCard(
          l10n: l10n,
          theme: theme,
          responsive: responsive,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (context) => const SavesScreen()),
          ),
        ),
      ],
    );
  }
}

class _HomeBentoPrimaryCard extends StatefulWidget {
  const _HomeBentoPrimaryCard({
    required this.l10n,
    required this.theme,
    required this.responsive,
    required this.onPressed,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final AppResponsiveData responsive;
  final VoidCallback onPressed;

  @override
  State<_HomeBentoPrimaryCard> createState() => _HomeBentoPrimaryCardState();
}

class _HomeBentoPrimaryCardState extends State<_HomeBentoPrimaryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    reverseDuration: const Duration(milliseconds: 360),
  );
  late final Animation<double> _hoverT = CurvedAnimation(
    parent: _hoverCtrl,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  void _setHover(final bool hovering) {
    if (hovering) {
      _hoverCtrl.forward();
    } else {
      _hoverCtrl.reverse();
    }
  }

  @override
  Widget build(final BuildContext context) {
    final BorderRadius outerRadius = BorderRadius.circular(16);
    final BorderRadius innerRadius = BorderRadius.circular(15);
    final EdgeInsets pad = EdgeInsets.all(
      widget.responsive.isCompact ? 20 : 28,
    );
    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: GestureDetector(
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _hoverT,
            builder: (context, _) {
              final double t = _hoverT.value;
              final Color borderColor = Color.lerp(
                AetherPalette.accent.withValues(alpha: 0.28),
                AetherPalette.accent.withValues(alpha: 0.52),
                t,
              )!;
              return DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: outerRadius,
                  border: Border.all(color: borderColor),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AetherPalette.accent.withValues(
                        alpha: 0.08 + t * 0.18,
                      ),
                      blurRadius: 12 + t * 28,
                      spreadRadius: -4 + t * 2,
                      offset: Offset(0, 4 + t * 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: innerRadius,
                  child: Stack(
                    children: <Widget>[
                      const Positioned.fill(
                        child: ColoredBox(
                          color: AetherPalette.backgroundElevated,
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                AetherPalette.accent.withValues(
                                  alpha: 0.07 + t * 0.09,
                                ),
                                Colors.transparent,
                              ],
                              stops: const <double>[0.0, 0.58],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -36,
                        top: -36,
                        child: IgnorePointer(
                          child: SizedBox(
                            width: 168,
                            height: 168,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: <Color>[
                                    AetherPalette.accent.withValues(
                                      alpha: 0.11 + t * 0.14,
                                    ),
                                    Colors.transparent,
                                  ],
                                  stops: const <double>[0.0, 0.65],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: pad,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: AetherPalette.accent.withValues(
                                  alpha: 0.18 + t * 0.08,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.auto_awesome_rounded,
                                  color: AetherPalette.accent,
                                  size: 26,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: widget.responsive.isCompact ? 14 : 18,
                            ),
                            Text(
                              widget.l10n.homeBentoPrimaryTitle,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: widget.responsive.isCompact ? 22 : 26,
                                fontWeight: FontWeight.w400,
                                height: 1.15,
                                color: AetherPalette.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.l10n.homePrimaryCardSubtitle,
                              style: widget.theme.textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AetherPalette.textMuted,
                                    height: 1.45,
                                  ),
                            ),
                            SizedBox(
                              height: widget.responsive.isCompact ? 18 : 22,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  widget.l10n.homeBentoPrimaryLink,
                                  style: widget.theme.textTheme.labelLarge
                                      ?.copyWith(
                                        color:
                                            Color.lerp(
                                              AetherPalette.accent,
                                              AetherPalette.accentHover,
                                              t,
                                            ) ??
                                            AetherPalette.accent,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                  color:
                                      Color.lerp(
                                        AetherPalette.accent,
                                        AetherPalette.accentHover,
                                        t,
                                      ) ??
                                      AetherPalette.accent,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeBentoSecondaryCard extends StatefulWidget {
  const _HomeBentoSecondaryCard({
    required this.l10n,
    required this.theme,
    required this.responsive,
    required this.onPressed,
  });

  final AppLocalizations l10n;
  final ThemeData theme;
  final AppResponsiveData responsive;
  final VoidCallback onPressed;

  @override
  State<_HomeBentoSecondaryCard> createState() =>
      _HomeBentoSecondaryCardState();
}

class _HomeBentoSecondaryCardState extends State<_HomeBentoSecondaryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    reverseDuration: const Duration(milliseconds: 320),
  );
  late final Animation<double> _hoverT = CurvedAnimation(
    parent: _hoverCtrl,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  void _setHover(final bool hovering) {
    if (hovering) {
      _hoverCtrl.forward();
    } else {
      _hoverCtrl.reverse();
    }
  }

  @override
  Widget build(final BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(16);
    final EdgeInsets pad = EdgeInsets.all(
      widget.responsive.isCompact ? 20 : 24,
    );
    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: GestureDetector(
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _hoverT,
            builder: (context, _) {
              final double t = _hoverT.value;
              final Color bg = Color.lerp(
                AetherPalette.backgroundElevated,
                AetherPalette.backgroundTop,
                t,
              )!;
              final Color borderC = Color.lerp(
                AetherPalette.panelBorderSolid,
                AetherPalette.accent.withValues(alpha: 0.28),
                t,
              )!;
              final Color iconBg = Color.lerp(
                AetherPalette.panelSoft,
                AetherPalette.accent.withValues(alpha: 0.12),
                t,
              )!;
              final Color iconFg = Color.lerp(
                AetherPalette.textMuted,
                AetherPalette.accentHover,
                t,
              )!;
              return Container(
                padding: pad,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: radius,
                  border: Border.all(color: borderC),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.bookmark_added_outlined,
                          color: iconFg,
                          size: 22,
                        ),
                      ),
                    ),
                    SizedBox(height: widget.responsive.isCompact ? 14 : 16),
                    Text(
                      widget.l10n.homeSecondaryCta,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AetherPalette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.l10n.homeSecondaryCardSubtitle,
                      style: widget.theme.textTheme.bodySmall?.copyWith(
                        color: AetherPalette.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeFeatureTags extends StatelessWidget {
  const _HomeFeatureTags({
    required this.lines,
    required this.theme,
    required this.responsive,
  });

  final List<String> lines;
  final ThemeData theme;
  final AppResponsiveData responsive;

  @override
  Widget build(final BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    spacing: responsive.isCompact ? 16 : 22,
    runSpacing: 10,
    children: lines
        .map(
          (line) => Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AetherPalette.accent.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                line,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AetherPalette.textDim,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        )
        .toList(),
  );
}
