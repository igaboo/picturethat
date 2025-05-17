import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/providers/theme_provider.dart';
import 'package:picture_that/utils/constants.dart';
import 'package:picture_that/widgets/settings_list_tile.dart';

class AppAppearanceScreen extends ConsumerWidget {
  const AppAppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text("App Appearance")),
      body: ListView(
        children: [
          SettingsListHeader(title: "Theme Settings"),
          Padding(
            padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: themeOptions.map((option) {
                final key = option["key"];
                final title = option["title"];
                final icon = option["icon"];

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: colorScheme.onPrimaryContainer,
                          size: 40,
                        ),
                      ),
                    ),
                    Text(
                      title,
                      style: textTheme.bodyMedium,
                    ),
                    Radio(
                      value: key,
                      groupValue: themeAsync.theme,
                      onChanged: (value) {
                        themeNotifier.setTheme(key);
                      },
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          SettingsListHeader(title: "Theme Color"),
          Padding(
            padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 16.0),
            child: Column(
              spacing: 16.0,
              children: [
                ...themeColors.map((row) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ...row.map((color) {
                        final isSelected =
                            themeAsync.color.toARGB32() == color?.toARGB32();

                        if (color == null) {
                          return const SizedBox(
                            width: 50,
                            height: 50,
                          );
                        }

                        return ThemeColorOption(
                          color: color,
                          isSelected: isSelected,
                          onTap: () => themeNotifier.setColor(color),
                        );
                      })
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ThemeColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeColorOption({
    super.key,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: isSelected
            ? Container(
                margin: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 5,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
