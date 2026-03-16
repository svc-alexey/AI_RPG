import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_scope.dart';
import 'package:ai_prg/src/core/data/character_templates.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/ai_client.dart';
import 'package:ai_prg/src/core/services/character_prompt_builder.dart';
import 'package:ai_prg/src/features/chat/presentation/chat_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NewGameScreen extends StatefulWidget {
  const NewGameScreen({super.key});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  final TextEditingController _heroController = TextEditingController();
  final TextEditingController _storyWishController = TextEditingController();
  final TextEditingController _customStoryController = TextEditingController();
  final TextEditingController _characterPromptController = TextEditingController();
  final TextEditingController _personalityController = TextEditingController();
  CampaignSetting _setting = CampaignSetting.fantasy;
  StoryMode _mode = StoryMode.shortStory;
  DifficultyLevel _difficulty = DifficultyLevel.easy;
  bool _isSaving = false;
  bool _isGenerating = false;
  bool _aiConfigured = false;
  CharacterProfile? _characterProfile;
  bool _characterExpanded = false;

  static const CharacterPromptBuilder _charBuilder = CharacterPromptBuilder();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAiConfigured();
  }

  Future<void> _checkAiConfigured() async {
    final AiSettings settings = await AppScope.of(context).settingsRepository.loadAiSettings();
    if (mounted && settings.isConfigured != _aiConfigured) {
      setState(() => _aiConfigured = settings.isConfigured);
    }
  }

  @override
  void dispose() {
    _heroController.dispose();
    _storyWishController.dispose();
    _customStoryController.dispose();
    _characterPromptController.dispose();
    _personalityController.dispose();
    super.dispose();
  }

  CharacterProfile _defaultCharacterProfile() {
    final AppLanguage lang = AppScope.of(context).appLanguageListenable.value;
    final List<CharacterClass> classes = classesBySetting[_setting] ?? <CharacterClass>[CharacterClass.warrior];
    final List<String> races = racesBySetting[_setting] ?? <String>['human'];
    return CharacterProfile(
      name: _heroController.text.trim().isEmpty
          ? (lang == AppLanguage.ru ? 'Странник' : 'Wayfarer')
          : _heroController.text.trim(),
      gender: CharacterGender.other,
      race: races.first,
      characterClass: classes.first,
      skills: <String>[],
      personality: '',
      perks: <String>[],
      promptFragment: '',
    );
  }

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;

    if (defaultTargetPlatform == TargetPlatform.windows) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.newCampaign)),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            Text(l10n.newCampaign, style: theme.textTheme.headlineLarge),
            const SizedBox(height: 24),
            DropdownButtonFormField<CampaignSetting>(
              initialValue: _setting,
              decoration: InputDecoration(labelText: l10n.settingTitle),
              items: CampaignSetting.values
                  .map(
                    (item) => DropdownMenuItem<CampaignSetting>(
                      value: item,
                      child: Text(l10n.settingLabel(item)),
                    ),
                  )
                  .toList(),
              onChanged: (item) {
                if (item != null) {
                  setState(() => _setting = item);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<StoryMode>(
              initialValue: _mode,
              decoration: InputDecoration(labelText: l10n.storyModeTitle),
              items: StoryMode.values
                  .map(
                    (item) => DropdownMenuItem<StoryMode>(
                      value: item,
                      child: Text(l10n.storyModeLabel(item)),
                    ),
                  )
                  .toList(),
              onChanged: (item) {
                if (item != null) {
                  setState(() => _mode = item);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DifficultyLevel>(
              initialValue: _difficulty,
              decoration: InputDecoration(labelText: l10n.difficultyTitle),
              items: DifficultyLevel.values
                  .map(
                    (item) => DropdownMenuItem<DifficultyLevel>(
                      value: item,
                      child: Text(l10n.difficultyLabel(item)),
                    ),
                  )
                  .toList(),
              onChanged: (item) {
                if (item != null) {
                  setState(() => _difficulty = item);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _heroController,
              decoration: InputDecoration(
                labelText: l10n.heroName,
                hintText: l10n.heroNameHint,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving ? null : _createCampaign,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.createCampaignButton),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newCampaign)),
      body: AetherBackdrop(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AetherPageReveal(
                child: ListView(
                  children: <Widget>[
                    Text(
                      l10n.newCampaign,
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel(title: l10n.storyWishTitle),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _storyWishController,
                      maxLines: 3,
                      decoration: InputDecoration(hintText: l10n.storyWishHint),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        OutlinedButton(
                          onPressed: () {
                            final String text = _storyWishController.text.trim();
                            if (text.isNotEmpty) {
                              setState(() => _customStoryController.text = text);
                            }
                          },
                          child: Text(l10n.insertTextPrompt),
                        ),
                        FilledButton(
                          onPressed: _aiConfigured && !_isGenerating && _storyWishController.text.trim().isNotEmpty
                              ? _generatePrompts
                              : null,
                          child: _isGenerating
                              ? Text(l10n.generatingPrompts)
                              : Text(l10n.generatePrompts),
                        ),
                        if (!_aiConfigured)
                          Tooltip(
                            message: l10n.configureAiFirst,
                            child: Icon(Icons.info_outline, color: AetherPalette.textMuted, size: 20),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _SectionLabel(title: l10n.customStoryPromptTitle),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _customStoryController,
                      maxLines: 4,
                      decoration: const InputDecoration(hintText: ''),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 28),
                    ExpansionTile(
                      title: Text(l10n.characterSectionTitle),
                      initiallyExpanded: _characterExpanded,
                      onExpansionChanged: (v) => setState(() => _characterExpanded = v),
                      children: <Widget>[
                        _buildCharacterSection(context, l10n, theme),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _SectionLabel(title: l10n.settingTitle),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: CampaignSetting.values
                          .map(
                            (item) => _SelectionCard(
                              width: 320,
                              title: l10n.settingLabel(item),
                              subtitle: switch (item) {
                                CampaignSetting.fantasy =>
                                  'Swords, ruins and ritual light',
                                CampaignSetting.detective =>
                                  'Clues, motives and city shadows',
                                CampaignSetting.sciFi =>
                                  'Stations, signals and cosmic anomalies',
                              },
                              selected: _setting == item,
                              icon: switch (item) {
                                CampaignSetting.fantasy =>
                                  Icons.auto_awesome_rounded,
                                CampaignSetting.detective =>
                                  Icons.search_rounded,
                                CampaignSetting.sciFi =>
                                  Icons.rocket_launch_outlined,
                              },
                              onTap: () => setState(() => _setting = item),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 28),
                    _SectionLabel(title: l10n.storyModeTitle),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: StoryMode.values
                          .map(
                            (item) => _SelectionCard(
                              width: 490,
                              title: l10n.storyModeLabel(item),
                              subtitle: item == StoryMode.shortStory
                                  ? 'A focused 30-60 minute arc'
                                  : 'A longer journey with memory and build-up',
                              selected: _mode == item,
                              icon: item == StoryMode.shortStory
                                  ? Icons.menu_book_outlined
                                  : Icons.timelapse_rounded,
                              onTap: () => setState(() => _mode = item),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 28),
                    _SectionLabel(title: l10n.difficultyTitle),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: DifficultyLevel.values
                          .map(
                            (item) => _SelectionCard(
                              width: 320,
                              title: l10n.difficultyLabel(item),
                              subtitle: item == DifficultyLevel.easy
                                  ? 'Forgiving flow'
                                  : item == DifficultyLevel.medium
                                  ? 'Balanced tension'
                                  : 'Consequences bite hard',
                              selected: _difficulty == item,
                              accentColor: item == DifficultyLevel.medium
                                  ? AetherPalette.gold
                                  : null,
                              onTap: () => setState(() => _difficulty = item),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 28),
                    _SectionLabel(title: l10n.heroName),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: TextField(
                        controller: _heroController,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.heroNameHint,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    FilledButton(
                      onPressed: _isSaving ? null : _createCampaign,
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.createCampaignButton),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generatePrompts() async {
    setState(() => _isGenerating = true);
    final AppScope scope = AppScope.of(context);
    final AiSettings settings = await scope.settingsRepository.loadAiSettings();
    final AiClient client = scope.aiServiceFactory.create(settings);
    try {
      final GeneratedPrompts result = await client.generatePromptsFromStoryWish(
        settings: settings,
        language: scope.appLanguageListenable.value,
        storyWish: _storyWishController.text.trim(),
        setting: _setting,
      );
      if (mounted) {
        setState(() {
          _customStoryController.text = result.storyPrompt;
          if (result.characterPrompt.isNotEmpty && _characterProfile == null) {
            _characterPromptController.text = result.characterPrompt;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {});
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Widget _buildCharacterSection(
    final BuildContext context,
    final AppLocalizations l10n,
    final ThemeData theme,
  ) {
    final CharacterProfile profile = _characterProfile ?? _defaultCharacterProfile();
    final List<CharacterClass> classes = classesBySetting[_setting] ?? <CharacterClass>[CharacterClass.warrior];
    final List<String> races = racesBySetting[_setting] ?? <String>['human'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              DropdownButtonFormField<CharacterClass>(
                value: profile.characterClass,
                decoration: InputDecoration(labelText: l10n.characterClassTitle),
                items: classes
                    .map(
                      (c) => DropdownMenuItem<CharacterClass>(
                        value: c,
                        child: Text(l10n.characterClassLabel(c)),
                      ),
                    )
                    .toList(),
                onChanged: (c) {
                  if (c != null) {
                    setState(() {
                      _characterProfile = (profile.copyWith(characterClass: c));
                    });
                  }
                },
              ),
              DropdownButtonFormField<String>(
                value: profile.race.isEmpty ? races.first : profile.race,
                decoration: InputDecoration(labelText: l10n.characterRaceTitle),
                items: races
                    .map(
                      (r) => DropdownMenuItem<String>(
                        value: r,
                        child: Text(l10n.raceLabel(r, _setting)),
                      ),
                    )
                    .toList(),
                onChanged: (r) {
                  if (r != null) {
                    setState(() {
                      _characterProfile = (profile.copyWith(race: r));
                    });
                  }
                },
              ),
              DropdownButtonFormField<CharacterGender>(
                value: profile.gender,
                decoration: InputDecoration(labelText: l10n.characterGenderTitle),
                items: CharacterGender.values
                    .map(
                      (g) => DropdownMenuItem<CharacterGender>(
                        value: g,
                        child: Text(l10n.characterGenderLabel(g)),
                      ),
                    )
                    .toList(),
                onChanged: (g) {
                  if (g != null) {
                    setState(() {
                      _characterProfile = (profile.copyWith(gender: g));
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _personalityController,
            maxLines: 1,
            decoration: InputDecoration(labelText: l10n.characterPersonalityTitle),
            onChanged: (v) => setState(() {
              _characterProfile = (profile.copyWith(personality: v));
            }),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              final CharacterProfile random = _charBuilder.randomProfile(
                setting: _setting,
                language: AppScope.of(context).appLanguageListenable.value,
                baseName: _heroController.text.trim(),
              );
              setState(() {
                _characterProfile = random;
                _personalityController.text = random.personality;
                _characterPromptController.text = random.promptFragment;
              });
            },
            child: Text(l10n.randomCharacter),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _characterPromptController,
            maxLines: 3,
            decoration: InputDecoration(labelText: l10n.editCharacterPrompt),
            onChanged: (v) => setState(() {
              _characterProfile = (profile.copyWith(promptFragment: v));
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _createCampaign() async {
    setState(() => _isSaving = true);

    final AppScope scope = AppScope.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final AppLanguage lang = scope.appLanguageListenable.value;

    CharacterProfile? charProfile = _characterProfile;
    if (charProfile == null && _characterExpanded) {
      charProfile = _defaultCharacterProfile();
    }
    if (charProfile != null && _characterPromptController.text.trim().isNotEmpty) {
      charProfile = charProfile.copyWith(promptFragment: _characterPromptController.text.trim());
    }
    if (charProfile != null && _personalityController.text.trim().isNotEmpty) {
      charProfile = charProfile.copyWith(personality: _personalityController.text.trim());
    }
    if (charProfile != null) {
      charProfile = charProfile.copyWith(
        name: _heroController.text.trim().isEmpty
            ? (lang == AppLanguage.ru ? 'Странник' : 'Wayfarer')
            : _heroController.text.trim(),
      );
    }

    final CampaignState campaign = scope.gameEngine.createCampaign(
      draft: CampaignDraft(
        setting: _setting,
        mode: _mode,
        difficulty: _difficulty,
        heroName: _heroController.text,
        storyWish: _storyWishController.text.trim(),
        customStoryPrompt: _customStoryController.text.trim(),
        characterProfile: charProfile,
      ),
      language: lang,
    );

    await scope.campaignRepository.saveCampaign(campaign);
    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    await navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => ChatScreen(campaignId: campaign.id),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(final BuildContext context) => Text(
    title.toUpperCase(),
    style: Theme.of(context).textTheme.labelLarge?.copyWith(
      color: AetherPalette.textMuted,
      letterSpacing: 3,
    ),
  );
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.width,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.icon,
    this.accentColor,
  });

  final double width;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? accentColor;

  @override
  Widget build(final BuildContext context) {
    final Color color = accentColor ??
        (selected ? AetherPalette.accent : AetherPalette.textMuted);

    return SizedBox(
      width: width,
      child: AetherCard(
        highlight: selected,
        borderColor: selected ? color : null,
        child: SizedBox(
          width: double.infinity,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    Icon(icon, color: color),
                    const SizedBox(height: 18),
                  ],
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: selected ? AetherPalette.textPrimary : color,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
