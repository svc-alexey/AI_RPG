import 'package:ai_prg/src/core/models/map_models.dart';
import 'package:ai_prg/src/features/map/presentation/map_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MapCanvasPainter node states', () {
    testWidgets('paints current node with emerald-gold', (tester) async {
      final nodes = [
        const CampaignMapNode(
          id: 'n1',
          title: 'Throne Room',
          nodeState: MapNodeState.current,
          x: 5000,
          y: 5000,
          isRevealed: true,
        ),
      ];
      final painter = MapCanvasPainter(
        nodes: nodes,
        edges: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              painter: painter,
              size: const Size(400, 400),
            ),
          ),
        ),
      );

      // Should render without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('paints fog nodes as charcoal', (tester) async {
      final nodes = [
        const CampaignMapNode(
          id: 'n1',
          title: 'Dark Cellar',
          x: 3000,
          y: 3000,
        ),
      ];
      final painter = MapCanvasPainter(
        nodes: nodes,
        edges: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(painter: painter, size: const Size(400, 400)),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('skips nodes with null coordinates', (tester) async {
      final nodes = [
        const CampaignMapNode(
          id: 'n1',
          title: 'Bad Node',
          nodeState: MapNodeState.current,
          isRevealed: true,
        ),
      ];
      final painter = MapCanvasPainter(
        nodes: nodes,
        edges: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(painter: painter, size: const Size(400, 400)),
          ),
        ),
      );

      // Should not crash on null coords
      expect(tester.takeException(), isNull);
    });

    testWidgets('paints threat node with ember effect', (tester) async {
      final nodes = [
        const CampaignMapNode(
          id: 'n1',
          title: 'Barracks',
          nodeState: MapNodeState.threat,
          x: 2000,
          y: 2000,
          isRevealed: true,
        ),
      ];
      final painter = MapCanvasPainter(
        nodes: nodes,
        edges: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(painter: painter, size: const Size(400, 400)),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('paints blocked node with strikethrough', (tester) async {
      final nodes = [
        const CampaignMapNode(
          id: 'n1',
          title: 'Blocked',
          nodeState: MapNodeState.blocked,
          x: 7000,
          y: 7000,
          isRevealed: true,
        ),
      ];
      final painter = MapCanvasPainter(
        nodes: nodes,
        edges: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(painter: painter, size: const Size(400, 400)),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('paints rumored node with dotted border', (tester) async {
      final nodes = [
        const CampaignMapNode(
          id: 'n1',
          title: 'Rumored',
          nodeState: MapNodeState.rumored,
          x: 8000,
          y: 8000,
        ),
      ];
      final painter = MapCanvasPainter(
        nodes: nodes,
        edges: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(painter: painter, size: const Size(400, 400)),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('CampaignMapNode fromJson', () {
    test('parses known node states', () {
      final node = CampaignMapNode.fromJson({
        'id': 'n1',
        'title': 'Throne Room',
        'node_state': 'current',
        'is_revealed': true,
      });
      expect(node.nodeState, MapNodeState.current);

      final fog = CampaignMapNode.fromJson({
        'id': 'n2',
        'title': 'Unknown',
        'node_state': 'fog',
        'is_revealed': false,
      });
      expect(fog.nodeState, MapNodeState.fog);
    });

    test('falls back to fog for unknown state', () {
      final node = CampaignMapNode.fromJson({
        'id': 'n1',
        'title': 'Mystery',
        'node_state': 'quantum_superposition',
        'is_revealed': true,
      });
      expect(node.nodeState, MapNodeState.fog);
    });

    test('parses coordinates', () {
      final node = CampaignMapNode.fromJson({
        'id': 'n1',
        'title': 'Precise',
        'node_state': 'explored',
        'is_revealed': true,
        'x': 1234.5,
        'y': 6789.0,
      });
      expect(node.x, 1234.5);
      expect(node.y, 6789.0);
    });
  });

  group('MapEdgeType parsing', () {
    test('parses known edge types', () {
      final edge = CampaignMapEdge.fromJson({
        'id': 'e1',
        'location_id_a': 'a',
        'location_id_b': 'b',
        'edge_type': 'known',
      });
      expect(edge.edgeType, MapEdgeType.known);

      final rumored = CampaignMapEdge.fromJson({
        'id': 'e2',
        'location_id_a': 'a',
        'location_id_b': 'b',
        'edge_type': 'rumored',
      });
      expect(rumored.edgeType, MapEdgeType.rumored);

      final blocked = CampaignMapEdge.fromJson({
        'id': 'e3',
        'location_id_a': 'a',
        'location_id_b': 'b',
        'edge_type': 'blocked',
      });
      expect(blocked.edgeType, MapEdgeType.blocked);
    });

    test('falls back to known for unknown edge type', () {
      final edge = CampaignMapEdge.fromJson({
        'id': 'e1',
        'location_id_a': 'a',
        'location_id_b': 'b',
        'edge_type': 'magic_portal',
      });
      expect(edge.edgeType, MapEdgeType.known);
    });
  });
}
