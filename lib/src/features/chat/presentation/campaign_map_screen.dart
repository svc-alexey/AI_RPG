import 'dart:math' as math;

import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/core/models/campaign_map_models.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/repositories/symmetry_campaign_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class CampaignMapScreen extends ConsumerStatefulWidget {
  const CampaignMapScreen({
    required this.campaignId,
    required this.campaignTitle,
    required this.onTravelIntent,
    super.key,
  });

  final String campaignId;
  final String campaignTitle;
  final Future<void> Function(String prompt) onTravelIntent;

  @override
  ConsumerState<CampaignMapScreen> createState() => _CampaignMapScreenState();
}

class _CampaignMapScreenState extends ConsumerState<CampaignMapScreen> {
  bool _isLoading = true;
  bool _isTraveling = false;
  String? _error;
  CampaignMapView? _map;
  String _mode = 'local';
  String? _selectedNodeId;
  Map<String, CampaignMapMark> _marks = <String, CampaignMapMark>{};

  SymmetryCampaignRepository get _campaignRepository =>
      ref.read(symmetryCampaignRepositoryProvider);
  SettingsRepository get _settingsRepository =>
      ref.read(settingsRepositoryProvider);

  bool get _isRussian => Localizations.localeOf(
    context,
  ).languageCode.toLowerCase().startsWith('ru');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitial();
    });
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final CampaignMapView map = await _campaignRepository.loadCampaignMap(
        widget.campaignId,
      );
      final Map<String, String> rawMarks = await _settingsRepository
          .loadCampaignMapMarks(widget.campaignId);
      if (!mounted) {
        return;
      }
      setState(() {
        _map = map;
        _mode =
            map.activeScale == CampaignMapScale.region ||
                map.activeScale == CampaignMapScale.world
            ? 'global'
            : 'local';
        _selectedNodeId = _preferredNodeIdForMode(map: map, mode: _mode);
        _marks = rawMarks.map(
          (final key, final value) => MapEntry(
            key,
            CampaignMapMark.values.firstWhere(
              (final item) => item.name == value,
              orElse: () => CampaignMapMark.important,
            ),
          ),
        );
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    await _loadReturnSummary();
  }

  Future<void> _loadReturnSummary() async {
    try {
      final CampaignReturnSummary summary = await _campaignRepository
          .loadCampaignReturnSummary(widget.campaignId);
      if (!mounted || summary.unseenCount <= 0) {
        return;
      }
      await _showReturnSummary(summary);
    } catch (_) {
      // Keep the map usable even if the return digest could not be loaded.
    }
  }

  Future<void> _showReturnSummary(final CampaignReturnSummary summary) =>
      showDialog<void>(
        context: context,
        builder: (final context) => Dialog(
          backgroundColor: Colors.transparent,
          child: AetherCard(
            highlight: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _isRussian ? 'Пульс мира' : 'World Pulse',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    color: AetherPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isRussian
                      ? 'Пока вас не было, мир заметно сдвинулся:'
                      : 'While you were away, the world shifted:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AetherPalette.textMuted,
                  ),
                ),
                const SizedBox(height: 18),
                for (final CampaignMapEvent item in summary.events)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '• ${item.text}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AetherPalette.narrativeText,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(_isRussian ? 'Продолжить' : 'Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  CampaignMapPlane? get _activePlane {
    final CampaignMapView? map = _map;
    if (map == null) {
      return null;
    }
    return _mode == 'global' ? map.globalView : map.localView;
  }

  String? _preferredNodeIdForMode({
    required final CampaignMapView map,
    required final String mode,
  }) {
    final CampaignMapPlane plane = mode == 'global'
        ? map.globalView
        : map.localView;
    return _resolvedSelectedNodeId(
      plane,
      preferredId: _selectedNodeId,
      map: map,
    );
  }

  String? _resolvedSelectedNodeId(
    final CampaignMapPlane plane, {
    final String? preferredId,
    final CampaignMapView? map,
  }) {
    if (plane.nodes.isEmpty) {
      return null;
    }
    if (preferredId != null &&
        plane.nodes.any((final item) => item.id == preferredId)) {
      return preferredId;
    }
    final List<String> fallbackIds = <String>[
      if (map?.focusNodeId.isNotEmpty ?? false) map!.focusNodeId,
      if (map?.currentNodeId.isNotEmpty ?? false) map!.currentNodeId,
    ];
    for (final String id in fallbackIds) {
      if (plane.nodes.any((final item) => item.id == id)) {
        return id;
      }
    }
    final CampaignMapNode? currentNode = plane.nodes
        .cast<CampaignMapNode?>()
        .firstWhere(
          (final item) => item?.state == CampaignMapNodeState.current,
          orElse: () => null,
        );
    if (currentNode != null) {
      return currentNode.id;
    }
    return plane.nodes.first.id;
  }

  CampaignMapNode? _nodeById(
    final CampaignMapPlane plane,
    final String? nodeId,
  ) {
    if (nodeId == null) {
      return null;
    }
    return plane.nodes.cast<CampaignMapNode?>().firstWhere(
      (final item) => item?.id == nodeId,
      orElse: () => null,
    );
  }

  List<CampaignMapEvent> _eventsForNode(final CampaignMapNode node) {
    final CampaignMapView? map = _map;
    if (map == null) {
      return const <CampaignMapEvent>[];
    }
    if (node.events.isNotEmpty) {
      return node.events;
    }
    return map.returnEvents
        .where(
          (final item) =>
              item.locationSlug.trim().isNotEmpty &&
              item.locationSlug.trim() == node.slug.trim(),
        )
        .toList();
  }

  Future<void> _setMark(
    final CampaignMapNode node,
    final CampaignMapMark? mark,
  ) async {
    final Map<String, CampaignMapMark> next = <String, CampaignMapMark>{
      ..._marks,
    };
    if (mark == null) {
      next.remove(node.id);
    } else {
      next[node.id] = mark;
    }
    setState(() {
      _marks = next;
    });
    await _settingsRepository.saveCampaignMapMarks(
      widget.campaignId,
      next.map((final key, final value) => MapEntry(key, value.name)),
    );
  }

  Future<void> _showMarkPicker(final CampaignMapNode node) =>
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (final context) => AetherCard(
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _MarkSheetTile(
                  label: _isRussian ? 'Подозрительно' : 'Suspicious',
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _setMark(node, CampaignMapMark.suspicious);
                  },
                ),
                _MarkSheetTile(
                  label: _isRussian ? 'Важно' : 'Important',
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _setMark(node, CampaignMapMark.important);
                  },
                ),
                _MarkSheetTile(
                  label: _isRussian ? 'Вернуться' : 'Return later',
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _setMark(node, CampaignMapMark.returnLater);
                  },
                ),
                _MarkSheetTile(
                  label: _isRussian ? 'Убрать метку' : 'Clear mark',
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _setMark(node, null);
                  },
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> _travelToSelected(final CampaignMapNode? node) async {
    if (node == null || _isTraveling || !node.isReachable) {
      return;
    }
    if (node.state == CampaignMapNodeState.current) {
      return;
    }
    setState(() {
      _isTraveling = true;
    });
    try {
      await widget.onTravelIntent(node.travelPrompt);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTraveling = false;
        });
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    final CampaignMapView? map = _map;
    final CampaignMapPlane? activePlane = _activePlane;
    final String? selectedNodeId = map == null || activePlane == null
        ? null
        : _resolvedSelectedNodeId(
            activePlane,
            preferredId: _selectedNodeId,
            map: map,
          );
    final CampaignMapNode? selectedNode = activePlane == null
        ? null
        : _nodeById(activePlane, selectedNodeId);
    final List<CampaignMapEvent> selectedEvents = selectedNode == null
        ? const <CampaignMapEvent>[]
        : _eventsForNode(selectedNode);
    final bool wide = MediaQuery.of(context).size.width >= 1100;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _isRussian ? 'Карта кампании' : 'Campaign Map',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                color: AetherPalette.textPrimary,
              ),
            ),
            Text(
              widget.campaignTitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AetherPalette.textDim),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            tooltip: _isRussian ? 'Обновить' : 'Refresh',
            onPressed: _isLoading ? null : _loadInitial,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: AetherBackdrop(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AetherPalette.textPrimary,
                    ),
                  ),
                )
              : map == null || activePlane == null
              ? Center(
                  child: Text(
                    _isRussian
                        ? 'Карта пока недоступна.'
                        : 'Map is not available yet.',
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      _buildTopBar(map),
                      const SizedBox(height: 18),
                      Expanded(
                        child: wide
                            ? Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 7,
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 280,
                                      ),
                                      switchInCurve: Curves.easeOutCubic,
                                      switchOutCurve: Curves.easeInCubic,
                                      child: KeyedSubtree(
                                        key: ValueKey<String>(
                                          '${activePlane.scale.name}_${activePlane.title}',
                                        ),
                                        child: _buildCanvas(
                                          activePlane,
                                          selectedNodeId: selectedNodeId,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    flex: 3,
                                    child: _buildInspector(
                                      map: map,
                                      plane: activePlane,
                                      selectedNode: selectedNode,
                                      selectedEvents: selectedEvents,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: <Widget>[
                                  Expanded(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 280,
                                      ),
                                      switchInCurve: Curves.easeOutCubic,
                                      switchOutCurve: Curves.easeInCubic,
                                      child: KeyedSubtree(
                                        key: ValueKey<String>(
                                          '${activePlane.scale.name}_${activePlane.title}',
                                        ),
                                        child: _buildCanvas(
                                          activePlane,
                                          selectedNodeId: selectedNodeId,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    height: 300,
                                    child: _buildInspector(
                                      map: map,
                                      plane: activePlane,
                                      selectedNode: selectedNode,
                                      selectedEvents: selectedEvents,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTopBar(final CampaignMapView map) => Row(
    children: <Widget>[
      Expanded(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final CampaignMapBreadcrumb item in map.breadcrumbs)
              Chip(
                label: Text(item.label),
                backgroundColor: AetherPalette.panelSoft,
                side: const BorderSide(color: AetherPalette.panelBorder),
              ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      SegmentedButton<String>(
        segments: <ButtonSegment<String>>[
          ButtonSegment<String>(
            value: 'local',
            label: Text(_isRussian ? 'Локально' : 'Local'),
            enabled: map.localView.nodes.isNotEmpty,
          ),
          ButtonSegment<String>(
            value: 'global',
            label: Text(_isRussian ? 'Глобально' : 'Global'),
            enabled: map.globalView.nodes.isNotEmpty,
          ),
        ],
        selected: <String>{_mode},
        onSelectionChanged: (final selection) {
          setState(() {
            _mode = selection.first;
            _selectedNodeId = _preferredNodeIdForMode(map: map, mode: _mode);
          });
        },
      ),
    ],
  );

  Widget _buildCanvas(
    final CampaignMapPlane plane, {
    required final String? selectedNodeId,
  }) => AetherCard(
    padding: const EdgeInsets.all(16),
    child: LayoutBuilder(
      builder: (final context, final constraints) {
        final List<CampaignMapNode> nodes = plane.nodes;
        if (nodes.isEmpty) {
          return Center(
            child: Text(
              _isRussian
                  ? 'Нет точек для этого масштаба.'
                  : 'No nodes for this scale.',
            ),
          );
        }
        return Stack(
          children: <Widget>[
            Positioned.fill(child: CustomPaint(painter: _MapBackdropPainter())),
            Positioned.fill(
              child: CustomPaint(
                painter: _MapConnectionsPainter(
                  nodes: nodes,
                  selectedNodeId: selectedNodeId,
                ),
              ),
            ),
            for (final CampaignMapNode node in nodes)
              Positioned(
                left: constraints.maxWidth * (node.x / 100) - 42,
                top: constraints.maxHeight * (node.y / 100) - 26,
                width: 84,
                child: _MapNodeChip(
                  node: node,
                  mark: _marks[node.id],
                  isSelected: node.id == selectedNodeId,
                  onTap: () => setState(() => _selectedNodeId = node.id),
                  onLongPress: () => _showMarkPicker(node),
                ),
              ),
          ],
        );
      },
    ),
  );

  Widget _buildInspector({
    required final CampaignMapView map,
    required final CampaignMapPlane plane,
    required final CampaignMapNode? selectedNode,
    required final List<CampaignMapEvent> selectedEvents,
  }) {
    final Map<String, CampaignMapNode> lookup = <String, CampaignMapNode>{
      for (final CampaignMapNode item in plane.nodes) item.id: item,
    };
    final List<CampaignMapNode> nearbyNodes = selectedNode == null
        ? const <CampaignMapNode>[]
        : selectedNode.connections
              .map((final id) => lookup[id])
              .whereType<CampaignMapNode>()
              .take(4)
              .toList();
    return AetherCard(
      highlight: selectedNode?.isChanged ?? false,
      child: ListView(
        children: <Widget>[
          Text(
            selectedNode?.name ??
                (_isRussian ? 'Выберите точку на карте' : 'Select a node'),
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              color: AetherPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedNode?.summary ??
                (_isRussian
                    ? 'Карта показывает состояние мира, фронты и ближайшие направления.'
                    : 'The map shows world state, active fronts, and nearby routes.'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AetherPalette.narrativeText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          if (selectedNode != null) ...<Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _InspectorChip(
                  label: _nodeStateLabel(selectedNode.state),
                  color: _nodeAccent(selectedNode.state),
                ),
                if (_marks[selectedNode.id] != null)
                  _InspectorChip(
                    label: _markLabel(_marks[selectedNode.id]!),
                    color: AetherPalette.gold,
                  ),
                _InspectorChip(
                  label: _isRussian
                      ? 'Связей: ${selectedNode.connections.length}'
                      : 'Routes: ${selectedNode.connections.length}',
                  color: AetherPalette.accent,
                ),
                if (selectedNode.eventsCount > 0)
                  _InspectorChip(
                    label: _isRussian
                        ? 'Сигналы: ${selectedNode.eventsCount}'
                        : 'Signals: ${selectedNode.eventsCount}',
                    color: const Color(0xFFD36547),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            if (selectedNode.frontBadges.isNotEmpty) ...<Widget>[
              _SectionTitle(label: _isRussian ? 'Фронты' : 'Fronts'),
              for (final CampaignMapFront front in selectedNode.frontBadges)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text('• ${front.label}: ${front.summary}'),
                ),
              const SizedBox(height: 10),
            ],
            _SectionTitle(label: _isRussian ? 'Пульс узла' : 'Node Pulse'),
            const SizedBox(height: 8),
            if (selectedEvents.isEmpty)
              Text(
                _isRussian
                    ? 'Здесь пока тихо, но обстановка может измениться.'
                    : 'Quiet for now, but the situation can still shift.',
              )
            else
              for (final CampaignMapEvent event in selectedEvents.take(4))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _EventLine(
                    text: event.text,
                    location: event.locationTitle,
                    importance: event.importance,
                  ),
                ),
            if (nearbyNodes.isNotEmpty) ...<Widget>[
              const SizedBox(height: 18),
              _SectionTitle(label: _isRussian ? 'Рядом' : 'Nearby'),
              const SizedBox(height: 8),
              for (final CampaignMapNode node in nearbyNodes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _nodeAccent(node.state),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          node.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        _nodeStateLabel(node.state),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AetherPalette.textDim,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: selectedNode.isReachable && !_isTraveling
                  ? () => _travelToSelected(selectedNode)
                  : null,
              icon: _isTraveling
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.explore_outlined),
              label: Text(
                selectedNode.state == CampaignMapNodeState.current
                    ? (_isRussian ? 'Вы уже здесь' : 'You are here')
                    : selectedNode.travelPrompt,
              ),
            ),
          ],
          const SizedBox(height: 20),
          _SectionTitle(label: _isRussian ? 'Пока вас не было' : 'While Away'),
          const SizedBox(height: 8),
          if (map.returnEvents.isEmpty)
            Text(
              _isRussian
                  ? 'Новых межсессионных сдвигов пока нет.'
                  : 'No unseen between-session shifts yet.',
            )
          else
            for (final CampaignMapEvent item in map.returnEvents.take(4))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _EventLine(
                  text: item.text,
                  location: item.locationTitle,
                  importance: item.importance,
                ),
              ),
        ],
      ),
    );
  }

  String _nodeStateLabel(final CampaignMapNodeState state) => switch (state) {
    CampaignMapNodeState.current => _isRussian ? 'Текущая' : 'Current',
    CampaignMapNodeState.explored => _isRussian ? 'Исследовано' : 'Explored',
    CampaignMapNodeState.threat => _isRussian ? 'Угроза' : 'Threat',
    CampaignMapNodeState.rumored => _isRussian ? 'Слухи' : 'Rumored',
    CampaignMapNodeState.blocked => _isRussian ? 'Перекрыто' : 'Blocked',
    CampaignMapNodeState.fog => _isRussian ? 'Туман' : 'Fog',
  };

  String _markLabel(final CampaignMapMark mark) => switch (mark) {
    CampaignMapMark.suspicious => _isRussian ? 'Подозрительно' : 'Suspicious',
    CampaignMapMark.important => _isRussian ? 'Важно' : 'Important',
    CampaignMapMark.returnLater => _isRussian ? 'Вернуться' : 'Return later',
  };

  Color _nodeAccent(final CampaignMapNodeState state) => switch (state) {
    CampaignMapNodeState.current => const Color(0xFF63C7A4),
    CampaignMapNodeState.explored => AetherPalette.gold,
    CampaignMapNodeState.threat => const Color(0xFFD36547),
    CampaignMapNodeState.rumored => AetherPalette.accent,
    CampaignMapNodeState.blocked => AetherPalette.textMuted,
    CampaignMapNodeState.fog => AetherPalette.textDim,
  };
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(final BuildContext context) => Text(
    label,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(color: AetherPalette.textPrimary),
  );
}

class _InspectorChip extends StatelessWidget {
  const _InspectorChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(final BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: color.withValues(alpha: 0.45)),
    ),
    child: Text(label),
  );
}

class _MarkSheetTile extends StatelessWidget {
  const _MarkSheetTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) =>
      ListTile(title: Text(label), onTap: onTap);
}

class _EventLine extends StatelessWidget {
  const _EventLine({
    required this.text,
    required this.location,
    required this.importance,
  });

  final String text;
  final String location;
  final int importance;

  @override
  Widget build(final BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        '• $text',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AetherPalette.narrativeText),
      ),
      if (location.trim().isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '$location • ${importance.clamp(1, 10)}/10',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AetherPalette.textDim),
          ),
        ),
    ],
  );
}

