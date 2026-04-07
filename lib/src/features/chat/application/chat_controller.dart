import 'dart:async';

import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/repositories/settings_repository.dart';
import 'package:ai_prg/src/core/repositories/symmetry_campaign_repository.dart';
import 'package:ai_prg/src/core/services/ai_client.dart' show AiTurnException;
import 'package:ai_prg/src/core/services/app_logger.dart';
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
    required this.worldRumors,
    required this.clearInputRevision,
  });

  ChatViewState.initial()
    : isLoading = true,
      isSending = false,
      campaign = null,
      settings = AiSettings.withEnvFallbacks(const AiSettings.defaults()),
      status = null,
      pendingPlayerMessage = null,
      pendingNarratorMessage = null,
      transientNotifications = const <StateChangeNotification>[],
      highlightedModules = const <CampaignModule>[],
      newlyUnlockedModules = const <CampaignModule>[],
      worldRumors = const <SymmetryWorldRumor>[],
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
  final List<SymmetryWorldRumor> worldRumors;
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
    final List<SymmetryWorldRumor>? worldRumors,
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
    worldRumors: worldRumors ?? this.worldRumors,
    clearInputRevision: clearInputRevision ?? this.clearInputRevision,
  );
}

class ChatController extends StateNotifier<ChatViewState> {
  ChatController(this._ref, this._campaignId) : super(ChatViewState.initial());

  final Ref _ref;
  final String _campaignId;

  Timer? _notificationTimer;
  Timer? _rumorRefreshTimer;
  String? _activeFlowId;
  bool _didLoad = false;
  bool _disposed = false;

  SymmetryCampaignRepository get _campaignRepository =>
      _ref.read(symmetryCampaignRepositoryProvider);

  SettingsRepository get _settingsRepository =>
      _ref.read(settingsRepositoryProvider);

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
    _notificationTimer?.cancel();
    _rumorRefreshTimer?.cancel();
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
    final List<SymmetryWorldRumor> worldRumors = campaign == null
        ? const <SymmetryWorldRumor>[]
        : await _safeLoadRumors(_campaignId);
    final AiSettings settings = await _settingsRepository.loadAiSettings();

    if (_disposed) {
      return;
    }

