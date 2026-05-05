import 'package:ai_prg/src/core/models/campaign_models.dart';

class CampaignModuleResolver {
  const CampaignModuleResolver();

  /// Модули, всегда активные (базовый набор).
  static const Set<CampaignModule> _alwaysActive = {
    CampaignModule.notes,
  };

  /// Матрица активации: модуль → (сеттинги, жанры).
  /// Модуль активируется если сеттинг ИЛИ жанр совпадает.
  static const Map<CampaignModule, ({
    List<CampaignSetting> settings,
    List<LiteraryGenre> genres,
  })> _moduleActivation = {
    CampaignModule.inventory: (
      settings: [
        CampaignSetting.romantasy,
        CampaignSetting.grimdarkFantasy,
        CampaignSetting.litRpgProgression,
        CampaignSetting.postApocalypse,
        CampaignSetting.nearFutureSciFi,
      ],
      genres: [
        LiteraryGenre.fantasyGenre,
        LiteraryGenre.speculativeFiction,
      ],
    ),
    CampaignModule.companions: (
      settings: [
        CampaignSetting.romantasy,
        CampaignSetting.cozyFantasy,
      ],
      genres: [
        LiteraryGenre.romance,
        LiteraryGenre.romantasyGenre,
        LiteraryGenre.youngAdult,
      ],
    ),
    CampaignModule.vitality: (
      settings: [
        CampaignSetting.grimdarkFantasy,
        CampaignSetting.horrorWeird,
        CampaignSetting.postApocalypse,
      ],
      genres: [
        LiteraryGenre.horrorGenre,
      ],
    ),
    CampaignModule.resources: (
      settings: [
        CampaignSetting.postApocalypse,
        CampaignSetting.nearFutureSciFi,
        CampaignSetting.litRpgProgression,
      ],
      genres: [
        LiteraryGenre.speculativeFiction,
      ],
    ),
    CampaignModule.progression: (
      settings: [
        CampaignSetting.litRpgProgression,
        CampaignSetting.grimdarkFantasy,
      ],
      genres: [],
    ),
    CampaignModule.checks: (
      settings: [
        CampaignSetting.grimdarkFantasy,
        CampaignSetting.litRpgProgression,
        CampaignSetting.horrorWeird,
      ],
      genres: [],
    ),
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

  List<CampaignModuleState> resolveInitialModules({
    required final CampaignDraft draft,
  }) {
    final DateTime now = DateTime.now();
    final Map<CampaignModule, CampaignModuleState> resolved = {};

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

    // 1. Always-active modules
    for (final module in _alwaysActive) {
      activate(module, 'preset:core');
    }

    // 2. Matrix activation (setting OR genre match)
    for (final entry in _moduleActivation.entries) {
      final bool settingMatch = entry.value.settings.contains(draft.setting);
      final bool genreMatch = draft.literaryGenre != null
          && entry.value.genres.contains(draft.literaryGenre);
      if (settingMatch || genreMatch) {
        final String trigger = settingMatch && genreMatch
            ? 'matrix:${draft.setting.name}+${draft.literaryGenre!.name}'
            : settingMatch
                ? 'matrix:setting:${draft.setting.name}'
                : 'matrix:genre:${draft.literaryGenre!.name}';
        activate(entry.key, trigger);
      }
    }

    // 3. Keyword matching from user prompt (additional signal)
    final String signalText = <String>[
      draft.storyWish,
      draft.customStoryPrompt,
      draft.characterProfile?.promptFragment ?? '',
      draft.characterProfile?.personality ?? '',
      draft.literaryGenre?.name ?? '',
    ].join(' ').toLowerCase();

    for (final entry in _moduleKeywords.entries) {
      if (entry.value.any(signalText.contains)) {
        activate(entry.key, 'prompt:${entry.key.name}');
      }
    }

    final ordered = CampaignModule.values.where(resolved.containsKey).toList();
    return ordered.map((item) => resolved[item]!).toList();
  }
}
