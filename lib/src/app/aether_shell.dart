import 'dart:async';

import 'package:ai_prg/src/app/responsive.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Noir palette aligned with [tool/js_верстка/app/globals.css].
class AetherPalette {
  static const Color background = Color(0xFF0A0908);
  static const Color backgroundElevated = Color(0xFF0F0D0B);
  static const Color backgroundTop = Color(0xFF141210);
  static const Color panel = Color(0xF212100E);
  static const Color panelSoft = Color(0xFF1A1816);
  static const Color panelBorder = Color(0x26C87941);
  static const Color panelBorderSolid = Color(0xFF1A1816);
  static const Color panelGlow = Color(0xFFC87941);
  static const Color textPrimary = Color(0xFFE8E4E0);
  static const Color textMuted = Color(0xFF7A7570);
  static const Color textDim = Color(0xFF5A5550);
  /// Narration body (JS mockup prose-invert).
  static const Color narrativeText = Color(0xFFC8C4C0);
  static const Color accent = Color(0xFFC87941);
  static const Color accentSoft = Color(0x1FC87941);
  static const Color accentHover = Color(0xFFD4956A);
  static const Color gold = Color(0xFFBFA76F);
  static const Color success = Color(0xFF34D399);
}

class AetherBackdrop extends StatefulWidget {
  const AetherBackdrop({required this.child, super.key});

  final Widget child;

  @override
  State<AetherBackdrop> createState() => _AetherBackdropState();
}

class _AetherBackdropState extends State<AetherBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  late final Animation<double> _pulse = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    if (_animationsEnabled) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 0.5;
    }
  }

  bool get _animationsEnabled {
    final String bindingName = WidgetsBinding.instance.runtimeType.toString();
    return bindingName != 'AutomatedTestWidgetsFlutterBinding' &&
        bindingName != 'LiveTestWidgetsFlutterBinding';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => AnimatedBuilder(
    animation: _pulse,
    builder: (context, _) => DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AetherPalette.backgroundTop,
            AetherPalette.background,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CustomPaint(
            painter: _WarmGlowPainter(pulse: _pulse.value),
            size: Size.infinite,
          ),
          if (!kIsWeb)
            const CustomPaint(
              painter: _FilmNoisePainter(),
              size: Size.infinite,
            ),
          widget.child,
        ],
      ),
    ),
  );
}

/// Central warm radial glow; strength follows CSS `glow-pulse` (~4s).
class _WarmGlowPainter extends CustomPainter {
  const _WarmGlowPainter({required this.pulse});

  final double pulse;

  @override
  void paint(final Canvas canvas, final Size size) {
    final Offset center = Offset(size.width * 0.5, size.height * 0.28);
    final double radius =
        size.shortestSide * 0.92 * (0.94 + pulse * 0.14);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final Paint paint = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          AetherPalette.accent.withValues(alpha: 0.12 + pulse * 0.14),
          AetherPalette.accent.withValues(alpha: 0.05 + pulse * 0.06),
          Colors.transparent,
        ],
        stops: const <double>[0.0, 0.4, 0.72],
      ).createShader(rect);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _WarmGlowPainter oldDelegate) =>
      oldDelegate.pulse != pulse;
}

/// Sparse grain (~3% opacity) similar to SVG noise overlay in the JS mockup.
class _FilmNoisePainter extends CustomPainter {
  const _FilmNoisePainter();

  @override
  void paint(final Canvas canvas, final Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    const double step = 5;
    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        final int ix = x.round();
        final int iy = y.round();
        final int hash = (ix * 92837111 ^ iy * 689287499) & 0xFF;
        if (hash < 188) {
          continue;
        }
        paint.color = AetherPalette.textPrimary.withValues(
          alpha: 0.018 + (hash & 7) * 0.002,
        );
        canvas.drawRect(Rect.fromLTWH(x, y, 1.4, 1.4), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AetherCard extends StatelessWidget {
  const AetherCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderColor,
    this.highlight = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final bool highlight;

  @override
  Widget build(final BuildContext context) {
    final AppResponsiveData responsive = context.responsive;
    final Color resolvedBorder =
        borderColor ??
        (highlight ? AetherPalette.accent : AetherPalette.panelBorder);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: padding,
      decoration: BoxDecoration(
        color: AetherPalette.panel.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(responsive.cardRadius),
        border: Border.all(color: resolvedBorder.withValues(alpha: 0.68)),
        boxShadow: highlight
            ? <BoxShadow>[
                BoxShadow(
                  color: AetherPalette.accent.withValues(alpha: 0.22),
                  blurRadius: 28,
                  spreadRadius: -8,
                ),
              ]
            : const <BoxShadow>[],
      ),
      child: child,
    );
  }
}

class AetherPageReveal extends StatefulWidget {
  const AetherPageReveal({
    required this.child,
    this.delay = Duration.zero,
    super.key,
  });

  final Widget child;
  final Duration delay;

  @override
  State<AetherPageReveal> createState() => _AetherPageRevealState();
}

class _AetherPageRevealState extends State<AetherPageReveal>
    with SingleTickerProviderStateMixin {
  Timer? _startTimer;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.09),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  late final Animation<double> _scale = Tween<double>(
    begin: 0.97,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  bool get _animationsEnabled {
    final String bindingName = WidgetsBinding.instance.runtimeType.toString();
    return bindingName != 'AutomatedTestWidgetsFlutterBinding' &&
        bindingName != 'LiveTestWidgetsFlutterBinding';
  }

  @override
  void initState() {
    super.initState();
    if (!_animationsEnabled) {
      _controller.value = 1;
      return;
    }

    if (widget.delay == Duration.zero) {
      _controller.forward();
      return;
    }

    _startTimer = Timer(widget.delay, () {
      if (!mounted) {
        return;
      }
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(
      position: _slide,
      child: ScaleTransition(scale: _scale, child: widget.child),
    ),
  );
}
