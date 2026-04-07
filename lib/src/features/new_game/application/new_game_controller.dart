import 'dart:math';

import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/core/data/character_templates.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/repositories/symmetry_auth_repository.dart';
import 'package:ai_prg/src/core/repositories/symmetry_campaign_repository.dart';
import 'package:ai_prg/src/core/services/ai_client.dart' show CancelToken;
import 'package:ai_prg/src/core/services/campaign_module_resolver.dart';
import 'package:ai_prg/src/core/services/character_prompt_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NewGameWizardMode { modeSelection, quickStart, customSetup }

enum NewGameCustomSetupStep {
  literaryGenre,
  worldSetting,
  foundation,
  story,
  character,
  review,
}

final newGameControllerProvider =
    StateNotifierProvider.autoDispose<NewGameController, NewGameViewState>(
      (final ref) => NewGameController(ref)..load(),
    );

class NewGameViewState {
  const NewGameViewState({
    required this.heroName,
    required this.storyWish,
    required this.customStoryPrompt,
    required this.campaignTitleHint,
    required this.objectiveHint,
    required this.characterPrompt,
    required this.personality,
    required this.mode,
    required this.currentStep,
    required this.setting,
    required this.literaryGenre,
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
      campaignTitleHint = '',
      objectiveHint = '',
      characterPrompt = '',
      personality = '',
      mode = NewGameWizardMode.modeSelection,
      currentStep = NewGameCustomSetupStep.literaryGenre,
      setting = CampaignSetting.romantasy,
      literaryGenre = LiteraryGenre.fantasyGenre,
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
  final String campaignTitleHint;
  final String objectiveHint;
  final String characterPrompt;
  final String personality;
  final NewGameWizardMode mode;
  final NewGameCustomSetupStep currentStep;
  final CampaignSetting setting;
  final LiteraryGenre literaryGenre;
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
    final String? campaignTitleHint,
    final String? objectiveHint,
    final String? characterPrompt,
    final String? personality,
    final NewGameWizardMode? mode,
    final NewGameCustomSetupStep? currentStep,
    final CampaignSetting? setting,
    final LiteraryGenre? literaryGenre,
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
    campaignTitleHint: campaignTitleHint ?? this.campaignTitleHint,
    objectiveHint: objectiveHint ?? this.objectiveHint,
    characterPrompt: characterPrompt ?? this.characterPrompt,
    personality: personality ?? this.personality,
    mode: mode ?? this.mode,
    currentStep: currentStep ?? this.currentStep,
    setting: setting ?? this.setting,
    literaryGenre: literaryGenre ?? this.literaryGenre,
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

  static final Random _random = Random();
  static const int quickStartShortStoryWeight = 70;
  static const int quickStartLongCampaignWeight = 30;
  static const CharacterPromptBuilder _charBuilder = CharacterPromptBuilder();
  static const CampaignModuleResolver _moduleResolver =
      CampaignModuleResolver();

  CancelToken? _cancelToken;
  bool _didLoad = false;

  Future<void> load() async {
    if (_didLoad) {
      return;
    }
    _didLoad = true;

    final AiSettings settings = AiSettings.withEnvFallbacks(
      await _settingsRepository.loadAiSettings(),
    );
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
      currentStep: NewGameCustomSetupStep.literaryGenre,
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

  void setLiteraryGenre(final LiteraryGenre value) {
    state = state.copyWith(literaryGenre: value);
    _refreshPlannedModules();
  }

  void randomizeLiteraryGenre() {
    state = state.copyWith(
      literaryGenre:
          LiteraryGenre.values[_random.nextInt(LiteraryGenre.values.length)],
    );
    _refreshPlannedModules();
  }

  void randomizeSetting() {
    setSetting(
      CampaignSetting.values[_random.nextInt(CampaignSetting.values.length)],
    );
  }

  void setHeroName(final String value) {
    state = state.copyWith(heroName: value);
  }

  void setStoryWish(final String value) {
    state = state.copyWith(
      storyWish: value,
      campaignTitleHint: '',
      objectiveHint: '',
    );
    _refreshPlannedModules();
  }

  void setStoryInput(final String value) {
    state = state.copyWith(
      storyWish: value,
      customStoryPrompt: value,
      campaignTitleHint: '',
      objectiveHint: '',
    );
    _refreshPlannedModules();
  }

  void setCustomStoryPrompt(final String value) {
    state = state.copyWith(
      customStoryPrompt: value,
      campaignTitleHint: '',
      objectiveHint: '',
    );
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
    final List<CharacterClass> classes = classesBySetting[newSetting]!;
    final List<String> races = racesBySetting[newSetting] ?? <String>['human'];

    if (profile != null) {
      if (classes.isEmpty) {
        profile = profile.copyWith(characterClass: CharacterClass.unspecified);
      } else if (!classes.contains(profile.characterClass)) {
        profile = profile.copyWith(characterClass: classes.first);
      }
      if (!races.contains(profile.race)) {
        profile = profile.copyWith(race: races.first);
      }
    }

    state = state.copyWith(setting: newSetting, characterProfile: profile);
    _rebuildCharacterPromptFromCurrentProfile();
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
    _rebuildCharacterPromptFromCurrentProfile();
  }

  void setCharacterClass(final CharacterClass value) {
    state = state.copyWith(
      characterProfile: effectiveCharacterProfile().copyWith(
        characterClass: value,
      ),
    );
    _rebuildCharacterPromptFromCurrentProfile();
  }

  void setRace(final String value) {
    state = state.copyWith(
      characterProfile: effectiveCharacterProfile().copyWith(race: value),
    );
    _rebuildCharacterPromptFromCurrentProfile();
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
    final AppLanguage currentLanguage = language;
    final String currentInput = state.customStoryPrompt.trim().isNotEmpty
        ? state.customStoryPrompt.trim()
        : state.storyWish.trim();

    final CancelToken cancelToken = CancelToken();
    _cancelToken = cancelToken;
    state = state.copyWith(isGenerating: true);

    final AiSettings settings = await _settingsRepository.loadAiSettings();
    try {
      final GeneratedPrompts result = await _symmetryAuthRepository
          .generateCampaignPrompts(
            aiSettings: settings,
            language: currentLanguage,
            request: CampaignPromptGenerationRequest(
              setting: state.setting,
              literaryGenre: state.literaryGenre,
              mode: state.storyMode,
              difficulty: state.difficulty,
              storyWish: currentInput,
            ),
          );

      final GeneratedPrompts resolved = _resolvePrompts(
        generationSeed: currentInput,
        generated: result,
      );

      state = state.copyWith(
        storyWish: resolved.storyPrompt,
        customStoryPrompt: resolved.storyPrompt,
        campaignTitleHint: resolved.campaignTitle,
        objectiveHint: resolved.objectiveHint,
        characterPrompt: resolved.characterPrompt,
        formRevision: state.formRevision + 1,
      );
      _refreshPlannedModules();
    } finally {
      _cancelToken = null;
      state = state.copyWith(isGenerating: false);
    }
  }

  void cancelGeneration() => _cancelToken?.cancel();

  GeneratedPrompts _resolvePrompts({
    required final String generationSeed,
    required final GeneratedPrompts generated,
  }) {
    final String rawStoryPrompt = generated.storyPrompt.trim();
    final String rawCharacterPrompt = generated.characterPrompt.trim();
    if (rawStoryPrompt.isNotEmpty && rawCharacterPrompt.isNotEmpty) {
      return GeneratedPrompts(
        storyPrompt: rawStoryPrompt,
        characterPrompt: rawCharacterPrompt,
        campaignTitle: generated.campaignTitle.trim(),
        objectiveHint: generated.objectiveHint.trim(),
      );
    }
    if (rawStoryPrompt.isNotEmpty) {
      return GeneratedPrompts(
        storyPrompt: rawStoryPrompt,
        characterPrompt: rawCharacterPrompt.isNotEmpty
            ? rawCharacterPrompt
            : state.characterPrompt.trim(),
        campaignTitle: generated.campaignTitle.trim(),
        objectiveHint: generated.objectiveHint.trim(),
      );
    }
    final String seed = generationSeed.trim();
    return GeneratedPrompts(
      storyPrompt: seed,
      characterPrompt: state.characterPrompt.trim(),
      campaignTitle: generated.campaignTitle.trim(),
      objectiveHint: generated.objectiveHint.trim(),
    );
  }

  Future<CampaignState> createQuickCampaign() async {
    state = state.copyWith(isSaving: true);
    try {
      if (!state.aiConfigured) {
        throw StateError('ai_not_configured');
      }
      final AppLanguage currentLanguage = language;
      final AiSettings settings = await _settingsRepository.loadAiSettings();
      final CampaignSetting rolledSetting = CampaignSetting
          .values[_random.nextInt(CampaignSetting.values.length)];
      final LiteraryGenre rolledGenre =
          LiteraryGenre.values[_random.nextInt(LiteraryGenre.values.length)];
      final StoryMode rolledMode = pickQuickStartStoryMode(_random);
      final GeneratedPrompts prompts = await _symmetryAuthRepository
          .generateCampaignPrompts(
            aiSettings: settings,
            language: currentLanguage,
            request: CampaignPromptGenerationRequest(
              setting: rolledSetting,
              literaryGenre: rolledGenre,
              mode: rolledMode,
              difficulty: DifficultyLevel.easy,
            ),
          );
      final CharacterProfile charProfile = _defaultCharacterProfile().copyWith(
        name: _resolvedHeroName(currentLanguage),
        promptFragment: prompts.characterPrompt.trim(),
      );
      final String storyText = prompts.storyPrompt.trim();
      if (storyText.isEmpty) {
        throw StateError('prompt_generation_failed');
      }
      final CampaignDraft draft = CampaignDraft(
        setting: rolledSetting,
        literaryGenre: rolledGenre,
        mode: rolledMode,
        difficulty: DifficultyLevel.easy,
        heroName: _resolvedHeroName(currentLanguage),
        customStoryPrompt: storyText,
        campaignTitle: prompts.campaignTitle.trim(),
        objectiveHint: prompts.objectiveHint.trim(),
        characterProfile: charProfile,
      );
      return _symmetryCampaignRepository.createCampaign(
        draft: draft,
        language: currentLanguage,
        aiSettings: settings,
      );
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  Future<CampaignState> createCampaign() async {
    state = state.copyWith(isSaving: true);
    try {
      final AppLanguage currentLanguage = language;
      final String storyPrompt = state.customStoryPrompt.trim();
      if (storyPrompt.isEmpty) {
        throw StateError('story_prompt_required');
      }
      CharacterProfile charProfile =
          state.characterProfile ?? _defaultCharacterProfile();
      if (state.characterPrompt.trim().isNotEmpty) {
        charProfile = charProfile.copyWith(
          promptFragment: state.characterPrompt.trim(),
        );
      }
      if (state.personality.trim().isNotEmpty) {
        charProfile = charProfile.copyWith(
          personality: state.personality.trim(),
        );
      }
      charProfile = charProfile.copyWith(
        name: _resolvedHeroName(currentLanguage),
      );

      final AiSettings settings = await _settingsRepository.loadAiSettings();
      final CampaignDraft draft = CampaignDraft(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        setting: state.setting,
        literaryGenre: state.literaryGenre,
        mode: state.storyMode,
        difficulty: state.difficulty,
        heroName: _resolvedHeroName(currentLanguage),
        storyWish: state.storyWish.trim(),
        customStoryPrompt: storyPrompt,
        campaignTitle: state.campaignTitleHint.trim(),
        objectiveHint: state.objectiveHint.trim(),
        characterProfile: charProfile,
      );
      return _symmetryCampaignRepository.createCampaign(
        draft: draft,
        language: currentLanguage,
        aiSettings: settings,
      );
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  CharacterProfile _defaultCharacterProfile() {
    final List<CharacterClass> classes = classesBySetting[state.setting]!;
    final List<String> races =
        racesBySetting[state.setting] ?? <String>['human'];
    final CharacterClass charClass = classes.isEmpty
        ? CharacterClass.unspecified
        : classes.first;
    return CharacterProfile(
      name: _resolvedHeroName(language),
      gender: state.gender,
      race: races.first,
      characterClass: charClass,
      skills: <String>[],
      personality: '',
      perks: <String>[],
      promptFragment: '',
    );
  }

  String _resolvedHeroName(final AppLanguage language) =>
      state.heroName.trim().isEmpty
      ? (language == AppLanguage.ru ? 'Странник' : 'Wayfarer')
      : state.heroName.trim();

  /// Syncs stored character prompt text and profile fragment with race, class,
  /// gender, personality, etc. Call after structural profile changes.
  void _rebuildCharacterPromptFromCurrentProfile() {
    final CharacterProfile cleared = effectiveCharacterProfile().copyWith(
      promptFragment: '',
    );
    final String rebuilt = _charBuilder.buildPrompt(
      profile: cleared,
      setting: state.setting,
      language: language,
    );
    state = state.copyWith(
      characterProfile: cleared.copyWith(promptFragment: rebuilt),
      characterPrompt: rebuilt,
      formRevision: state.formRevision + 1,
    );
    _refreshPlannedModules();
  }

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
            literaryGenre: state.literaryGenre,
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

  SymmetryAuthRepository get _symmetryAuthRepository =>
      _ref.read(symmetryAuthRepositoryProvider);

  SymmetryCampaignRepository get _symmetryCampaignRepository =>
      _ref.read(symmetryCampaignRepositoryProvider);

  static StoryMode pickQuickStartStoryMode(final Random random) {
    final int totalWeight =
        quickStartShortStoryWeight + quickStartLongCampaignWeight;
    final int roll = random.nextInt(totalWeight);
    if (roll < quickStartShortStoryWeight) {
      return StoryMode.shortStory;
    }
    return StoryMode.longCampaign;
  }
}
