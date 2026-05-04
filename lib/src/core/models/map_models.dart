/// Spatial campaign map models — server-authoritative.
///
/// Node states matching API contract: current, explored, threat, fog, rumored, blocked.
library;

// --- Node & edge states ---

enum MapNodeState { current, explored, threat, fog, rumored, blocked }

enum MapEdgeType { known, rumored, blocked }

// --- API response models ---

class CampaignMap {
  const CampaignMap({
    this.activeScale = 'room',
    this.currentNodeId,
    this.breadcrumbs = const [],
    this.nodes = const [],
    this.edges = const [],
    this.fronts = const [],
    this.returnEvents = const [],
    this.lastSeenDelta,
    this.availableScales = const [],
  });

  factory CampaignMap.fromJson(Map<String, dynamic> json) => CampaignMap(
    activeScale: (json['active_scale'] as String?) ?? 'room',
    currentNodeId: json['current_node_id'] as String?,
    breadcrumbs: (json['breadcrumbs'] as List<dynamic>?)
        ?.map((b) => MapBreadcrumb.fromJson(b as Map<String, dynamic>))
        .toList() ?? [],
    nodes: (json['nodes'] as List<dynamic>?)
        ?.map((n) => CampaignMapNode.fromJson(n as Map<String, dynamic>))
        .toList() ?? [],
    edges: (json['edges'] as List<dynamic>?)
        ?.map((e) => CampaignMapEdge.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
    fronts: (json['fronts'] as List<dynamic>?)
        ?.map((f) => MapFront.fromJson(f as Map<String, dynamic>))
        .toList() ?? [],
    returnEvents: (json['return_events'] as List<dynamic>?)
        ?.map((r) => MapReturnEvent.fromJson(r as Map<String, dynamic>))
        .toList() ?? [],
    lastSeenDelta: json['last_seen_delta'] != null
        ? MapLastSeenDelta.fromJson(json['last_seen_delta'] as Map<String, dynamic>)
        : null,
    availableScales: (json['available_scales'] as List<dynamic>?)
        ?.map((s) => s as String)
        .toList() ?? [],
  );

  final String activeScale;
  final String? currentNodeId;
  final List<MapBreadcrumb> breadcrumbs;
  final List<CampaignMapNode> nodes;
  final List<CampaignMapEdge> edges;
  final List<MapFront> fronts;
  final List<MapReturnEvent> returnEvents;
  final MapLastSeenDelta? lastSeenDelta;
  final List<String> availableScales;
}

class MapBreadcrumb {
  const MapBreadcrumb({required this.id, required this.title});

  factory MapBreadcrumb.fromJson(Map<String, dynamic> json) => MapBreadcrumb(
    id: (json['id'] as String?) ?? '',
    title: (json['title'] as String?) ?? '',
  );

  final String id;
  final String title;
}

class CampaignMapNode {
  const CampaignMapNode({
    required this.id,
    required this.title,
    this.locationType = 'room',
    this.x,
    this.y,
    this.parentId,
    this.nodeState = MapNodeState.fog,
    this.isRevealed = false,
    this.frontBadges = const [],
    this.eventsCount = 0,
    this.isReachable = false,
    this.travelPrompt,
  });

  factory CampaignMapNode.fromJson(Map<String, dynamic> json) => CampaignMapNode(
    id: (json['id'] as String?) ?? '',
    title: (json['title'] as String?) ?? '',
    locationType: (json['location_type'] as String?) ?? 'room',
    x: (json['x'] as num?)?.toDouble(),
    y: (json['y'] as num?)?.toDouble(),
    parentId: json['parent_id'] as String?,
    nodeState: _parseNodeState(json['node_state']),
    isRevealed: json['is_revealed'] as bool? ?? false,
    frontBadges: (json['front_badges'] as List<dynamic>?)
        ?.map((b) => b as String)
        .toList() ?? [],
    eventsCount: json['events_count'] as int? ?? 0,
    isReachable: json['is_reachable'] as bool? ?? false,
    travelPrompt: json['travel_prompt'] as String?,
  );

  final String id;
  final String title;
  final String locationType;
  final double? x;
  final double? y;
  final String? parentId;
  final MapNodeState nodeState;
  final bool isRevealed;
  final List<String> frontBadges;
  final int eventsCount;
  final bool isReachable;
  final String? travelPrompt;
}

MapNodeState _parseNodeState(dynamic value) {
  if (value is String) {
    for (final s in MapNodeState.values) {
      if (s.name == value) return s;
    }
  }
  return MapNodeState.fog;
}

class CampaignMapEdge {
  const CampaignMapEdge({
    required this.id,
    required this.locationIdA,
    required this.locationIdB,
    this.edgeType = MapEdgeType.known,
    this.travelTimeMinutes,
  });

  factory CampaignMapEdge.fromJson(Map<String, dynamic> json) => CampaignMapEdge(
    id: (json['id'] as String?) ?? '',
    locationIdA: (json['location_id_a'] as String?) ?? '',
    locationIdB: (json['location_id_b'] as String?) ?? '',
    edgeType: _parseEdgeType(json['edge_type']),
    travelTimeMinutes: json['travel_time_minutes'] as int?,
  );

