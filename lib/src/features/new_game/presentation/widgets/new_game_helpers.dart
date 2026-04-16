import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel({required this.title, super.key});

  final String title;

  @override
  Widget build(final BuildContext context) => Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AetherPalette.textMuted,
              letterSpacing: context.responsive.scaleLetterSpacing(2),
            ),
      );
}

class ModeCard extends StatelessWidget {
  const ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => AetherCard(
        padding: EdgeInsets.all(context.responsive.cardPadding),
        child: SizedBox(
          width: double.infinity,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: context.responsive.isCompact ? 82 : 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    icon,
                    color: AetherPalette.accent,
                    size: context.responsive.isCompact ? 28 : 32,
                  ),
                  SizedBox(height: context.responsive.sectionSpacing),
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AetherPalette.textMuted,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

/// Horizontal progress segments (like in the "World Creation" mockup).
class WizardSegmentProgress extends StatelessWidget {
  const WizardSegmentProgress({
    required this.currentIndex,
    required this.segmentCount,
    super.key,
  });

  final int currentIndex;
  final int segmentCount;

  @override
  Widget build(final BuildContext context) => Row(
        children: List<Widget>.generate(segmentCount, (index) {
          final bool filled = index <= currentIndex;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == segmentCount - 1 ? 0 : 6,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: filled
                      ? AetherPalette.accent
                      : AetherPalette.panelSoft,
                ),
              ),
            ),
          );
        }),
      );
}

class WizardCircleIconButton extends StatelessWidget {
  const WizardCircleIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(final BuildContext context) {
    final Widget child = Material(
      color: AetherPalette.backgroundElevated,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            size: 22,
            color: AetherPalette.textPrimary,
          ),
        ),
      ),
    );
    if (tooltip == null) {
      return child;
    }
    return Tooltip(message: tooltip!, child: child);
  }
}

class GenreSelectPill extends StatelessWidget {
  const GenreSelectPill({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AetherPalette.backgroundElevated.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? AetherPalette.accent
                    : AetherPalette.panelBorderSolid,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (selected) ...<Widget>[
                  const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AetherPalette.accent,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: selected
                            ? AetherPalette.textPrimary
                            : AetherPalette.textMuted,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
}

class ReviewItem extends StatelessWidget {
  const ReviewItem({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(final BuildContext context) {
    final AppResponsiveData responsive = context.responsive;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 18, color: AetherPalette.textMuted),
        SizedBox(width: responsive.isCompact ? 10 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AetherPalette.textMuted,
                    ),
              ),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
