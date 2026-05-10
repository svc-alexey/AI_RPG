import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/widgets/aether_confirmation_dialog.dart';
import 'package:ai_prg/src/features/chat/presentation/chat_screen.dart';
import 'package:ai_prg/src/features/new_game/presentation/new_game_screen.dart';
import 'package:ai_prg/src/core/presentation/widgets/app_error_view.dart';
import 'package:ai_prg/src/features/story_library/presentation/story_library_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SavesScreen extends ConsumerStatefulWidget {
  const SavesScreen({super.key});

  @override
  ConsumerState<SavesScreen> createState() => _SavesScreenState();
}

class _SavesScreenState extends ConsumerState<SavesScreen> {
  bool _isLoading = true;
  bool _didLoad = false;
  List<CampaignState> _campaigns = const <CampaignState>[];
  String? _error;
  String? _deletingId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) {
      return;
    }
    _didLoad = true;
    _load();
  }

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppResponsiveData responsive = context.responsive;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 68,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: _SavesToolbarButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
        title: Text(l10n.savedCampaigns),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.storyLibraryTitle,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (final _) => const StoryLibraryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.public_rounded),
          ),
        ],
      ),
      body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? AppErrorView(
                message: _error!,
                onRetry: _load,
              )
            : _campaigns.isEmpty
            ? Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: responsive.isMobile ? 400 : 440,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                      responsive.isCompact
                          ? 20
                          : (responsive.isMobile ? 24 : 32),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.auto_stories_outlined,
                          size: 64,
                          color: AetherPalette.textMuted.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.noSavesYet,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: AetherPalette.textMuted),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noSavesCreateNew,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AetherPalette.textMuted),
                        ),
                        const SizedBox(height: 32),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => const NewGameScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: Text(l10n.createNewCampaign),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: ListView.separated(
                    padding: EdgeInsets.all(responsive.pagePadding),
                    itemCount: _campaigns.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: responsive.sectionSpacing),
                    itemBuilder: (context, index) {
                      final CampaignState campaign = _campaigns[index];
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) =>
                            SizeTransition(
                          sizeFactor: animation,
                          axisAlignment: -1,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        ),
                        child: AetherPageReveal(
                          key: ValueKey(campaign.id),
                          delay: Duration(milliseconds: 60 * index),
                          child: _SaveCard(
                            campaign: campaign,
                            subtitle: l10n.saveSubtitle(campaign),
                            isDeleting: _deletingId == campaign.id,
                            onOpen: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (context) =>
                                      ChatScreen(campaignId: campaign.id),
                                ),
                              );
                            },
                            onShareToLibrary: () =>
                                _shareCampaignToLibrary(campaign),
                            onDelete: () => _delete(campaign.id),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
    );
  }

  Future<void> _load() async {
    final AppLocalizations l10n = context.l10n;

    try {
      final List<CampaignState> campaigns = await ref
          .read(symmetryCampaignRepositoryProvider)
          .loadAllCampaigns();
      if (!mounted) {
        return;
      }
      setState(() {
        _campaigns = campaigns;
        _error = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _campaigns = const <CampaignState>[];
        _error = l10n.savesOpenFailed;
        _isLoading = false;
      });
    }
  }

  Future<void> _delete(final String id) async {
    final AppLocalizations l10n = context.l10n;
    final bool? confirmed = await showAetherConfirmationDialog(
      context,
      title: l10n.deleteCampaignConfirmTitle,
      message: l10n.deleteCampaignConfirmMessage,
      confirmLabel: l10n.deleteLabel,
      cancelLabel: l10n.cancelLabel,
      destructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deletingId = id);
    try {
      await ref.read(symmetryCampaignRepositoryProvider).deleteCampaign(id);
      if (!mounted) return;
      setState(() {
        _campaigns = _campaigns.where((c) => c.id != id).toList();
        _deletingId = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _deletingId = null);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.deleteCampaignFailed)),
        );
    }
  }

  Future<void> _shareCampaignToLibrary(final CampaignState campaign) async {
    final AppLocalizations l10n = context.l10n;
    final SymmetrySession? sym = ref.read(symmetrySessionProvider).value;
    if (sym == null || sym.isGuest) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.savesShareRequiresAccount)),
        );
      return;
    }
    final String prompt = campaign.customStoryPrompt.trim();
    if (prompt.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.savesShareMissingPrompt)),
        );
      return;
    }
    final String summaryLine = campaign.displayObjectiveLine.trim().isNotEmpty
        ? campaign.displayObjectiveLine.trim()
        : campaign.summary.trim();
    final Map<String, Object?> payload = <String, Object?>{
      'title': campaign.title.trim().isNotEmpty
          ? campaign.title.trim()
          : (l10n.language == AppLanguage.ru ? 'Мир игрока' : 'Player world'),
      'summary': summaryLine,
      'prompt_text': prompt,
      'setting': campaign.setting.name,
      if (campaign.literaryGenre != null)
        'literary_genre_slug': campaign.literaryGenre!.name,
      'tags': const <String>[],
      'is_public': true,
      'metadata': <String, Object?>{
        'source_campaign_id': campaign.id,
        'published_from': 'saves',
      },
    };
    try {
      await ref.read(storyLibraryRepositoryProvider).publishStoryTemplate(
        payload: payload,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.savesShareToLibrarySuccess)),
        );
    } catch (err) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.symmetryFriendlyError(err))),
        );
    }
  }
}

