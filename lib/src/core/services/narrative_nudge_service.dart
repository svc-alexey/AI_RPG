import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';

/// Short hidden lines for the model: soft anchors, not story bibles.
class NarrativeNudgeService {
  const NarrativeNudgeService();

  String buildHiddenBlock({
    required final CampaignSetting setting,
    required final LiteraryGenre? genre,
    required final AppLanguage language,
    required final bool confirmed18Plus,
    required final DifficultyLevel difficulty,
  }) {
    final List<String> parts = <String>[
      _settingNudge(setting, language),
      if (genre != null) _genreNudge(genre, language),
      switch (language) {
        AppLanguage.ru =>
          'Ориентиры мягкие: можно смешивать жанры, тон и поджанры свободно.',
        AppLanguage.en =>
          'Soft anchors only: feel free to blend genres, tones, and subgenres.',
      },
      if (confirmed18Plus)
        switch (language) {
          AppLanguage.ru =>
            '18+: не ограничивайся боёвкой — уместны романтика и спокойные сцены.',
          AppLanguage.en =>
            '18+: not only combat — romance and calm scenes are fine.',
        },
      _difficultyNudge(difficulty, language),
    ];
    return parts.join('\n');
  }

  String _settingNudge(
    final CampaignSetting setting,
    final AppLanguage language,
  ) =>
      switch ((setting, language)) {
        (CampaignSetting.romantasy, AppLanguage.ru) =>
          'Мир: романтическое фэнтези — магия, дворы, империи, академии; сильная любовная линия уместна.',
        (CampaignSetting.romantasy, AppLanguage.en) =>
          'World: romantasy — magic, courts, empires, academies; a strong romance thread fits.',
        (CampaignSetting.cozyFantasy, AppLanguage.ru) =>
          'Мир: уютное фэнтези — малый город, таверны, бытовая магия, тепло и отношения важнее эпика.',
        (CampaignSetting.cozyFantasy, AppLanguage.en) =>
          'World: cozy fantasy — small town, taverns, everyday magic; warmth over epic war.',
        (CampaignSetting.darkAcademia, AppLanguage.ru) =>
          'Мир: тёмная академия — университеты, тайные общества, интеллектуальная мистика, серая мораль.',
        (CampaignSetting.darkAcademia, AppLanguage.en) =>
          'World: dark academia — schools, secret societies, cerebral mystery, moral gray zones.',
        (CampaignSetting.postApocalypse, AppLanguage.ru) =>
          'Мир: постапокалипсис / система — коллапс, выживание, уровни и прокачка возможны.',
        (CampaignSetting.postApocalypse, AppLanguage.en) =>
          'World: post-apocalypse / system — collapse, survival, levels and progression may appear.',
        (CampaignSetting.litRpgProgression, AppLanguage.ru) =>
          'Мир: LitRPG / progression — рост силы, классы, навыки, испытания, данжи.',
        (CampaignSetting.litRpgProgression, AppLanguage.en) =>
          'World: LitRPG / progression — power growth, classes, skills, trials, dungeons.',
        (CampaignSetting.grimdarkFantasy, AppLanguage.ru) =>
          'Мир: гримдарк — жестокие империи, войны, моральная серость, угрозы.',
        (CampaignSetting.grimdarkFantasy, AppLanguage.en) =>
          'World: grimdark — brutal empires, war, moral decay, pervasive threat.',
        (CampaignSetting.nearFutureSciFi, AppLanguage.ru) =>
          'Мир: НФ близкого будущего — корпорации, ИИ, контроль, космос, кризисы.',
        (CampaignSetting.nearFutureSciFi, AppLanguage.en) =>
          'World: near-future SF — corporations, AI, control, space, crises.',
        (CampaignSetting.horrorWeird, AppLanguage.ru) =>
          'Мир: хоррор — изоляция, телесность, странность, заброшенные места, культы.',
        (CampaignSetting.horrorWeird, AppLanguage.en) =>
          'World: horror — isolation, body horror, weirdness, abandoned sites, cults.',
        (CampaignSetting.cozyCrime, AppLanguage.ru) =>
          'Мир: cozy crime / малый город — камерное сообщество, тайны, характеры.',
        (CampaignSetting.cozyCrime, AppLanguage.en) =>
          'World: cozy crime / small town — tight-knit community, secrets, character.',
        (CampaignSetting.altHistorySecret, AppLanguage.ru) =>
          'Мир: альтернативная история — реальная эпоха плюс скрытая магия или технология.',
        (CampaignSetting.altHistorySecret, AppLanguage.en) =>
          'World: alt history — real era plus hidden magic or tech.',
      };

