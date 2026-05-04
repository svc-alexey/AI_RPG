/// MapCanvas — CustomPainter-based spatial map rendering.
///
/// Renders nodes (6 visual states) + edges (3 types) on a dark bronze grid.
/// Wrapped in InteractiveViewer for zoom/pan. Supports tap + long-press.
library;

import 'dart:math' as math;

import 'package:ai_prg/src/core/models/map_models.dart';
import 'package:flutter/material.dart';

/// Design tokens from Aether DESIGN.md
class MapTokens {
  static const bg = Color(0xFF0A0908);
  static const gridColor = Color(0x0FBFA76F);
  static const goldBorder = Color(0xFFBFA76F);
  static const currentFillCenter = Color(0xFF34D399);
  static const currentFillEdge = Color(0xFF1A1512);
  static const exploredFill = Color(0xFF888780);
  static const threatFillCenter = Color(0xFFD85A30);
  static const threatFillEdge = Color(0xFF1A1512);
  static const threatRingColor = Color(0x1FD85A30);
  static const fogFill = Color(0xFF1A1816);
  static const fogBorder = Color(0xFF3D3328);
  static const textPrimary = Color(0xFFE8E4E0);
  static const textMuted = Color(0xFF7A7570);
  static const textDim = Color(0xFF5A5550);
  static const edgeKnown = Color(0x993D3328);
  static const labelFontSize = 10.0;
}

class MapCanvasPainter extends CustomPainter {

  MapCanvasPainter({
    required this.nodes,
    required this.edges,
    this.highlightedNodeIds,
    this.canvasSize = const Size(10000, 10000),
    this.playerMarks = const {},
    this.viewportScale = 1.0,
  });
  final List<CampaignMapNode> nodes;
  final List<CampaignMapEdge> edges;
  final Set<String>? highlightedNodeIds;
  final Size canvasSize;
  final Map<String, PlayerMark> playerMarks;
  final double viewportScale;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawEdges(canvas);
    _drawNodes(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MapTokens.gridColor
      ..strokeWidth = 1.0 / viewportScale.clamp(0.5, 2.0);

    const gridStep = 200.0;
    for (double x = 0; x < canvasSize.width; x += gridStep) {
      final sx = (x / canvasSize.width) * size.width;
      canvas.drawLine(Offset(sx, 0), Offset(sx, size.height), paint);
    }
    for (double y = 0; y < canvasSize.height; y += gridStep) {
      final sy = (y / canvasSize.height) * size.height;
      canvas.drawLine(Offset(0, sy), Offset(size.width, sy), paint);
    }
  }

