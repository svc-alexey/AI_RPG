/// Server-backed narrative world / story template from Symmetry `/v1/story-templates`.
class StoryTemplate {
  const StoryTemplate({
    required this.id,
    required this.title,
    required this.summary,
    required this.promptText,
    required this.setting,
    required this.isPublic,
    required this.isMasterCurated,
    required this.metadata,
    required this.authorDisplayName,
    required this.tags,
    required this.likes,
    required this.views,
    required this.bookmarked,
    required this.createdAt,
    required this.updatedAt,
    this.literaryGenreSlug,
    this.coverImageHref,
  });

  factory StoryTemplate.fromJson(final Map<String, Object?> json) {
    final Object? meta = json['metadata'];
    final Map<String, Object?> metadata = meta is Map<Object?, Object?>
        ? meta.map(
            (final key, final value) =>
                MapEntry(key.toString(), _normalizeMetadataValue(value)),
          )
        : const <String, Object?>{};
    final Object? tagsRaw = json['tags'];
    final List<String> tags = tagsRaw is List<Object?>
        ? tagsRaw.map((final item) => item.toString()).toList()
        : const <String>[];
    return StoryTemplate(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      summary: (json['summary'] as String?) ?? '',
      promptText: (json['prompt_text'] as String?) ?? '',
      setting: (json['setting'] as String?) ?? '',
      isPublic: json['is_public'] as bool? ?? false,
      isMasterCurated: json['is_master_curated'] as bool? ?? false,
      metadata: metadata,
      authorDisplayName: _parseOptionalNonEmpty(
        json['author_display_name'] as String?,
      ),
      tags: tags,
      likes: (json['likes'] as int?) ?? 0,
      views: (json['views'] as int?) ?? 0,
      bookmarked: json['bookmarked'] as bool? ?? false,
      createdAt: DateTime.tryParse((json['created_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse((json['updated_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      literaryGenreSlug: _parseOptionalNonEmpty(
        json['literary_genre_slug'] as String?,
      ),
      coverImageHref: _parseOptionalNonEmpty(
        json['cover_image_href'] as String?,
      ),
    );
  }

  final String id;
  final String title;
  final String summary;
  final String promptText;
  final String setting;
  final bool isPublic;
  final bool isMasterCurated;
  final Map<String, Object?> metadata;
  final String? authorDisplayName;
  final List<String> tags;
  final int likes;
  final int views;
  final bool bookmarked;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? literaryGenreSlug;
  final String? coverImageHref;

  /// External URL from legacy metadata (optional).
  String? get coverImageUrlFromMetadata {
    final Object? raw = metadata['cover_image_url'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return null;
  }

  /// Cover for UI: DB-backed path on Symmetry or legacy metadata URL.
  /// Appends `?v=` from [updatedAt] so browsers do not show a stale image after
  /// re-upload (same path, new bytes).
  String? resolveCoverDisplayUrl({required final String symmetryBaseUrl}) {
    final String? href = coverImageHref;
    if (href != null && href.trim().isNotEmpty) {
      final String h = href.trim();
      if (h.startsWith('http://') || h.startsWith('https://')) {
        return h;
      }
      final String base = symmetryBaseUrl.endsWith('/')
          ? symmetryBaseUrl.substring(0, symmetryBaseUrl.length - 1)
          : symmetryBaseUrl;
      String relative = h.startsWith('/') ? h : '/$h';
      // Server href is `/v1/story-templates/...` while [symmetryBaseUrl] is already
      // `scheme://host/v1` — concatenating would produce `/v1/v1/...` (404).
      if (base.endsWith('/v1') && relative.startsWith('/v1/')) {
        relative = relative.substring(3);
      }
      final String path = '$base$relative';
      final int stamp = updatedAt.millisecondsSinceEpoch;
      if (stamp > 0) {
        final String sep = path.contains('?') ? '&' : '?';
        return '$path${sep}v=$stamp';
      }
      return path;
    }
    return coverImageUrlFromMetadata;
  }

  static String? _parseOptionalNonEmpty(final String? raw) {
    if (raw == null) {
      return null;
    }
    final String t = raw.trim();
    return t.isEmpty ? null : t;
  }

  static Object? _normalizeMetadataValue(final Object? value) {
    if (value is Map<Object?, Object?>) {
      return value.map(
        (final key, final Object? v) =>
            MapEntry(key.toString(), _normalizeMetadataValue(v)),
      );
    }
    if (value is List<Object?>) {
      return value.map(_normalizeMetadataValue).toList();
    }
    return value;
  }
}
