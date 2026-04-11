import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/features/update/application/update_gate_controller.dart';
import 'package:ai_prg/src/features/update/presentation/update_gate_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateGateOverlay extends ConsumerWidget {
  const UpdateGateOverlay({required this.child, super.key});

  final Widget child;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final UpdateGateState state = ref.watch(updateGateControllerProvider);
    final SymmetryVersionPlatformInfo? info = state.platformInfo;
    if (info == null || !state.shouldShowPrompt) {
      return child;
    }

    final AppLocalizations l10n = context.l10n;
    final bool reloadOnly = info.reloadRequired;
    final bool force = state.shouldBlock;
    final String versionLabel = info.latestVersion.trim().isEmpty
        ? l10n.updateUnknownVersion
        : info.latestVersion;

    return Stack(
      children: <Widget>[
        child,
        Positioned.fill(
          child: ColoredBox(
            color: Colors.black.withValues(alpha: 0.62),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  margin: const EdgeInsets.all(24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          force
                              ? l10n.updateRequiredTitle
                              : l10n.updateAvailableTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          force
                              ? l10n.updateRequiredBody(versionLabel)
                              : l10n.updateAvailableBody(versionLabel),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        if (info.message.trim().isNotEmpty) ...<Widget>[
                          const SizedBox(height: 12),
                          Text(
                            info.message,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            if (!force)
                              TextButton(
                                onPressed: () => ref
                                    .read(updateGateControllerProvider.notifier)
                                    .dismissSoftPrompt(),
                                child: Text(l10n.updateLaterAction),
                              ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () => triggerClientUpdate(
                                reloadOnly: reloadOnly,
                                updateUrl: info.updateUrl,
                              ),
                              child: Text(
                                reloadOnly
                                    ? l10n.reloadNowAction
                                    : l10n.updateNowAction,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
