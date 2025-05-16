import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/utils/preference_utils.dart';

class ThemeConfig {
  final String theme;
  final Color color;

  ThemeConfig({
    required this.theme,
    required this.color,
  });

  ThemeMode get themeMode {
    switch (theme) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  ThemeConfig copyWith({String? theme, Color? color}) {
    return ThemeConfig(theme: theme ?? this.theme, color: color ?? this.color);
  }
}

class ThemeNotifier extends StateNotifier<ThemeConfig> {
  ThemeNotifier() : super(ThemeConfig(theme: "system", color: Colors.yellow)) {
    loadTheme();
  }

  Future<void> loadTheme() async {
    final theme = await getString("theme") ?? "system";
    final colorHex = await getString("themeColor");

    print("Saved Theme: $theme, Saved Color: $colorHex");

    final color = (colorHex != null && colorHex.isNotEmpty)
        ? Color(int.parse(colorHex))
        : Colors.yellow;

    state = ThemeConfig(theme: theme, color: color);
  }

  Future<void> setTheme(String newTheme) async {
    await setString("theme", newTheme);
    state = state.copyWith(theme: newTheme);
  }

  Future<void> setColor(Color newColor) async {
    await setString("themeColor", newColor.toARGB32().toRadixString(10));
    state = state.copyWith(color: newColor);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeConfig>(
  (ref) => ThemeNotifier(),
);
