import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/app/app_route_observer.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/literary_genre_model.dart';
import 'package:ai_prg/src/core/widgets/aether_empty_state.dart';
import 'package:ai_prg/src/core/models/story_template_model.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/features/new_game/presentation/new_game_screen.dart';
import 'package:ai_prg/src/features/story_admin/presentation/story_admin_screen.dart';
import 'package:ai_prg/src/features/story_library/presentation/story_template_detail_screen.dart';
import 'package:ai_prg/src/features/story_library/presentation/widgets/story_template_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoryLibraryScreen extends ConsumerStatefulWidget {
  const StoryLibraryScreen({super.key});

  @override
  ConsumerState<StoryLibraryScreen> createState() => _StoryLibraryScreenState();
}

class _StoryLibraryScreenState extends ConsumerState<StoryLibraryScreen>
    with RouteAware {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;
  List<StoryTemplate> _templates = const <StoryTemplate>[];
  _LibraryScope _scope = _LibraryScope.master;
  String? _genreSlug;
  List<LiteraryGenreCatalogItem> _genreCatalog =
      const <LiteraryGenreCatalogItem>[];
  bool _routeSubscribed = false;

  @override
  void dispose() {
    if (_routeSubscribed) {
      appRouteObserver.unsubscribe(this);
    }
    _searchController.dispose();
    super.dispose();
  }

  bool _didInitLoad = false;

  void _ensureRouteObserver() {
    if (_routeSubscribed) {
      return;
    }
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      appRouteObserver.subscribe(this, route);
      _routeSubscribed = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureRouteObserver();
    if (_didInitLoad) {
      return;
    }
    _didInitLoad = true;
    _loadGenreCatalog();
    _load();
  }

  @override
  void didPopNext() {
    if (mounted) {
      _load(silent: true);
    }
  }

  Future<void> _loadGenreCatalog() async {
    try {
      final List<LiteraryGenreCatalogItem> rows = await ref
          .read(storyLibraryRepositoryProvider)
          .loadLiteraryGenres();
      if (!mounted) {
        return;
      }
      setState(() => _genreCatalog = rows);
    } catch (_) {
      // Catalog is optional; genre filter still works when empty.
    }
  }

  Future<void> _load({final bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    final AppLocalizations l10n = context.l10n;
    try {
      final List<StoryTemplate> list = await ref
          .read(storyLibraryRepositoryProvider)
          .loadTemplates(
            scope: switch (_scope) {
              _LibraryScope.master => 'master',
              _LibraryScope.community => 'community',
            },
            sort: 'popular',
            genre: _genreSlug,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _templates = list;
        _isLoading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      if (silent) {
        return;
      }
      setState(() {
        _templates = const <StoryTemplate>[];
        _error = l10n.storyLibraryLoadFailed;
        _isLoading = false;
      });
    }
  }

  List<StoryTemplate> _filtered() {
    final String q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      return _templates;
    }
    return _templates
        .where(
          (final t) =>
              t.title.toLowerCase().contains(q) ||
              t.summary.toLowerCase().contains(q) ||
              t.tags.any((final g) => g.toLowerCase().contains(q)),
        )
        .toList();
  }

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final AppResponsiveData responsive = context.responsive;
    final List<StoryTemplate> visible = _filtered();
    final int crossAxisCount = switch (responsive.breakpoint) {
      AppBreakpoint.desktop => 4,
      AppBreakpoint.tablet => 3,
      _ => 2,
    };
    final double cardAspectRatio = switch (crossAxisCount) {
      4 => 0.86,
      3 => 0.84,
      _ => 0.82,
    };
    final AsyncValue<SymmetrySession?> sessionState = ref.watch(
      symmetrySessionProvider,
    );
    final SymmetrySession? symSession = sessionState.value;
    final String symmetryBaseUrl = symSession?.baseUrl ?? '';
    final String? symmetryAccessToken =
        symSession != null && symSession.tokens.accessToken.trim().isNotEmpty
        ? symSession.tokens.accessToken.trim()
        : null;
    final List<Widget> adminActions = sessionState.maybeWhen(
      data: (final session) {
        final bool isAdmin =
            session != null && !session.isGuest && session.user.isAdmin;
        if (!isAdmin) {
          return const <Widget>[];
        }
        return <Widget>[
          IconButton(
            tooltip: l10n.storyAdminTitle,
            icon: const Icon(Icons.library_books_outlined),
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (final _) => const StoryAdminScreen(),
                ),
              );
            },
          ),
        ];
      },
      orElse: () => const <Widget>[],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leadingWidth: 68,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: _ToolbarIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
        title: Text(l10n.storyLibraryTitle),
        actions: adminActions,
      ),
      body: SafeArea(
        child: CustomScrollView(
          cacheExtent: responsive.isCompact ? 1200 : 1800,
          slivers: <Widget>[
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                responsive.pagePadding,
                12,
                responsive.pagePadding,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: _LibraryHeader(
                  l10n: l10n,
                  responsive: responsive,
                  scope: _scope,
                  onScopeChanged: (final s) {
                    if (s == _scope) {
                      return;
                    }
                    setState(() => _scope = s);
                    _load();
                  },
                  onCreateStory: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (final _) => const NewGameScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                responsive.pagePadding,
                16,
                responsive.pagePadding,
                8,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AetherPalette.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.storyLibrarySearchHint,
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: AetherPalette.textMuted,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AetherPalette.textMuted,
                          ),
                          filled: true,
                          fillColor: AetherPalette.backgroundElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AetherPalette.panelBorderSolid,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AetherPalette.panelBorderSolid,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AetherPalette.accent.withValues(
                                alpha: 0.55,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    PopupMenuButton<String>(
                      tooltip: l10n.storyLibraryGenresFilter,
                      onSelected: (final value) {
                        setState(
                          () => _genreSlug = value.isEmpty ? null : value,
                        );
                        _load();
                      },
                      itemBuilder: (final ctx) {
                        final bool ru = l10n.language == AppLanguage.ru;
                        final List<PopupMenuEntry<String>> items =
                            <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: '',
                                child: Text(l10n.storyLibraryAllGenres),
                              ),
                            ];
                        for (final LiteraryGenreCatalogItem g
                            in _genreCatalog) {
                          items.add(
                            PopupMenuItem<String>(
                              value: g.slug,
                              child: Text(g.labelForLocale(isRussian: ru)),
                            ),
                          );
                        }
                        return items;
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AetherPalette.backgroundElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AetherPalette.accent.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              l10n.storyLibraryGenresFilter,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AetherPalette.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.expand_more_rounded,
                              color: AetherPalette.accent,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: AetherCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () => _load(),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(l10n.retryButton),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_templates.isEmpty)
              SliverFillRemaining(
                child: AetherEmptyState(
                  icon: Icons.auto_stories_outlined,
                  title: l10n.storyLibraryEmptyCatalog,
                  subtitle: l10n.storyLibraryEmptyCatalogSubtitle,
                ),
              )
            else if (visible.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    l10n.storyLibraryNoSearchResults,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AetherPalette.textMuted,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  responsive.pagePadding,
                  8,
                  responsive.pagePadding,
                  32,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: responsive.sectionSpacing + 4,
                    crossAxisSpacing: responsive.sectionSpacing + 4,
                    childAspectRatio: cardAspectRatio,
                  ),
                  delegate: SliverChildBuilderDelegate((
                    final context,
                    final index,
                  ) {
                    final StoryTemplate item = visible[index];
                    return StoryTemplateGridCard(
                      key: ValueKey<String>('story-card-${item.id}'),
                      template: item,
                      symmetryBaseUrl: symmetryBaseUrl,
                      accessToken: symmetryAccessToken,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (final _) =>
                                StoryTemplateDetailScreen(template: item),
                          ),
                        );
                      },
                    );
                  }, childCount: visible.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum _LibraryScope { master, community }

class _LibraryHeader extends StatelessWidget {
  const _LibraryHeader({
    required this.l10n,
    required this.responsive,
    required this.scope,
    required this.onScopeChanged,
    required this.onCreateStory,
  });

  final AppLocalizations l10n;
  final AppResponsiveData responsive;
  final _LibraryScope scope;
  final ValueChanged<_LibraryScope> onScopeChanged;
  final VoidCallback onCreateStory;

  @override
  Widget build(final BuildContext context) {
    final bool narrow = responsive.isMobile;
    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ScopeTabs(l10n: l10n, scope: scope, onScopeChanged: onScopeChanged),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onCreateStory,
            style: OutlinedButton.styleFrom(
              foregroundColor: AetherPalette.accent,
              side: BorderSide(
                color: AetherPalette.accent.withValues(alpha: 0.55),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(l10n.storyLibraryCreateYourStory),
          ),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: _ScopeTabs(
            l10n: l10n,
            scope: scope,
            onScopeChanged: onScopeChanged,
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: onCreateStory,
          style: OutlinedButton.styleFrom(
            foregroundColor: AetherPalette.accent,
            side: BorderSide(
              color: AetherPalette.accent.withValues(alpha: 0.55),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(l10n.storyLibraryCreateYourStory),
        ),
      ],
    );
  }
}

class _ScopeTabs extends StatelessWidget {
  const _ScopeTabs({
    required this.l10n,
    required this.scope,
    required this.onScopeChanged,
  });

  final AppLocalizations l10n;
  final _LibraryScope scope;
  final ValueChanged<_LibraryScope> onScopeChanged;

  @override
  Widget build(final BuildContext context) => Row(
    children: <Widget>[
      _ScopeLink(
        label: l10n.storyLibraryTabMaster,
        selected: scope == _LibraryScope.master,
        onTap: () => onScopeChanged(_LibraryScope.master),
      ),
      SizedBox(width: context.responsive.isCompact ? 16 : 28),
      _ScopeLink(
        label: l10n.storyLibraryTabCommunity,
        selected: scope == _LibraryScope.community,
        onTap: () => onScopeChanged(_LibraryScope.community),
      ),
    ],
  );
}

class _ScopeLink extends StatelessWidget {
  const _ScopeLink({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected
                    ? AetherPalette.accent
                    : AetherPalette.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: selected ? 48 : 0,
              decoration: BoxDecoration(
                color: AetherPalette.accent,
                borderRadius: BorderRadius.circular(2),
                boxShadow: selected
                    ? <BoxShadow>[
                        BoxShadow(
                          color: AetherPalette.accent.withValues(alpha: 0.45),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  const _ToolbarIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AetherPalette.panelSoft.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AetherPalette.panelBorder.withValues(alpha: 0.72),
        ),
      ),
      child: Icon(icon, color: AetherPalette.textPrimary),
    ),
  );
}
