import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:flutter/material.dart';

/// Стек плавающих кнопок выбора справа от текста.
/// Стиль — pill/chip как в JS-макете; позиция внутри чата не меняется.
class OverlayChoiceStack extends StatelessWidget {
  const OverlayChoiceStack({
    required this.choices,
    required this.onChoiceSelected,
    this.enabled = true,
    super.key,
  });

  final List<String> choices;
  final void Function(String) onChoiceSelected;
  final bool enabled;

  @override
  Widget build(final BuildContext context) {
    if (choices.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Widget> buttons = <Widget>[];

    for (int i = 0; i < choices.length; i++) {
      buttons.add(
        OverlayChoiceButton(
          label: choices[i],
          onPressed: enabled ? () => onChoiceSelected(choices[i]) : null,
          index: i,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: buttons,
        ),
      ),
    );
  }
}

class OverlayChoiceButton extends StatefulWidget {
  const OverlayChoiceButton({
    required this.label,
    required this.onPressed,
    required this.index,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final int index;

  @override
  State<OverlayChoiceButton> createState() => _OverlayChoiceButtonState();
}

class _OverlayChoiceButtonState extends State<OverlayChoiceButton> {
  bool _hover = false;

  @override
  Widget build(final BuildContext context) {
    final bool isEnabled = widget.onPressed != null;
    final AppResponsiveData responsive = context.responsive;
    final Color borderColor = !isEnabled
        ? AetherPalette.panelBorderSolid.withValues(alpha: 0.35)
        : _hover
        ? AetherPalette.accent.withValues(alpha: 0.35)
        : AetherPalette.panelBorderSolid;
    final Color fg = !isEnabled
        ? AetherPalette.textMuted.withValues(alpha: 0.45)
        : _hover
        ? AetherPalette.accentHover
        : AetherPalette.textMuted;
    const Color bg = AetherPalette.backgroundElevated;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: responsive.overlayMaxWidth,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                constraints: BoxConstraints(
                  minHeight: responsive.isCompact ? 38 : 42,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.isCompact ? 14 : 16,
                  vertical: responsive.isCompact ? 9 : 10,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: responsive.isCompact ? 12 : 13,
                          fontWeight: FontWeight.w500,
                          color: fg,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: fg,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
