import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/core/data/character_templates.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/repositories/campaign_repository.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/services/ai_client.dart'
    show AiClient, CancelToken;
import 'package:ai_prg/src/core/services/ai_service_factory.dart';
import 'package:ai_prg/src/core/services/campaign_module_resolver.dart';
import 'package:ai_prg/src/core/services/character_prompt_builder.dart';
import 'package:ai_prg/src/core/services/game_engine.dart';
import 'package:ai_prg/src/core/services/random_story_prompt_generator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NewGameWizardMode { modeSelection, quickStart, customSetup }

enum NewGameCustomSetupStep { foundation, story, character, review }

final newGameControllerProvider =
    StateNotifierProvider.autoDispose<NewGameController, NewGameViewState>(
      (final ref) => NewGameController(ref)..load(),
    );

class NewGameViewState {
  const NewGameViewState({
    required this.heroName,
    required this.storyWish,
    required this.customStoryPrompt,
    required this.characterPrompt,
    required this.personality,
    required this.mode,
    required this.currentStep,
    required this.setting,
    required this.storyMode,
    required this.difficulty,
    required this.gender,
    required this.isSaving,
    required this.isGenerating,
    required this.aiConfigured,
    required this.characterProfile,
    required this.plannedModules,
    required this.formRevision,
  });

  const NewGameViewState.initial()
    : heroName = '',
      storyWish = '',
      customStoryPrompt = '',
      characterPrompt = '',
      personality = '',
      mode = NewGameWizardMode.modeSelection,
      currentStep = NewGameCustomSetupStep.foundation,
      setting = CampaignSetting.fantasy,
      storyMode = StoryMode.shortStory,
      difficulty = DifficultyLevel.easy,
      gender = CharacterGender.other,
      isSaving = false,
      isGenerating = false,
      aiConfigured = false,
      characterProfile = null,
      plannedModules = const <CampaignModuleState>[],
      formRevision = 0;

  final String heroName;
  final String storyWish;
  final String customStoryPrompt;
  final String characterPrompt;
  final String personality;
  final NewGameWizardMode mode;
  final NewGameCustomSetupStep currentStep;
  final CampaignSetting setting;
  final StoryMode storyMode;
  final DifficultyLevel difficulty;
  final CharacterGender gender;
  final bool isSaving;
  final bool isGenerating;
  final bool aiConfigured;
  final CharacterProfile? characterProfile;
  final List<CampaignModuleState> plannedModules;
  final int formRevision;

  NewGameViewState copyWith({
    final String? heroName,
    final String? storyWish,
    final String? customStoryPrompt,
    final String? characterPrompt,
    final String? personality,
    final NewGameWizardMode? mode,
    final NewGameCustomSetupStep? currentStep,
    final CampaignSetting? setting,
    final StoryMode? storyMode,
    final DifficultyLevel? difficulty,
    final CharacterGender? gender,
    final bool? isSaving,
    final bool? isGenerating,
    final bool? aiConfigured,
    final CharacterProfile? characterProfile,
    final List<CampaignModuleState>? plannedModules,
    final int? formRevision,
  }) => NewGameViewState(
    heroName: heroName ?? this.heroName,
    storyWish: storyWish ?? this.storyWish,
    customStoryPrompt: customStoryPrompt ?? this.customStoryPrompt,
    characterPrompt: characterPrompt ?? this.characterPrompt,
    personality: personality ?? this.personality,
    mode: mode ?? this.mode,
    currentStep: currentStep ?? this.currentStep,
    setting: setting ?? this.setting,
    storyMode: storyMode ?? this.storyMode,
    difficulty: difficulty ?? this.difficulty,
    gender: gender ?? this.gender,
    isSaving: isSaving ?? this.isSaving,
    isGenerating: isGenerating ?? this.isGenerating,
    aiConfigured: aiConfigured ?? this.aiConfigured,
    characterProfile: characterProfile ?? this.characterProfile,
    plannedModules: plannedModules ?? this.plannedModules,
    formRevision: formRevision ?? this.formRevision,
  );
}

class NewGameController extends StateNotifier<NewGameViewState> {
  NewGameController(this._ref) : super(const NewGameViewState.initial()) {
    _refreshPlannedModules();
  }

  final Ref _ref;

  static const CharacterPromptBuilder _charBuilder = CharacterPromptBuilder();
  static const CampaignModuleResolver _moduleResolver =
      CampaignModuleResolver();
  static const RandomStoryPromptGenerator _storyPromptGenerator =
      RandomStoryPromptGenerator();

  CancelToken? _cancelToken;
  bool _didLoad = false;

