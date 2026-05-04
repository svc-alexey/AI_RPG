import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/features/chat/widgets/portrait_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatSidebar extends ConsumerWidget {
  const ChatSidebar({
    required this.campaignId,
    required this.campaign,
    required this.highlightedModules,
    required this.newlyUnlockedModules,
    required this.worldRumors,
    required this.onExitToMainMenu,
    super.key,
  });

  final String campaignId;
  final CampaignState campaign;
  final List<CampaignModule> highlightedModules;
  final List<CampaignModule> newlyUnlockedModules;
  final List<SymmetryWorldRumor> worldRumors;
  final VoidCallback onExitToMainMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final responsive = context.responsive;
    final character = campaign.character;
    final showVitality =
        campaign.isModuleActive(CampaignModule.vitality) &&
        (character.maxHp > 0 ||
            character.maxEnergy > 0 ||
            character.might > 0 ||
            character.wit > 0 ||
            character.spirit > 0);
    final latestWorldRumors = List<SymmetryWorldRumor>.from(worldRumors)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final latestRecentTurns = List<RecentTurnSummary>.from(
      campaign.recentTurns.reversed,
    ).take(5).toList();

    return AetherCard(
      padding: EdgeInsets.all(responsive.isCompact ? 8 : 14),
      child: ListView(
        padding: EdgeInsets.all(
          responsive.isCompact ? 8 : responsive.cardPadding - 2,
        ),
        children: <Widget>[
          _CharacterPortraitCard(campaign: campaign),
          SizedBox(height: responsive.sectionSpacing),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _SidebarMetaChip(label: '${l10n.turn}: ${campaign.turnNumber}'),
              _SidebarMetaChip(label: l10n.settingLabel(campaign.setting)),
            ],
          ),
          SizedBox(height: responsive.sectionSpacing),
          if (campaign.activeModules.isNotEmpty) ...<Widget>[
            _ModuleIconStrip(
              campaign: campaign,
              highlightedModules: highlightedModules,
              newlyUnlockedModules: newlyUnlockedModules,
            ),
            SizedBox(height: responsive.sectionSpacing),
          ],
          _SidebarInfoLine(label: l10n.location, value: campaign.location),
          SizedBox(height: responsive.isCompact ? 8 : 6),
          if (campaign.hasDisplayObjective) ...<Widget>[
            _SidebarInfoLine(
              label: l10n.objective,
              value: campaign.displayObjectiveLine,
            ),
            SizedBox(height: responsive.isCompact ? 8 : 6),
          ],
          SizedBox(height: responsive.sectionSpacing),
          if (showVitality) ...<Widget>[
            _SidebarSectionTitle(
              title: l10n.campaignModuleLabel(CampaignModule.vitality),
            ),
            const SizedBox(height: 8),
            Text(l10n.healthLabel(character)),
            Text(l10n.energyLabel(character)),
            Text(l10n.statsLabel(character)),
            SizedBox(height: responsive.sectionSpacing),
          ],
          if (campaign.isModuleActive(CampaignModule.inventory)) ...<Widget>[
            _SidebarSectionTitle(
              title: l10n.campaignModuleLabel(CampaignModule.inventory),
            ),
            const SizedBox(height: 8),
            if (campaign.inventory.isEmpty) Text(l10n.nothingTrackedYet),
            for (final item in campaign.inventory) Text('- $item'),
            SizedBox(height: responsive.sectionSpacing),
          ],
          if (campaign.isModuleActive(CampaignModule.notes)) ...<Widget>[
            _SidebarSectionTitle(
              title: l10n.campaignModuleLabel(CampaignModule.notes),
            ),
            const SizedBox(height: 8),
            if (campaign.notes.isEmpty) Text(l10n.nothingTrackedYet),
            for (final item in campaign.notes) Text('- $item'),
            SizedBox(height: responsive.sectionSpacing),
          ],
          if (campaign.isModuleActive(CampaignModule.companions)) ...<Widget>[
            _SidebarSectionTitle(
              title: l10n.campaignModuleLabel(CampaignModule.companions),
            ),
            const SizedBox(height: 8),
            if (campaign.companions.isEmpty) Text(l10n.nothingTrackedYet),
            for (final item in campaign.companions)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '- ${item.name} (${item.status})${item.notes.trim().isEmpty ? '' : ' • ${item.notes}'}',
                ),
              ),
            SizedBox(height: responsive.sectionSpacing),
          ],
          if (campaign.isModuleActive(CampaignModule.resources)) ...<Widget>[
            _SidebarSectionTitle(
              title: l10n.campaignModuleLabel(CampaignModule.resources),
            ),
            const SizedBox(height: 8),
            if (campaign.resources.isEmpty) Text(l10n.nothingTrackedYet),
            for (final item in campaign.resources)
              Text(
                '- ${item.label}: ${item.value}${item.maxValue == null ? '' : '/${item.maxValue}'}',
              ),
            SizedBox(height: responsive.sectionSpacing),
          ],
          if (campaign.isModuleActive(CampaignModule.progression)) ...<Widget>[
            _SidebarSectionTitle(
              title: l10n.campaignModuleLabel(CampaignModule.progression),
            ),
            const SizedBox(height: 8),
            Text(
              campaign.progression == null
                  ? l10n.nothingTrackedYet
                  : l10n.progressionLabel(campaign.progression!),
            ),
            const SizedBox(height: 16),
          ],
          if (campaign.isModuleActive(CampaignModule.checks)) ...<Widget>[
            _SidebarSectionTitle(
              title: l10n.campaignModuleLabel(CampaignModule.checks),
            ),
            const SizedBox(height: 8),
            if (campaign.checks.isEmpty) Text(l10n.nothingTrackedYet),
            for (final item in campaign.checks.reversed)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('- ${l10n.campaignCheckLabel(item)}'),
              ),
            const SizedBox(height: 16),
          ],
          Text(l10n.summary, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(campaign.summary),
          const SizedBox(height: 16),
          Text(
            l10n.worldRumorsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (latestWorldRumors.isEmpty)
            Text(l10n.worldRumorsEmpty)
          else
            for (final item in latestWorldRumors.take(5))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('- ${item.eventText}'),
                    if ((item.locationTitle ?? '').trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item.locationTitle!.trim(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AetherPalette.textDim),
                        ),
                      ),
                  ],
                ),
              ),
          const SizedBox(height: 16),
          Text(
            l10n.recentEventsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final item in latestRecentTurns)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('- ${item.playerAction} -> ${item.outcome}'),
            ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: Text(l10n.exitToMainMenu),
            onTap: onExitToMainMenu,
          ),
        ],
      ),
    );
  }
}

