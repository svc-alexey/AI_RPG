import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/repositories/symmetry_auth_repository.dart';
import 'package:ai_prg/src/core/services/symmetry_api_client.dart';

class SymmetryCampaignRepository {
  SymmetryCampaignRepository({
    required SymmetryAuthRepository authRepository,
    SymmetryApiClient Function(String baseUrl)? clientFactory,
  }) : _authRepository = authRepository,
       _clientFactory = clientFactory;

  final SymmetryAuthRepository _authRepository;
  final SymmetryApiClient Function(String baseUrl)? _clientFactory;

  Future<List<CampaignState>> loadAllCampaigns() async {
    final List<SymmetryCampaignSummary> summaries = await _authRepository
        .runWithAuthorizedSession(
          (final session) => _client(
            session.baseUrl,
          ).listCampaigns(accessToken: session.tokens.accessToken),
          allowGuest: false,
        );
    final List<CampaignState> campaigns = <CampaignState>[];
    for (final SymmetryCampaignSummary summary in summaries) {
      final SymmetryCampaignStateResponse response = await _authRepository
          .runWithAuthorizedSession(
            (final session) => _client(session.baseUrl).getCampaignState(
              accessToken: session.tokens.accessToken,
              campaignId: summary.id,
            ),
            allowGuest: false,
          );
      campaigns.add(_campaignStateFromServer(response.state));
    }
    return campaigns;
  }

  Future<CampaignState?> loadCampaign(final String id) async {
    final SymmetryCampaignStateResponse response = await _authRepository
        .runWithAuthorizedSession(
          (final session) => _client(session.baseUrl).getCampaignState(
            accessToken: session.tokens.accessToken,
            campaignId: id,
          ),
        );
    return _campaignStateFromServer(response.state);
  }

  Future<List<SymmetryWorldRumor>> loadCampaignRumors(
    final String id, {
    final int limit = 5,
  }) => _authRepository.runWithAuthorizedSession(
    (final session) => _client(session.baseUrl).getCampaignRumors(
      accessToken: session.tokens.accessToken,
      campaignId: id,
      limit: limit,
    ),
  );

  Future<CampaignState> createCampaign({
    required final CampaignDraft draft,
    required final AppLanguage language,
    required final AiSettings aiSettings,
  }) async {
    final SymmetryCampaignStateResponse
    response = await _authRepository.runWithAuthorizedSession(
      (final session) => _client(session.baseUrl).createCampaign(
        accessToken: session.tokens.accessToken,
        payload: <String, Object?>{
          'title': draft.campaignTitle.trim().isNotEmpty
              ? _normalizeCampaignTitle(
                  draft.campaignTitle.trim(),
                  language: language,
                )
              : draft.customStoryPrompt.trim().isNotEmpty
              ? _campaignTitleFromPrompt(draft.customStoryPrompt, language)
              : _fallbackTitle(language),
          'setting': draft.setting.name,
          'mode': draft.mode.name,
          'difficulty': draft.difficulty.name,
          'language': language.code,
          'story_prompt': draft.customStoryPrompt.trim(),
          'objective_hint': _normalizeObjective(
            draft.objectiveHint.trim().isNotEmpty
                ? draft.objectiveHint.trim()
                : draft.storyWish.trim(),
          ),
          'character': <String, Object?>{
            'name': draft.heroName,
            'gender':
                (draft.characterProfile?.gender ?? CharacterGender.other).name,
            'race': draft.characterProfile?.race ?? '',
            'character_class':
                (draft.characterProfile?.characterClass ??
                        CharacterClass.unspecified)
                    .name,
            'personality': draft.characterProfile?.personality ?? '',
            'prompt_fragment': draft.characterProfile?.promptFragment ?? '',
            'skills': draft.characterProfile?.skills ?? const <String>[],
            'perks': draft.characterProfile?.perks ?? const <String>[],
          },
          if (aiSettings.baseUrl.trim().isNotEmpty &&
              aiSettings.model.trim().isNotEmpty &&
              aiSettings.apiKey.trim().isNotEmpty)
            'provider_credentials': <String, Object?>{
              'base_url': aiSettings.baseUrl.trim(),
              'model': aiSettings.model.trim(),
              'api_key': aiSettings.apiKey.trim(),
            },
        },
      ),
    );
    return _campaignStateFromServer(response.state);
  }