  void _drawEdges(Canvas canvas) {
    final nodeMap = {for (final n in nodes) n.id: n};
    for (final edge in edges) {
      final a = nodeMap[edge.locationIdA];
      final b = nodeMap[edge.locationIdB];
      if (a?.x == null || a?.y == null || b?.x == null || b?.y == null) continue;

      final paint = Paint()
        ..strokeWidth = 1.5 / viewportScale.clamp(0.5, 2.0)
        ..style = PaintingStyle.stroke
        ..color = MapTokens.edgeKnown;

      if (edge.edgeType == MapEdgeType.blocked) {
        paint.color = MapTokens.edgeKnown.withValues(alpha: 0.3);
      }

      canvas.drawLine(
        Offset(a!.x!, a.y!),
        Offset(b!.x!, b.y!),
        paint,
      );

      // Dashed effect for rumored
      if (edge.edgeType == MapEdgeType.rumored) {
        paint.color = MapTokens.edgeKnown;
        _drawDashedLine(canvas, Offset(a.x!, a.y!), Offset(b.x!, b.y!), paint);
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final dist = (dx * dx + dy * dy).clamp(1.0, double.infinity);
    final len = math.sqrt(dist);
    final ux = dx / len;
    final uy = dy / len;
    const dashLen = 6.0;
    const gapLen = 4.0;
    double pos = 0.0;
    bool dash = true;
    while (pos < len) {
      final step = dash ? dashLen : gapLen;
      final double end = (pos + step).clamp(0.0, len);
      if (dash) {
        canvas.drawLine(
          Offset(a.dx + ux * pos, a.dy + uy * pos),
          Offset(a.dx + ux * end, a.dy + uy * end),
          paint,
        );
      }
      pos = end;
      dash = !dash;
    }
  }

  void _drawNodes(Canvas canvas, Size size) {
    for (final node in nodes) {
      if (node.x == null || node.y == null) continue;
      final center = Offset(node.x!, node.y!);

      // LOD: simplify at low zoom
      final scale = viewportScale;
      final radius = scale < 0.7 ? 10.0 : 16.0;

      switch (node.nodeState) {
        case MapNodeState.current:
          _drawCurrentNode(canvas, center, radius, node.id);
        case MapNodeState.explored:
          _drawExploredNode(canvas, center, radius, node.id);
        case MapNodeState.threat:
          _drawThreatNode(canvas, center, radius, node.id);
        case MapNodeState.fog:
          _drawFogNode(canvas, center, radius, node.id);
        case MapNodeState.rumored:
          _drawRumoredNode(canvas, center, radius, node.id);
        case MapNodeState.blocked:
          _drawBlockedNode(canvas, center, radius, node.id);
      }

      // Player marks
      final mark = playerMarks[node.id];
      if (mark != null) {
        final icon = switch (mark) {
          PlayerMark.important => '⚐',
          PlayerMark.suspicious => '⚑',
          PlayerMark.returnHere => '↩',
        };
        final tp = TextPainter(
          text: TextSpan(
            text: icon,
            style: TextStyle(
              fontSize: 12 / viewportScale.clamp(0.5, 2.0),
              color: const Color(0xFFC87941),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, center - Offset(tp.width / 2, radius + 16));
      }
    }
  }

  void _drawCurrentNode(Canvas canvas, Offset center, double radius, String id) {
    // Emerald-gold core with glow
    final glowPaint = Paint()
      ..color = MapTokens.goldBorder.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(center, radius + 8, glowPaint);

    const gradient = RadialGradient(
      colors: [MapTokens.currentFillCenter, MapTokens.currentFillEdge],
    );
    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fillPaint);

    final borderPaint = Paint()
      ..color = MapTokens.goldBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);

    _drawLabel(canvas, '▼ вы здесь', center, radius, MapTokens.goldBorder);
  }

  void _drawExploredNode(Canvas canvas, Offset center, double radius, String id) {
    final fillPaint = Paint()..color = MapTokens.exploredFill;
    canvas.drawCircle(center, radius, fillPaint);

    final borderPaint = Paint()
      ..color = MapTokens.goldBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, borderPaint);
  }

  void _drawThreatNode(Canvas canvas, Offset center, double radius, String id) {
    // Threat ring
    final ringPaint = Paint()
      ..color = MapTokens.threatRingColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius + 6, ringPaint);

    const gradient = RadialGradient(
      colors: [MapTokens.threatFillCenter, MapTokens.threatFillEdge],
    );
    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fillPaint);

    final borderPaint = Paint()
      ..color = MapTokens.threatFillCenter
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, borderPaint);
  }

  void _drawFogNode(Canvas canvas, Offset center, double radius, String id) {
    final fillPaint = Paint()..color = MapTokens.fogFill;
    canvas.drawCircle(center, radius, fillPaint);

    final borderPaint = Paint()
      ..color = MapTokens.fogBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    // Dashed circle for fog
    _drawDashedCircle(canvas, center, radius, borderPaint);
  }

  void _drawRumoredNode(Canvas canvas, Offset center, double radius, String id) {
    final fillPaint = Paint()..color = MapTokens.fogFill;
    canvas.drawCircle(center, radius, fillPaint);

    final borderPaint = Paint()
      ..color = MapTokens.goldBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    // Dotted circle
    _drawDottedCircle(canvas, center, radius, borderPaint);
  }

  void _drawBlockedNode(Canvas canvas, Offset center, double radius, String id) {
    final fillPaint = Paint()..color = MapTokens.fogFill.withValues(alpha: 0.5);
    canvas.drawCircle(center, radius, fillPaint);

    final borderPaint = Paint()
      ..color = MapTokens.textDim
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, borderPaint);

    // Strikethrough line
    final strikePaint = Paint()
      ..color = MapTokens.textDim
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      strikePaint,
    );
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    const segments = 16;
    const dashRatio = 0.6;
    for (var i = 0; i < segments; i++) {
      final startAngle = (i / segments) * 2 * 3.14159;
      const sweepAngle = (dashRatio / segments) * 2 * 3.14159;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  void _drawDottedCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    const dots = 20;
    for (var i = 0; i < dots; i++) {
      final angle = (i / dots) * 2 * 3.14159;
      final dotCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawCircle(dotCenter, 2.0, paint);
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset nodeCenter, double radius, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: MapTokens.labelFontSize,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, nodeCenter - Offset(tp.width / 2, -(radius + 4)));
  }

  @override
  bool shouldRepaint(covariant MapCanvasPainter oldDelegate) =>
      oldDelegate.nodes != nodes ||
      oldDelegate.edges != edges ||
      oldDelegate.highlightedNodeIds != highlightedNodeIds ||
      oldDelegate.playerMarks != playerMarks ||
      oldDelegate.viewportScale != viewportScale;
}

