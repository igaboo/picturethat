import 'package:flutter/material.dart';

class LabeledIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final bool? isSelected;
  final Color? selectedColor;
  final IconData? selectedIcon;
  final String? label;

  const LabeledIconButton({
    required this.onPressed,
    required this.icon,
    this.label,
    this.isSelected,
    this.selectedColor,
    this.selectedIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        IconButton(
          style: ButtonStyle(visualDensity: VisualDensity.compact),
          onPressed: onPressed,
          icon: isSelected == true
              ? Icon(selectedIcon ?? icon, color: selectedColor ?? Colors.red)
              : Icon(icon, color: colorScheme.primary),
        ),
        if (label != null) Text(label!, style: textTheme.titleMedium),
      ],
    );
  }
}
