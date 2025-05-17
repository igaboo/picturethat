import 'package:flutter/material.dart';
import 'package:picture_that/widgets/common/custom_button.dart';

typedef EmptyStateAction = ({
  String label,
  VoidCallback? onPressed,
});

class EmptyState extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final EmptyStateAction? action;

  const EmptyState({
    required this.title,
    required this.icon,
    this.subtitle,
    this.action,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.secondaryContainer,
              ),
              padding: const EdgeInsets.all(16.0),
              child: Icon(
                icon,
                size: 45,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  subtitle!,
                  style: textTheme.bodyMedium!.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (action != null)
              CustomButton(
                label: action!.label,
                onPressed: action!.onPressed,
                type: CustomButtonType.text,
              ),
          ],
        ),
      ),
    );
  }
}
