import 'dart:math';
import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:flutter/material.dart';

class D20RollWidget extends StatefulWidget {
  final int result;
  final double size;
  final VoidCallback? onFinished;

  const D20RollWidget({
    super.key,
    required this.result,
    this.size = 88,
    this.onFinished,
  });

  @override
  State<D20RollWidget> createState() => _D20RollWidgetState();
}

class _D20RollWidgetState extends State<D20RollWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  late final Animation<double> _spinY;
  late final Animation<double> _spinX;
  late final Animation<double> _bounce;
  late final Animation<double> _opacity;
  late final Animation<double> _glow;

  int _displayNumber = 1;
  bool _showResult = false;
  final _rng = Random();
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _spinY = Tween<double>(begin: 0, end: pi * 8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );

    _spinX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.4), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.4, end: -0.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: -0.2, end: 0.1), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: 0.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    _bounce = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.2)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 25),
      TweenSequenceItem(
          tween: Tween(begin: 1.2, end: 0.9)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 15),
      TweenSequenceItem(
          tween: Tween(begin: 0.9, end: 1.05)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 1.05, end: 1.0), weight: 30),
    ]).animate(_ctrl);

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.15)),
    );

    _glow = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 75),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.addListener(() {
      if (_ctrl.value < 0.78) {
        final n = _rng.nextInt(20) + 1;
        if (n != _displayNumber) setState(() => _displayNumber = n);
      } else if (!_showResult) {
        setState(() {
          _displayNumber = widget.result;
          _showResult = true;
        });
      }
    });

    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onFinished?.call();
    });

    _ctrl.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context) == true;
    if (_reducedMotion && _ctrl.isAnimating) {
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reducedMotion) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _D20Painter(
            spinY: 0,
            spinX: 0,
            number: widget.result,
            isFinal: true,
            result: widget.result,
            glowIntensity: widget.result == 20 ? 1.0 : 0.0,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _bounce,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _D20Painter(
                  spinY: _spinY.value,
                  spinX: _spinX.value,
                  number: _displayNumber,
                  isFinal: _showResult,
                  result: widget.result,
                  glowIntensity: _glow.value,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _D20Painter extends CustomPainter {
  final double spinY;
  final double spinX;
  final int number;
  final bool isFinal;
  final int result;
  final double glowIntensity;

  _D20Painter({
    required this.spinY,
    required this.spinX,
    required this.number,
    required this.isFinal,
    required this.result,
    required this.glowIntensity,
  });

  static const Color _baseColorDefault = Color(0xFF3D2C5E);
  static const Color _lightColorDefault = Color(0xFF7B6FAE);
  static const Color _critSuccessColor = Color(0xFFBFA76F); // gold
  static const Color _critFailColor = Color(0xFF8B1A1A);
  static const Color _successColor = Color(0xFF2E6B3E);
  static const Color _failColor = Color(0xFF3D2C5E);

  Color get _baseColor {
    if (!isFinal) return _baseColorDefault;
    if (result == 20) return _critSuccessColor;
    if (result == 1) return _critFailColor;
    if (result >= 15) return _successColor;
    return _failColor;
  }

  Color get _lightColor {
    if (!isFinal) return _lightColorDefault;
    if (result == 20) return const Color(0xFFFFD700);
    if (result == 1) return const Color(0xFFCC3333);
    if (result >= 15) return const Color(0xFF4CAF50);
    return const Color(0xFF5B4F8A);
  }

  Color get _glowColor {
    if (result == 20) return AetherPalette.gold;
    if (result == 1) return const Color(0xFFFF2020);
    if (result >= 15) return AetherPalette.success;
    return const Color(0xFF7B6FAE);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 4;

    final cosY = cos(spinY);
    final scaleX = cosY.abs().clamp(0.08, 1.0);
    final isMirror = cosY < 0;
    final tiltScale = 1.0 - spinX.abs() * 0.15;

    if (isFinal && glowIntensity > 0) {
      final glowPaint = Paint()
        ..color = _glowColor.withValues(alpha: 0.25 * glowIntensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.drawCircle(Offset(cx, cy), r * 1.3, glowPaint);

      final glowPaint2 = Paint()
        ..color = _glowColor.withValues(alpha: 0.12 * glowIntensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32);
      canvas.drawCircle(Offset(cx, cy), r * 1.6, glowPaint2);
    }

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scaleX, tiltScale);
    canvas.translate(-cx, -cy);

    final shadowPath = _buildD20Shape(cx, cy + 3, r * 0.95);
    canvas.drawShadow(shadowPath, Colors.black.withValues(alpha: 0.6), 10, true);

    final mainPath = _buildD20Shape(cx, cy, r);

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        isMirror ? _baseColor.withValues(alpha: 0.7) : _lightColor,
        _baseColor,
        _baseColor.withValues(alpha: isMirror ? 0.5 : 0.85),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawPath(mainPath, fillPaint);

    _drawFaces(canvas, cx, cy, r, isMirror);

    final borderPaint = Paint()
      ..color = _lightColor.withValues(alpha: isMirror ? 0.2 : 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawPath(mainPath, borderPaint);

    _drawHighlight(canvas, cx, cy, r);

    canvas.restore();

    if (scaleX > 0.2) {
      _drawNumber(canvas, size, scaleX);
    }
  }

  Path _buildD20Shape(double cx, double cy, double r) {
    final path = Path();
    const outerR = 1.0;
    const innerR = 0.78;
    const points = 10;
    for (int i = 0; i < points; i++) {
      final angle = (2 * pi * i / points) - pi / 2;
      final radius = i.isEven ? r * outerR : r * innerR;
      final x = cx + radius * cos(angle);
      final y = cy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  void _drawFaces(Canvas canvas, double cx, double cy, double r, bool mirror) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: mirror ? 0.06 : 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final innerPath = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (2 * pi * i / 5) - pi / 2;
      final x = cx + r * 0.42 * cos(angle);
      final y = cy + r * 0.42 * sin(angle);
      if (i == 0) innerPath.moveTo(x, y);
      else innerPath.lineTo(x, y);
    }
    innerPath.close();
    canvas.drawPath(innerPath, paint);

    final outerVerts = <Offset>[];
    final innerVerts = <Offset>[];
    for (int i = 0; i < 10; i++) {
      final angle = (2 * pi * i / 10) - pi / 2;
      final rad = i.isEven ? r : r * 0.78;
      outerVerts.add(Offset(cx + rad * cos(angle), cy + rad * sin(angle)));
    }
    for (int i = 0; i < 5; i++) {
      final angle = (2 * pi * i / 5) - pi / 2;
      innerVerts.add(
          Offset(cx + r * 0.42 * cos(angle), cy + r * 0.42 * sin(angle)));
    }

    for (int i = 0; i < 5; i++) {
      canvas.drawLine(outerVerts[i * 2], innerVerts[i], paint);
      canvas.drawLine(outerVerts[i * 2], outerVerts[(i * 2 + 1) % 10], paint);
      canvas.drawLine(outerVerts[(i * 2 + 1) % 10], innerVerts[(i + 1) % 5],
          paint);
    }
  }

  void _drawHighlight(Canvas canvas, double cx, double cy, double r) {
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final highlightPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(cx - r * 0.28, cy - r * 0.32),
        width: r * 0.55,
        height: r * 0.35,
      ));
    canvas.drawPath(highlightPath, highlightPaint);

    final sharpHighlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.45);
    canvas.drawCircle(
        Offset(cx - r * 0.3, cy - r * 0.35), r * 0.07, sharpHighlight);
  }

  void _drawNumber(Canvas canvas, Size size, double squish) {
    final opacity = ((squish - 0.2) / 0.8).clamp(0.0, 1.0);

    Color numColor = Colors.white;
    if (isFinal && result == 20) numColor = AetherPalette.gold;
    if (isFinal && result == 1) numColor = const Color(0xFFFF8080);

    final fontSize = isFinal ? size.width * 0.28 : size.width * 0.22;

    final span = TextSpan(
      text: '$number',
      style: TextStyle(
        color: numColor.withValues(alpha: opacity),
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.7 * opacity),
            blurRadius: 6,
            offset: const Offset(1, 2),
          ),
          if (isFinal && (result == 20 || result == 1))
            Shadow(
              color: _glowColor.withValues(alpha: 0.8 * opacity),
              blurRadius: 12,
            ),
        ],
      ),
    );

    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
      canvas,
      Offset(
        size.width / 2 - tp.width / 2,
        size.height / 2 - tp.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_D20Painter old) =>
      old.spinY != spinY ||
      old.spinX != spinX ||
      old.number != number ||
      old.isFinal != isFinal ||
      old.glowIntensity != glowIntensity;
}