  final String id;
  final String locationIdA;
  final String locationIdB;
  final MapEdgeType edgeType;
  final int? travelTimeMinutes;
}

MapEdgeType _parseEdgeType(dynamic value) {
  if (value is String) {
    for (final t in MapEdgeType.values) {
      if (t.name == value) return t;
    }
  }
  return MapEdgeType.known;
}

class MapFront {
  const MapFront({
    required this.nodeId,
    required this.frontType,
    required this.description,
  });

  factory MapFront.fromJson(Map<String, dynamic> json) => MapFront(
    nodeId: (json['node_id'] as String?) ?? '',
    frontType: (json['front_type'] as String?) ?? '',
    description: (json['description'] as String?) ?? '',
  );

  final String nodeId;
  final String frontType;
  final String description;
}

class MapReturnEvent {
  const MapReturnEvent({
    required this.chronicleId,
    required this.locationSlug,
    required this.eventText,
  });

  factory MapReturnEvent.fromJson(Map<String, dynamic> json) => MapReturnEvent(
    chronicleId: (json['chronicle_id'] as String?) ?? '',
    locationSlug: (json['location_slug'] as String?) ?? '',
    eventText: (json['event_text'] as String?) ?? '',
  );

  final String chronicleId;
  final String locationSlug;
  final String eventText;
}

class MapLastSeenDelta {
  const MapLastSeenDelta({required this.sinceTurn, required this.newEvents});

  factory MapLastSeenDelta.fromJson(Map<String, dynamic> json) => MapLastSeenDelta(
    sinceTurn: json['since_turn'] as int? ?? 0,
    newEvents: json['new_events'] as int? ?? 0,
  );

  final int sinceTurn;
  final int newEvents;
}

class MapContext {
  const MapContext({
    this.activeScale = 'room',
    this.focusNodeId,
    this.changedNodeIds = const [],
    this.newReturnEventsCount = 0,
    this.availableScales = const [],
    this.frontsChanged = false,
    this.rejectedProposals = const [],
  });

  factory MapContext.fromJson(Map<String, dynamic> json) => MapContext(
    activeScale: (json['active_scale'] as String?) ?? 'room',
    focusNodeId: json['focus_node_id'] as String?,
    changedNodeIds: (json['changed_node_ids'] as List<dynamic>?)
        ?.map((s) => s as String)
        .toList() ?? [],
    newReturnEventsCount: json['new_return_events_count'] as int? ?? 0,
    availableScales: (json['available_scales'] as List<dynamic>?)
        ?.map((s) => s as String)
        .toList() ?? [],
    frontsChanged: json['fronts_changed'] as bool? ?? false,
    rejectedProposals: (json['rejected_proposals'] as List<dynamic>?)
        ?.map((r) => RejectedProposal.fromJson(r as Map<String, dynamic>))
        .toList() ?? [],
  );

  final String activeScale;
  final String? focusNodeId;
  final List<String> changedNodeIds;
  final int newReturnEventsCount;
  final List<String> availableScales;
  final bool frontsChanged;
  final List<RejectedProposal> rejectedProposals;
}

class RejectedProposal {
  const RejectedProposal({
    required this.proposalType,
    required this.payloadSummary,
    required this.rejectionReason,
  });

  factory RejectedProposal.fromJson(Map<String, dynamic> json) => RejectedProposal(
    proposalType: (json['proposal_type'] as String?) ?? '',
    payloadSummary: (json['payload_summary'] as String?) ?? '',
    rejectionReason: (json['rejection_reason'] as String?) ?? '',
  );

  final String proposalType;
  final String payloadSummary;
  final String rejectionReason;
}

class ReturnSummary {
  const ReturnSummary({
    this.sinceTurn = 0,
    this.newEventsCount = 0,
    this.digest = const [],
    this.changedNodeIds = const [],
  });

  factory ReturnSummary.fromJson(Map<String, dynamic> json) => ReturnSummary(
    sinceTurn: json['since_turn'] as int? ?? 0,
    newEventsCount: json['new_events_count'] as int? ?? 0,
    digest: (json['digest'] as List<dynamic>?)
        ?.map((d) => DigestItem.fromJson(d as Map<String, dynamic>))
        .toList() ?? [],
    changedNodeIds: (json['changed_node_ids'] as List<dynamic>?)
        ?.map((s) => s as String)
        .toList() ?? [],
  );

  final int sinceTurn;
  final int newEventsCount;
  final List<DigestItem> digest;
  final List<String> changedNodeIds;
}

class DigestItem {
  const DigestItem({
    required this.chronicleId,
    required this.locationTitle,
    required this.eventText,
    this.category = 'event',
  });

  factory DigestItem.fromJson(Map<String, dynamic> json) => DigestItem(
    chronicleId: (json['chronicle_id'] as String?) ?? '',
    locationTitle: (json['location_title'] as String?) ?? '',
    eventText: (json['event_text'] as String?) ?? '',
    category: (json['category'] as String?) ?? 'event',
  );

  final String chronicleId;
  final String locationTitle;
  final String eventText;
  final String category;
}

/// Local-only player marks (not server-authoritative).
enum PlayerMark { important, suspicious, returnHere }
