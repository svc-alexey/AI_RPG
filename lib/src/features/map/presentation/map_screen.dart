/// MapScreen — spatial campaign map, the primary map view.
///
/// Desktop: 70/30 split (canvas + inspector).
/// Mobile: canvas full-width + DraggableScrollableSheet.
library;

import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/core/models/map_models.dart';
import 'package:ai_prg/src/features/map/presentation/map_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Map scale labels derived from common RPG location types.
/// Falls back to displaying the raw scale key when unknown (e.g. "space_station" → "space_station").
const _scaleLabels = {
  'room': 'Комната',
  'building': 'Здание',
  'district': 'Район',
  'city': 'Город',
  'region': 'Регион',
  'world': 'Мир',
  'station': 'Станция',
  'ship': 'Корабль',
  'planet': 'Планета',
  'system': 'Система',
  'habitat': 'Отсек',
  'level': 'Уровень',
  'zone': 'Зона',
  'sector': 'Сектор',
};

/// Returns a human-readable label for a scale key.
/// Falls back to the raw key with first letter capitalised.
String scaleLabel(String key) {
  final known = _scaleLabels[key];
  if (known != null) return known;
  // Capitalise first letter for unknown types
  if (key.isEmpty) return key;
  return key[0].toUpperCase() + key.substring(1);
}

class MapScreen extends ConsumerStatefulWidget {

  const MapScreen({
    required this.campaignId, required this.campaignTitle, super.key,
  });
  final String campaignId;
  final String campaignTitle;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  CampaignMap? _map;
  CampaignMapNode? _selectedNode;
  String _activeScale = 'room';
  final Map<String, PlayerMark> _playerMarks = {};
  bool _loading = true;
  String? _error;
  bool _showWorldPulse = false;
  ReturnSummary? _returnSummary;
  final TransformationController _transformCtrl = TransformationController();

  @override
  void initState() {
    super.initState();
    _loadMap();
    _loadReturnSummary();
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  void _centerOnNodes() {
    final nodes = _map?.nodes ?? [];
    if (nodes.isEmpty) return;

    // Compute bounding box of all nodes
    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
    for (final n in nodes) {
      if (n.x == null || n.y == null) continue;
      if (n.x! < minX) minX = n.x!;
      if (n.y! < minY) minY = n.y!;
      if (n.x! > maxX) maxX = n.x!;
      if (n.y! > maxY) maxY = n.y!;
    }
    if (!minX.isFinite) return;

    final boxWidth = maxX - minX + 200; // padding
    final boxHeight = maxY - minY + 200;
    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;

    // Calculate zoom to fit the bounding box
    final size = MediaQuery.of(context).size;
    final canvasWidth = _isMobile ? size.width : size.width * 0.7;
    final canvasHeight = _isMobile ? size.height * 0.5 : size.height;
    final scaleX = canvasWidth / boxWidth.clamp(400, 10000);
    final scaleY = canvasHeight / boxHeight.clamp(400, 10000);
    final scale = (scaleX < scaleY ? scaleX : scaleY).clamp(0.3, 2.0);

    // ignore: deprecated_member_use
    final matrix = Matrix4.identity()
      ..translate(-centerX * scale + canvasWidth / 2,
                   -centerY * scale + canvasHeight / 2)
      ..scale(scale);
    _transformCtrl.value = matrix;
  }

  Future<void> _loadMap() async {
    setState(() { _loading = true; _error = null; });
    try {
      final repo = ref.read(mapRepositoryProvider);
      final map = await repo.getMap(widget.campaignId);
      setState(() { _map = map; _loading = false; });
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerOnNodes());
    } catch (e) {
      setState(() { _loading = false; _error = 'Не удалось загрузить карту'; });
    }
  }

  Future<void> _loadReturnSummary() async {
    try {
      final repo = ref.read(mapRepositoryProvider);
      final summary = await repo.getReturnSummary(widget.campaignId);
      if (summary.newEventsCount > 0) {
        setState(() { _showWorldPulse = true; _returnSummary = summary; });
      }
    } catch (_) {}
  }

  void _onScaleChanged(String scale) {
    if (_activeScale == scale) return;
    setState(() { _activeScale = scale; });
  }

  void _onNodeTap(CampaignMapNode node) {
    setState(() { _selectedNode = node; });
    if (_isMobile) {
      _showInspectorSheet(context, node);
    }
  }

  void _onNodeLongPress(CampaignMapNode node) {
    _showPlayerMarkMenu(context, node);
  }

