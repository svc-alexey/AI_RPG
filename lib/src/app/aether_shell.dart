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
  AnimationController? _controller;
  Animation<double>? _pulse;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 4),
      );
      _pulse = CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeInOut,
      );

      if (_animationsEnabled) {
        _controller!.repeat(reverse: true);
      } else {
        _controller!.value = 0.5;
      }
    }
  }

  bool get _animationsEnabled {
    final String bindingName = WidgetsBinding.instance.runtimeType.toString();
    return bindingName != 'AutomatedTestWidgetsFlutterBinding' &&
        bindingName != 'LiveTestWidgetsFlutterBinding';
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return DecoratedBox(
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
          // Static base glow: shader created once per size, no per-frame work.
          const Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: _StaticWarmGlowPainter()),
            ),
          ),
          // Animated pulse overlay: only opacity is tweened, shader is static.
          if (!kIsWeb && _pulse != null)
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: FadeTransition(
                    opacity: _pulse!.drive(
                      Tween<double>(begin: 0, end: 0.32),
                    ),
                    child: const CustomPaint(painter: _PulseGlowPainter()),
                  ),
                ),
              ),
            ),
          RepaintBoundary(child: widget.child),
        ],
      ),
    );
  }
}

/// Static warm radial glow. Shader is cached per size, so 60fps repaint of
/// parent widgets doesn't recompile the gradient on CanvasKit.
class _StaticWarmGlowPainter extends CustomPainter {
  const _StaticWarmGlowPainter();

  // Shaders are cheap to share across instances since they only depend on size.
  static Size? _cachedSize;
  static Shader? _cachedShader;
  static Offset? _cachedCenter;
  static double? _cachedRadius;

  @override
  void paint(final Canvas canvas, final Size size) {
    if (_cachedShader == null || size != _cachedSize) {
      _cachedCenter = Offset(size.width * 0.5, size.height * 0.28);
      _cachedRadius = size.shortestSide * 0.92;
      final Rect rect = Rect.fromCircle(
        center: _cachedCenter!,
        radius: _cachedRadius!,
      );
      _cachedShader = const RadialGradient(
        colors: <Color>[
          Color(0x29C87941),
          Color(0x14C87941),
          Color(0x00C87941),
        ],
        stops: <double>[0.0, 0.4, 0.72],
      ).createShader(rect);
      _cachedSize = size;
    }
    canvas.drawCircle(
      _cachedCenter!,
      _cachedRadius!,
      Paint()..shader = _cachedShader,
    );
  }

  @override
  bool shouldRepaint(covariant _StaticWarmGlowPainter oldDelegate) => false;
}

/// Extra warm layer that rides on top of the static glow. Its opacity is
/// animated by a parent [FadeTransition]; the shader here never changes.
class _PulseGlowPainter extends CustomPainter {
  const _PulseGlowPainter();

  static Size? _cachedSize;
  static Shader? _cachedShader;
  static Offset? _cachedCenter;
  static double? _cachedRadius;

  @override
  void paint(final Canvas canvas, final Size size) {
    if (_cachedShader == null || size != _cachedSize) {
      _cachedCenter = Offset(size.width * 0.5, size.height * 0.28);
      _cachedRadius = size.shortestSide * 1.04;
      final Rect rect = Rect.fromCircle(
        center: _cachedCenter!,
        radius: _cachedRadius!,
      );
      _cachedShader = const RadialGradient(
        colors: <Color>[
          Color(0x33C87941),
          Color(0x14C87941),
          Color(0x00C87941),
        ],
        stops: <double>[0.0, 0.45, 0.78],
      ).createShader(rect);
      _cachedSize = size;
    }
    canvas.drawCircle(
      _cachedCenter!,
      _cachedRadius!,
      Paint()..shader = _cachedShader,
    );
  }

  @override
  bool shouldRepaint(covariant _PulseGlowPainter oldDelegate) => false;
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
