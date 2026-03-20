import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:flutter/material.dart';

/// Стек плавающих кнопок выбора справа от текста.
/// Кнопки отображаются с прозрачным фоном и тонкой рамкой.
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
  Widget build(BuildContext context) {
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

/// Плавающая кнопка выбора с полупрозрачным фоном.
class OverlayChoiceButton extends StatelessWidget {
  const OverlayChoiceButton({
    required this.label,
    required this.onPressed,
    required this.index,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final int index;

  static const double _buttonPadding = 12.0;
  static const double _buttonMaxWidth = 180.0;
  static const double _buttonBorderRadius = 12.0;
  static const double _borderOpacity = 0.8;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(_buttonBorderRadius),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: _buttonMaxWidth,
              minHeight: 40,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: _buttonPadding,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(_buttonBorderRadius),
              border: Border.all(
                color: isEnabled
                    ? AetherPalette.accent.withValues(alpha: _borderOpacity)
                    : AetherPalette.panelBorder.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isEnabled
                              ? AetherPalette.textPrimary
                              : AetherPalette.textMuted.withValues(alpha: 0.5),
                        ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: isEnabled
                      ? AetherPalette.accent
                      : AetherPalette.textMuted.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
