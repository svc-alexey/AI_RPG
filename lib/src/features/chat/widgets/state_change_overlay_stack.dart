import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:flutter/material.dart';

class StateChangeOverlayStack extends StatelessWidget {
  const StateChangeOverlayStack({required this.notifications, super.key});

  final List<StateChangeNotification> notifications;

  @override
  Widget build(final BuildContext context) {
    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: notifications
                .map(
                  (final item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 220),
                      opacity: 1,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 220),
                        offset: Offset.zero,
                        child: _NotificationCard(notification: item),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final StateChangeNotification notification;

  @override
  Widget build(final BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 280),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: _backgroundColor(notification.kind),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: _accentColor(notification.kind).withValues(alpha: 0.55),
      ),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0x22000000),
          blurRadius: 18,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          _icon(notification.kind),
          size: 18,
          color: _accentColor(notification.kind),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            notification.message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AetherPalette.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Color _backgroundColor(final StateChangeNotificationKind kind) =>
      switch (kind) {
        StateChangeNotificationKind.itemAdded =>
          AetherPalette.accentSoft.withValues(alpha: 0.92),
        StateChangeNotificationKind.itemRemoved =>
          AetherPalette.panelSoft.withValues(alpha: 0.95),
        StateChangeNotificationKind.companionJoined =>
          AetherPalette.accentSoft.withValues(alpha: 0.92),
        StateChangeNotificationKind.noteAdded => AetherPalette.panel.withValues(
          alpha: 0.96,
        ),
        StateChangeNotificationKind.resourceChanged =>
          AetherPalette.accentSoft.withValues(alpha: 0.92),
        StateChangeNotificationKind.progressionChanged =>
          AetherPalette.panel.withValues(alpha: 0.98),
        StateChangeNotificationKind.vitalityChanged =>
          AetherPalette.panelSoft.withValues(alpha: 0.95),
        StateChangeNotificationKind.checkResolved =>
          AetherPalette.panel.withValues(alpha: 0.98),
        StateChangeNotificationKind.moduleUnlocked =>
          AetherPalette.panel.withValues(alpha: 0.98),
      };

  Color _accentColor(final StateChangeNotificationKind kind) => switch (kind) {
    StateChangeNotificationKind.itemAdded => AetherPalette.accent,
    StateChangeNotificationKind.itemRemoved => AetherPalette.textMuted,
    StateChangeNotificationKind.companionJoined => AetherPalette.accent,
    StateChangeNotificationKind.noteAdded => AetherPalette.textPrimary,
    StateChangeNotificationKind.resourceChanged => AetherPalette.accent,
    StateChangeNotificationKind.progressionChanged => AetherPalette.accent,
    StateChangeNotificationKind.vitalityChanged => AetherPalette.accent,
    StateChangeNotificationKind.checkResolved => AetherPalette.accent,
    StateChangeNotificationKind.moduleUnlocked => AetherPalette.accent,
  };

  IconData _icon(final StateChangeNotificationKind kind) => switch (kind) {
    StateChangeNotificationKind.itemAdded => Icons.add_circle_outline_rounded,
    StateChangeNotificationKind.itemRemoved =>
      Icons.remove_circle_outline_rounded,
    StateChangeNotificationKind.companionJoined => Icons.group_add_outlined,
    StateChangeNotificationKind.noteAdded => Icons.sticky_note_2_outlined,
    StateChangeNotificationKind.resourceChanged => Icons.toll_outlined,
    StateChangeNotificationKind.progressionChanged => Icons.trending_up_rounded,
    StateChangeNotificationKind.vitalityChanged =>
      Icons.favorite_border_rounded,
    StateChangeNotificationKind.checkResolved => Icons.casino_outlined,
    StateChangeNotificationKind.moduleUnlocked => Icons.auto_awesome_rounded,
  };
}
