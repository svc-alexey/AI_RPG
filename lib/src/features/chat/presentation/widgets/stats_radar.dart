import 'dart:math';

import 'package:flutter/material.dart';

class StatsRadar extends StatelessWidget {
  const StatsRadar({
    required this.might,
    required this.wit,
    required this.spirit,
    this.size = 140,
    super.key,
  });

  final int might;
  final int wit;
  final int spirit;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(size, size),
    painter: _StatsRadarPainter(
      might: might.clamp(0, 10),
      wit: wit.clamp(0, 10),
      spirit: spirit.clamp(0, 10),
      radarStroke: const Color(0xFFBFA76F).withValues(alpha: 0.6),
      radarFill: const Color(0xFFBFA76F).withValues(alpha: 0.12),
      radarAxes: const Color(0xFF3D3328),
      radarLabel: const Color(0xFF888780),
    ),
  );
}

class _StatsRadarPainter extends CustomPainter {
  _StatsRadarPainter({
    required this.might,
    required this.wit,
    required this.spirit,
    required this.radarStroke,
    required this.radarFill,
    required this.radarAxes,
    required this.radarLabel,
  });

  final int might;
  final int wit;
  final int spirit;
  final Color radarStroke;
  final Color radarFill;
  final Color radarAxes;
  final Color radarLabel;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20;

    const labels = ['Might', 'Wit', 'Spirit'];
    final values = [might / 10.0, wit / 10.0, spirit / 10.0];

    final points = <Offset>[];
    for (var i = 0; i < 3; i++) {
      final angle = -pi / 2 + i * (2 * pi / 3);
      final r = radius * values[i];
      points.add(Offset(
        center.dx + r * cos(angle),
        center.dy + r * sin(angle),
      ));
    }

    // Axis lines
    final axisPaint = Paint()
      ..color = radarAxes
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      final angle = -pi / 2 + i * (2 * pi / 3);
      canvas.drawLine(
        center,
        Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle)),
        axisPaint,
      );
    }

    // Polygon fill
    final fillPath = Path()..addPolygon(points, true);
    canvas.drawPath(fillPath, Paint()..color = radarFill);

    // Polygon stroke
    final strokePath = Path()..addPolygon(points, true);
    canvas.drawPath(
      strokePath,
      Paint()
        ..color = radarStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Labels
    for (var i = 0; i < 3; i++) {
      final angle = -pi / 2 + i * (2 * pi / 3);
      final labelOffset = Offset(
        center.dx + (radius + 14) * cos(angle),
        center.dy + (radius + 14) * sin(angle),
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(color: radarLabel, fontSize: 11, height: 1.2),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        labelOffset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StatsRadarPainter oldDelegate) =>
      might != oldDelegate.might || wit != oldDelegate.wit || spirit != oldDelegate.spirit;
}
