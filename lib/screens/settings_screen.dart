import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:picturethat/firebase_service.dart';
import 'package:picturethat/utils/handle_error.dart';
import 'package:picturethat/utils/show_dialog.dart';
import 'package:picturethat/widgets/settings_list_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _logout(BuildContext context, WidgetRef ref) async {
    try {
      await signOut();

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/landing_screen",
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) handleError(context, e);
    }
  }

  @override
  Widget build(context, ref) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: ListView(
        children: [
          SettingsListTile(
            title: "Account",
            subtitle: "Manage email, password, username",
            icon: Icons.person_outline,
            onTap: () {},
          ),
          SettingsListTile(
            title: "Reset Tooltips",
            subtitle: "Reset all tooltips to show again",
            icon: Icons.refresh,
            onTap: () async {
              final preferences = await SharedPreferences.getInstance();
              await preferences.clear();

              if (context.mounted) {
                handleError(context,
                    "Tooltips reset successfully! Please restart the app to see changes.");
              }
            },
          ),
          SettingsListTile(
            title: "Logout",
            icon: Icons.login_outlined,
            onTap: () => customShowDialog(
              context: context,
              title: "Logout",
              content: "Are you sure you want to logout?",
              onPressed: () => _logout(context, ref),
              buttonText: "Logout",
            ),
            color: Colors.red,
          ),
          FutureBuilder(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final packageInfo = snapshot.data;
              final isDarkMode =
                  Theme.of(context).brightness == Brightness.dark;
              if (packageInfo == null) return const SizedBox();

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage(
                        isDarkMode
                            ? "assets/splash_screen_dark.png"
                            : "assets/splash_screen_light.png",
                      ),
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                    ),
                    Text(
                      "You are using Picture That v${packageInfo.version}",
                      style: Theme.of(context).textTheme.bodySmall,
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
