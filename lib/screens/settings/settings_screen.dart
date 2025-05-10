import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:picture_that/screens/settings/account_settings_screen.dart';
import 'package:picture_that/screens/settings/behavior_settings_screen.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/widgets/settings_list_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(context, ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: ListView(
        children: [
          SettingsListTile(
            title: "Account",
            subtitle: "Manage password, delete account",
            leading: const Icon(Icons.person),
            onTap: () => navigate(const AccountSettingsScreen()),
          ),
          SettingsListTile(
            title: "Behavior",
            subtitle: "Manage screen behavior, tooltips",
            leading: const Icon(Icons.settings),
            onTap: () => navigate(const BehaviorSettingsScreen()),
          ),
          FutureBuilder(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final packageInfo = snapshot.data;
              if (packageInfo == null) return const SizedBox();

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage(isDarkMode
                          ? "assets/splash_screen_dark.png"
                          : "assets/splash_screen_light.png"),
                      width: 35,
                      height: 35,
                    ),
                    Text(
                      "You are using Picture That v${packageInfo.version}",
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