  void _showPlayerMarkMenu(BuildContext context, CampaignMapNode node) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF12100E),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('⚐', style: TextStyle(fontSize: 20)),
              title: const Text('Важно'),
              onTap: () {
                setState(() { _playerMarks[node.id] = PlayerMark.important; });
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Text('⚑', style: TextStyle(fontSize: 20)),
              title: const Text('Подозрительно'),
              onTap: () {
                setState(() { _playerMarks[node.id] = PlayerMark.suspicious; });
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Text('↩', style: TextStyle(fontSize: 20)),
              title: const Text('Вернуться'),
              onTap: () {
                setState(() { _playerMarks[node.id] = PlayerMark.returnHere; });
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInspectorSheet(BuildContext context, CampaignMapNode node) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF12100E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: Color(0xFF3D3328)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        minChildSize: 0.3,
        maxChildSize: 0.75,
        expand: false,
        builder: (ctx, scrollCtrl) => _InspectorContent(
          node: node,
          scrollController: scrollCtrl,
        ),
      ),
    );
  }

  void _dismissWorldPulse() {
    setState(() { _showWorldPulse = false; });
    ref.read(mapRepositoryProvider).markSeen(widget.campaignId);
  }

  bool get _isMobile => MediaQuery.of(context).size.width < 600;

  @override
  Widget build(BuildContext context) {
    final nodes = _map?.nodes ?? [];
    final edges = _map?.edges ?? [];
    final availableScales = _map?.availableScales ?? ['room', 'castle'];
    final highlightedIds = _selectedNode != null
        ? {_selectedNode!.id}
        : <String>{};

    return Scaffold(
      backgroundColor: const Color(0xFF0A0908),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF7A7570)),
          tooltip: 'Назад',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.campaignTitle,
          style: const TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 18,
            color: Color(0xFFE8E4E0),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _loading
            ? _buildLoading()
            : _error != null
                ? _buildError()
                : _isMobile
                    ? _buildMobile(nodes, edges, availableScales, highlightedIds)
                    : _buildDesktop(nodes, edges, availableScales, highlightedIds),
      ),
    );
  }

  Widget _buildLoading() => const Center(
        child: CircularProgressIndicator(color: Color(0xFFC87941)),
      );

  Widget _buildError() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Не удалось загрузить карту',
              style: TextStyle(color: Color(0xFF7A7570), fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC87941),
              ),
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      );

  Widget _buildMobile(
    List<CampaignMapNode> nodes,
    List<CampaignMapEdge> edges,
    List<String> scales,
    Set<String> highlightedIds,
  ) => Stack(
      children: [
        Column(
          children: [
            _MapTopBar(
              title: widget.campaignTitle,
              subtitle: '${scaleLabel(_activeScale)} · Ход 0',
              scales: scales,
              activeScale: _activeScale,
              onScaleChanged: _onScaleChanged,
            ),
            Expanded(
              child: MapCanvasWidget(
                nodes: nodes,
                edges: edges,
                highlightedNodeIds: highlightedIds,
                playerMarks: _playerMarks,
                onNodeTap: _onNodeTap,
                onNodeLongPress: _onNodeLongPress,
                transformController: _transformCtrl,
              ),
            ),
          ],
        ),
        if (_showWorldPulse && _returnSummary != null)
          _WorldPulseOverlay(
            summary: _returnSummary!,
            onDismiss: _dismissWorldPulse,
          ),
      ],
    );

  Widget _buildDesktop(
    List<CampaignMapNode> nodes,
    List<CampaignMapEdge> edges,
    List<String> scales,
    Set<String> highlightedIds,
  ) => Row(
      children: [
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _MapTopBar(
                title: widget.campaignTitle,
                subtitle: scaleLabel(_activeScale),
                scales: scales,
                activeScale: _activeScale,
                onScaleChanged: _onScaleChanged,
              ),
              Expanded(
                child: Stack(
                  children: [
                    MapCanvasWidget(
                      nodes: nodes,
                      edges: edges,
                      highlightedNodeIds: highlightedIds,
                      playerMarks: _playerMarks,
                      onNodeTap: _onNodeTap,
                      onNodeLongPress: _onNodeLongPress,
                      transformController: _transformCtrl,
                    ),
                    if (_showWorldPulse && _returnSummary != null)
                      _WorldPulseOverlay(
                        summary: _returnSummary!,
                        onDismiss: _dismissWorldPulse,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: _selectedNode != null
              ? _InspectorContent(
                  node: _selectedNode!,
                  onTravelTap: () {
                    Navigator.of(context).pop();
                  },
                )
              : const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Выберите локацию\nна карте',
                      style: TextStyle(
                        color: Color(0xFF5A5550),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
        ),
      ],
    );
}

// --- Sub-widgets ---

class _MapTopBar extends StatelessWidget {

  const _MapTopBar({
    required this.title,
    required this.subtitle,
    required this.scales,
    required this.activeScale,
    required this.onScaleChanged,
  });
  final String title;
  final String subtitle;
  final List<String> scales;
  final String activeScale;
  final ValueChanged<String> onScaleChanged;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 20,
                    color: Color(0xFFE8E4E0),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF7A7570)),
                ),
              ],
            ),
          ),
          SegmentedButton<String>(
            segments: scales.map((s) {
              final label = scaleLabel(s);
              return ButtonSegment<String>(
                value: s,
                label: Text(label, style: const TextStyle(fontSize: 11)),
              );
            }).toList(),
            selected: {activeScale},
            onSelectionChanged: (sel) => onScaleChanged(sel.first),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF1A1512);
                }
                return Colors.transparent;
              }),
            ),
          ),
        ],
      ),
    );
}