class D20ResultLabel extends StatefulWidget {
  final int result;

  const D20ResultLabel({super.key, required this.result});

  @override
  State<D20ResultLabel> createState() => _D20ResultLabelState();
}

class _D20ResultLabelState extends State<D20ResultLabel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeSlide = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (widget.result) {
      20 => ('Критический успех!', AetherPalette.gold, '⚡'),
      1 => ('Критический провал', const Color(0xFFFF4444), '💀'),
      >= 15 => ('Отличный бросок', AetherPalette.success, '✨'),
      >= 10 => ('Бросок: ${widget.result}', AetherPalette.textMuted, '🎲'),
      _ => ('Неудача...', AetherPalette.accent, '😬'),
    };

    return AnimatedBuilder(
      animation: _fadeSlide,
      builder: (_, __) => Opacity(
        opacity: _fadeSlide.value,
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - _fadeSlide.value)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$icon $label',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              if (widget.result != 20 && widget.result != 1)
                Text(
                  'д20 → ${widget.result}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class D20ChatBubble extends StatelessWidget {
  final int result;
  final VoidCallback? onFinished;

  const D20ChatBubble({
    super.key,
    required this.result,
    this.onFinished,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          D20RollWidget(result: result, onFinished: onFinished),
          const SizedBox(width: 14),
          D20ResultLabel(result: result),
        ],
      ),
    );
  }
}