class _MapNodeChip extends StatelessWidget {
  const _MapNodeChip({
    required this.node,
    required this.mark,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  final CampaignMapNode node;
  final CampaignMapMark? mark;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(final BuildContext context) {
    final Color accent = switch (node.state) {
      CampaignMapNodeState.current => const Color(0xFF63C7A4),
      CampaignMapNodeState.explored => AetherPalette.gold,
      CampaignMapNodeState.threat => const Color(0xFFD36547),
      CampaignMapNodeState.rumored => AetherPalette.accent,
      CampaignMapNodeState.blocked => AetherPalette.textMuted,
      CampaignMapNodeState.fog => AetherPalette.textDim,
    };
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AetherPalette.panel.withValues(
            alpha: isSelected ? 0.96 : 0.86,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: accent.withValues(alpha: isSelected ? 0.9 : 0.45),
          ),
          boxShadow: <BoxShadow>[
            if (node.isChanged || isSelected)
              BoxShadow(
                color: accent.withValues(alpha: 0.28),
                blurRadius: 18,
                spreadRadius: -4,
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                if (node.eventsCount > 0) ...<Widget>[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AetherPalette.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${node.eventsCount}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AetherPalette.accentHover,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
                if (mark != null) ...<Widget>[
                  const SizedBox(width: 6),
                  Icon(
                    switch (mark!) {
                      CampaignMapMark.suspicious => Icons.priority_high_rounded,
                      CampaignMapMark.important => Icons.push_pin_rounded,
                      CampaignMapMark.returnLater =>
                        Icons.history_toggle_off_rounded,
                    },
                    size: 14,
                    color: AetherPalette.gold,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              node.state == CampaignMapNodeState.fog ? '???' : node.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AetherPalette.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapBackdropPainter extends CustomPainter {
  @override
  void paint(final Canvas canvas, final Size size) {
    final Rect rect = Offset.zero & size;
    final Paint fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[Color(0xFF14110F), Color(0xFF0E0C0A)],
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(26)),
      fill,
    );
    final Paint grid = Paint()
      ..color = AetherPalette.accent.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y <= size.height; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  @override
  bool shouldRepaint(final _MapBackdropPainter oldDelegate) => false;
}

class _MapConnectionsPainter extends CustomPainter {
  const _MapConnectionsPainter({
    required this.nodes,
    required this.selectedNodeId,
  });

  final List<CampaignMapNode> nodes;
  final String? selectedNodeId;

  @override
  void paint(final Canvas canvas, final Size size) {
    final Map<String, CampaignMapNode> lookup = <String, CampaignMapNode>{
      for (final CampaignMapNode node in nodes) node.id: node,
    };
    for (final CampaignMapNode node in nodes) {
      for (final String connectionId in node.connections) {
        final CampaignMapNode? peer = lookup[connectionId];
        if (peer == null) {
          continue;
        }
        final Offset start = Offset(
          size.width * (node.x / 100),
          size.height * (node.y / 100),
        );
        final Offset end = Offset(
          size.width * (peer.x / 100),
          size.height * (peer.y / 100),
        );
        final bool highlighted =
            node.id == selectedNodeId || peer.id == selectedNodeId;
        final Paint paint = Paint()
          ..color = (highlighted ? AetherPalette.gold : AetherPalette.accent)
              .withValues(alpha: highlighted ? 0.55 : 0.22)
          ..strokeWidth = highlighted ? 2 : 1.2
          ..style = PaintingStyle.stroke;
        _drawDashedLine(canvas, paint, start, end, dash: highlighted ? 9 : 6);
      }
    }
  }

  void _drawDashedLine(
    final Canvas canvas,
    final Paint paint,
    final Offset start,
    final Offset end, {
    required final double dash,
  }) {
    final double distance = (end - start).distance;
    final Offset direction = (end - start) / distance;
    double progress = 0;
    while (progress < distance) {
      final double next = math.min(progress + dash, distance);
      canvas.drawLine(
        start + direction * progress,
        start + direction * next,
        paint,
      );
      progress += dash * 1.9;
    }
  }

  @override
  bool shouldRepaint(final _MapConnectionsPainter oldDelegate) =>
      oldDelegate.nodes != nodes ||
      oldDelegate.selectedNodeId != selectedNodeId;
}
