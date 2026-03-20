import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/repositories/campaign_repository.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/services/ai_client.dart'
    show AiCancelException, AiClient, AiTurnException, CancelToken;
import 'package:ai_prg/src/core/services/ai_service_factory.dart';
import 'package:ai_prg/src/core/services/game_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatControllerProvider = StateNotifierProvider.autoDispose
    .family<ChatController, ChatViewState, String>(
      (final ref, final campaignId) => ChatController(ref, campaignId)..load(),
    );

class ChatViewState {
  const ChatViewState({
    required this.isLoading,
    required this.isSending,
    required this.campaign,
    required this.settings,
    required this.status,
    required this.pendingPlayerMessage,
    required this.pendingNarratorMessage,
    required this.clearInputRevision,
  });

  const ChatViewState.initial()
    : isLoading = true,
      isSending = false,
      campaign = null,
      settings = const AiSettings.defaults(),
      status = null,
      pendingPlayerMessage = null,
      pendingNarratorMessage = null,
      clearInputRevision = 0;

  static const Object _unset = Object();

  final bool isLoading;
  final bool isSending;
  final CampaignState? campaign;
  final AiSettings settings;
  final String? status;
  final ChatMessage? pendingPlayerMessage;
  final ChatMessage? pendingNarratorMessage;
  final int clearInputRevision;

  List<ChatMessage> get visibleMessages {
    final List<ChatMessage> messages = <ChatMessage>[...?campaign?.messages];
    if (pendingPlayerMessage != null) {
      messages.add(pendingPlayerMessage!);
    }
    if (pendingNarratorMessage != null) {
      messages.add(pendingNarratorMessage!);
    }
    return messages;
  }

  ChatViewState copyWith({
    final bool? isLoading,
    final bool? isSending,
    final Object? campaign = _unset,
    final AiSettings? settings,
    final Object? status = _unset,
    final Object? pendingPlayerMessage = _unset,
    final Object? pendingNarratorMessage = _unset,
    final int? clearInputRevision,
  }) => ChatViewState(
    isLoading: isLoading ?? this.isLoading,
    isSending: isSending ?? this.isSending,
    campaign: identical(campaign, _unset)
        ? this.campaign
        : campaign as CampaignState?,
    settings: settings ?? this.settings,
    status: identical(status, _unset) ? this.status : status as String?,
    pendingPlayerMessage: identical(pendingPlayerMessage, _unset)
        ? this.pendingPlayerMessage
        : pendingPlayerMessage as ChatMessage?,
    pendingNarratorMessage: identical(pendingNarratorMessage, _unset)
        ? this.pendingNarratorMessage
        : pendingNarratorMessage as ChatMessage?,
    clearInputRevision: clearInputRevision ?? this.clearInputRevision,
  );
}

class ChatController extends StateNotifier<ChatViewState> {
  ChatController(this._ref, this._campaignId)
    : super(const ChatViewState.initial());

  final Ref _ref;
  final String _campaignId;

  CancelToken? _cancelToken;
  bool _didLoad = false;
  bool _disposed = false;

  CampaignRepository get _campaignRepository =>
      _ref.read(campaignRepositoryProvider);

  SettingsRepository get _settingsRepository =>
      _ref.read(settingsRepositoryProvider);

  AiServiceFactory get _aiServiceFactory => _ref.read(aiServiceFactoryProvider);

  GameEngine get _gameEngine => _ref.read(gameEngineProvider);

  AppLanguage get _appLanguage =>
      _ref.read(appLanguageListenableProvider).value;

  @override
  void dispose() {
    _disposed = true;
    _cancelToken?.cancel();
    super.dispose();
  }

  Future<void> load() async {
    if (_didLoad) {
      return;
    }
    _didLoad = true;

    final CampaignState? campaign = await _campaignRepository.loadCampaign(
      _campaignId,
    );
    final AiSettings settings = await _settingsRepository.loadAiSettings();

    if (_disposed) {
      return;
    }

    state = state.copyWith(
      campaign: campaign,
      settings: settings,
      isLoading: false,
    );
  }

  Future<void> save({required final AppLocalizations l10n}) async {
    final CampaignState? campaign = state.campaign;
    if (campaign == null) {
      return;
    }

    await _campaignRepository.saveCampaign(campaign);
    if (_disposed) {
      return;
    }

    state = state.copyWith(status: l10n.campaignSaved);
  }

  void cancelGeneration() => _cancelToken?.cancel();

