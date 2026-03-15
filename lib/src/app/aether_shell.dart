import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AetherPalette {
  static const Color background = Color(0xFF17121F);
  static const Color backgroundTop = Color(0xFF22182D);
  static const Color panel = Color(0xFF211A2C);
  static const Color panelSoft = Color(0xFF261F33);
  static const Color panelBorder = Color(0xFF3A2F49);
  static const Color panelGlow = Color(0xFF8C4DD4);
  static const Color textPrimary = Color(0xFFE9E2D7);
  static const Color textMuted = Color(0xFF9E93AF);
  static const Color accent = Color(0xFFB463FF);
  static const Color accentSoft = Color(0xFF5D3B79);
  static const Color gold = Color(0xFFE0B35B);
  static const Color success = Color(0xFF34D399);
}

class AetherBackdrop extends StatefulWidget {
  const AetherBackdrop({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<AetherBackdrop> createState() => _AetherBackdropState();
}

class _AetherBackdropState extends State<AetherBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
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
        bindingName != 'LiveTestWidgetsFlutterBinding' &&
        defaultTargetPlatform != TargetPlatform.windows;
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
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.35,
              colors: <Color>[
                AetherPalette.backgroundTop,
                AetherPalette.background,
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _AmbientGlow(
                alignment: Alignment(-0.8 + (_pulse.value * 0.08), -0.9),
                color: AetherPalette.accent.withValues(
                  alpha: 0.75 + (_pulse.value * 0.25),
                ),
                size: 300 + (_pulse.value * 60),
              ),
              _AmbientGlow(
                alignment: Alignment(0.88, 0.72 - (_pulse.value * 0.06)),
                color: AetherPalette.accentSoft.withValues(
                  alpha: 0.8 + (_pulse.value * 0.2),
                ),
                size: 340 + (_pulse.value * 80),
              ),
              _AmbientGlow(
                alignment: Alignment(0.1, -0.1 + (_pulse.value * 0.03)),
                color: const Color(0x33432653).withValues(
                  alpha: 0.6 + (_pulse.value * 0.3),
                ),
                size: 540 + (_pulse.value * 70),
              ),
              widget.child,
            ],
          ),
        ),
      );
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({
    required this.alignment,
    required this.color,
    required this.size,
  });

  final Alignment alignment;
  final Color color;
  final double size;

  @override
  Widget build(final BuildContext context) => Align(
        alignment: alignment,
        child: IgnorePointer(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[
                  color.withValues(alpha: 0.28),
                  color.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      );
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
    final Color resolvedBorder = borderColor ??
        (highlight ? AetherPalette.accent : AetherPalette.panelBorder);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: padding,
      decoration: BoxDecoration(
        color: AetherPalette.panel.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: resolvedBorder.withValues(alpha: 0.68)),
        boxShadow: highlight
            ? const <BoxShadow>[
                BoxShadow(
                  color: Color(0x2AB463FF),
                  blurRadius: 24,
                  spreadRadius: -6,
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
  ).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 0.97,
    end: 1,
  ).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
  );

  bool get _animationsEnabled =>
      defaultTargetPlatform != TargetPlatform.windows;

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
          child: ScaleTransition(
            scale: _scale,
            child: widget.child,
          ),
        ),
      );
}
