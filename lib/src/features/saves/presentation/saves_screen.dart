import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/features/chat/presentation/chat_screen.dart';
import 'package:ai_prg/src/features/new_game/presentation/new_game_screen.dart';
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
      ),
      body: AetherBackdrop(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: AetherCard(
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
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
                      return AetherPageReveal(
                        delay: Duration(milliseconds: 60 * index),
                        child: _SaveCard(
                          campaign: campaign,
                          subtitle: l10n.saveSubtitle(campaign),
                          onOpen: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) =>
                                    ChatScreen(campaignId: campaign.id),
                              ),
                            );
                          },
                          onDelete: () => _delete(campaign.id),
                        ),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _load() async {
    final AppLocalizations l10n = context.l10n;

    try {
      final List<CampaignState> campaigns = await ref
          .read(campaignRepositoryProvider)
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
    await ref.read(campaignRepositoryProvider).deleteCampaign(id);
    await _load();
  }
}

class _SaveCard extends StatelessWidget {
  const _SaveCard({
    required this.campaign,
    required this.subtitle,
    required this.onOpen,
    required this.onDelete,
  });

  final CampaignState campaign;
  final String subtitle;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppResponsiveData responsive = context.responsive;
    final bool isNarrow = responsive.isCompact;
    final bool isMobile = responsive.isMobile;

    return AetherCard(
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
              children: [
                SizedBox(
                  width: double.infinity,
                  child: _SavesActionButton(
                    label: l10n.loadCampaignAction,
                    onTap: onOpen,
                  ),
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
