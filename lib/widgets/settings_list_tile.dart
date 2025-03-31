import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const SettingsListTile({
    required this.title,
    this.subtitle,
    required this.icon,
    this.color,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 14.0),
      leading:
          Icon(icon, color: color ?? Theme.of(context).colorScheme.onSurface),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: color ?? Theme.of(context).colorScheme.onSurface,
                ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: color ?? Theme.of(context).colorScheme.onSurface,
                  ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}
