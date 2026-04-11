import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final updateGateControllerProvider =
    StateNotifierProvider<UpdateGateController, UpdateGateState>(
      (final ref) => UpdateGateController(ref),
    );

class UpdateGateState {
  const UpdateGateState({
    required this.isChecking,
    required this.platformInfo,
    required this.dismissedSoftPrompt,
  });

  const UpdateGateState.initial()
    : isChecking = false,
      platformInfo = null,
      dismissedSoftPrompt = false;

  final bool isChecking;
  final SymmetryVersionPlatformInfo? platformInfo;
  final bool dismissedSoftPrompt;

  bool get shouldBlock {
    final SymmetryVersionPlatformInfo? info = platformInfo;
    if (info == null) {
      return false;
    }
    return info.updateMode == SymmetryUpdateMode.force ||
        (kIsWeb && info.reloadRequired);
  }

  bool get shouldShowPrompt {
    final SymmetryVersionPlatformInfo? info = platformInfo;
    if (info == null) {
      return false;
    }
    if (shouldBlock) {
      return true;
    }
    return info.updateMode == SymmetryUpdateMode.soft && !dismissedSoftPrompt;
  }

  UpdateGateState copyWith({
    final bool? isChecking,
    final SymmetryVersionPlatformInfo? platformInfo,
    final bool? dismissedSoftPrompt,
  }) => UpdateGateState(
    isChecking: isChecking ?? this.isChecking,
    platformInfo: platformInfo ?? this.platformInfo,
    dismissedSoftPrompt: dismissedSoftPrompt ?? this.dismissedSoftPrompt,
  );
}

class UpdateGateController extends StateNotifier<UpdateGateState> {
  UpdateGateController(this._ref) : super(const UpdateGateState.initial());

  final Ref _ref;
  bool _didCheck = false;

  Future<void> checkForUpdates() async {
    if (_didCheck) {
      return;
    }
    _didCheck = true;
    state = state.copyWith(isChecking: true);
    try {
      final SymmetryVersionPlatformInfo info = await _ref
          .read(versionCheckServiceProvider)
          .checkCurrentPlatform();
      state = state.copyWith(
        isChecking: false,
        platformInfo: info,
        dismissedSoftPrompt: false,
      );
    } catch (_) {
      state = state.copyWith(isChecking: false);
    }
  }

  void dismissSoftPrompt() {
    final SymmetryVersionPlatformInfo? info = state.platformInfo;
    if (info == null || info.updateMode != SymmetryUpdateMode.soft) {
      return;
    }
    state = state.copyWith(dismissedSoftPrompt: true);
  }
}