  Future<void> runTurn({
    required final AppLocalizations? l10n,
    required final String action,
    required final bool suggestionsOnly,
    final bool isIntro = false,
  }) async {
    final CampaignState? campaign = state.campaign;
    if (campaign == null) {
      return;
    }

    final String trimmedAction = isIntro ? '' : action.trim();
    if (!suggestionsOnly && !isIntro && trimmedAction.isEmpty) {
      if (l10n != null && !_disposed) {
        state = state.copyWith(status: l10n.actionRequired);
      }
      return;
    }

    final CancelToken cancelToken = CancelToken();
    final DateTime now = DateTime.now();
    _cancelToken = cancelToken;

    state = state.copyWith(
      isSending: true,
      status: null,
      pendingPlayerMessage: !suggestionsOnly && !isIntro
          ? ChatMessage(
              id: 'pending_player',
              role: ChatRole.player,
              text: trimmedAction,
              createdAt: now,
            )
          : null,
      pendingNarratorMessage: !suggestionsOnly
          ? ChatMessage(
              id: 'pending_narrator',
              role: ChatRole.narrator,
              text: l10n?.generatingResponse ?? '',
              createdAt: now,
            )
          : null,
    );

    try {
      final AppLanguage language = _appLanguage;
      final AiSettings settings = await _settingsRepository.loadAiSettings();
      final AiClient client = _aiServiceFactory.create(settings);
      final TurnResult result = await client.generateTurn(
        settings: settings,
        language: language,
        state: campaign,
        playerAction: trimmedAction,
        suggestionsOnly: suggestionsOnly,
        onNarrationDelta: suggestionsOnly
            ? null
            : (final narration) =>
                  _updatePendingNarration(narration: narration, createdAt: now),
        cancelToken: cancelToken,
      );

      final CampaignState nextState = suggestionsOnly
          ? campaign.copyWith(
              choices: result.choices,
              memory: campaign.memory.copyWith(
                activeSituation: result.narration,
              ),
              updatedAt: DateTime.now(),
            )
          : _gameEngine.applyTurn(
              language: language,
              state: campaign,
              playerAction: trimmedAction,
              result: result,
              contextWindowSize: settings.contextWindowSize,
            );

      await _campaignRepository.saveCampaign(nextState);

      if (_disposed) {
        return;
      }

      state = state.copyWith(
        campaign: nextState,
        settings: settings,
        isSending: false,
        pendingPlayerMessage: null,
        pendingNarratorMessage: null,
        status: l10n == null
            ? null
            : suggestionsOnly
            ? l10n.suggestionsUpdated(settings.isConfigured)
            : l10n.turnCompleted(settings.isConfigured),
        clearInputRevision: suggestionsOnly
            ? state.clearInputRevision
            : state.clearInputRevision + 1,
      );
      _cancelToken = null;
    } on AiTurnException catch (error) {
      _clearPendingMessages();
      await _handleAiTurnException(error, l10n);
    } catch (error) {
      if (_disposed) {
        return;
      }
      final bool wasCancelled = error is AiCancelException;
      _cancelToken = null;
      state = state.copyWith(
        isSending: false,
        pendingPlayerMessage: null,
        pendingNarratorMessage: null,
        status: l10n == null
            ? null
            : wasCancelled
            ? l10n.generationCancelled
            : l10n.turnError(error),
      );
      if (wasCancelled) {
        _clearPendingMessages();
      }
    }
  }

  Future<void> _handleAiTurnException(
    final AiTurnException error,
    final AppLocalizations? l10n,
  ) async {
    final CampaignState? campaign = state.campaign;
    if (campaign == null) {
      return;
    }

    CampaignState nextState = _gameEngine.appendSystemMessage(
      state: campaign,
      text: error.userMessage,
    );

    if ((error.rawResponse ?? '').trim().isNotEmpty && l10n != null) {
      nextState = _gameEngine.appendSystemMessage(
        state: nextState,
        text: l10n.rawModelResponseSaved,
      );
    }

    await _campaignRepository.saveCampaign(nextState);

    if (_disposed) {
      return;
    }

    _cancelToken = null;
    state = state.copyWith(
      campaign: nextState,
      isSending: false,
      pendingPlayerMessage: null,
      pendingNarratorMessage: null,
      status: error.userMessage,
    );
  }

  void _updatePendingNarration({
    required final String narration,
    required final DateTime createdAt,
  }) {
    if (_disposed || narration.trim().isEmpty) {
      return;
    }

    state = state.copyWith(
      pendingNarratorMessage: ChatMessage(
        id: 'pending_narrator',
        role: ChatRole.narrator,
        text: narration,
        createdAt: state.pendingNarratorMessage?.createdAt ?? createdAt,
      ),
    );
  }

  void _clearPendingMessages() {
    if (_disposed) {
      return;
    }

    state = state.copyWith(
      pendingPlayerMessage: null,
      pendingNarratorMessage: null,
    );
  }
}