class _CharacterPortraitCard extends StatelessWidget {
  const _CharacterPortraitCard({required this.campaign});

  final CampaignState campaign;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final String imagePath = campaign.portraitPath.trim().isNotEmpty
        ? campaign.portraitPath.trim()
        : _portraitAssetForCampaign(campaign);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AetherPalette.backgroundElevated,
        borderRadius: BorderRadius.circular(responsive.isCompact ? 16 : 20),
        border: Border.all(color: AetherPalette.accent.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(responsive.isCompact ? 16 : 20),
            ),
            child: buildPortraitImage(
              portraitPath: imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: responsive.isCompact ? 190 : 220,
              errorBuilder: (_, __, ___) =>
                  _PortraitFallbackLabel(label: campaign.character.name),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              responsive.isCompact ? 12 : 14,
              10,
              responsive.isCompact ? 12 : 14,
              responsive.isCompact ? 12 : 14,
            ),
            child: Text(
              campaign.character.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AetherPalette.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortraitFallbackLabel extends StatelessWidget {
  const _PortraitFallbackLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    height: 180,
    color: AetherPalette.panel.withValues(alpha: 0.94),
    alignment: Alignment.center,
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AetherPalette.textMuted,
      ),
      textAlign: TextAlign.center,
    ),
  );
}

class _ModuleIconStrip extends StatelessWidget {
  const _ModuleIconStrip({
    required this.campaign,
    required this.highlightedModules,
    required this.newlyUnlockedModules,
  });

