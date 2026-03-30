import 'package:ai_prg/src/core/models/campaign_models.dart';

class CampaignModuleResolver {
  const CampaignModuleResolver();

  List<CampaignModuleState> resolveInitialModules({
    required final CampaignDraft draft,
  }) {
    final DateTime now = DateTime.now();
    final Map<CampaignModule, CampaignModuleState> resolved =
        <CampaignModule, CampaignModuleState>{};

    void activate(final CampaignModule module, final String reason) {
      resolved.putIfAbsent(
        module,
        () => CampaignModuleState(
          module: module,
          isActive: true,
          activationReason: reason,
          activatedAt: now,
        ),
      );
    }

    for (final CampaignModule module in _presetModules(draft.setting)) {
      activate(module, 'preset:${draft.setting.name}');
    }

    final String signalText = <String>[
      draft.storyWish,
      draft.customStoryPrompt,
      draft.characterProfile?.promptFragment ?? '',
      draft.characterProfile?.personality ?? '',
    ].join(' ').toLowerCase();

    for (final MapEntry<CampaignModule, List<String>> entry
        in _moduleKeywords.entries) {
      if (entry.value.any(signalText.contains)) {
        activate(entry.key, 'prompt:${entry.key.name}');
      }
    }

    final List<CampaignModule> ordered = CampaignModule.values
        .where(resolved.containsKey)
        .toList();
    return ordered.map((final item) => resolved[item]!).toList();
  }

  List<CampaignModule> _presetModules(final CampaignSetting setting) =>
      switch (setting) {
        CampaignSetting.fantasy => const <CampaignModule>[
          CampaignModule.inventory,
          CampaignModule.notes,
          CampaignModule.vitality,
          CampaignModule.checks,
        ],
        CampaignSetting.detective => const <CampaignModule>[
          CampaignModule.notes,
        ],
        CampaignSetting.sciFi => const <CampaignModule>[
          CampaignModule.inventory,
          CampaignModule.notes,
          CampaignModule.vitality,
          CampaignModule.resources,
          CampaignModule.checks,
        ],
      };

  static const Map<CampaignModule, List<String>> _moduleKeywords =
      <CampaignModule, List<String>>{
        CampaignModule.inventory: <String>[
          'inventory',
          'gear',
          'artifact',
          'artifacts',
          'weapon',
          'weapons',
          'loot',
          'item',
          'items',
          'bag',
          'рюкзак',
          'инвентарь',
          'артефакт',
          'оруж',
          'добыч',
          'предмет',
        ],
        CampaignModule.companions: <String>[
          'companion',
          'companions',
          'ally',
          'allies',
          'partner',
          'partners',
          'crew',
          'teammate',
          'sidekick',
          'спутник',
          'спутники',
          'союзник',
          'напарник',
          'команда',
          'экипаж',
        ],
        CampaignModule.notes: <String>[
          'mystery',
          'clue',
          'clues',
          'evidence',
          'investigation',
          'case',
          'secret',
          'journal',
          'detective',
          'улика',
          'улики',
          'расслед',
          'тайн',
          'дело',
          'дневник',
          'замет',
        ],
        CampaignModule.vitality: <String>[
          'combat',
          'battle',
          'fight',
          'survival',
          'wound',
          'injury',
          'hp',
          'health',
          'stamina',
          'бо',
          'битв',
          'сраж',
          'выжив',
          'ранен',
          'здоров',
          'энерги',
        ],
        CampaignModule.resources: <String>[
          'credits',
          'credit',
          'money',
          'gold',
          'fuel',
          'resource',
          'resources',
          'supplies',
          'currency',
          'кредит',
          'деньг',
          'золот',
          'топлив',
          'ресурс',
          'припас',
        ],
        CampaignModule.progression: <String>[
          'level',
          'levels',
          'experience',
          'xp',
          'rank',
          'upgrade',
          'skill tree',
          'training',
          'уров',
          'опыт',
          'ранг',
          'прокач',
          'улучш',
          'трениров',
        ],
        CampaignModule.checks: <String>[
          'dice',
          'roll',
          'check',
          'checks',
          'skill check',
          'test',
          'd20',
          'куб',
          'брос',
          'провер',
          'тест',
        ],
      };
}