/// Widget wrapping the canvas with InteractiveViewer for zoom/pan.
class MapCanvasWidget extends StatefulWidget {

  const MapCanvasWidget({
    required this.nodes, required this.edges, super.key,
    this.highlightedNodeIds,
    this.playerMarks = const {},
    this.onNodeTap,
    this.onNodeLongPress,
    this.transformController,
  });
  final List<CampaignMapNode> nodes;
  final List<CampaignMapEdge> edges;
  final Set<String>? highlightedNodeIds;
  final Map<String, PlayerMark> playerMarks;
  final void Function(CampaignMapNode node)? onNodeTap;
  final void Function(CampaignMapNode node)? onNodeLongPress;
  final TransformationController? transformController;

  @override
  State<MapCanvasWidget> createState() => _MapCanvasWidgetState();
}

class _MapCanvasWidgetState extends State<MapCanvasWidget> {
  late final TransformationController _transformCtrl;
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _transformCtrl = widget.transformController ?? TransformationController();
  }

  @override
  void didUpdateWidget(covariant MapCanvasWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transformController != null &&
        widget.transformController != oldWidget.transformController) {
      // External controller changed — dispose old internal one and use new
      if (oldWidget.transformController == null) {
        _transformCtrl.dispose();
        _transformCtrl = widget.transformController!;
      }
    }
  }

  @override
  void dispose() {
    if (widget.transformController == null) {
      _transformCtrl.dispose();
    }
    super.dispose();
  }

  CampaignMapNode? _hitTest(Offset localPos) {
    // Transform local position back to canvas coordinates
    final matrix = Matrix4.inverted(_transformCtrl.value);
    final canvasPos = MatrixUtils.transformPoint(matrix, localPos);

    final tolerance = 24.0 / _currentScale.clamp(0.5, 2.0);
    for (final node in widget.nodes.reversed) {
      if (node.x == null || node.y == null) continue;
      final dx = canvasPos.dx - node.x!;
      final dy = canvasPos.dy - node.y!;
      if (dx * dx + dy * dy < tolerance * tolerance) {
        return node;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTapUp: (details) {
        final node = _hitTest(details.localPosition);
        if (node != null) {
          widget.onNodeTap?.call(node);
        }
      },
      onLongPressStart: (details) {
        final node = _hitTest(details.localPosition);
        if (node != null) {
          widget.onNodeLongPress?.call(node);
        }
      },
      child: InteractiveViewer(
        transformationController: _transformCtrl,
        constrained: false,
        boundaryMargin: const EdgeInsets.all(200),
        minScale: 0.3,
        maxScale: 3.0,
        onInteractionEnd: (_) {
          setState(() {
            _currentScale = _transformCtrl.value.getMaxScaleOnAxis();
          });
        },
        child: Semantics(
          label: 'Карта мира',
          child: CustomPaint(
            painter: MapCanvasPainter(
              nodes: widget.nodes,
              edges: widget.edges,
              highlightedNodeIds: widget.highlightedNodeIds,
              playerMarks: widget.playerMarks,
              viewportScale: _currentScale,
            ),
            size: const Size(10000, 10000),
          ),
        ),
      ),
    );
}
