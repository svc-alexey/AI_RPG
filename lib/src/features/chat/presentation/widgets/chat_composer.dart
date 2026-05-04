import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/features/chat/application/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatComposer extends ConsumerStatefulWidget {
  const ChatComposer({
    required this.campaignId,
    required this.inputController,
    required this.composerFocusNode,
    required this.onSubmit,
    super.key,
  });

  final String campaignId;
  final TextEditingController inputController;
  final FocusNode composerFocusNode;
  final VoidCallback onSubmit;

  @override
  ConsumerState<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends ConsumerState<ChatComposer> {
  @override
  void initState() {
    super.initState();
    widget.composerFocusNode.onKeyEvent = _onKeyEvent;
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (!mounted) return KeyEventResult.ignored;

    final isSending = ref.read(
      chatControllerProvider(widget.campaignId).select((c) => c.isSending),
    );
    if (isSending) return KeyEventResult.ignored;
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final isEnter = event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;
    if (!isEnter) return KeyEventResult.ignored;
    if (HardwareKeyboard.instance.isShiftPressed) return KeyEventResult.ignored;

    widget.onSubmit();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final responsive = context.responsive;
    final isSending = ref.watch(
      chatControllerProvider(widget.campaignId).select((c) => c.isSending),
    );
    final controller = ref.read(chatControllerProvider(widget.campaignId).notifier);
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final isNarrow = responsive.isCompact;
    final compactMobileComposer = responsive.isPhoneSmall && keyboardVisible;

    return Container(
      decoration: BoxDecoration(
        color: AetherPalette.backgroundElevated,
        borderRadius: BorderRadius.circular(isNarrow ? 12 : 14),
        border: Border.all(color: AetherPalette.panelBorderSolid),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? (compactMobileComposer ? 6 : 8) : 10,
        vertical: isNarrow ? (compactMobileComposer ? 3 : 5) : 6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 2,
            child: isSending
                ? const LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AetherPalette.accent,
                    ),
                  )
                : null,
          ),
          if (responsive.isPhoneSmall)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildTextField(
                  maxLines: compactMobileComposer ? 3 : 4,
                  decoration: const InputDecoration(
                    hintText: '',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ).copyWith(hintText: l10n.chatInputHint),
                ),
                SizedBox(height: compactMobileComposer ? 4 : 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: isSending
                      ? TextButton(
                          onPressed: controller.cancelGeneration,
                          child: Text(l10n.cancel),
                        )
                      : IconButton.filled(
                          onPressed: widget.onSubmit,
                          icon: const Icon(Icons.send_rounded),
                          tooltip: l10n.send,
                        ),
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: _buildTextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: l10n.chatInputHint,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: responsive.isCompact ? 12 : 14,
                        vertical: responsive.isCompact ? 8 : 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isSending)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextButton(
                        onPressed: controller.cancelGeneration,
                        child: Text(l10n.cancel),
                      ),
                    ],
                  )
                else
                  IconButton.filled(
                    onPressed: widget.onSubmit,
                    icon: const Icon(Icons.send_rounded),
                    tooltip: l10n.send,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required int maxLines,
    required InputDecoration decoration,
  }) => TextField(
    controller: widget.inputController,
    focusNode: widget.composerFocusNode,
    minLines: 1,
    maxLines: maxLines,
    textInputAction: TextInputAction.newline,
    onSubmitted: (_) => widget.onSubmit(),
    decoration: decoration,
  );
}
