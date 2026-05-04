import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/features/chat/application/chat_controller.dart';
import 'package:ai_prg/src/features/chat/widgets/overlay_choice_stack.dart';
import 'package:ai_prg/src/features/chat/widgets/state_change_overlay_stack.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatBody extends ConsumerWidget {
  const ChatBody({
    required this.campaignId,
    required this.scrollController,
    required this.onChoiceSelected,
    super.key,
  });

  final String campaignId;
  final ScrollController scrollController;
  final void Function(String choice) onChoiceSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final responsive = context.responsive;
    final chatState = ref.watch(chatControllerProvider(campaignId));
    final visibleMessages = chatState.visibleMessages;
    final campaign = chatState.campaign;
    final isSending = chatState.isSending;
    final screenWidth = responsive.width;
    final isNarrow = responsive.isCompact;

    if (campaign == null) return const SizedBox.shrink();

    return Stack(
      children: <Widget>[
        AetherCard(
          padding: EdgeInsets.all(isNarrow ? 8 : 14),
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.only(bottom: 6),
            itemCount:
                visibleMessages.length +
                (campaign.choices.isNotEmpty && !responsive.isPhoneSmall ? 1 : 0),
            itemBuilder: (_, index) {
              if (index == visibleMessages.length) {
                return IgnorePointer(
                  ignoring: isSending,
                  child: OverlayChoiceStack(
                    choices: campaign.choices.take(3).toList(),
                    onChoiceSelected: onChoiceSelected,
                    enabled: !isSending,
                  ),
                );
              }

              final message = visibleMessages[index];
              final isPlayer = message.role == ChatRole.player;
              final isSystem = message.role == ChatRole.system;
              final isPendingNarrator =
                  isSending &&
                  message.id == 'pending_narrator' &&
                  message.role == ChatRole.narrator;

              final semanticLabel = isSystem
                  ? l10n.chatNarratorLabel
                  : isPlayer
                  ? l10n.youLabel
                  : l10n.chatNarratorLabel;
              return Semantics(
                label: semanticLabel,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: index == visibleMessages.length - 1
                        ? 0
                        : (isNarrow ? 8 : 12),
                  ),
                  child: Align(
                  alignment: isPlayer
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isNarrow ? screenWidth * 0.9 : 680,
                    ),
                    padding: EdgeInsets.all(isNarrow ? 10 : 16),
                    decoration: BoxDecoration(
                      color: isPlayer
                          ? AetherPalette.accent.withValues(alpha: 0.10)
                          : isSystem
                          ? AetherPalette.panelSoft.withValues(alpha: 0.95)
                          : isPendingNarrator
                          ? AetherPalette.backgroundElevated.withValues(alpha: 0.98)
                          : AetherPalette.backgroundElevated.withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(isNarrow ? 14 : 16),
                      border: Border.all(
                        color: isPlayer
                            ? AetherPalette.accent.withValues(alpha: 0.32)
                            : isPendingNarrator
                            ? AetherPalette.accent.withValues(alpha: 0.22)
                            : AetherPalette.panelBorderSolid,
                      ),
                      boxShadow: isPendingNarrator
                          ? <BoxShadow>[
                              BoxShadow(
                                color: AetherPalette.accent.withValues(alpha: 0.12),
                                blurRadius: 22,
                                spreadRadius: -8,
                                offset: const Offset(0, 10),
                              ),
                            ]
                          : const <BoxShadow>[],
                    ),
                    child: isPendingNarrator
                        ? _StreamingNarrationContent(
                            text: message.text,
                            placeholder: l10n.generatingResponse,
                            isNarrow: isNarrow,
                          )
                        : message.role == ChatRole.narrator
                        ? _AnimatedNarrationMessage(
                            key: ValueKey<String>(message.id),
                            text: message.text,
                            isNarrow: isNarrow,
                          )
                        : Text(
                            message.text,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isSystem
                                  ? AetherPalette.textMuted
                                  : isPlayer
                                  ? AetherPalette.accentHover
                                  : AetherPalette.textPrimary,
                              fontSize: isNarrow ? 14 : 16,
                            ),
                          ),
                  ),
                ),
              ),
              );
            },
          ),
        ),
        StateChangeOverlayStack(
          notifications: chatState.transientNotifications,
        ),
      ],
    );
  }
}

