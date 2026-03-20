import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_scope.dart';
import 'package:ai_prg/src/core/data/character_templates.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/services/ai_client.dart' show AiClient, CancelToken;
import 'package:ai_prg/src/core/services/character_prompt_builder.dart';
import 'package:ai_prg/src/core/services/random_story_prompt_generator.dart';
import 'package:ai_prg/src/features/chat/presentation/chat_screen.dart';
import 'package:flutter/material.dart';

enum _WizardMode {
  modeSelection,
  quickStart,
  customSetup,
}

enum _CustomSetupStep {
  foundation,
  story,
  character,
  review,
}

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
  
  _WizardMode _mode = _WizardMode.modeSelection;
  _CustomSetupStep _currentStep = _CustomSetupStep.foundation;
  
  CampaignSetting _setting = CampaignSetting.fantasy;
  StoryMode _storyMode = StoryMode.shortStory;
  DifficultyLevel _difficulty = DifficultyLevel.easy;
  CharacterGender _gender = CharacterGender.other;
  
  bool _isSaving = false;
  bool _isGenerating = false;
  bool _aiConfigured = false;
  CharacterProfile? _characterProfile;
  CancelToken? _cancelToken;

  static const CharacterPromptBuilder _charBuilder = CharacterPromptBuilder();
  static const RandomStoryPromptGenerator _storyPromptGenerator = RandomStoryPromptGenerator();

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

  void _onSettingChanged(final CampaignSetting newSetting) {
    _setting = newSetting;
    final List<CharacterClass> classes =
        classesBySetting[newSetting] ?? <CharacterClass>[CharacterClass.warrior];
    final List<String> races =
        racesBySetting[newSetting] ?? <String>['human'];
    if (_characterProfile != null) {
      CharacterProfile p = _characterProfile!;
      if (!classes.contains(p.characterClass)) {
        p = p.copyWith(characterClass: classes.first);
      }
      if (!races.contains(p.race)) {
        p = p.copyWith(race: races.first);
      }
      _characterProfile = p;
    }
  }

  CharacterProfile _defaultCharacterProfile() {
    final AppLanguage lang = AppScope.of(context).appLanguageListenable.value;
    final List<CharacterClass> classes = classesBySetting[_setting] ?? <CharacterClass>[CharacterClass.warrior];
    final List<String> races = racesBySetting[_setting] ?? <String>['human'];
    return CharacterProfile(
      name: _heroController.text.trim().isEmpty
          ? (lang == AppLanguage.ru ? 'Странник' : 'Wayfarer')
          : _heroController.text.trim(),
      gender: _gender,
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newCampaign)),
      body: AetherBackdrop(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AetherPageReveal(
                child: _buildContent(context, l10n, theme),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    switch (_mode) {
      case _WizardMode.modeSelection:
        return _buildModeSelection(context, l10n, theme);
      case _WizardMode.quickStart:
        return _buildQuickStart(context, l10n, theme);
      case _WizardMode.customSetup:
        return _buildCustomSetup(context, l10n, theme);
    }
  }

  Widget _buildModeSelection(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return ListView(
      children: <Widget>[
        Text(
          l10n.howToStart,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _ModeCard(
          icon: Icons.flash_on_rounded,
          title: l10n.quickStart,
          subtitle: l10n.quickStartDesc,
          onTap: () => setState(() => _mode = _WizardMode.quickStart),
        ),
        const SizedBox(height: 16),
        _ModeCard(
          icon: Icons.tune_rounded,
          title: l10n.customSetup,
          subtitle: l10n.customSetupDesc,
          onTap: () => setState(() {
            _mode = _WizardMode.customSetup;
            _currentStep = _CustomSetupStep.foundation;
          }),
        ),
      ],
    );
  }

  Widget _buildQuickStart(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return ListView(
      children: <Widget>[
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _mode = _WizardMode.modeSelection),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                l10n.quickStart,
                style: theme.textTheme.headlineMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionLabel(title: l10n.settingTitle),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CampaignSetting.values.map((item) => 
            ChoiceChip(
              label: Text(l10n.settingLabel(item)),
              selected: _setting == item,
              onSelected: (_) => setState(() => _onSettingChanged(item)),
              avatar: Icon(
                switch (item) {
                  CampaignSetting.fantasy => Icons.auto_awesome_rounded,
                  CampaignSetting.detective => Icons.search_rounded,
                  CampaignSetting.sciFi => Icons.rocket_launch_outlined,
                },
                size: 18,
              ),
            ),
          ).toList(),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _heroController,
          decoration: InputDecoration(
            labelText: l10n.heroName,
            hintText: l10n.heroNameHint,
          ),
        ),
        const SizedBox(height: 24),
        _SectionLabel(title: l10n.characterGenderTitle),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CharacterGender.values.map((g) => 
            ChoiceChip(
              label: Text(l10n.characterGenderLabel(g)),
              selected: _gender == g,
              onSelected: (_) => setState(() => _gender = g),
            ),
          ).toList(),
        ),
        const SizedBox(height: 32),
        if (MediaQuery.of(context).viewInsets.bottom == 0)
          FilledButton(
            onPressed: _isSaving ? null : _createCampaignQuick,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.startAdventure),
          ),
      ],
    );
  }

  Widget _buildCustomSetup(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            IconButton(
              onPressed: _currentStep == _CustomSetupStep.foundation
                  ? () => setState(() => _mode = _WizardMode.modeSelection)
                  : null,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                l10n.customSetup,
                style: theme.textTheme.headlineMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStepIndicator(),
        const SizedBox(height: 8),
        Text(
          l10n.stepXOfY(_currentStep.index + 1, 4),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AetherPalette.textMuted,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            children: [_buildStepContent(context, l10n, theme)],
          ),
        ),
        const SizedBox(height: 16),
        _buildWizardNavigation(l10n),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final bool isCurrent = i == _currentStep.index;
        final bool isPast = i < _currentStep.index;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isCurrent || isPast
                ? AetherPalette.accent
                : AetherPalette.textMuted.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildStepContent(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    switch (_currentStep) {
      case _CustomSetupStep.foundation:
        return _buildFoundationStep(context, l10n, theme);
      case _CustomSetupStep.story:
        return _buildStoryStep(context, l10n, theme);
      case _CustomSetupStep.character:
        return _buildCharacterStep(context, l10n, theme);
      case _CustomSetupStep.review:
        return _buildReviewStep(context, l10n, theme);
    }
  }

  Widget _buildFoundationStep(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionLabel(title: l10n.settingTitle),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CampaignSetting.values.map((item) => 
            ChoiceChip(
              label: Text(l10n.settingLabel(item)),
              selected: _setting == item,
              onSelected: (_) => setState(() => _onSettingChanged(item)),
              avatar: Icon(
                switch (item) {
                  CampaignSetting.fantasy => Icons.auto_awesome_rounded,
                  CampaignSetting.detective => Icons.search_rounded,
                  CampaignSetting.sciFi => Icons.rocket_launch_outlined,
                },
                size: 18,
              ),
            ),
          ).toList(),
        ),
        const SizedBox(height: 24),
        _SectionLabel(title: l10n.storyModeTitle),
        const SizedBox(height: 12),
        DropdownButtonFormField<StoryMode>(
          initialValue: _storyMode,
          decoration: InputDecoration(
            filled: true,
            fillColor: AetherPalette.panelSoft.withValues(alpha: 0.3),
          ),
          items: StoryMode.values.map((mode) => 
            DropdownMenuItem(
              value: mode,
              child: Text(l10n.storyModeLabel(mode)),
            ),
          ).toList(),
          onChanged: (mode) {
            if (mode != null) setState(() => _storyMode = mode);
          },
        ),
        const SizedBox(height: 24),
        _SectionLabel(title: l10n.difficultyTitle),
        const SizedBox(height: 12),
        DropdownButtonFormField<DifficultyLevel>(
          initialValue: _difficulty,
          decoration: InputDecoration(
            filled: true,
            fillColor: AetherPalette.panelSoft.withValues(alpha: 0.3),
          ),
          items: DifficultyLevel.values.map((diff) => 
            DropdownMenuItem(
              value: diff,
              child: Text(l10n.difficultyLabel(diff)),
            ),
          ).toList(),
          onChanged: (diff) {
            if (diff != null) setState(() => _difficulty = diff);
          },
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _heroController,
          decoration: InputDecoration(
            labelText: l10n.heroName,
            hintText: l10n.heroNameHint,
          ),
        ),
      ],
    );
  }

  Widget _buildStoryStep(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionLabel(title: l10n.storyWishTitle),
        const SizedBox(height: 8),
        Text(
          l10n.storyWishOptional,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AetherPalette.textMuted,
          ),
        ),
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
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.generatePrompts),
            ),
            if (_isGenerating)
              OutlinedButton(
                onPressed: () => _cancelToken?.cancel(),
                child: Text(l10n.cancel),
              ),
          ],
        ),
        if (!_aiConfigured) ...[
          const SizedBox(height: 12),
          Text(
            l10n.configureAiFirst,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AetherPalette.textMuted,
            ),
          ),
        ],
        const SizedBox(height: 24),
        _SectionLabel(title: l10n.customStoryPromptTitle),
        const SizedBox(height: 12),
        TextField(
          controller: _customStoryController,
          maxLines: 4,
          decoration: const InputDecoration(hintText: ''),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildCharacterStep(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    final CharacterProfile profile = _characterProfile ?? _defaultCharacterProfile();
    final List<CharacterClass> classes = classesBySetting[_setting] ?? <CharacterClass>[CharacterClass.warrior];
    final List<String> races = racesBySetting[_setting] ?? <String>['human'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionLabel(title: l10n.characterSectionTitle),
        const SizedBox(height: 8),
        Text(
          l10n.characterOptional,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AetherPalette.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<CharacterClass>(
          initialValue: classes.contains(profile.characterClass) ? profile.characterClass : classes.first,
          decoration: InputDecoration(
            labelText: l10n.characterClassTitle,
            filled: true,
            fillColor: AetherPalette.panelSoft.withValues(alpha: 0.3),
          ),
          items: classes.map((c) => 
            DropdownMenuItem(
              value: c,
              child: Text(l10n.characterClassLabel(c)),
            ),
          ).toList(),
          onChanged: (c) {
            if (c != null) {
              setState(() {
                _characterProfile = profile.copyWith(characterClass: c);
              });
            }
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: profile.race.isEmpty || !races.contains(profile.race) ? races.first : profile.race,
          decoration: InputDecoration(
            labelText: l10n.characterRaceTitle,
            filled: true,
            fillColor: AetherPalette.panelSoft.withValues(alpha: 0.3),
          ),
          items: races.map((r) => 
            DropdownMenuItem(
              value: r,
              child: Text(l10n.raceLabel(r, _setting)),
            ),
          ).toList(),
          onChanged: (r) {
            if (r != null) {
              setState(() {
                _characterProfile = profile.copyWith(race: r);
              });
            }
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<CharacterGender>(
          initialValue: profile.gender,
          decoration: InputDecoration(
            labelText: l10n.characterGenderTitle,
            filled: true,
            fillColor: AetherPalette.panelSoft.withValues(alpha: 0.3),
          ),
          items: CharacterGender.values.map((g) => 
            DropdownMenuItem(
              value: g,
              child: Text(l10n.characterGenderLabel(g)),
            ),
          ).toList(),
          onChanged: (g) {
            if (g != null) {
              setState(() {
                _characterProfile = profile.copyWith(gender: g);
                _gender = g;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _personalityController,
          decoration: InputDecoration(labelText: l10n.characterPersonalityTitle),
          onChanged: (v) => setState(() {
            _characterProfile = profile.copyWith(personality: v);
          }),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
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
              _gender = random.gender;
            });
          },
          icon: const Icon(Icons.shuffle_rounded, size: 18),
          label: Text(l10n.randomCharacter),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _characterPromptController,
          maxLines: 3,
          decoration: InputDecoration(labelText: l10n.editCharacterPrompt),
          onChanged: (v) => setState(() {
            _characterProfile = profile.copyWith(promptFragment: v);
          }),
        ),
      ],
    );
  }

  Widget _buildReviewStep(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    final CharacterProfile? profile = _characterProfile;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionLabel(title: l10n.reviewTitle),
        const SizedBox(height: 16),
        AetherCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _ReviewItem(
                label: l10n.settingTitle,
                value: l10n.settingLabel(_setting),
                icon: Icons.public_rounded,
              ),
              const SizedBox(height: 12),
              _ReviewItem(
                label: l10n.storyModeTitle,
                value: l10n.storyModeLabel(_storyMode),
                icon: Icons.menu_book_outlined,
              ),
              const SizedBox(height: 12),
              _ReviewItem(
                label: l10n.difficultyTitle,
                value: l10n.difficultyLabel(_difficulty),
                icon: Icons.show_chart_rounded,
              ),
              const SizedBox(height: 12),
              _ReviewItem(
                label: l10n.heroName,
                value: _heroController.text.trim().isEmpty 
                    ? l10n.heroNameHint 
                    : _heroController.text.trim(),
                icon: Icons.person_outline_rounded,
              ),
              if (_customStoryController.text.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                _ReviewItem(
                  label: l10n.customStoryPromptTitle,
                  value: _customStoryController.text.trim().length > 100
                      ? '${_customStoryController.text.trim().substring(0, 100)}...'
                      : _customStoryController.text.trim(),
                  icon: Icons.edit_note_rounded,
                ),
              ],
              if (profile != null) ...[
                const SizedBox(height: 12),
                _ReviewItem(
                  label: l10n.characterSectionTitle,
                  value: '${l10n.characterClassLabel(profile.characterClass)} • ${l10n.raceLabel(profile.race, _setting)} • ${l10n.characterGenderLabel(profile.gender)}',
                  icon: Icons.badge_outlined,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.readyToStart,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AetherPalette.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildWizardNavigation(AppLocalizations l10n) {
    final bool isLastStep = _currentStep == _CustomSetupStep.review;
    final bool canGoBack = _currentStep != _CustomSetupStep.foundation;
    
    // Скрываем кнопки при открытой клавиатуре
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight > 0) {
      return const SizedBox.shrink();
    }
    
    return Row(
      children: <Widget>[
        if (canGoBack)
          OutlinedButton.icon(
            onPressed: _previousStep,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: Text(l10n.backButton),
          ),
        const Spacer(),
        FilledButton(
          onPressed: _isSaving ? null : (isLastStep ? _createCampaign : _nextStep),
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isLastStep ? l10n.createCampaignButton : l10n.nextButton),
                    if (!isLastStep) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  void _previousStep() {
    if (_currentStep.index > 0) {
      setState(() {
        _currentStep = _CustomSetupStep.values[_currentStep.index - 1];
      });
    }
  }

  void _nextStep() {
    if (_currentStep.index < _CustomSetupStep.values.length - 1) {
      setState(() {
        _currentStep = _CustomSetupStep.values[_currentStep.index + 1];
      });
    }
  }

  Future<void> _generatePrompts() async {
    final CancelToken cancelToken = CancelToken();
    setState(() {
      _cancelToken = cancelToken;
      _isGenerating = true;
    });
    final AppScope scope = AppScope.of(context);
    final AiSettings settings = await scope.settingsRepository.loadAiSettings();
    final AiClient client = scope.aiServiceFactory.create(settings);
    try {
      final GeneratedPrompts result = await client.generatePromptsFromStoryWish(
        settings: settings,
        language: scope.appLanguageListenable.value,
        storyWish: _storyWishController.text.trim(),
        setting: _setting,
        cancelToken: cancelToken,
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
        setState(() {
          _cancelToken = null;
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _createCampaignQuick() async {
    setState(() => _isSaving = true);

    final AppScope scope = AppScope.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final AppLanguage lang = scope.appLanguageListenable.value;

    final CharacterProfile charProfile = _defaultCharacterProfile();

    final String randomPrompt = _storyPromptGenerator.generateForSetting(
      setting: _setting,
      language: lang,
    );

    final CampaignState campaign = scope.gameEngine.createCampaign(
      draft: CampaignDraft(
        setting: _setting,
        mode: StoryMode.shortStory,
        difficulty: DifficultyLevel.easy,
        heroName: _heroController.text.trim().isEmpty
            ? (lang == AppLanguage.ru ? 'Странник' : 'Wayfarer')
            : _heroController.text.trim(),
        storyWish: '',
        customStoryPrompt: randomPrompt,
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

  Future<void> _createCampaign() async {
    setState(() => _isSaving = true);

    final AppScope scope = AppScope.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final AppLanguage lang = scope.appLanguageListenable.value;

    CharacterProfile? charProfile = _characterProfile;
    if (charProfile == null) {
      charProfile = _defaultCharacterProfile();
    }
    if (_characterPromptController.text.trim().isNotEmpty) {
      charProfile = charProfile.copyWith(promptFragment: _characterPromptController.text.trim());
    }
    if (_personalityController.text.trim().isNotEmpty) {
      charProfile = charProfile.copyWith(personality: _personalityController.text.trim());
    }
    charProfile = charProfile.copyWith(
      name: _heroController.text.trim().isEmpty
          ? (lang == AppLanguage.ru ? 'Странник' : 'Wayfarer')
          : _heroController.text.trim(),
    );

    final String storyPrompt = _customStoryController.text.trim().isEmpty
        ? _storyPromptGenerator.generateForSetting(
            setting: _setting,
            language: lang,
          )
        : _customStoryController.text.trim();

    final CampaignState campaign = scope.gameEngine.createCampaign(
      draft: CampaignDraft(
        setting: _setting,
        mode: _storyMode,
        difficulty: _difficulty,
        heroName: _heroController.text.trim().isEmpty
            ? (lang == AppLanguage.ru ? 'Странник' : 'Wayfarer')
            : _heroController.text.trim(),
        storyWish: _storyWishController.text.trim(),
        customStoryPrompt: storyPrompt,
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
      letterSpacing: 2,
    ),
  );
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => AetherCard(
    highlight: false,
    child: SizedBox(
      width: double.infinity,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: AetherPalette.accent, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AetherPalette.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(final BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Icon(icon, size: 20, color: AetherPalette.accent),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AetherPalette.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    ],
  );
}
