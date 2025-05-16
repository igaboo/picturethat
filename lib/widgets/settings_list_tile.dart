import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Color? color;
  final VoidCallback? onTap;

  const SettingsListTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.color,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 32.0, vertical: 14.0),
      leading: leading,
      trailing: trailing,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleLarge!.copyWith(
              color: color ?? colorScheme.onSurface,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: textTheme.bodyMedium!.copyWith(
                color: color ?? colorScheme.onSurface,
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class SettingsListHeader extends StatelessWidget {
  final String title;

  const SettingsListHeader({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 16.0),
      child: Text(
        title,
        style: textTheme.titleSmall!.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