  Future<CampaignState> processTurn({
    required final CampaignState campaign,
    required final String playerAction,
    required final AppLanguage language,
    required final AiSettings aiSettings,
    final String triggerSource = 'manual',
  }) async {
    final SymmetryTurnResponse response = await _authRepository
        .runWithAuthorizedSession(
          (final session) => _client(session.baseUrl).processTurn(
            accessToken: session.tokens.accessToken,
            campaignId: campaign.id,
            playerAction: playerAction,
            languageCode: language.code,
            aiSettings: aiSettings,
            triggerSource: triggerSource,
          ),
        );
    return _campaignStateFromServer(response.state);
  }

  Future<void> deleteCampaign(final String id) =>
      _authRepository.runWithAuthorizedSession(
        (final session) => _client(session.baseUrl).deleteCampaign(
          accessToken: session.tokens.accessToken,
          campaignId: id,
        ),
      );

  Future<void> saveCampaign(final CampaignState campaign) async {
    // Server snapshots are persisted during create/process-turn flows.
    // Keep this as a no-op so existing UI actions do not break.
    campaign;
  }

  SymmetryApiClient _client(final String baseUrl) =>
      _clientFactory?.call(baseUrl) ?? SymmetryApiClient(baseUrl: baseUrl);

  CampaignState _campaignStateFromServer(final Map<String, Object?> json) =>
      CampaignState.fromJson(_normalizeServerState(json));

  Map<String, Object?> _normalizeServerState(final Map<String, Object?> json) {
    final Map<String, Object?> memory =
        (json['memory'] as Map<Object?, Object?>?)?.map(
          (final key, final value) => MapEntry(key.toString(), value),
        ) ??
        const <String, Object?>{};
    final Map<String, Object?> character =
        (json['character'] as Map<Object?, Object?>?)?.map(
          (final key, final value) => MapEntry(key.toString(), value),
        ) ??
        const <String, Object?>{};
    final List<Object?> modules =
        (json['modules'] as List<Object?>?)?.toList() ?? const <Object?>[];
    final List<Object?> companions =
        (json['companions'] as List<Object?>?)?.toList() ?? const <Object?>[];
    final List<Object?> resources =
        (json['resources'] as List<Object?>?)?.toList() ?? const <Object?>[];
    final List<Object?> checks =
        (json['checks'] as List<Object?>?)?.toList() ?? const <Object?>[];

    return <String, Object?>{
      'id': json['id'] ?? json['campaign_id'] ?? '',
      'title': _normalizeCampaignTitle(
        (json['title'] as String?) ?? _fallbackTitle(AppLanguage.ru),
        language: _resolveLanguage(json),
      ),
      'setting': json['setting'] ?? CampaignSetting.romantasy.name,
      'mode': json['mode'] ?? StoryMode.shortStory.name,
      'difficulty': json['difficulty'] ?? DifficultyLevel.easy.name,
      'location': _normalizeLocation(
        (json['location'] as String?) ?? '',
        language: _resolveLanguage(json),
      ),
      'objective': _normalizeObjective((json['objective'] as String?) ?? ''),
      'turnNumber': json['turn_number'] ?? json['turnNumber'] ?? 0,
      'updatedAt': DateTime.now().toIso8601String(),
      'character': <String, Object?>{
        'name': character['name'] ?? 'Hero',
        'hp': character['hp'] ?? 0,
        'maxHp': character['maxHp'] ?? character['max_hp'] ?? 0,
        'energy': character['energy'] ?? 0,
        'maxEnergy': character['maxEnergy'] ?? character['max_energy'] ?? 0,
        'might': character['might'] ?? 0,
        'wit': character['wit'] ?? 0,
        'spirit': character['spirit'] ?? 0,
      },
      'memory': <String, Object?>{
        'rollingSummary':
            memory['rolling_summary'] ?? memory['rollingSummary'] ?? '',
        'activeGoal': _normalizeObjective(
          (memory['active_goal'] ?? memory['activeGoal'] ?? '').toString(),
        ),
        'activeSituation':
            memory['active_situation'] ?? memory['activeSituation'] ?? '',
        'recentTurns':
            (memory['recent_turns'] as List<Object?>?)?.map((final item) {
              final Map<Object?, Object?> map =
                  item as Map<Object?, Object?>? ?? const <Object?, Object?>{};
              return <String, Object?>{
                'playerAction':
                    map['player_action'] ?? map['playerAction'] ?? '',
                'outcome': map['outcome'] ?? '',
                'stateHint': map['state_hint'] ?? map['stateHint'] ?? '',
              };
            }).toList() ??
            const <Map<String, Object?>>[],
      },
      'messages':
          (json['messages'] as List<Object?>?)?.map((final item) {
            final Map<Object?, Object?> map =
                item as Map<Object?, Object?>? ?? const <Object?, Object?>{};
            return <String, Object?>{
              'id': DateTime.now().microsecondsSinceEpoch.toString(),
              'role': map['role'] == 'player' ? 'player' : 'narrator',
              'text': map['text'] ?? '',
              'createdAt': DateTime.now().toIso8601String(),
            };
          }).toList() ??
          const <Map<String, Object?>>[],
      'choices': _normalizeChoices(
        (json['choices'] as List<Object?>?)
                ?.map((final item) => item.toString())
                .toList() ??
            const <String>[],
      ),
      'inventory':
          (json['inventory'] as List<Object?>?)
              ?.map((final item) => item.toString())
              .toList() ??
          const <String>[],
      'notes':
          ((json['notes'] ?? json['questLog']) as List<Object?>?)
              ?.map((final item) => item.toString())
              .toList() ??
          const <String>[],
      'companions': companions,
      'resources': resources,
      'checks': checks,
      'modules': modules.map((final item) {
        final Map<Object?, Object?> map =
            item as Map<Object?, Object?>? ?? const <Object?, Object?>{};
        return <String, Object?>{
          'module': map['module']?.toString() ?? '',
          'isActive': map['isActive'] ?? map['is_active'] ?? true,
          'activationReason':
              map['activationReason'] ?? map['activation_reason'] ?? '',
          'activatedAt': map['activatedAt'] ?? map['activated_at'],
        };
      }).toList(),
      'progression': json['progression'] is Map<Object?, Object?>
          ? (json['progression'] as Map<Object?, Object?>).map(
              (final key, final value) => MapEntry(key.toString(), value),
            )
          : const <String, Object?>{},
      'customStoryPrompt':
          json['custom_story_prompt'] ?? json['customStoryPrompt'] ?? '',
      'characterPrompt':
          json['character_prompt'] ?? character['prompt_fragment'] ?? '',
    };
  }

