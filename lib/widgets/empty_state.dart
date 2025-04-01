import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;

  const EmptyState({
    required this.title,
    required this.icon,
    this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              padding: const EdgeInsets.all(16.0),
              child: Icon(
                icon,
                size: 45,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