class _InspectorContent extends StatelessWidget {

  const _InspectorContent({
    required this.node,
    this.scrollController,
    this.onTravelTap,
  });
  final CampaignMapNode node;
  final ScrollController? scrollController;
  final VoidCallback? onTravelTap;

  @override
  Widget build(BuildContext context) => ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          node.title,
          style: const TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 18,
            color: Color(0xFFE8E4E0),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          scaleLabel(node.locationType),
          style: const TextStyle(fontSize: 11, color: Color(0xFF7A7570)),
        ),
        const SizedBox(height: 12),
        if (node.nodeState == MapNodeState.current)
          _badge('◉ вы здесь', const Color(0xFF34D399)),
        if (node.nodeState == MapNodeState.threat)
          _badge('⚠ угроза', const Color(0xFFD85A30)),
        const SizedBox(height: 16),
        _section('Последние события', [
          if (node.eventsCount > 0)
            _eventLine('Событий в этой локации: ${node.eventsCount}')
          else
            _eventLine('Нет недавних событий'),
        ]),
        const SizedBox(height: 12),
        _section('Связи', [
          _eventLine(node.isReachable
              ? 'Доступна для перехода'
              : 'Недоступна — локация скрыта или заблокирована'),
        ]),
        if (node.frontBadges.isNotEmpty) ...[
          const SizedBox(height: 12),
          _section('Активные фронты', [
            for (final badge in node.frontBadges)
              _eventLine('Фронт: $badge'),
          ]),
        ],
        if (node.isReachable && node.travelPrompt != null) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTravelTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1512),
                side: const BorderSide(color: Color(0xFFC87941)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                node.travelPrompt!,
                style: const TextStyle(color: Color(0xFFC87941)),
              ),
            ),
          ),
        ],
      ],
    );

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
      );

  Widget _section(String title, List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF5A5550),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      );

  Widget _eventLine(String text) => Text(
        text,
        style: const TextStyle(fontSize: 11, color: Color(0xFF7A7570)),
      );
}

class _WorldPulseOverlay extends StatelessWidget {

  const _WorldPulseOverlay({
    required this.summary,
    required this.onDismiss,
  });
  final ReturnSummary summary;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) => Positioned(
      top: 8,
      left: 16,
      right: 16,
      child: Material(
        color: const Color(0xEE12100E),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.circle, color: Color(0xFFBFA76F), size: 8),
                  const SizedBox(width: 6),
                  Text(
                    '${summary.newEventsCount} новых событий',
                    style: const TextStyle(
                      color: Color(0xFFBFA76F),
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onDismiss,
                    child: const Text(
                      'Понятно',
                      style: TextStyle(
                        color: Color(0xFFC87941),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...summary.digest.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.category == 'threat' ? '⚠' : '◉',
                          style: TextStyle(
                            fontSize: 10,
                            color: item.category == 'threat'
                                ? const Color(0xFFD85A30)
                                : const Color(0xFFBFA76F),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7A7570),
                              ),
                              children: [
                                TextSpan(
                                  text: '${item.locationTitle}: ',
                                  style: const TextStyle(
                                    color: Color(0xFFE8E4E0),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(text: item.eventText),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
}