  Future<void> load() async {
    if (_didLoad) {
      return;
    }
    _didLoad = true;

    final AiSettings settings = await _settingsRepository.loadAiSettings();
    state = state.copyWith(aiConfigured: settings.isConfigured);
    _refreshPlannedModules();
  }

  AppLanguage get language => _ref.read(appLanguageListenableProvider).value;

  CharacterProfile effectiveCharacterProfile() =>
      state.characterProfile ?? _defaultCharacterProfile();

  void setModeSelection() {
    state = state.copyWith(mode: NewGameWizardMode.modeSelection);
  }

  void setQuickStartMode() {
    state = state.copyWith(mode: NewGameWizardMode.quickStart);
  }

  void setCustomSetupMode() {
    state = state.copyWith(
      mode: NewGameWizardMode.customSetup,
      currentStep: NewGameCustomSetupStep.foundation,
    );
  }

  void previousStep() {
    if (state.currentStep.index == 0) {
      return;
    }
    state = state.copyWith(
      currentStep: NewGameCustomSetupStep.values[state.currentStep.index - 1],
    );
  }

  void nextStep() {
    if (state.currentStep.index >= NewGameCustomSetupStep.values.length - 1) {
      return;
    }
    state = state.copyWith(
      currentStep: NewGameCustomSetupStep.values[state.currentStep.index + 1],
    );
  }

  void setHeroName(final String value) {
    state = state.copyWith(heroName: value);
  }

  void setStoryWish(final String value) {
    state = state.copyWith(storyWish: value);
    _refreshPlannedModules();
  }

  void setCustomStoryPrompt(final String value) {
    state = state.copyWith(customStoryPrompt: value);
    _refreshPlannedModules();
  }

  void setCharacterPrompt(final String value) {
    state = state.copyWith(
      characterPrompt: value,
      characterProfile: effectiveCharacterProfile().copyWith(
        promptFragment: value,
      ),
    );
    _refreshPlannedModules();
  }

  void setPersonality(final String value) {
    state = state.copyWith(
      personality: value,
      characterProfile: effectiveCharacterProfile().copyWith(
        personality: value,
      ),
    );
    _refreshPlannedModules();
  }

  void setSetting(final CampaignSetting newSetting) {
    CharacterProfile? profile = state.characterProfile;
    final List<CharacterClass> classes =
        classesBySetting[newSetting] ??
        <CharacterClass>[CharacterClass.warrior];
    final List<String> races = racesBySetting[newSetting] ?? <String>['human'];

    if (profile != null) {
      if (!classes.contains(profile.characterClass)) {
        profile = profile.copyWith(characterClass: classes.first);
      }
      if (!races.contains(profile.race)) {
        profile = profile.copyWith(race: races.first);
      }
    }

    state = state.copyWith(setting: newSetting, characterProfile: profile);
    _refreshPlannedModules();
  }

  void setStoryMode(final StoryMode value) {
    state = state.copyWith(storyMode: value);
  }

  void setDifficulty(final DifficultyLevel value) {
    state = state.copyWith(difficulty: value);
  }

  void setGender(final CharacterGender value) {
    state = state.copyWith(
      gender: value,
      characterProfile: state.characterProfile?.copyWith(gender: value),
    );
  }

  void setCharacterClass(final CharacterClass value) {
    state = state.copyWith(
      characterProfile: effectiveCharacterProfile().copyWith(
        characterClass: value,
      ),
    );
  }

  void setRace(final String value) {
    state = state.copyWith(
      characterProfile: effectiveCharacterProfile().copyWith(race: value),
    );
  }

  void randomizeCharacter() {
    final CharacterProfile random = _charBuilder.randomProfile(
      setting: state.setting,
      language: language,
      baseName: state.heroName.trim(),
    );

    state = state.copyWith(
      characterProfile: random,
      personality: random.personality,
      characterPrompt: random.promptFragment,
      gender: random.gender,
      formRevision: state.formRevision + 1,
    );
    _refreshPlannedModules();
  }

  Future<void> generatePrompts() async {
    final CancelToken cancelToken = CancelToken();
    _cancelToken = cancelToken;
    state = state.copyWith(isGenerating: true);

    final AiSettings settings = await _settingsRepository.loadAiSettings();
    final AiClient client = _aiServiceFactory.create(settings);
    try {
      final GeneratedPrompts result = await client.generatePromptsFromStoryWish(
        settings: settings,
        language: language,
        storyWish: state.storyWish.trim(),
        setting: state.setting,
        cancelToken: cancelToken,
      );

      state = state.copyWith(
        customStoryPrompt: result.storyPrompt,
        characterPrompt:
            result.characterPrompt.isNotEmpty && state.characterProfile == null
            ? result.characterPrompt
            : state.characterPrompt,
        formRevision: state.formRevision + 1,
      );
      _refreshPlannedModules();
    } catch (_) {
      // Intentionally keep the screen quiet on generation errors for now.
    } finally {
      _cancelToken = null;
      state = state.copyWith(isGenerating: false);
    }
  }

