import 'dart:async';
import 'dart:convert';

import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/repositories/symmetry_auth_repository.dart';
import 'package:ai_prg/src/features/chat/presentation/widgets/stats_radar.dart';
import 'package:ai_prg/src/features/chat/widgets/portrait_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class ChatSidebar extends ConsumerStatefulWidget {
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
  ConsumerState<ChatSidebar> createState() => _ChatSidebarState();
}

class _ChatSidebarState extends ConsumerState<ChatSidebar>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _rebuildTabs();
  }

  @override
  void didUpdateWidget(covariant ChatSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.campaign.activeModules != widget.campaign.activeModules) {
      _rebuildTabs();
    }
  }

  void _rebuildTabs() {
    final tabs = _buildTabList();
    _tabController?.dispose();
    _tabController = TabController(
      length: tabs.length,
      vsync: this,
      initialIndex: 0,
    );
  }

  List<CampaignModule> _buildTabList() {
    final modules = <CampaignModule>[];
    final character = widget.campaign.character;
    final showVitality = widget.campaign
            .isModuleActive(CampaignModule.vitality) &&
        (character.maxHp > 0 ||
            character.maxEnergy > 0 ||
            character.might > 0 ||
            character.wit > 0 ||
            character.spirit > 0);
    if (showVitality) modules.add(CampaignModule.vitality);
    for (final m in widget.campaign.activeModules) {
      if (m != CampaignModule.vitality && !modules.contains(m)) {
        modules.add(m);
      }
    }
    return modules;
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final responsive = context.responsive;
    final campaign = widget.campaign;
    final tabs = _buildTabList();

    if (tabs.isEmpty) {
      return _fallbackSidebar(context);
    }

    // Ensure TabController is in sync
    if (_tabController == null || _tabController!.length != tabs.length) {
      _rebuildTabs();
    }

    final tabController = _tabController!;

    final double contentPadding = responsive.isCompact ? 8 : 14;

    return AetherCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(responsive.cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1. Portrait image — bleeds to card edges
            _CharacterPortraitCard(campaign: campaign, campaignId: widget.campaignId),

            // 2. Content below portrait
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  contentPadding,
                  10,
                  contentPadding,
                  contentPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Character name
                    Text(
                      campaign.character.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AetherPalette.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: responsive.sectionSpacing - 4),

                    // Meta info
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _SidebarMetaChip(label: '${l10n.turn}: ${campaign.turnNumber}'),
                        _SidebarMetaChip(label: l10n.settingLabel(campaign.setting)),
                      ],
                    ),
                    SizedBox(height: responsive.isCompact ? 8 : 6),

                    // Location + Objective
                    _SidebarInfoLine(label: l10n.location, value: campaign.location),
                    SizedBox(height: responsive.isCompact ? 8 : 6),
                    if (campaign.hasDisplayObjective) ...[
                      _SidebarInfoLine(
                        label: l10n.objective,
                        value: campaign.displayObjectiveLine,
                      ),
                      SizedBox(height: responsive.isCompact ? 8 : 6),
                    ],

                    // TabBar
                    TabBar(
                      controller: tabController,
                      isScrollable: false,
                      indicatorColor: const Color(0xFFBFA76F),
                      labelColor: AetherPalette.textPrimary,
                      unselectedLabelColor: AetherPalette.textMuted,
                      tabs: tabs.map((m) => _buildTab(m, l10n, responsive)).toList(),
                    ),

                    // TabBarView
                    Expanded(
                      child: TabBarView(
                        controller: tabController,
                        children: tabs.map((m) => _buildTabContent(m, context)).toList(),
                      ),
                    ),

                    // Exit button
                    const SizedBox(height: 8),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.home_outlined, size: 20),
                      title: Text(l10n.exitToMainMenu),
                      onTap: widget.onExitToMainMenu,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
    CampaignModule module,
    AppLocalizations l10n,
    AppResponsiveData responsive,
  ) {
    final icon = _iconForModule(module);
    final label = l10n.campaignModuleLabel(module);
    final iconWidget = Icon(icon, size: responsive.isCompact ? 22 : 20);
    return Tab(
      child: Tooltip(
        message: label,
        child: Center(child: iconWidget),
      ),
    );
  }

  Widget _buildTabContent(CampaignModule module, BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.responsive.isCompact ? 8 : 12),
      child: switch (module) {
        CampaignModule.vitality => _VitalityTab(
            character: widget.campaign.character,
          ),
        CampaignModule.inventory => _InventoryTab(
            inventory: widget.campaign.inventory,
          ),
        CampaignModule.companions => _CompanionsTab(
            companions: widget.campaign.companions,
          ),
        CampaignModule.notes => _NotesTab(
            notes: widget.campaign.notes,
          ),
        CampaignModule.resources => _ResourcesTab(
            resources: widget.campaign.resources,
          ),
        CampaignModule.progression => _ProgressionTab(
            progression: widget.campaign.progression,
          ),
        CampaignModule.checks => _ChecksTab(
            checks: widget.campaign.checks,
          ),
      },
    );
  }

  Widget _fallbackSidebar(BuildContext context) {
    final l10n = context.l10n;
    final campaign = widget.campaign;

    final double contentPadding = context.responsive.isCompact ? 8 : 14;

    return AetherCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.responsive.cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _CharacterPortraitCard(campaign: campaign, campaignId: widget.campaignId),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(contentPadding),
                children: <Widget>[
                  Text(
                    campaign.character.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AetherPalette.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.summary),
                  const SizedBox(height: 8),
                  Text(campaign.summary),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.home_outlined),
                    title: Text(l10n.exitToMainMenu),
                    onTap: widget.onExitToMainMenu,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab content widgets ──────────────────────────────────────────────────

class _VitalityTab extends StatelessWidget {
  const _VitalityTab({required this.character});

  final CharacterStats character;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // HP bar
        _VitalityBar(
          label: 'HP',
          value: character.hp,
          max: character.maxHp,
          colorFn: _hpColor,
        ),
        const SizedBox(height: 12),
        // Energy bar
        _VitalityBar(
          label: 'Energy',
          value: character.energy,
          max: character.maxEnergy,
          colorFn: (_, __) => const Color(0xFF4A90D9),
        ),
        const SizedBox(height: 20),
        // Stats radar
        Center(
          child: StatsRadar(
            might: character.might,
            wit: character.wit,
            spirit: character.spirit,
          ),
        ),
        const SizedBox(height: 12),
        // Text labels
        Text(
          l10n.healthLabel(character),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AetherPalette.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.energyLabel(character),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AetherPalette.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.statsLabel(character),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AetherPalette.textMuted,
          ),
        ),
      ],
    );
  }

  static Color _hpColor(int hp, int maxHp) {
    if (maxHp <= 0) return const Color(0xFF34D399);
    final ratio = hp / maxHp;
    if (ratio < 0.25) return const Color(0xFFD85A30);
    if (ratio < 0.5) return const Color(0xFFC87941);
    return const Color(0xFF34D399);
  }
}

