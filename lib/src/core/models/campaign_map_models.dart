enum CampaignMapScale { room, district, city, region, world }

enum CampaignMapNodeState { current, explored, threat, fog, rumored, blocked }

enum CampaignMapMark { suspicious, important, returnLater }

Map<String, Object?> _mapJson(final Object? value) {
  if (value is Map) {
    return value.map((final key, final item) => MapEntry(key.toString(), item));
  }
  return const <String, Object?>{};
}

List<Object?> _mapList(final Object? value) =>
    value is List ? List<Object?>.from(value) : const <Object?>[];

String _mapString(final Object? value, {final String fallback = ''}) {
  if (value == null) {
    return fallback;
  }
  if (value is String) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }
  return value.toString();
}

class CampaignMapContext {
  factory CampaignMapContext.fromJson(final Map<String, Object?> json) =>
      CampaignMapContext(
        activeScale: CampaignMapScale.values.firstWhere(
          (final item) => item.name == _mapString(json['active_scale']),
          orElse: () => CampaignMapScale.district,
        ),
        focusNodeId: _mapString(json['focus_node_id']),
        changedNodeIds: _mapList(
          json['changed_node_ids'],
        ).map((final item) => item.toString()).toList(),
        newReturnEventsCount:
            (json['new_return_events_count'] as num?)?.toInt() ?? 0,
        availableScales: _mapList(json['available_scales'])
            .map(
              (final item) => CampaignMapScale.values.firstWhere(
                (final scale) => scale.name == item.toString(),
                orElse: () => CampaignMapScale.district,
              ),
            )
            .toList(),
        frontsChanged: _mapList(
          json['fronts_changed'],
        ).map((final item) => item.toString()).toList(),
      );

  const CampaignMapContext({
    required this.activeScale,
    required this.focusNodeId,
    required this.changedNodeIds,
    required this.newReturnEventsCount,
    required this.availableScales,
    required this.frontsChanged,
  });

  final CampaignMapScale activeScale;
  final String focusNodeId;
  final List<String> changedNodeIds;
  final int newReturnEventsCount;
  final List<CampaignMapScale> availableScales;
  final List<String> frontsChanged;

  Map<String, Object?> toJson() => <String, Object?>{
    'active_scale': activeScale.name,
    'focus_node_id': focusNodeId,
    'changed_node_ids': changedNodeIds,
    'new_return_events_count': newReturnEventsCount,
    'available_scales': availableScales.map((final item) => item.name).toList(),
    'fronts_changed': frontsChanged,
  };
}

class CampaignMapFront {
  factory CampaignMapFront.fromJson(final Map<String, Object?> json) =>
      CampaignMapFront(
        id: _mapString(json['id']),
        label: _mapString(json['label']),
        severity: _mapString(json['severity']),
        summary: _mapString(json['summary']),
        nodeId: _mapString(json['node_id']),
        nodeName: _mapString(json['node_name']),
      );

  const CampaignMapFront({
    required this.id,
    required this.label,
    required this.severity,
    required this.summary,
    this.nodeId = '',
    this.nodeName = '',
  });

  final String id;
  final String label;
  final String severity;
  final String summary;
  final String nodeId;
  final String nodeName;
}

class CampaignMapEvent {
  factory CampaignMapEvent.fromJson(final Map<String, Object?> json) =>
      CampaignMapEvent(
        id: _mapString(json['id']),
        text: _mapString(json['text']),
        locationSlug: _mapString(json['location_slug']),
        locationTitle: _mapString(json['location_title']),
        importance: (json['importance'] as num?)?.toInt() ?? 0,
        createdAt:
            DateTime.tryParse(_mapString(json['created_at'])) ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );

  const CampaignMapEvent({
    required this.id,
    required this.text,
    required this.locationSlug,
    required this.locationTitle,
    required this.importance,
    required this.createdAt,
  });

  final String id;
  final String text;
  final String locationSlug;
  final String locationTitle;
  final int importance;
  final DateTime createdAt;
}

class CampaignMapBreadcrumb {
  factory CampaignMapBreadcrumb.fromJson(final Map<String, Object?> json) =>
      CampaignMapBreadcrumb(
        id: _mapString(json['id']),
        label: _mapString(json['label']),
        scale: CampaignMapScale.values.firstWhere(
          (final item) => item.name == _mapString(json['scale']),
          orElse: () => CampaignMapScale.district,
        ),
      );

  const CampaignMapBreadcrumb({
    required this.id,
    required this.label,
    required this.scale,
  });

  final String id;
  final String label;
  final CampaignMapScale scale;
}

class CampaignMapNode {
  factory CampaignMapNode.fromJson(final Map<String, Object?> json) =>
      CampaignMapNode(
        id: _mapString(json['id']),
        slug: _mapString(json['slug']),
        parentId: _mapString(json['parent_id']),
        scale: CampaignMapScale.values.firstWhere(
          (final item) => item.name == _mapString(json['scale']),
          orElse: () => CampaignMapScale.district,
        ),
        name: _mapString(json['name']),
        type: _mapString(json['type']),
        x: (json['x'] as num?)?.toDouble() ?? 50,
        y: (json['y'] as num?)?.toDouble() ?? 50,
        state: CampaignMapNodeState.values.firstWhere(
          (final item) => item.name == _mapString(json['state']),
          orElse: () => CampaignMapNodeState.fog,
        ),
        connections: _mapList(
          json['connections'],
        ).map((final item) => item.toString()).toList(),
        frontBadges: _mapList(json['front_badges'])
            .map((final item) => CampaignMapFront.fromJson(_mapJson(item)))
            .toList(),
        eventsCount: (json['events_count'] as num?)?.toInt() ?? 0,
        isReachable: json['is_reachable'] as bool? ?? true,
        travelPrompt: _mapString(json['travel_prompt']),
        summary: _mapString(json['summary']),
        events: _mapList(json['events'])
            .map((final item) => CampaignMapEvent.fromJson(_mapJson(item)))
            .toList(),
        isChanged: json['is_changed'] as bool? ?? false,
      );