class _SaveCard extends StatelessWidget {
  const _SaveCard({
    required this.campaign,
    required this.subtitle,
    required this.isDeleting,
    required this.onOpen,
    required this.onShareToLibrary,
    required this.onDelete,
  });

  final CampaignState campaign;
  final String subtitle;
  final bool isDeleting;
  final VoidCallback onOpen;
  final VoidCallback onShareToLibrary;
  final VoidCallback onDelete;

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppResponsiveData responsive = context.responsive;
    final bool isNarrow = responsive.isCompact;
    final bool isMobile = responsive.isMobile;

    return Stack(
      children: <Widget>[
        AetherCard(
          padding: EdgeInsets.all(responsive.cardPadding),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            campaign.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: isNarrow ? 18 : 24),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 2,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                l10n.settingLabel(campaign.setting),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AetherPalette.textMuted,
                  fontSize: isNarrow ? 11 : 12,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                ' • ',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AetherPalette.textMuted),
              ),
              Text(
                '${l10n.turn} ${campaign.turnNumber}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AetherPalette.textMuted,
                  fontSize: isNarrow ? 11 : 12,
                ),
              ),
              Text(
                ' • ',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AetherPalette.textMuted),
              ),
              Text(
                '${campaign.updatedAt.day.toString().padLeft(2, '0')}.${campaign.updatedAt.month.toString().padLeft(2, '0')}.${campaign.updatedAt.year}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AetherPalette.textMuted,
                  fontSize: isNarrow ? 11 : 12,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.sectionSpacing),
          Text(
            campaign.summary.isEmpty ? campaign.objective : campaign.summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              fontSize: isNarrow ? 13 : 14,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: responsive.sectionSpacing),
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: _SavesActionButton(
                    label: l10n.loadCampaignAction,
                    onTap: onOpen,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onShareToLibrary,
                  icon: const Icon(Icons.public_rounded, size: 18),
                  label: Text(l10n.savesPublishToLibrary),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: Text(l10n.delete),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                _SavesToolbarButton(
                  icon: Icons.delete_outline_rounded,
                  onTap: onDelete,
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: l10n.savesShareToLibraryTooltip,
                  child: _SavesToolbarButton(
                    icon: Icons.public_rounded,
                    onTap: onShareToLibrary,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _SavesActionButton(
                    label: l10n.loadCampaignAction,
                    onTap: onOpen,
                  ),
                ),
              ],
            ),
        ],
      ),
    ),
    if (isDeleting)
      Positioned.fill(
        child: Container(
          color: AetherPalette.backgroundElevated.withAlpha(200),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
  ],
);
  }
}

class _SavesToolbarButton extends StatelessWidget {
  const _SavesToolbarButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      width: context.responsive.isCompact ? 40 : 44,
      height: context.responsive.isCompact ? 40 : 44,
      decoration: BoxDecoration(
        color: AetherPalette.panelSoft.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(
          context.responsive.isCompact ? 12 : 14,
        ),
        border: Border.all(
          color: AetherPalette.panelBorder.withValues(alpha: 0.72),
        ),
      ),
      child: Icon(icon, color: AetherPalette.textPrimary),
    ),
  );
}

class _SavesActionButton extends StatelessWidget {
  const _SavesActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsive.isCompact ? 16 : 18,
        vertical: context.responsive.isCompact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: AetherPalette.accentSoft.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(
          context.responsive.isCompact ? 14 : 16,
        ),
        border: Border.all(
          color: AetherPalette.panelBorder.withValues(alpha: 0.7),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge,
        textAlign: TextAlign.center,
      ),
    ),
  );
}