class _StreamingNarrationContent extends StatelessWidget {
  const _StreamingNarrationContent({
    required this.text,
    required this.placeholder,
    required this.isNarrow,
  });

  final String text;
  final String placeholder;
  final bool isNarrow;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final resolvedText = text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.auto_awesome_rounded,
              size: isNarrow ? 14 : 16,
              color: AetherPalette.accent,
            ),
            const SizedBox(width: 8),
            Text(
              placeholder,
              style: textTheme.labelLarge?.copyWith(
                color: AetherPalette.accent.withValues(alpha: 0.92),
                fontSize: isNarrow ? 11 : 12,
                letterSpacing: 0.9,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          resolvedText.isEmpty ? placeholder : resolvedText,
          style: textTheme.bodyLarge?.copyWith(
            color: resolvedText.isEmpty
                ? AetherPalette.textMuted
                : AetherPalette.narrativeText,
            fontSize: isNarrow ? 15 : 17,
            height: 1.75,
            fontWeight: FontWeight.w400,
          ),
          strutStyle: StrutStyle(
            fontSize: isNarrow ? 15 : 17,
            height: 1.75,
            forceStrutHeight: true,
          ),
        ),
        const SizedBox(height: 10),
        const _TypingPulseIndicator(),
      ],
    );
  }
}

class _AnimatedNarrationMessage extends StatefulWidget {
  const _AnimatedNarrationMessage({
    required this.text,
    required this.isNarrow,
    super.key,
  });

  final String text;
  final bool isNarrow;

  @override
  State<_AnimatedNarrationMessage> createState() =>
      _AnimatedNarrationMessageState();
}

class _AnimatedNarrationMessageState extends State<_AnimatedNarrationMessage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeText = Theme.of(context).textTheme;
    final baseStyle = themeText.bodyLarge ?? themeText.bodyMedium ?? const TextStyle();
    final style = baseStyle.copyWith(
      color: AetherPalette.narrativeText,
      fontSize: widget.isNarrow ? 15 : 17,
      height: 1.75,
      fontWeight: FontWeight.w400,
    );

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.12, 1.0, curve: Curves.easeOutCubic),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.018),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: Text(
          widget.text,
          style: style,
          strutStyle: StrutStyle(
            fontSize: widget.isNarrow ? 15 : 17,
            height: 1.75,
            forceStrutHeight: true,
          ),
        ),
      ),
    );
  }
}

class _TypingPulseIndicator extends StatefulWidget {
  const _TypingPulseIndicator();

  @override
  State<_TypingPulseIndicator> createState() => _TypingPulseIndicatorState();
}

class _TypingPulseIndicatorState extends State<_TypingPulseIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1100),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return RepaintBoundary(
        child: SizedBox(
          width: 34,
          height: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(3, (_) => Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AetherPalette.accent.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(999),
              ),
            )),
          ),
        ),
      );
    }
    return RepaintBoundary(
      child: SizedBox(
        width: 34,
        height: 12,
        child: AnimatedBuilder(
          animation: _controller!,
          builder: (_, __) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(3, (index) {
              final phase = _wrappedPhase(_controller!.value - (index * 0.16));
              final intensity = (1 - ((phase * 2) - 1).abs()).clamp(0.2, 1.0);

              return Container(
                width: 6,
                height: 6 + (2 * intensity),
                decoration: BoxDecoration(
                  color: AetherPalette.accent.withValues(
                    alpha: 0.35 + (0.55 * intensity),
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  double _wrappedPhase(double value) {
    if (value >= 0) return value % 1.0;
    return 1.0 - ((-value) % 1.0);
  }
}