  final CampaignState campaign;
  final List<CampaignModule> highlightedModules;
  final List<CampaignModule> newlyUnlockedModules;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: campaign.activeModules.map((module) {
      final _ModuleHighlightState highlightState = _resolveHighlight(
        campaign: campaign,
        module: module,
      );
      return Tooltip(
        message: context.l10n.campaignModuleLabel(module),
        waitDuration: const Duration(milliseconds: 250),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AetherPalette.backgroundElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: switch (highlightState) {
                _ModuleHighlightState.newlyUnlocked =>
                  AetherPalette.accent.withValues(alpha: 0.75),
                _ModuleHighlightState.updated =>
                  AetherPalette.accentSoft.withValues(alpha: 0.78),
                _ModuleHighlightState.none => AetherPalette.panelBorderSolid,
              },
            ),
            boxShadow: highlightState == _ModuleHighlightState.none
                ? const <BoxShadow>[]
                : <BoxShadow>[
                    BoxShadow(
                      color: AetherPalette.accent.withValues(
                        alpha: highlightState == _ModuleHighlightState.newlyUnlocked
                            ? 0.22
                            : 0.12,
                      ),
                      blurRadius: 20,
                      spreadRadius: -6,
                    ),
                  ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Icon(
                _iconForModule(module),
                size: 18,
                color: highlightState == _ModuleHighlightState.none
                    ? AetherPalette.textMuted
                    : AetherPalette.textPrimary,
              ),
              if (highlightState != _ModuleHighlightState.none)
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: highlightState == _ModuleHighlightState.newlyUnlocked
                          ? AetherPalette.accent
                          : AetherPalette.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList(),
  );

  _ModuleHighlightState _resolveHighlight({
    required CampaignState campaign,
    required CampaignModule module,
  }) {
    if (newlyUnlockedModules.contains(module)) {
      return _ModuleHighlightState.newlyUnlocked;
    }
    if (highlightedModules.contains(module)) {
      return _ModuleHighlightState.updated;
    }
    final DateTime? activatedAt = campaign.moduleState(module)?.activatedAt;
    if (activatedAt == null) {
      return _ModuleHighlightState.none;
    }
    return DateTime.now().difference(activatedAt) <= const Duration(minutes: 5)
        ? _ModuleHighlightState.newlyUnlocked
        : _ModuleHighlightState.none;
  }
}

class _SidebarMetaChip extends StatelessWidget {
  const _SidebarMetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: context.responsive.isCompact ? 10 : 12,
      vertical: context.responsive.isCompact ? 6 : 8,
    ),
    decoration: BoxDecoration(
      color: AetherPalette.panelSoft,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: AetherPalette.panelBorderSolid),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AetherPalette.textPrimary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

class _SidebarInfoLine extends StatelessWidget {
  const _SidebarInfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        '$label:',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AetherPalette.textMuted,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: Theme.of(context).textTheme.bodyLarge,
        maxLines: context.responsive.isCompact ? 4 : 3,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

class _SidebarSectionTitle extends StatelessWidget {
  const _SidebarSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title.toUpperCase(),
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      letterSpacing: 2.2,
      color: AetherPalette.textDim,
      fontWeight: FontWeight.w600,
      fontSize: 10,
    ),
  );
}

String _portraitAssetForCampaign(CampaignState campaign) =>
    switch (campaign.setting) {
      CampaignSetting.cozyCrime => 'assets/images/portraits/detective_shadow.png',
      CampaignSetting.postApocalypse || CampaignSetting.nearFutureSciFi =>
        'assets/images/portraits/scifi_oracle.png',
      _ => 'assets/images/portraits/fantasy_guardian.png',
    };

IconData _iconForModule(CampaignModule module) => switch (module) {
  CampaignModule.inventory => Icons.backpack_outlined,
  CampaignModule.companions => Icons.groups_2_outlined,
  CampaignModule.notes => Icons.menu_book_outlined,
  CampaignModule.vitality => Icons.favorite_border_rounded,
  CampaignModule.resources => Icons.diamond_outlined,
  CampaignModule.progression => Icons.insights_outlined,
  CampaignModule.checks => Icons.casino_outlined,
};

enum _ModuleHighlightState { none, updated, newlyUnlocked }