  const CampaignMapNode({
    required this.id,
    required this.slug,
    required this.parentId,
    required this.scale,
    required this.name,
    required this.type,
    required this.x,
    required this.y,
    required this.state,
    required this.connections,
    required this.frontBadges,
    required this.eventsCount,
    required this.isReachable,
    required this.travelPrompt,
    required this.summary,
    required this.events,
    required this.isChanged,
  });

  final String id;
  final String slug;
  final String parentId;
  final CampaignMapScale scale;
  final String name;
  final String type;
  final double x;
  final double y;
  final CampaignMapNodeState state;
  final List<String> connections;
  final List<CampaignMapFront> frontBadges;
  final int eventsCount;
  final bool isReachable;
  final String travelPrompt;
  final String summary;
  final List<CampaignMapEvent> events;
  final bool isChanged;
}

class CampaignMapPlane {
  factory CampaignMapPlane.fromJson(final Map<String, Object?> json) =>
      CampaignMapPlane(
        scale: CampaignMapScale.values.firstWhere(
          (final item) => item.name == _mapString(json['scale']),
          orElse: () => CampaignMapScale.district,
        ),
        title: _mapString(json['title']),
        nodes: _mapList(json['nodes'])
            .map((final item) => CampaignMapNode.fromJson(_mapJson(item)))
            .toList(),
      );

  const CampaignMapPlane({
    required this.scale,
    required this.title,
    required this.nodes,
  });

  final CampaignMapScale scale;
  final String title;
  final List<CampaignMapNode> nodes;
}

class CampaignMapView {
  factory CampaignMapView.fromJson(final Map<String, Object?> json) =>
      CampaignMapView(
        activeScale: CampaignMapScale.values.firstWhere(
          (final item) => item.name == _mapString(json['active_scale']),
          orElse: () => CampaignMapScale.district,
        ),
        breadcrumbs: _mapList(json['breadcrumbs'])
            .map((final item) => CampaignMapBreadcrumb.fromJson(_mapJson(item)))
            .toList(),
        currentNodeId: _mapString(json['current_node_id']),
        focusNodeId: _mapString(json['focus_node_id']),
        availableScales: _mapList(json['available_scales'])
            .map(
              (final item) => CampaignMapScale.values.firstWhere(
                (final scale) => scale.name == item.toString(),
                orElse: () => CampaignMapScale.district,
              ),
            )
            .toList(),
        changedNodeIds: _mapList(
          json['changed_node_ids'],
        ).map((final item) => item.toString()).toList(),
        localView: CampaignMapPlane.fromJson(_mapJson(json['local_view'])),
        globalView: CampaignMapPlane.fromJson(_mapJson(json['global_view'])),
        fronts: _mapList(json['fronts'])
            .map((final item) => CampaignMapFront.fromJson(_mapJson(item)))
            .toList(),
        returnEvents: _mapList(json['return_events'])
            .map((final item) => CampaignMapEvent.fromJson(_mapJson(item)))
            .toList(),
        unseenEventsCount:
            (_mapJson(json['last_seen_delta'])['unseen_events_count'] as num?)
                ?.toInt() ??
            0,
        lastSeenAt: DateTime.tryParse(
          _mapString(_mapJson(json['last_seen_delta'])['last_seen_at']),
        ),
      );

  const CampaignMapView({
    required this.activeScale,
    required this.breadcrumbs,
    required this.currentNodeId,
    required this.focusNodeId,
    required this.availableScales,
    required this.changedNodeIds,
    required this.localView,
    required this.globalView,
    required this.fronts,
    required this.returnEvents,
    required this.unseenEventsCount,
    required this.lastSeenAt,
  });

  final CampaignMapScale activeScale;
  final List<CampaignMapBreadcrumb> breadcrumbs;
  final String currentNodeId;
  final String focusNodeId;
  final List<CampaignMapScale> availableScales;
  final List<String> changedNodeIds;
  final CampaignMapPlane localView;
  final CampaignMapPlane globalView;
  final List<CampaignMapFront> fronts;
  final List<CampaignMapEvent> returnEvents;
  final int unseenEventsCount;
  final DateTime? lastSeenAt;
}

class CampaignReturnSummary {
  factory CampaignReturnSummary.fromJson(final Map<String, Object?> json) =>
      CampaignReturnSummary(
        unseenCount: (json['unseen_count'] as num?)?.toInt() ?? 0,
        changedNodeIds: _mapList(
          json['changed_node_ids'],
        ).map((final item) => item.toString()).toList(),
        frontsChanged: _mapList(
          json['fronts_changed'],
        ).map((final item) => item.toString()).toList(),
        events: _mapList(json['events'])
            .map((final item) => CampaignMapEvent.fromJson(_mapJson(item)))
            .toList(),
        generatedAt:
            DateTime.tryParse(_mapString(json['generated_at'])) ??
            DateTime.now(),
      );

  const CampaignReturnSummary({
    required this.unseenCount,
    required this.changedNodeIds,
    required this.frontsChanged,
    required this.events,
    required this.generatedAt,
  });

  final int unseenCount;
  final List<String> changedNodeIds;
  final List<String> frontsChanged;
  final List<CampaignMapEvent> events;
  final DateTime generatedAt;
}