  void cancelGeneration() => _cancelToken?.cancel();

  Future<CampaignState> createQuickCampaign() async {
    state = state.copyWith(isSaving: true);

    final AppLanguage currentLanguage = language;
    final CharacterProfile charProfile = _defaultCharacterProfile();
    final String randomPrompt = _storyPromptGenerator.generateForSetting(
      setting: state.setting,
      language: currentLanguage,
    );

    final CampaignState campaign = _gameEngine.createCampaign(
      draft: CampaignDraft(
        setting: state.setting,
        mode: StoryMode.shortStory,
        difficulty: DifficultyLevel.easy,
        heroName: _resolvedHeroName(currentLanguage),
        customStoryPrompt: randomPrompt,
        characterProfile: charProfile,
      ),
      language: currentLanguage,
    );

    await _campaignRepository.saveCampaign(campaign);
    state = state.copyWith(isSaving: false);
    return campaign;
  }

  Future<CampaignState> createCampaign() async {
    state = state.copyWith(isSaving: true);

    final AppLanguage currentLanguage = language;
    CharacterProfile charProfile =
        state.characterProfile ?? _defaultCharacterProfile();
    if (state.characterPrompt.trim().isNotEmpty) {
      charProfile = charProfile.copyWith(
        promptFragment: state.characterPrompt.trim(),
      );
    }
    if (state.personality.trim().isNotEmpty) {
      charProfile = charProfile.copyWith(personality: state.personality.trim());
    }
    charProfile = charProfile.copyWith(
      name: _resolvedHeroName(currentLanguage),
    );

    final String storyPrompt = state.customStoryPrompt.trim().isEmpty
        ? _storyPromptGenerator.generateForSetting(
            setting: state.setting,
            language: currentLanguage,
          )
        : state.customStoryPrompt.trim();

    final CampaignState campaign = _gameEngine.createCampaign(
      draft: CampaignDraft(
        setting: state.setting,
        mode: state.storyMode,
        difficulty: state.difficulty,
        heroName: _resolvedHeroName(currentLanguage),
        storyWish: state.storyWish.trim(),
        customStoryPrompt: storyPrompt,
        characterProfile: charProfile,
      ),
      language: currentLanguage,
    );

    await _campaignRepository.saveCampaign(campaign);
    state = state.copyWith(isSaving: false);
    return campaign;
  }

  CharacterProfile _defaultCharacterProfile() {
    final List<CharacterClass> classes =
        classesBySetting[state.setting] ??
        <CharacterClass>[CharacterClass.warrior];
    final List<String> races =
        racesBySetting[state.setting] ?? <String>['human'];
    return CharacterProfile(
      name: _resolvedHeroName(language),
      gender: state.gender,
      race: races.first,
      characterClass: classes.first,
      skills: <String>[],
      personality: '',
      perks: <String>[],
      promptFragment: '',
    );
  }

  String _resolvedHeroName(final AppLanguage language) =>
      state.heroName.trim().isEmpty
      ? (language == AppLanguage.ru ? 'РЎС‚СЂР°РЅРЅРёРє' : 'Wayfarer')
      : state.heroName.trim();

  void _refreshPlannedModules() {
    final CharacterProfile profile =
        state.characterProfile ?? _defaultCharacterProfile();
    final String storyPrompt = state.customStoryPrompt.trim().isEmpty
        ? state.storyWish.trim()
        : state.customStoryPrompt.trim();
    final List<CampaignModuleState> planned = _moduleResolver
        .resolveInitialModules(
          draft: CampaignDraft(
            setting: state.setting,
            mode: state.storyMode,
            difficulty: state.difficulty,
            heroName: state.heroName.trim(),
            storyWish: state.storyWish.trim(),
            customStoryPrompt: storyPrompt,
            characterProfile: profile.copyWith(
              promptFragment: state.characterPrompt.trim(),
              personality: state.personality.trim(),
            ),
          ),
        );
    state = state.copyWith(plannedModules: planned);
  }

  SettingsRepository get _settingsRepository =>
      _ref.read(settingsRepositoryProvider);

  AiServiceFactory get _aiServiceFactory => _ref.read(aiServiceFactoryProvider);

  GameEngine get _gameEngine => _ref.read(gameEngineProvider);

  CampaignRepository get _campaignRepository =>
      _ref.read(campaignRepositoryProvider);
}
