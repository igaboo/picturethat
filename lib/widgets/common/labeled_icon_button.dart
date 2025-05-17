import 'package:flutter/material.dart';
import 'package:picture_that/widgets/custom_animations.dart';

class LabeledIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final bool? isSelected;
  final Color? selectedColor;
  final IconData? selectedIcon;
  final String? label;
  final bool? enableAnimation;

  const LabeledIconButton({
    required this.onPressed,
    required this.icon,
    this.label,
    this.isSelected,
    this.selectedColor,
    this.selectedIcon,
    this.enableAnimation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final currentTargetKey = isSelected == true
        ? const ValueKey("selectedIcon")
        : const ValueKey("unselectedIcon");
    const duration = Duration(milliseconds: 400);

    return Row(
      children: [
        IconButton(
          style: ButtonStyle(visualDensity: VisualDensity.compact),
          onPressed: onPressed,
          icon: AnimatedSwitcher(
            reverseDuration: const Duration(milliseconds: 100),
            duration: duration,
            transitionBuilder: (child, animation) {
              final bool isIncoming = child.key == currentTargetKey;

              if (isIncoming) {
                if (isSelected == true) {
                  return HopRotateTransition(
                    animation: animation,
                    child: child,
                  );
                } else {
                  return FadeTransition(opacity: animation, child: child);
                }
              } else {
                return FadeTransition(opacity: animation, child: child);
              }
            },
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: isSelected == true
                ? Icon(
                    key: ValueKey("selectedIcon"),
                    selectedIcon ?? icon,
                    color: selectedColor ?? Colors.red)
                : Icon(
                    key: ValueKey("unselectedIcon"),
                    icon,
                    color: colorScheme.primary),
          ),
        ),
        if (label != null) Text(label!, style: textTheme.titleMedium),
      ],
    );
  }
}
