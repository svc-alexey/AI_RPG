import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_scope.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/features/chat/presentation/chat_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SavesScreen extends StatefulWidget {
  const SavesScreen({super.key});

  @override
  State<SavesScreen> createState() => _SavesScreenState();
}

class _SavesScreenState extends State<SavesScreen> {
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

    if (defaultTargetPlatform == TargetPlatform.windows) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.savedCampaigns)),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _campaigns.isEmpty
                    ? Center(child: Text(l10n.noSavesYet))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _campaigns.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final CampaignState campaign = _campaigns[index];
                          return Card(
                            child: ListTile(
                              title: Text(campaign.title),
                              subtitle: Text(l10n.saveSubtitle(campaign)),
                              trailing: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 180),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    TextButton(
                                      onPressed: () => _delete(campaign.id),
                                      child: const Text('Delete'),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (context) => ChatScreen(
                                                campaignId: campaign.id,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(l10n.loadCampaignAction),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      );
    }

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
                        child: AetherCard(
                          child: Text(
                            l10n.noSavesYet,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      )
                    : Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1040),
                          child: ListView.separated(
                            padding: const EdgeInsets.all(24),
                            itemCount: _campaigns.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 16),
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
    final AppScope scope = AppScope.of(context);
    final AppLocalizations l10n = context.l10n;

    try {
      final List<CampaignState> campaigns = await scope.campaignRepository
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
    final AppScope scope = AppScope.of(context);
    await scope.campaignRepository.deleteCampaign(id);
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
  Widget build(final BuildContext context) => AetherCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              campaign.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text(
              campaign.summary.isEmpty ? campaign.objective : campaign.summary,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Text(
                  '${campaign.updatedAt.day.toString().padLeft(2, '0')}.${campaign.updatedAt.month.toString().padLeft(2, '0')}.${campaign.updatedAt.year}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                _SavesToolbarButton(
                  icon: Icons.delete_outline_rounded,
                  onTap: onDelete,
                ),
                const SizedBox(width: 8),
                _SavesActionButton(
                  label: context.l10n.loadCampaignAction,
                  onTap: onOpen,
                ),
              ],
            ),
          ],
        ),
      );
}

class _SavesToolbarButton extends StatelessWidget {
  const _SavesToolbarButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
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

class _SavesActionButton extends StatelessWidget {
  const _SavesActionButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: AetherPalette.accentSoft.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AetherPalette.panelBorder.withValues(alpha: 0.7),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      );
}
