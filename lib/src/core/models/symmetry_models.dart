class SymmetryTokenPair {
  const SymmetryTokenPair({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
  });

  factory SymmetryTokenPair.fromJson(
    final Map<String, Object?> json,
  ) => SymmetryTokenPair(
    accessToken: (json['access_token'] as String?) ?? '',
    accessTokenExpiresAt: (json['access_token_expires_at'] as String?) ?? '',
    refreshToken: (json['refresh_token'] as String?) ?? '',
    refreshTokenExpiresAt: (json['refresh_token_expires_at'] as String?) ?? '',
  );

  final String accessToken;
  final String accessTokenExpiresAt;
  final String refreshToken;
  final String refreshTokenExpiresAt;

  Map<String, Object?> toJson() => <String, Object?>{
    'access_token': accessToken,
    'access_token_expires_at': accessTokenExpiresAt,
    'refresh_token': refreshToken,
    'refresh_token_expires_at': refreshTokenExpiresAt,
  };
}

class SymmetryUser {
  const SymmetryUser({
    required this.id,
    required this.email,
    required this.displayName,
  });

  factory SymmetryUser.fromJson(final Map<String, Object?> json) =>
      SymmetryUser(
        id: (json['id'] as String?) ?? '',
        email: (json['email'] as String?) ?? '',
        displayName: (json['display_name'] as String?) ?? '',
      );

  final String id;
  final String email;
  final String displayName;

  bool get isGuest =>
      email.startsWith('guest-') &&
      email.endsWith('@symmetry.dev') &&
      displayName.toLowerCase() == 'guest';

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'email': email,
    'display_name': displayName,
  };
}

class SymmetryAuthResponse {
  const SymmetryAuthResponse({required this.user, required this.tokens});

  factory SymmetryAuthResponse.fromJson(final Map<String, Object?> json) =>
      SymmetryAuthResponse(
        user: SymmetryUser.fromJson(_jsonMap(json['user'])),
        tokens: SymmetryTokenPair.fromJson(_jsonMap(json['tokens'])),
      );

  final SymmetryUser user;
  final SymmetryTokenPair tokens;

  Map<String, Object?> toJson() => <String, Object?>{
    'user': user.toJson(),
    'tokens': tokens.toJson(),
  };
}

class SymmetryCampaignStateResponse {
  const SymmetryCampaignStateResponse({
    required this.campaignId,
    required this.snapshotVersion,
    required this.state,
  });

  factory SymmetryCampaignStateResponse.fromJson(
    final Map<String, Object?> json,
  ) {
    final Map<String, Object?> campaign = _jsonMap(json['campaign']);
    return SymmetryCampaignStateResponse(
      campaignId: (campaign['id'] as String?) ?? '',
      snapshotVersion: (json['snapshot_version'] as int?) ?? 0,
      state: _jsonMap(json['state']),
    );
  }

  final String campaignId;
  final int snapshotVersion;
  final Map<String, Object?> state;
}

class SymmetryCampaignSummary {
  const SymmetryCampaignSummary({
    required this.id,
    required this.title,
    required this.setting,
    required this.mode,
    required this.difficulty,
    required this.language,
    required this.status,
  });

  factory SymmetryCampaignSummary.fromJson(final Map<String, Object?> json) =>
      SymmetryCampaignSummary(
        id: (json['id'] as String?) ?? '',
        title: (json['title'] as String?) ?? '',
        setting: (json['setting'] as String?) ?? '',
        mode: (json['mode'] as String?) ?? '',
        difficulty: (json['difficulty'] as String?) ?? '',
        language: (json['language'] as String?) ?? 'ru',
        status: (json['status'] as String?) ?? 'active',
      );

  final String id;
  final String title;
  final String setting;
  final String mode;
  final String difficulty;
  final String language;
  final String status;
}

class SymmetryTurnResponse {
  const SymmetryTurnResponse({
    required this.narration,
    required this.choices,
    required this.stateChanges,
    required this.memoryEntry,
    required this.requestId,
    required this.snapshotVersion,
    required this.state,
  });

  factory SymmetryTurnResponse.fromJson(final Map<String, Object?> json) =>
      SymmetryTurnResponse(
        narration: (json['narration'] as String?) ?? '',
        choices:
            (json['choices'] as List<Object?>?)
                ?.map((final item) => item.toString())
                .toList() ??
            const <String>[],
        stateChanges: _jsonMap(json['state_changes']),
        memoryEntry: (json['memory_entry'] as String?) ?? '',
        requestId: (json['request_id'] as String?) ?? '',
        snapshotVersion: (json['campaign_snapshot_version'] as int?) ?? 0,
        state: _jsonMap(json['state']),
      );

  final String narration;
  final List<String> choices;
  final Map<String, Object?> stateChanges;
  final String memoryEntry;
  final String requestId;
  final int snapshotVersion;
  final Map<String, Object?> state;
}

class SymmetryWorldRumor {
  const SymmetryWorldRumor({
    required this.id,
    required this.entityType,
    required this.eventText,
    required this.importance,
    required this.locationSlug,
    required this.createdAt,
  });

