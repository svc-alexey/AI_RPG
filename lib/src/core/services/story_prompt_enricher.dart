import 'dart:math';

import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';

class StoryPromptEnricher {
  const StoryPromptEnricher();

  static final Random _random = Random();

  GeneratedPrompts expand({
    required final String storyWish,
    required final CampaignSetting setting,
    required final AppLanguage language,
  }) {
    final String seed = storyWish.trim();
    if (seed.isEmpty) {
      return const GeneratedPrompts(storyPrompt: '', characterPrompt: '');
    }

    return switch ((language, setting)) {
      (AppLanguage.ru, CampaignSetting.fantasy) => _fantasyRu(seed),
      (AppLanguage.ru, CampaignSetting.detective) => _detectiveRu(seed),
      (AppLanguage.ru, CampaignSetting.sciFi) => _sciFiRu(seed),
      (AppLanguage.en, CampaignSetting.fantasy) => _fantasyEn(seed),
      (AppLanguage.en, CampaignSetting.detective) => _detectiveEn(seed),
      (AppLanguage.en, CampaignSetting.sciFi) => _sciFiEn(seed),
    };
  }

  GeneratedPrompts _fantasyRu(final String seed) {
    final String place = _pick(<String>[
      'в сыром городе под тенью старых башен',
      'на границе леса, где шепчутся древние духи',
      'среди руин храма, который не должен был проснуться',
    ]);
    final String hook = _pick(<String>[
      'первый след приводит к тайне, за которую уже заплатили кровью',
      'слухи оказываются лишь маской для куда более древнего ужаса',
      'любое найденное чудо требует опасной цены',
    ]);
    return GeneratedPrompts(
      storyPrompt:
          'Веди историю как мрачное, кинематографичное фэнтези с живыми деталями и постоянным чувством опасности. В основе сюжета: $seed. Начни $place: запах мокрого камня, тусклый свет, напряжённые взгляды, шорохи за спиной. Каждая сцена должна давать новую зацепку, усиливать атмосферу и подталкивать героя к трудному выбору. Пусть магия манит и пугает одновременно, союзники скрывают часть правды, а $hook. Держи тон серьёзным, насыщенным, образным, но без перегруза.',
      characterPrompt:
          'Измотанный, но упрямый герой, умеющий замечать скрытые знаки, держать слово и идти вперёд даже тогда, когда страх уже стал частью дороги.',
    );
  }

  GeneratedPrompts _detectiveRu(final String seed) {
    final String place = _pick(<String>[
      'в дождливый вечер под дрожащими вывесками и жёлтым светом фонарей',
      'с места, где воздух пахнет мокрым асфальтом, табаком и дешёвым кофе',
      'с тревожной сцены, где слишком много молчания и слишком мало правды',
    ]);
    final String hook = _pick(<String>[
      'каждая улика ведёт не к ответу, а к ещё более опасному человеку',
      'за простым делом скрывается чужая игра с высокими ставками',
      'правда оказывается личной и бьёт ближе, чем герой ожидал',
    ]);
    return GeneratedPrompts(
      storyPrompt:
          'Веди историю как мрачный, напряжённый детективный нуар с насыщенной атмосферой и конкретными бытовыми деталями. Основа истории: $seed. Начни $place. Показывай скрип дверей, отражения в лужах, нервные жесты свидетелей, полупустые кабинеты, усталость города и ощущение, что за героем наблюдают. Каждая сцена должна двигать расследование вперёд, открывать новый слой лжи и повышать цену ошибки. Диалоги делай колкими и живыми, второстепенных персонажей неоднозначными, а $hook.',
      characterPrompt:
          'Наблюдательный, уставший, но цепкий сыщик с хорошим чутьём на ложь, привычкой замечать детали и внутренней готовностью лезть туда, куда другие не суются.',
    );
  }

  GeneratedPrompts _sciFiRu(final String seed) {
    final String place = _pick(<String>[
      'с холодной технологичной сцены, где каждая ошибка дорого стоит',
      'в пространстве, полном тихого гула машин, предупреждений и скрытых угроз',
      'с момента, когда привычная логика мира начинает давать трещину',
    ]);
    final String hook = _pick(<String>[
      'каждое открытие расширяет масштаб угрозы и ставит под вопрос прежние убеждения',
      'технология помогает выжить, но одновременно делает ситуацию опаснее',
      'самая страшная тайна оказывается связана не с космосом, а с людьми',
    ]);
    return GeneratedPrompts(
      storyPrompt:
          'Веди историю как плотную научно-фантастическую драму с ощущением масштаба, тревоги и материальности мира. В центре истории: $seed. Начни $place. Добавляй живые детали: холод металла под ладонью, мерцание интерфейсов, сухие отчёты систем, сбои связи, странные сигналы, чужую геометрию пространства. Сюжет должен чередовать исследование, риск, моральный выбор и нарастающее чувство, что мир устроен сложнее, чем казалось. Пусть $hook, а каждая новая сцена даёт либо открытие, либо осложнение.',
      characterPrompt:
          'Собранный и любопытный специалист, который умеет думать под давлением, замечает аномалии раньше других и не теряет человеческость рядом с технологиями и страхом.',
    );
  }

  GeneratedPrompts _fantasyEn(final String seed) {
    return GeneratedPrompts(
      storyPrompt:
          'Run the story as dark, cinematic fantasy rooted in "$seed". Open with tactile detail, uneasy silence, and a sense that old powers are waking up nearby. Give each scene a strong image, a hard choice, and a revelation that deepens the world. Let magic feel tempting and dangerous, let allies hide inconvenient truths, and keep the tone vivid, serious, and atmospheric.',
      characterPrompt:
          'A stubborn, perceptive wanderer who notices hidden signs, keeps going under pressure, and treats every promise as something costly.',
    );
  }

  GeneratedPrompts _detectiveEn(final String seed) {
    return GeneratedPrompts(
      storyPrompt:
          'Run the story as a grim noir investigation built around "$seed". Start with rain, bad lighting, tired witnesses, and a city that feels like it is withholding the truth. Make every scene advance the case, add a fresh contradiction, or raise the personal cost of the search. Keep the dialogue sharp, the suspects layered, and the atmosphere concrete and alive.',
      characterPrompt:
          'A sharp, worn-down investigator with a talent for spotting lies, reading rooms, and pushing one question too far.',
    );
  }

  GeneratedPrompts _sciFiEn(final String seed) {
    return GeneratedPrompts(
      storyPrompt:
          'Run the story as tense, sensory science fiction centered on "$seed". Open with concrete technological detail, subtle system failures, and a feeling that reality is starting to misbehave. Alternate discovery, danger, and moral pressure. Let every new scene either reveal a deeper layer of the mystery or complicate survival, while keeping the world tactile and believable.',
      characterPrompt:
          'A composed, curious specialist who stays useful under pressure, notices anomalies early, and still reacts like a human being when the unknown pushes back.',
    );
  }

  String _pick(final List<String> values) =>
      values[_random.nextInt(values.length)];
}