class _VitalityBar extends StatelessWidget {
  const _VitalityBar({
    required this.label,
    required this.value,
    required this.max,
    required this.colorFn,
  });

  final String label;
  final int value;
  final int max;
  final Color Function(int value, int max) colorFn;

  @override
  Widget build(BuildContext context) {
    final ratio = max > 0 ? (value / max).clamp(0.0, 1.0) : 0.0;
    final color = colorFn(value, max);

    return Row(
      children: <Widget>[
        SizedBox(
          width: 48,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AetherPalette.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: AetherPalette.panelBorderSolid.withValues(alpha: 0.4),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$value/$max',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AetherPalette.textMuted,
          ),
        ),
      ],
    );
  }
}

class _InventoryTab extends StatelessWidget {
  const _InventoryTab({required this.inventory});

  final List<String> inventory;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (inventory.isEmpty) {
      return _EmptyState(
        icon: Icons.backpack_outlined,
        text: switch (l10n.language) {
          AppLanguage.ru =>
            'Твой рюкзак пуст. Предметы появятся здесь когда ты найдёшь их в мире.',
          AppLanguage.en =>
            'Your backpack is empty. Items will appear here as you find them in the world.',
        },
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: inventory.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text('- $item'),
      )).toList(),
    );
  }
}

class _CompanionsTab extends StatelessWidget {
  const _CompanionsTab({required this.companions});