    state = state.copyWith(
      campaign: campaign,
      settings: settings,
      worldRumors: worldRumors,
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

  void cancelGeneration() {}

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

    if (state.isSending) {
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
    final DateTime now = DateTime.now();
    final String flowId = '${campaign.id}-${now.microsecondsSinceEpoch}';
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
      final CampaignState nextCampaign = await _campaignRepository.processTurn(
        playerAction: trimmedAction,
        language: language,
        campaign: campaign,
        aiSettings: settings,
        triggerSource: triggerSource,
      );

      if (_disposed) {
        return;
      }
      final List<SymmetryWorldRumor> worldRumors = await _safeLoadRumors(
        nextCampaign.id,
      );

      _showTransientNotifications(
        notifications: _buildNotificationsFromCampaignDiff(
          previousCampaign: campaign,
          nextCampaign: nextCampaign,
          language: language,
        ),
        previousCampaign: campaign,
        nextCampaign: nextCampaign,
      );
      state = state.copyWith(
        campaign: nextCampaign,
        settings: settings,
        worldRumors: worldRumors,
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
      _scheduleRumorRefresh(nextCampaign.id);
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
      _activeFlowId = null;
      state = state.copyWith(
        isSending: false,
        pendingPlayerMessage: null,
        pendingNarratorMessage: null,
        status: error.userMessage,
      );
    } catch (error) {
      if (_disposed) {
        return;
      }
      AppLogger.logDiagnostic(
        level: 'ERROR',
        event: 'turn_unexpected_error',
        message: error.toString(),
        flowId: flowId,
        campaignId: campaign.id,
        triggerSource: triggerSource,
        requestMode: suggestionsOnly ? 'suggestions' : 'controller',
        screenMounted: !_disposed,
      );
      _activeFlowId = null;
      state = state.copyWith(
        isSending: false,
        pendingPlayerMessage: null,
        pendingNarratorMessage: null,
        status: l10n?.turnError(error),
      );
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

  void _scheduleRumorRefresh(final String campaignId) {
    _rumorRefreshTimer?.cancel();
    _rumorRefreshTimer = Timer(const Duration(seconds: 2), () async {
      if (_disposed) {
        return;
      }
      try {
        final List<SymmetryWorldRumor> worldRumors = await _safeLoadRumors(
          campaignId,
        );
        if (_disposed) {
          return;
        }
        state = state.copyWith(worldRumors: worldRumors);
      } catch (_) {}
    });
  }

  Future<List<SymmetryWorldRumor>> _safeLoadRumors(
    final String campaignId,
  ) async {
    try {
      return await _campaignRepository.loadCampaignRumors(campaignId);
    } catch (_) {
      return const <SymmetryWorldRumor>[];
    }
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

  List<StateChangeNotification> _buildNotificationsFromCampaignDiff({
    required final CampaignState previousCampaign,
    required final CampaignState nextCampaign,
    required final AppLanguage language,
  }) {
    final List<StateChangeNotification> notifications =
        <StateChangeNotification>[];
    final DateTime now = DateTime.now();

    for (final String item in nextCampaign.inventory.where(
      (final candidate) => !previousCampaign.inventory.contains(candidate),
    )) {
      notifications.add(
        StateChangeNotification(
          id: 'item_add_${item}_${now.microsecondsSinceEpoch}',
          kind: StateChangeNotificationKind.itemAdded,
          message: '+ $item',
        ),
      );
    }

    for (final String item in previousCampaign.inventory.where(
      (final candidate) => !nextCampaign.inventory.contains(candidate),
    )) {
      notifications.add(
        StateChangeNotification(
          id: 'item_remove_${item}_${now.microsecondsSinceEpoch}',
          kind: StateChangeNotificationKind.itemRemoved,
          message: '- $item',
        ),
      );
    }

    final int hpDelta =
        nextCampaign.character.hp - previousCampaign.character.hp;
    final int energyDelta =
        nextCampaign.character.energy - previousCampaign.character.energy;
    if (hpDelta != 0 || energyDelta != 0) {
      final List<String> parts = <String>[
        if (hpDelta != 0) 'HP ${_signed(hpDelta)}',
        if (energyDelta != 0)
          language == AppLanguage.ru
              ? 'Энергия ${_signed(energyDelta)}'
              : 'Energy ${_signed(energyDelta)}',
      ];
      notifications.add(
        StateChangeNotification(
          id: 'vitality_${now.microsecondsSinceEpoch}',
          kind: StateChangeNotificationKind.vitalityChanged,
          message: parts.join(' • '),
        ),
      );
    }

    final CampaignCheck? latestAddedCheck = nextCampaign.checks
        .cast<CampaignCheck?>()
        .firstWhere(
          (final item) =>
              item != null &&
              !previousCampaign.checks.any(
                (final previous) =>
                    previous.summary == item.summary &&
                    previous.outcome == item.outcome &&
                    previous.total == item.total &&
                    previous.difficulty == item.difficulty,
              ),
          orElse: () => null,
        );
    if (latestAddedCheck != null) {
      notifications.add(
        StateChangeNotification(
          id: 'check_${now.microsecondsSinceEpoch}',
          kind: StateChangeNotificationKind.checkResolved,
          message: latestAddedCheck.summary,
        ),
      );
    }

    final CampaignCompanion? latestCompanion = nextCampaign.companions
        .cast<CampaignCompanion?>()
        .firstWhere(
          (final item) =>
              item != null &&
              !previousCampaign.companions.any(
                (final previous) =>
                    previous.name.toLowerCase() == item.name.toLowerCase(),
              ),
          orElse: () => null,
        );
    if (latestCompanion != null) {
      notifications.add(
        StateChangeNotification(
          id: 'companion_${latestCompanion.id}_${now.microsecondsSinceEpoch}',
          kind: StateChangeNotificationKind.companionJoined,
          message: language == AppLanguage.ru
              ? 'Спутник: ${latestCompanion.name} присоединяется'
              : 'Companion: ${latestCompanion.name} joins you',
        ),
      );
    }

    final String? latestNote = nextCampaign.notes.cast<String?>().firstWhere(
      (final item) => item != null && !previousCampaign.notes.contains(item),
      orElse: () => null,
    );
    if (latestNote != null && latestNote.trim().isNotEmpty) {
      notifications.add(
        StateChangeNotification(
          id: 'note_${now.microsecondsSinceEpoch}',
          kind: StateChangeNotificationKind.noteAdded,
          message: language == AppLanguage.ru
              ? 'Заметка: $latestNote'
              : 'Note: $latestNote',
        ),
      );
    }

    for (final CampaignModule module in _deriveNewlyUnlockedModules(
      previousCampaign: previousCampaign,
      nextCampaign: nextCampaign,
    )) {
      notifications.add(
        StateChangeNotification(
          id: 'module_${module.name}_${now.microsecondsSinceEpoch}',
          kind: StateChangeNotificationKind.moduleUnlocked,
          message: language == AppLanguage.ru
              ? 'Новая система: ${module.name}'
              : 'New system: ${module.name}',
        ),
      );
    }

    return notifications.take(4).toList();
  }

  String _signed(final int value) => value > 0 ? '+$value' : '$value';

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
