import 'dart:async';

import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/repositories/campaign_repository.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/services/ai_client.dart'
    show
        AiCancelException,
        AiClient,
        AiRequestMetadata,
        AiTurnException,
        CancelToken;
import 'package:ai_prg/src/core/services/ai_service_factory.dart';
import 'package:ai_prg/src/core/services/app_logger.dart';
import 'package:ai_prg/src/core/services/deterministic_check_service.dart';
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
    required this.transientNotifications,
    required this.highlightedModules,
    required this.newlyUnlockedModules,
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
      transientNotifications = const <StateChangeNotification>[],
      highlightedModules = const <CampaignModule>[],
      newlyUnlockedModules = const <CampaignModule>[],
      clearInputRevision = 0;

  static const Object _unset = Object();

  final bool isLoading;
  final bool isSending;
  final CampaignState? campaign;
  final AiSettings settings;
  final String? status;
  final ChatMessage? pendingPlayerMessage;
  final ChatMessage? pendingNarratorMessage;
  final List<StateChangeNotification> transientNotifications;
  final List<CampaignModule> highlightedModules;
  final List<CampaignModule> newlyUnlockedModules;
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
    final List<StateChangeNotification>? transientNotifications,
    final List<CampaignModule>? highlightedModules,
    final List<CampaignModule>? newlyUnlockedModules,
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
    transientNotifications:
        transientNotifications ?? this.transientNotifications,
    highlightedModules: highlightedModules ?? this.highlightedModules,
    newlyUnlockedModules: newlyUnlockedModules ?? this.newlyUnlockedModules,
    clearInputRevision: clearInputRevision ?? this.clearInputRevision,
  );
}

class ChatController extends StateNotifier<ChatViewState> {
  ChatController(this._ref, this._campaignId)
    : super(const ChatViewState.initial());

  final Ref _ref;
  final String _campaignId;