  factory SymmetryWorldRumor.fromJson(final Map<String, Object?> json) =>
      SymmetryWorldRumor(
        id: (json['id'] as String?) ?? '',
        entityType: (json['entity_type'] as String?) ?? '',
        eventText: (json['event_text'] as String?) ?? '',
        importance: (json['importance'] as int?) ?? 0,
        locationSlug: (json['location_slug'] as String?) ?? '',
        createdAt:
            DateTime.tryParse((json['created_at'] as String?) ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );

  final String id;
  final String entityType;
  final String eventText;
  final int importance;
  final String locationSlug;
  final DateTime createdAt;
}

class SymmetrySession {
  const SymmetrySession({
    required this.user,
    required this.tokens,
    required this.baseUrl,
  });

  factory SymmetrySession.fromJson(final Map<String, Object?> json) =>
      SymmetrySession(
        user: SymmetryUser.fromJson(_jsonMap(json['user'])),
        tokens: SymmetryTokenPair.fromJson(_jsonMap(json['tokens'])),
        baseUrl: (json['base_url'] as String?) ?? '',
      );

  final SymmetryUser user;
  final SymmetryTokenPair tokens;
  final String baseUrl;

  bool get isGuest => user.isGuest;

  Map<String, Object?> toJson() => <String, Object?>{
    'user': user.toJson(),
    'tokens': tokens.toJson(),
    'base_url': baseUrl,
  };

  SymmetrySession copyWith({
    final SymmetryUser? user,
    final SymmetryTokenPair? tokens,
    final String? baseUrl,
  }) => SymmetrySession(
    user: user ?? this.user,
    tokens: tokens ?? this.tokens,
    baseUrl: baseUrl ?? this.baseUrl,
  );
}

class SymmetryGeneratedPrompts {
  const SymmetryGeneratedPrompts({
    required this.storyPrompt,
    required this.characterPrompt,
    required this.campaignTitle,
    required this.objectiveHint,
  });

  factory SymmetryGeneratedPrompts.fromJson(final Map<String, Object?> json) =>
      SymmetryGeneratedPrompts(
        storyPrompt: (json['story_prompt'] as String?) ?? '',
        characterPrompt: (json['character_prompt'] as String?) ?? '',
        campaignTitle: (json['campaign_title'] as String?) ?? '',
        objectiveHint: (json['objective_hint'] as String?) ?? '',
      );

  final String storyPrompt;
  final String characterPrompt;
  final String campaignTitle;
  final String objectiveHint;
}

class SymmetryApiException implements Exception {
  const SymmetryApiException({
    required this.message,
    this.statusCode,
    this.detailCode,
    this.validationErrors = const <String>[],
  });

  final String message;
  final int? statusCode;
  final String? detailCode;
  final List<String> validationErrors;

  bool get hasValidationErrors => validationErrors.isNotEmpty;

  @override
  String toString() => message;
}

Map<String, Object?> _jsonMap(final Object? value) =>
    (value as Map<Object?, Object?>?)?.map(
      (final key, final item) => MapEntry(key.toString(), item),
    ) ??
    const <String, Object?>{};

bool _jsonBool(final Object? value, {final bool fallback = false}) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final String normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return fallback;
    }
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return fallback;
}

enum SymmetryUpdateMode { none, soft, force }

class SymmetryVersionPlatformInfo {
  const SymmetryVersionPlatformInfo({
    required this.latestVersion,
    required this.minimumSupportedVersion,
    required this.updateMode,
    required this.message,
    this.assetVersion = '',
    this.reloadRequired = false,
    this.updateUrl = '',
  });

  factory SymmetryVersionPlatformInfo.fromJson(
    final Map<String, Object?> json,
  ) => SymmetryVersionPlatformInfo(
    latestVersion: (json['latest_version'] as String?) ?? '',
    minimumSupportedVersion:
        (json['minimum_supported_version'] as String?) ?? '',
    updateMode: SymmetryUpdateMode.values.firstWhere(
      (final item) => item.name == json['update_mode'],
      orElse: () => SymmetryUpdateMode.none,
    ),
    message: (json['message'] as String?) ?? '',
    assetVersion: (json['asset_version'] as String?) ?? '',
    reloadRequired: _jsonBool(json['reload_required']),
    updateUrl: (json['update_url'] as String?) ?? '',
  );

  final String latestVersion;
  final String minimumSupportedVersion;
  final SymmetryUpdateMode updateMode;
  final String message;
  final String assetVersion;
  final bool reloadRequired;
  final String updateUrl;
}

class SymmetryVersionPlatforms {
  const SymmetryVersionPlatforms({required this.web, required this.desktop});

  factory SymmetryVersionPlatforms.fromJson(final Map<String, Object?> json) =>
      SymmetryVersionPlatforms(
        web: SymmetryVersionPlatformInfo.fromJson(_jsonMap(json['web'])),
        desktop: SymmetryVersionPlatformInfo.fromJson(
          _jsonMap(json['desktop']),
        ),
      );

  final SymmetryVersionPlatformInfo web;
  final SymmetryVersionPlatformInfo desktop;
}

class SymmetryVersionInfo {
  const SymmetryVersionInfo({
    required this.apiVersion,
    required this.releaseId,
    required this.releasedAt,
    required this.platforms,
  });

  factory SymmetryVersionInfo.fromJson(final Map<String, Object?> json) =>
      SymmetryVersionInfo(
        apiVersion: (json['api_version'] as String?) ?? '',
        releaseId: (json['release_id'] as String?) ?? '',
        releasedAt: (json['released_at'] as String?) ?? '',
        platforms: SymmetryVersionPlatforms.fromJson(
          _jsonMap(json['platforms']),
        ),
      );

  final String apiVersion;
  final String releaseId;
  final String releasedAt;
  final SymmetryVersionPlatforms platforms;
}