  String _genreNudge(final LiteraryGenre genre, final AppLanguage language) =>
      switch ((genre, language)) {
        (LiteraryGenre.romance, AppLanguage.ru) =>
          'Жанровый акцент: романтика и эмоциональная дуга.',
        (LiteraryGenre.romance, AppLanguage.en) =>
          'Genre lean: romance and emotional arc.',
        (LiteraryGenre.romantasyGenre, AppLanguage.ru) =>
          'Жанровый акцент: romantasy — фэнтези и любовная линия.',
        (LiteraryGenre.romantasyGenre, AppLanguage.en) =>
          'Genre lean: romantasy — fantasy plus romance.',
        (LiteraryGenre.fantasyGenre, AppLanguage.ru) =>
          'Жанровый акцент: фэнтези широко.',
        (LiteraryGenre.fantasyGenre, AppLanguage.en) =>
          'Genre lean: fantasy broadly.',
        (LiteraryGenre.psychologicalThriller, AppLanguage.ru) =>
          'Жанровый акцент: психологический триллер.',
        (LiteraryGenre.psychologicalThriller, AppLanguage.en) =>
          'Genre lean: psychological thriller.',
        (LiteraryGenre.mysteryCrime, AppLanguage.ru) =>
          'Жанровый акцент: детектив / mystery / crime.',
        (LiteraryGenre.mysteryCrime, AppLanguage.en) =>
          'Genre lean: mystery / crime.',
        (LiteraryGenre.horrorGenre, AppLanguage.ru) =>
          'Жанровый акцент: хоррор (в т.ч. уютный или литературный).',
        (LiteraryGenre.horrorGenre, AppLanguage.en) =>
          'Genre lean: horror (cozy or literary blends ok).',
        (LiteraryGenre.youngAdult, AppLanguage.ru) =>
          'Жанровый акцент: YA — возрастная чувствительность и темп.',
        (LiteraryGenre.youngAdult, AppLanguage.en) =>
          'Genre lean: YA pacing and sensitivity.',
        (LiteraryGenre.speculativeFiction, AppLanguage.ru) =>
          'Жанровый акцент: speculative — смесь фантастики, магии и хоррора уместна.',
        (LiteraryGenre.speculativeFiction, AppLanguage.en) =>
          'Genre lean: speculative blends welcome.',
        (LiteraryGenre.darkAcademiaGenre, AppLanguage.ru) =>
          'Жанровый акцент: dark academia как настроение.',
        (LiteraryGenre.darkAcademiaGenre, AppLanguage.en) =>
          'Genre lean: dark academia mood.',
        (LiteraryGenre.cozyFeelGood, AppLanguage.ru) =>
          'Жанровый акцент: уют, feel-good, эмоциональный комфорт.',
        (LiteraryGenre.cozyFeelGood, AppLanguage.en) =>
          'Genre lean: cozy, feel-good, emotional comfort.',
      };

  String _difficultyNudge(
    final DifficultyLevel difficulty,
    final AppLanguage language,
  ) =>
      switch ((difficulty, language)) {
        (DifficultyLevel.easy, AppLanguage.ru) =>
          'Сложность лёгкая: будь снисходителен к герою; не ломай задумку игрока без нужды.',
        (DifficultyLevel.easy, AppLanguage.en) =>
          'Easy mode: be lenient; do not block the player’s intent without cause.',
        (DifficultyLevel.medium, AppLanguage.ru) =>
          'Сложность средняя: сбалансированные риски и награды.',
        (DifficultyLevel.medium, AppLanguage.en) =>
          'Medium: balanced risk and reward.',
        (DifficultyLevel.hardcore, AppLanguage.ru) =>
          'Сложность высокая: ошибки могут быть смертельны; ставки высокие.',
        (DifficultyLevel.hardcore, AppLanguage.en) =>
          'Hardcore: mistakes can be lethal; high stakes.',
      };
}