  CancelToken? _cancelToken;
  Timer? _notificationTimer;
  String? _activeFlowId;
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
    AppLogger.logDiagnostic(
      level: 'INFO',
      event: 'chat_controller_dispose',
      message: 'ChatController disposed',
      flowId: _activeFlowId,
      campaignId: _campaignId,
      screenMounted: false,
    );
    _disposed = true;
    _cancelToken?.cancel();
    _notificationTimer?.cancel();
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
    final String triggerSource = 'manual',
  }) async {
    final CampaignState? campaign = state.campaign;
    if (campaign == null) {
      return;
    }

    if (state.isSending || _cancelToken != null) {
      AppLogger.logDiagnostic(
        level: 'WARN',
        event: 'turn_reentry_blocked',
        message: 'Ignored duplicate runTurn while another turn is active.',
        flowId: _activeFlowId,
        campaignId: campaign.id,
        triggerSource: triggerSource,
        requestMode: 'controller',
        screenMounted: !_disposed,
      );
      return;
    }

    final String trimmedAction = isIntro ? '' : action.trim();
    if (!suggestionsOnly && !isIntro && trimmedAction.isEmpty) {
      if (l10n != null && !_disposed) {
        state = state.copyWith(status: l10n.actionRequired);
      }
      return;
    }

    final AppLanguage language = _appLanguage;
    final DeterministicTurnContext deterministicContext =
        suggestionsOnly || isIntro
        ? const DeterministicTurnContext.none()
        : _gameEngine.resolveDeterministicTurn(
            language: language,
            state: campaign,
            playerAction: trimmedAction,
          );

    final CancelToken cancelToken = CancelToken();
    final DateTime now = DateTime.now();
    final String flowId = '${campaign.id}-${now.microsecondsSinceEpoch}';
    final AiRequestMetadata metadata = AiRequestMetadata(
      flowId: flowId,
      campaignId: campaign.id,
      triggerSource: triggerSource,
      screenMounted: !_disposed,
    );
    _cancelToken = cancelToken;
    _activeFlowId = flowId;

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
    AppLogger.logDiagnostic(
      level: 'INFO',
      event: 'turn_started',
      message: 'Turn generation started.',
      flowId: flowId,
      campaignId: campaign.id,
      triggerSource: triggerSource,
      requestMode: suggestionsOnly ? 'suggestions' : 'controller',
      screenMounted: !_disposed,
    );

    try {
      final AiSettings settings = await _settingsRepository.loadAiSettings();
      final AiClient client = _aiServiceFactory.create(settings);
      final TurnResult result = await client.generateTurn(
        settings: settings,
        language: language,
        state: campaign,
        playerAction: trimmedAction,
        suggestionsOnly: suggestionsOnly,
        deterministicContext: deterministicContext,
        metadata: metadata,
        onNarrationDelta: suggestionsOnly
            ? null
            : (final narration) =>
                  _updatePendingNarration(narration: narration, createdAt: now),
        cancelToken: cancelToken,
      );

      final TurnApplicationResult turnApplication;
      if (suggestionsOnly) {
        final CampaignState nextState = campaign.copyWith(
          choices: result.choices,
          memory: campaign.memory.copyWith(activeSituation: result.narration),
          updatedAt: DateTime.now(),
        );
        turnApplication = TurnApplicationResult(
          state: nextState,
          notifications: const <StateChangeNotification>[],
        );
      } else {
        turnApplication = _gameEngine.applyTurn(
          language: language,
          state: campaign,
          playerAction: trimmedAction,
          result: result,
          contextWindowSize: settings.contextWindowSize,
          deterministicContext: deterministicContext,
        );
      }

      await _campaignRepository.saveCampaign(turnApplication.state);

      if (_disposed) {
        return;
      }

      _showTransientNotifications(
        notifications: turnApplication.notifications,
        previousCampaign: campaign,
        nextCampaign: turnApplication.state,
      );
      state = state.copyWith(
        campaign: turnApplication.state,
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
      AppLogger.logDiagnostic(
        level: 'INFO',
        event: 'turn_completed',
        message: 'Turn generation completed.',
        flowId: flowId,
        campaignId: campaign.id,
        triggerSource: triggerSource,
        requestMode: suggestionsOnly ? 'suggestions' : 'controller',
        screenMounted: !_disposed,
      );
      _cancelToken = null;
      _activeFlowId = null;
    } on AiTurnException catch (error) {
      _clearPendingMessages();
      AppLogger.logDiagnostic(
        level: 'ERROR',
        event: 'turn_failed',
        message: error.userMessage,
        flowId: flowId,
        campaignId: campaign.id,
        triggerSource: triggerSource,
        requestMode: suggestionsOnly ? 'suggestions' : 'controller',
        screenMounted: !_disposed,
      );
      await _handleAiTurnException(error, l10n);
      _activeFlowId = null;
    } catch (error) {
      if (_disposed) {
        return;
      }
      final bool wasCancelled = error is AiCancelException;
      AppLogger.logDiagnostic(
        level: wasCancelled ? 'INFO' : 'ERROR',
        event: wasCancelled ? 'turn_cancelled' : 'turn_unexpected_error',
        message: wasCancelled ? 'Generation cancelled.' : error.toString(),
        flowId: flowId,
        campaignId: campaign.id,
        triggerSource: triggerSource,
        requestMode: suggestionsOnly ? 'suggestions' : 'controller',
        screenMounted: !_disposed,
      );
      _cancelToken = null;
      _activeFlowId = null;
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
    // Some providers stream speculative text that gets revised mid-generation.
    // Keep the UI on a stable "generating" placeholder until the final turn lands.
    if (_disposed || narration.trim().isEmpty) {
      return;
    }
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

  void _showTransientNotifications({
    required final List<StateChangeNotification> notifications,
    required final CampaignState previousCampaign,
    required final CampaignState nextCampaign,
  }) {
    _notificationTimer?.cancel();
    final List<CampaignModule> highlightedModules = _deriveHighlightedModules(
      previousCampaign: previousCampaign,
      nextCampaign: nextCampaign,
    );
    final List<CampaignModule> newlyUnlockedModules =
        _deriveNewlyUnlockedModules(
          previousCampaign: previousCampaign,
          nextCampaign: nextCampaign,
        );
    final bool hasVisualFeedback =
        notifications.isNotEmpty || highlightedModules.isNotEmpty;
    if (_disposed || !hasVisualFeedback) {
      if (!_disposed) {
        state = state.copyWith(
          transientNotifications: const <StateChangeNotification>[],
          highlightedModules: const <CampaignModule>[],
          newlyUnlockedModules: const <CampaignModule>[],
        );
      }
      return;
    }

    state = state.copyWith(
      transientNotifications: notifications.take(2).toList(),
      highlightedModules: highlightedModules,
      newlyUnlockedModules: newlyUnlockedModules,
    );
    _notificationTimer = Timer(const Duration(seconds: 3), () {
      if (_disposed) {
        return;
      }
      state = state.copyWith(
        transientNotifications: const <StateChangeNotification>[],
        highlightedModules: const <CampaignModule>[],
        newlyUnlockedModules: const <CampaignModule>[],
      );
    });
  }

  List<CampaignModule> _deriveHighlightedModules({
    required final CampaignState previousCampaign,
    required final CampaignState nextCampaign,
  }) {
    final List<CampaignModule> highlighted = <CampaignModule>[];

    void addIfChanged(final CampaignModule module, final bool changed) {
      if (changed && !highlighted.contains(module)) {
        highlighted.add(module);
      }
    }

    addIfChanged(
      CampaignModule.vitality,
      previousCampaign.character.hp != nextCampaign.character.hp ||
          previousCampaign.character.energy != nextCampaign.character.energy,
    );
    addIfChanged(
      CampaignModule.inventory,
      !_sameStringList(previousCampaign.inventory, nextCampaign.inventory),
    );
    addIfChanged(
      CampaignModule.notes,
      !_sameStringList(previousCampaign.notes, nextCampaign.notes),
    );
    addIfChanged(
      CampaignModule.companions,
      !_sameCompanionList(previousCampaign.companions, nextCampaign.companions),
    );
    addIfChanged(
      CampaignModule.resources,
      !_sameResourceList(previousCampaign.resources, nextCampaign.resources),
    );
    addIfChanged(
      CampaignModule.progression,
      !_sameProgression(previousCampaign.progression, nextCampaign.progression),
    );
    addIfChanged(
      CampaignModule.checks,
      !_sameCheckList(previousCampaign.checks, nextCampaign.checks),
    );

    return highlighted;
  }

  List<CampaignModule> _deriveNewlyUnlockedModules({
    required final CampaignState previousCampaign,
    required final CampaignState nextCampaign,
  }) {
    final List<CampaignModule> unlocked = <CampaignModule>[];
    for (final CampaignModule module in nextCampaign.activeModules) {
      if (!previousCampaign.isModuleActive(module)) {
        unlocked.add(module);
      }
    }
    return unlocked;
  }

  bool _sameStringList(final List<String> left, final List<String> right) {
    if (identical(left, right)) {
      return true;
    }
    if (left.length != right.length) {
      return false;
    }
    for (int index = 0; index < left.length; index += 1) {
      if (left[index] != right[index]) {
        return false;
      }
    }
    return true;
  }

  bool _sameCompanionList(
    final List<CampaignCompanion> left,
    final List<CampaignCompanion> right,
  ) {
    if (identical(left, right)) {
      return true;
    }
    if (left.length != right.length) {
      return false;
    }
    for (int index = 0; index < left.length; index += 1) {
      if (left[index].id != right[index].id ||
          left[index].name != right[index].name ||
          left[index].status != right[index].status ||
          left[index].notes != right[index].notes) {
        return false;
      }
    }
    return true;
  }

  bool _sameResourceList(
    final List<CampaignResource> left,
    final List<CampaignResource> right,
  ) {
    if (identical(left, right)) {
      return true;
    }
    if (left.length != right.length) {
      return false;
    }
    for (int index = 0; index < left.length; index += 1) {
      if (left[index].id != right[index].id ||
          left[index].label != right[index].label ||
          left[index].value != right[index].value ||
          left[index].maxValue != right[index].maxValue) {
        return false;
      }
    }
    return true;
  }

  bool _sameProgression(
    final CampaignProgression? left,
    final CampaignProgression? right,
  ) {
    if (left == null || right == null) {
      return left == right;
    }
    return left.level == right.level &&
        left.experience == right.experience &&
        left.rank == right.rank;
  }

  bool _sameCheckList(
    final List<CampaignCheck> left,
    final List<CampaignCheck> right,
  ) {
    if (identical(left, right)) {
      return true;
    }
    if (left.length != right.length) {
      return false;
    }
    for (int index = 0; index < left.length; index += 1) {
      if (left[index].id != right[index].id ||
          left[index].label != right[index].label ||
          left[index].summary != right[index].summary ||
          left[index].outcome != right[index].outcome ||
          left[index].stat != right[index].stat ||
          left[index].difficulty != right[index].difficulty ||
          left[index].roll != right[index].roll ||
          left[index].total != right[index].total) {
        return false;
      }
    }
    return true;
  }
}