  final List<CampaignCompanion> companions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (companions.isEmpty) {
      return _EmptyState(
        icon: Icons.groups_2_outlined,
        text: switch (l10n.language) {
          AppLanguage.ru =>
            'Спутники присоединятся к тебе по мере приключений.',
          AppLanguage.en =>
            'Companions will join you as your adventures unfold.',
        },
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: companions.whereType<CampaignCompanion>().map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          '- ${item.name} (${item.status})${item.notes.trim().isEmpty ? '' : ' • ${item.notes}'}',
        ),
      )).toList(),
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({required this.notes});

  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (notes.isEmpty) {
      return _EmptyState(
        icon: Icons.menu_book_outlined,
        text: switch (l10n.language) {
          AppLanguage.ru =>
            'Заметки создаются автоматически при расследованиях и важных открытиях.',
          AppLanguage.en =>
            'Notes are created automatically during investigations and important discoveries.',
        },
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: notes.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text('- $item'),
      )).toList(),
    );
  }
}

class _ResourcesTab extends StatelessWidget {
  const _ResourcesTab({required this.resources});

  final List<CampaignResource> resources;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (resources.isEmpty) {
      return _EmptyState(
        icon: Icons.diamond_outlined,
        text: switch (l10n.language) {
          AppLanguage.ru =>
            'Ресурсы появятся когда ты начнёшь собирать припасы и валюту в мире.',
          AppLanguage.en =>
            'Resources will appear as you collect supplies and currency in the world.',
        },
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: resources.whereType<CampaignResource>().map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          '- ${item.label}: ${item.value}${item.maxValue == null ? '' : '/${item.maxValue}'}',
        ),
      )).toList(),
    );
  }
}

class _ProgressionTab extends StatelessWidget {
  const _ProgressionTab({required this.progression});

  final CampaignProgression? progression;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (progression == null) {
      return _EmptyState(
        icon: Icons.insights_outlined,
        text: switch (l10n.language) {
          AppLanguage.ru =>
            'Прогресс героя будет отображаться здесь по мере прохождения.',
          AppLanguage.en =>
            'Hero progression will appear here as you advance.',
        },
      );
    }
    return Text(l10n.progressionLabel(progression!));
  }
}

class _ChecksTab extends StatelessWidget {
  const _ChecksTab({required this.checks});

  final List<CampaignCheck> checks;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (checks.isEmpty) {
      return _EmptyState(
        icon: Icons.casino_outlined,
        text: switch (l10n.language) {
          AppLanguage.ru =>
            'Результаты проверок навыков появятся здесь.',
          AppLanguage.en =>
            'Skill check results will appear here.',
        },
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: checks.reversed.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text('- ${l10n.campaignCheckLabel(item)}'),
      )).toList(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 40, color: const Color(0xFF3D3328)),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF5A5550),
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── Reused widget classes ─────────────────────────────────────────────────

class _CharacterPortraitCard extends ConsumerStatefulWidget {
  const _CharacterPortraitCard({required this.campaign, required this.campaignId});

  final CampaignState campaign;
  final String campaignId;

  @override
  ConsumerState<_CharacterPortraitCard> createState() =>
      _CharacterPortraitCardState();
}

