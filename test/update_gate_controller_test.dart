import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/services/version_check_service.dart';
import 'package:ai_prg/src/features/update/application/update_gate_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('soft update can be dismissed after version check completes', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        versionCheckServiceProvider.overrideWithValue(
          const _FakeVersionCheckService(
            SymmetryVersionPlatformInfo(
              latestVersion: '1.1.0',
              minimumSupportedVersion: '1.0.0',
              updateMode: SymmetryUpdateMode.soft,
              message: 'Update available',
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final UpdateGateController controller = container.read(
      updateGateControllerProvider.notifier,
    );

    await controller.checkForUpdates();
    expect(
      container.read(updateGateControllerProvider).shouldShowPrompt,
      isTrue,
    );

    controller.dismissSoftPrompt();
    expect(
      container.read(updateGateControllerProvider).shouldShowPrompt,
      isFalse,
    );
  });
}

class _FakeVersionCheckService extends VersionCheckService {
  const _FakeVersionCheckService(this._info);

  final SymmetryVersionPlatformInfo _info;

  @override
  Future<SymmetryVersionPlatformInfo> checkCurrentPlatform() async => _info;
}
