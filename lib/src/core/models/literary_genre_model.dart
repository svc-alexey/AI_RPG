/// Row from GET /v1/literary-genres (catalog is DB-backed; extend via migrations).
/// Distinct from the `LiteraryGenre` enum in campaign models (prompt / character layer).
class LiteraryGenreCatalogItem {
  const LiteraryGenreCatalogItem({
    required this.slug,
    required this.titleEn,
    required this.titleRu,
    required this.sortOrder,
  });

  factory LiteraryGenreCatalogItem.fromJson(final Map<String, Object?> json) {
    final Object? orderRaw = json['sort_order'];
    final int sortOrder = orderRaw is int
        ? orderRaw
        : (orderRaw is num ? orderRaw.toInt() : 0);
    return LiteraryGenreCatalogItem(
      slug: (json['slug'] as String?) ?? '',
      titleEn: (json['title_en'] as String?) ?? '',
      titleRu: (json['title_ru'] as String?) ?? '',
      sortOrder: sortOrder,
    );
  }

  final String slug;
  final String titleEn;
  final String titleRu;
  final int sortOrder;

  String labelForLocale({required final bool isRussian}) =>
      isRussian ? titleRu : titleEn;
}