class _CharacterPortraitCardState
    extends ConsumerState<_CharacterPortraitCard> {
  String? _polledStatus;
  String? _polledUrl;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _polledStatus = widget.campaign.portraitStatus;
    _polledUrl = widget.campaign.portraitUrl;

    final needsPoll =
        (widget.campaign.turnNumber == 1 &&
            _polledStatus != 'ready' &&
            _polledStatus != 'failed') ||
        _polledStatus == 'pending';
    print('[PORTRAIT] initState turn=${widget.campaign.turnNumber} '
        'status=$_polledStatus url=$_polledUrl needsPoll=$needsPoll '
        'cid=${widget.campaignId}');
    if (needsPoll) {
      _startPolling();
    }
  }

  @override
  void didUpdateWidget(covariant _CharacterPortraitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newStatus = widget.campaign.portraitStatus;
    final newUrl = widget.campaign.portraitUrl;

    if (newStatus == 'ready' && newUrl != null) {
      print('[PORTRAIT] didUpdateWidget READY sync cid=${widget.campaignId}');
      _polledStatus = newStatus;
      _polledUrl = newUrl;
      _pollTimer?.cancel();
      _pollTimer = null;
      return;
    }

    final justTurnedOne = widget.campaign.turnNumber == 1 &&
        oldWidget.campaign.turnNumber != 1;
    final becamePending = newStatus == 'pending' &&
        oldWidget.campaign.portraitStatus != 'pending';
    print('[PORTRAIT] didUpdateWidget '
        'oldTurn=${oldWidget.campaign.turnNumber} '
        'newTurn=${widget.campaign.turnNumber} '
        'oldStatus=${oldWidget.campaign.portraitStatus} '
        'newStatus=$newStatus '
        'justTurnedOne=$justTurnedOne '
        'becamePending=$becamePending '
        'timerActive=${_pollTimer != null} '
        'cid=${widget.campaignId}');
    if ((justTurnedOne || becamePending) && _pollTimer == null) {
      _polledStatus = newStatus;
      _polledUrl = newUrl;
      _startPolling();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    print('[PORTRAIT] Poll START cid=${widget.campaignId}');
    final stopwatch = Stopwatch()..start();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!mounted) {
        print('[PORTRAIT] Poll TICK not-mounted, cancel');
        timer.cancel();
        return;
      }
      final elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed > 60000) {
        print('[PORTRAIT] Poll TIMEOUT elapsed=$elapsed');
        timer.cancel();
        if (mounted) {
          setState(() => _polledStatus = 'failed');
        }
        return;
      }
      try {
        final authRepo = ref.read(symmetryAuthRepositoryProvider);
        final session = await authRepo.ensureSession(allowGuest: true);
        final apiUrl = '${session.baseUrl}/campaigns/${widget.campaignId}/state';
        final response = await http.get(
          Uri.parse(apiUrl),
          headers: {'Authorization': 'Bearer ${session.tokens.accessToken}'},
        );
        if (response.statusCode != 200) {
          print('[PORTRAIT] Poll HTTP ${response.statusCode}');
          return;
        }
        final data = json.decode(response.body) as Map<String, dynamic>;
        final cj = data['campaign'] as Map<String, dynamic>?;
        final newStatus = cj?['portrait_status'] as String?;
        print('[PORTRAIT] Poll TICK status=$newStatus elapsed=$elapsed');

        if (newStatus == 'ready' && mounted) {
          final newUrl =
              '${session.baseUrl}/campaigns/${widget.campaignId}/portrait/image';
          print('[PORTRAIT] Poll READY url=$newUrl');
          setState(() {
            _polledStatus = 'ready';
            _polledUrl = newUrl;
          });
          timer.cancel();
        } else if (newStatus == 'failed' && mounted) {
          print('[PORTRAIT] Poll FAILED');
          setState(() => _polledStatus = 'failed');
          timer.cancel();
        }
      } catch (e) {
        print('[PORTRAIT] Poll ERROR $e');
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final double height = responsive.isMobile ? 200 : 220;
    final String? status = _polledStatus ?? widget.campaign.portraitStatus;
    final String? url = _polledUrl ?? widget.campaign.portraitUrl;
    final bool hasImageUrl = url != null && url.isNotEmpty;

    if (widget.campaign.turnNumber == 1 &&
        status != 'ready' &&
        status != 'failed' &&
        !hasImageUrl) {
      return _PortraitLoadingPlaceholder(
          height: height, label: widget.campaign.character.name);
    }

    if (status == 'pending') {
      return _PortraitLoadingPlaceholder(
          height: height, label: widget.campaign.character.name);
    }

    if (hasImageUrl) {
      return Image.network(
        url!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
        errorBuilder: (_, __, ___) =>
            _PortraitFallbackLabel(label: widget.campaign.character.name),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _PortraitLoadingPlaceholder(
              height: height, label: widget.campaign.character.name);
        },
      );
    }

    final String imagePath = widget.campaign.portraitPath.trim().isNotEmpty
        ? widget.campaign.portraitPath.trim()
        : _portraitAssetForCampaign(widget.campaign);

    return buildPortraitImage(
      portraitPath: imagePath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: height,
      errorBuilder: (_, __, ___) =>
          _PortraitFallbackLabel(label: widget.campaign.character.name),
    );
  }
}

class _PortraitLoadingPlaceholder extends StatelessWidget {
  const _PortraitLoadingPlaceholder({
    required this.height,
    required this.label,
  });

  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: AetherPalette.panel.withValues(alpha: 0.94),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Color(0xFFBFA76F)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AetherPalette.textMuted,
            ),
            textAlign: TextAlign.center,
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
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final double height = responsive.isMobile ? 200 : 220;
    return Container(
      height: height,
      width: double.infinity,
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
