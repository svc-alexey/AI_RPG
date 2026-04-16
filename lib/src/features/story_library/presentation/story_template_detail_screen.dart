import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/story_template_model.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/features/new_game/presentation/new_game_screen.dart';
import 'package:ai_prg/src/features/story_library/presentation/widgets/authenticated_cover_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class StoryTemplateDetailScreen extends ConsumerStatefulWidget {
  const StoryTemplateDetailScreen({
    required this.template,
    super.key,
  });

  final StoryTemplate template;

  @override
  ConsumerState<StoryTemplateDetailScreen> createState() =>
      _StoryTemplateDetailScreenState();
}

class _StoryTemplateDetailScreenState
    extends ConsumerState<StoryTemplateDetailScreen> {
  bool _didRecordView = false;
  late StoryTemplate _template;

  @override
  void initState() {
    super.initState();
    _template = widget.template;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didRecordView) {
      return;
    }
    _didRecordView = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(storyLibraryRepositoryProvider).recordView(_template.id);
      } catch (_) {
        // Non-blocking analytics.
      }
    });
  }

  Future<void> _onLike() async {
    try {
      await ref.read(storyLibraryRepositoryProvider).toggleLike(_template.id);
      final StoryTemplate fresh = await ref
          .read(storyLibraryRepositoryProvider)
          .loadTemplate(_template.id);
      if (!mounted) {
        return;
      }
      setState(() => _template = fresh);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.storyLibraryLoadFailed)),
        );
    }
  }

  Future<void> _onShare() async {
    final AppLocalizations l10n = context.l10n;
    final String text =
        '${_template.title}\n\n${_template.summary}\n\n${_template.promptText}';
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.storyTemplateShareCopied)));
  }

  void _onStartCampaign() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (final _) =>
            NewGameScreen(storyTemplateId: _template.id),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final AppResponsiveData responsive = context.responsive;
    final SymmetrySession? sym = ref.watch(symmetrySessionProvider).value;
    final String symBase = sym?.baseUrl ?? '';
    final String? cover = symBase.isNotEmpty
        ? _template.resolveCoverDisplayUrl(symmetryBaseUrl: symBase)
        : _template.coverImageUrlFromMetadata;
    final Map<String, String>? coverHeaders =
        cover != null &&
            sym != null &&
            sym.tokens.accessToken.trim().isNotEmpty &&
            symBase.isNotEmpty &&
            cover.startsWith(symBase)
        ? <String, String>{
            'Authorization': 'Bearer ${sym.tokens.accessToken}',
          }
        : null;
    final String authorName =
        _template.authorDisplayName?.trim().isNotEmpty == true
        ? _template.authorDisplayName!.trim()
        : 'AI Master';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 68,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8),
          child: _DetailBackButton(
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (cover != null)
            Positioned.fill(
              child: AuthenticatedCoverImage(
                imageUrl: cover,
                requestHeaders: coverHeaders,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const ColoredBox(color: AetherPalette.background),
              ),
            )
          else
            const ColoredBox(color: AetherPalette.background),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withValues(alpha: 0.35),
                    AetherPalette.background.withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(responsive.pagePadding),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AetherPalette.panel.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AetherPalette.accent.withValues(alpha: 0.22),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.55),
                          blurRadius: 48,
                          offset: const Offset(0, 24),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(
                        responsive.isCompact ? 20 : 28,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.auto_awesome_rounded,
                                color: AetherPalette.accent,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.storyTemplateNarrativeEyebrow,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  letterSpacing: 3.2,
                                  color: AetherPalette.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: responsive.isCompact ? 12 : 16),
                          Text(
                            _template.title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: responsive.isCompact ? 28 : 38,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w400,
                              color: AetherPalette.textPrimary,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.storyTemplateAuthorLine(authorName),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AetherPalette.textMuted,
                            ),
                          ),
                          SizedBox(height: responsive.isCompact ? 16 : 22),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _template.tags
                                .map(
                                  (final String tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.06,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: AetherPalette.accent.withValues(
                                          alpha: 0.22,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      tag,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            letterSpacing: 1.2,
                                            color: AetherPalette.narrativeText,
                                          ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          SizedBox(height: responsive.isCompact ? 18 : 24),
                          Text(
                            _template.summary.isNotEmpty
                                ? _template.summary
                                : _template.promptText,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AetherPalette.narrativeText,
                              height: 1.55,
                            ),
                          ),
                          SizedBox(height: responsive.isCompact ? 22 : 28),
                          Wrap(
                            spacing: responsive.isCompact ? 24 : 36,
                            runSpacing: 16,
                            children: <Widget>[
                              _StatBlock(
                                icon: Icons.favorite_rounded,
                                iconColor: AetherPalette.accent,
                                value: '${_template.likes}',
                                label: l10n.storyTemplateLikesLabel,
                              ),
                              _StatBlock(
                                icon: Icons.visibility_outlined,
                                iconColor: AetherPalette.textMuted,
                                value: '${_template.views}',
                                label: l10n.storyTemplateViewsLabel,
                              ),
                            ],
                          ),
                          SizedBox(height: responsive.isCompact ? 22 : 28),
                          LayoutBuilder(
                            builder: (
                              final BuildContext context,
                              final BoxConstraints constraints,
                            ) {
                              final bool stack = constraints.maxWidth < 420;
                              final Widget primary = _GradientCta(
                                label: l10n.storyTemplateStartCampaign,
                                onPressed: _onStartCampaign,
                              );
                              final Widget secondaryLike = OutlinedButton.icon(
                                onPressed: _onLike,
                                icon: const Icon(Icons.favorite_border_rounded),
                                label: Text(l10n.storyTemplateLike),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AetherPalette.textPrimary,
                                  side: BorderSide(
                                    color: AetherPalette.accent.withValues(
                                      alpha: 0.35,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              );
                              final Widget secondaryShare = OutlinedButton.icon(
                                onPressed: _onShare,
                                icon: const Icon(Icons.share_outlined),
                                label: Text(l10n.storyTemplateShare),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AetherPalette.textPrimary,
                                  side: BorderSide(
                                    color: AetherPalette.accent.withValues(
                                      alpha: 0.35,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              );
                              if (stack) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    primary,
                                    const SizedBox(height: 10),
                                    secondaryLike,
                                    const SizedBox(height: 10),
                                    secondaryShare,
                                  ],
                                );
                              }
                              return Column(
                                children: <Widget>[
                                  primary,
                                  const SizedBox(height: 12),
                                  Row(
                                    children: <Widget>[
                                      Expanded(child: secondaryLike),
                                      const SizedBox(width: 12),
                                      Expanded(child: secondaryShare),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30, top: 2),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 2,
              color: AetherPalette.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientCta extends StatelessWidget {
  const _GradientCta({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(final BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          AetherPalette.gold,
          AetherPalette.accent,
        ],
      ),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: AetherPalette.accent.withValues(alpha: 0.35),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF2A1E10),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF2A1E10),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _DetailBackButton extends StatelessWidget {
  const _DetailBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AetherPalette.panelSoft.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AetherPalette.panelBorder.withValues(alpha: 0.85),
        ),
      ),
      child: const Icon(
        Icons.arrow_back_rounded,
        color: AetherPalette.textPrimary,
      ),
    ),
  );
}
