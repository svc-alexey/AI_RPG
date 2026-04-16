import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/story_template_model.dart';
import 'package:ai_prg/src/features/story_library/presentation/widgets/authenticated_cover_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StoryTemplateGridCard extends StatelessWidget {
  const StoryTemplateGridCard({
    required this.template,
    required this.onTap,
    this.symmetryBaseUrl = '',
    this.accessToken,
    super.key,
  });

  final StoryTemplate template;
  final VoidCallback onTap;
  final String symmetryBaseUrl;
  final String? accessToken;

  @override
  Widget build(final BuildContext context) {
    final AppResponsiveData responsive = context.responsive;
    final String? cover = symmetryBaseUrl.trim().isNotEmpty
        ? template.resolveCoverDisplayUrl(symmetryBaseUrl: symmetryBaseUrl)
        : template.coverImageUrlFromMetadata;
    final Map<String, String>? imageHeaders =
        cover != null &&
            accessToken != null &&
            accessToken!.trim().isNotEmpty &&
            cover.startsWith(symmetryBaseUrl)
        ? <String, String>{
            'Authorization': 'Bearer ${accessToken!.trim()}',
          }
        : null;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AetherPalette.panelBorder.withValues(alpha: 0.45),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: cover != null
                      ? AuthenticatedCoverImage(
                          imageUrl: cover,
                          requestHeaders: imageHeaders,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _PlaceholderArt(responsive: responsive),
                        )
                      : _PlaceholderArt(responsive: responsive),
                ),
              ),
            ),
            SizedBox(height: responsive.isCompact ? 8 : 10),
            Text(
              template.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.playfairDisplay(
                fontSize: responsive.isCompact ? 18 : 20,
                fontWeight: FontWeight.w500,
                color: AetherPalette.textPrimary,
                height: 1.2,
              ),
            ),
            SizedBox(height: responsive.isCompact ? 6 : 8),
            Row(
              children: <Widget>[
                Icon(
                  Icons.visibility_outlined,
                  size: 16,
                  color: AetherPalette.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '${template.views}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AetherPalette.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.favorite_border_rounded,
                  size: 16,
                  color: AetherPalette.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '${template.likes}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AetherPalette.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderArt extends StatelessWidget {
  const _PlaceholderArt({required this.responsive});

  final AppResponsiveData responsive;

  @override
  Widget build(final BuildContext context) => ColoredBox(
    color: AetherPalette.backgroundElevated,
    child: Center(
      child: Icon(
        Icons.auto_stories_outlined,
        size: responsive.isCompact ? 40 : 48,
        color: AetherPalette.accent.withValues(alpha: 0.45),
      ),
    ),
  );
}