  String _campaignTitleFromPrompt(
    final String prompt,
    final AppLanguage language,
  ) => _normalizeCampaignTitle(
    prompt.trim().isEmpty ? _fallbackTitle(language) : prompt,
    language: language,
  );

  String _fallbackTitle(final AppLanguage language) =>
      language == AppLanguage.ru ? 'Новая кампания' : 'New campaign';

  AppLanguage _resolveLanguage(final Map<String, Object?> json) {
    final String raw = (json['language'] as String?)?.trim() ?? 'ru';
    return raw == 'en' ? AppLanguage.en : AppLanguage.ru;
  }

  String _normalizeCampaignTitle(
    final String raw, {
    required final AppLanguage language,
  }) {
    String prepared = _extractFirstPhrase(raw.trim());
    final RegExpMatch? scopedLead = RegExp(
      r'^(?:в|in)\s+(.+?),\s+(?:где|where)\b',
      caseSensitive: false,
    ).firstMatch(prepared);
    if (scopedLead != null) {
      prepared = scopedLead.group(1) ?? prepared;
    }
    String cleaned = _cleanDisplayText(prepared);
    cleaned = _stripLeadingConnector(cleaned);
    cleaned = _limitWords(cleaned, 4);
    final String limited = _truncateAtWord(cleaned, 30);
    if (limited.isEmpty) {
      return _fallbackTitle(language);
    }
    return _sentenceCase(limited, language);
  }

  String _normalizeLocation(
    final String raw, {
    required final AppLanguage language,
  }) {
    if (language == AppLanguage.ru && _looksLikeEnglishSlugSource(raw)) {
      return 'Неизвестное место';
    }
    final String prepared = raw.replaceAll('_', ' ').replaceAll('-', ' ');
    final String cleaned = _limitWords(_cleanDisplayText(prepared), 4);
    final String limited = _truncateAtWord(cleaned, 32);
    if (limited.isEmpty) {
      return language == AppLanguage.ru ? 'Начальная точка' : 'Starting Point';
    }
    return _sentenceCase(limited, language);
  }

  String _normalizeObjective(final String raw) {
    String cleaned = _extractFirstPhrase(raw.trim());
    cleaned = cleaned.replaceFirst(
      RegExp(
        r'^(?:начало пути|цель|текущая цель|objective|current objective)\s*:\s*',
        caseSensitive: false,
      ),
      '',
    );
    cleaned = _stripLeadingConnector(cleaned);
    cleaned = _cleanDisplayText(cleaned);
    cleaned = _limitWords(cleaned, 8);
    cleaned = _trimTrailingConnector(cleaned);
    cleaned = _truncateAtWord(cleaned, 56);
    return _trimTrailingConnector(cleaned);
  }

