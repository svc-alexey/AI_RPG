import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/story_template_model.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/features/story_admin/presentation/story_admin_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoryAdminScreen extends ConsumerStatefulWidget {
  const StoryAdminScreen({super.key});

  @override
  ConsumerState<StoryAdminScreen> createState() => _StoryAdminScreenState();
}

class _StoryAdminScreenState extends ConsumerState<StoryAdminScreen> {
  bool _isLoading = true;
  String? _error;
  List<StoryTemplate> _templates = const <StoryTemplate>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((final _) => _reload());
  }

  Future<void> _reload() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final List<StoryTemplate> list = await ref
          .read(storyLibraryRepositoryProvider)
          .loadAllTemplatesAdmin();
      if (!mounted) {
        return;
      }
      setState(() {
        _templates = list;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmDelete(final StoryTemplate template) async {
    final AppLocalizations l10n = context.l10n;
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (final BuildContext dialogContext) => AlertDialog(
        title: Text(l10n.storyAdminDelete),
        content: Text(l10n.storyAdminDeleteConfirm),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.storyAdminDelete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) {
      return;
    }
    try {
      await ref
          .read(storyLibraryRepositoryProvider)
          .deleteStoryTemplateAdmin(template.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.storyAdminDeleted)));
      await _reload();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.symmetryFriendlyError(error))),
        );
    }
  }

  Future<void> _openEditor({final StoryTemplate? template}) async {
    final Object? result = await Navigator.of(context).push<Object?>(
      MaterialPageRoute<Object?>(
        builder: (final BuildContext routeContext) =>
            StoryAdminEditorScreen(existing: template),
      ),
    );
    if (result == true) {
      await _reload();
    }
  }

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final AppResponsiveData responsive = context.responsive;
    final AsyncValue<SymmetrySession?> sessionState = ref.watch(
      symmetrySessionProvider,
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.storyAdminTitle)),
      floatingActionButton: sessionState.maybeWhen(
        data: (final SymmetrySession? session) {
          final bool isAdmin =
              session != null && !session.isGuest && session.user.isAdmin;
          if (!isAdmin) {
            return null;
          }
          return FloatingActionButton.extended(
            onPressed: () => _openEditor(),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.storyAdminCreate),
          );
        },
        orElse: () => null,
      ),
      body: AetherBackdrop(
        child: sessionState.when(
          data: (final SymmetrySession? session) {
            final bool isAdmin =
                session != null && !session.isGuest && session.user.isAdmin;
            if (!isAdmin) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(responsive.pagePadding),
                  child: Text(
                    l10n.storyAdminAccessDenied,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              );
            }
            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_error != null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(responsive.pagePadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        l10n.symmetryFriendlyError(_error!),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _reload,
                        child: Text(l10n.retryButton),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (_templates.isEmpty) {
              return Center(
                child: Text(
                  l10n.storyLibraryEmptyCatalog,
                  style: theme.textTheme.titleMedium,
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView.separated(
                padding: EdgeInsets.all(responsive.pagePadding),
                itemCount: _templates.length,
                separatorBuilder: (final _, final _) =>
                    SizedBox(height: responsive.blockSpacing),
                itemBuilder: (final context, final index) {
                  final StoryTemplate t = _templates[index];
                  return AetherCard(
                    padding: EdgeInsets.all(responsive.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    t.title,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  if (t.summary.trim().isNotEmpty) ...<Widget>[
                                    const SizedBox(height: 6),
                                    Text(
                                      t.summary,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: AetherPalette.textMuted,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: l10n.storyAdminEdit,
                              onPressed: () => _openEditor(template: t),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: l10n.storyAdminDelete,
                              onPressed: () => _confirmDelete(t),
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: <Widget>[
                            Chip(
                              label: Text(
                                t.isPublic
                                    ? l10n.storyAdminPublic
                                    : l10n.storyAdminPrivate,
                                style: theme.textTheme.labelSmall,
                              ),
                            ),
                            if (t.isMasterCurated)
                              Chip(
                                label: Text(
                                  l10n.storyAdminMasterCurated,
                                  style: theme.textTheme.labelSmall,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (final Object error, final StackTrace stackTrace) => Center(
            child: Padding(
              padding: EdgeInsets.all(responsive.pagePadding),
              child: Text(l10n.symmetryFriendlyError(error)),
            ),
          ),
        ),
      ),
    );
  }
}