  List<String> _normalizeChoices(final List<String> rawChoices) {
    final List<String> result = <String>[];
    for (final String raw in rawChoices) {
      String cleaned = raw.replaceFirst(
        RegExp(r'^\s*(?:[-*•]|\d+[.)])\s*'),
        '',
      );
      cleaned = _extractFirstPhrase(cleaned);
      cleaned = _stripLeadingConnector(cleaned);
      cleaned = _cleanDisplayText(cleaned);
      cleaned = _limitWords(cleaned, 4);
      cleaned = _trimTrailingConnector(cleaned);
      cleaned = _truncateAtWord(cleaned, 24);
      cleaned = _trimTrailingConnector(cleaned);
      if (cleaned.isEmpty || result.contains(cleaned)) {
        continue;
      }
      result.add(cleaned);
      if (result.length >= 3) {
        break;
      }
    }
    return result;
  }

  String _extractFirstPhrase(final String raw) {
    final String candidate = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (candidate.isEmpty) {
      return '';
    }
    final RegExp splitPattern = RegExp(
      r'[.!?]|(?:, (?=где\b|where\b))|(?:;)|(?:\n)',
    );
    final Match? match = splitPattern.firstMatch(candidate);
    if (match == null) {
      return candidate;
    }
    return candidate.substring(0, match.start).trim();
  }

  String _cleanDisplayText(final String raw) {
    String cleaned = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    cleaned = cleaned.replaceAll(RegExp(r'["`~#@%^*+=<>\\[\\]{}|\\\\/]+'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'[,:;]+'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned.trim().replaceAll(RegExp(r'[.\\-_,\s]+$'), '');
  }

  String _limitWords(final String raw, final int maxWords) {
    final List<String> words = raw
        .split(' ')
        .where((final item) => item.isNotEmpty)
        .toList();
    if (words.length <= maxWords) {
      return words.join(' ');
    }
    return words.take(maxWords).join(' ');
  }

  String _truncateAtWord(final String raw, final int maxLength) {
    if (raw.length <= maxLength) {
      return raw;
    }
    String truncated = raw.substring(0, maxLength).trimRight();
    final int lastSpace = truncated.lastIndexOf(' ');
    if (lastSpace > 8) {
      truncated = truncated.substring(0, lastSpace);
    }
    return truncated.trim();
  }

  String _sentenceCase(final String raw, final AppLanguage language) {
    if (raw.isEmpty) {
      return raw;
    }
    final List<String> words = raw.split(' ');
    if (words.every((final item) => item.isEmpty || _isAsciiLower(item))) {
      return words
          .map(
            (final word) => word.isEmpty
                ? word
                : '${word[0].toUpperCase()}${word.substring(1)}',
          )
          .join(' ');
    }
    return '${raw[0].toUpperCase()}${raw.substring(1)}';
  }

  String _stripLeadingConnector(final String raw) => raw.replaceFirst(
    RegExp(r'^(?:и|а|но|или|and|but|or)\s+', caseSensitive: false),
    '',
  );

  String _trimTrailingConnector(final String raw) {
    final Set<String> connectors = <String>{
      'и',
      'а',
      'но',
      'или',
      'в',
      'во',
      'на',
      'по',
      'к',
      'ко',
      'с',
      'со',
      'у',
      'о',
      'об',
      'the',
      'a',
      'an',
      'of',
      'to',
      'in',
      'on',
      'at',
      'by',
      'for',
      'with',
      'and',
      'but',
      'or',
    };
    final List<String> words = raw
        .split(' ')
        .where((final item) => item.isNotEmpty)
        .toList();
    while (words.length > 1 && connectors.contains(words.last.toLowerCase())) {
      words.removeLast();
    }
    return words.join(' ');
  }

  bool _looksLikeEnglishSlugSource(final String raw) {
    final String stripped = raw.trim();
    if (stripped.isEmpty ||
        (!stripped.contains('_') && !stripped.contains('-'))) {
      return false;
    }
    final String normalized = stripped
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');
    return RegExp(r'^[a-z0-9 ]+$').hasMatch(normalized);
  }

  bool _isAsciiLower(final String raw) =>
      raw.isNotEmpty && raw == raw.toLowerCase();
}
