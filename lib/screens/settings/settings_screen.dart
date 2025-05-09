import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/screens/authentication/landing_screen.dart';
import 'package:picture_that/screens/settings/account_settings_screen.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/utils/show_snackbar.dart';
import 'package:picture_that/utils/show_dialog.dart';
import 'package:picture_that/widgets/settings_list_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _logout(BuildContext context) async {
    try {
      await signOut();

      navigateAndDisableBack(LandingScreen());
    } catch (e) {
      customShowSnackbar(e);
    }
  }

  void _handleResetTooltips() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();

    customShowSnackbar(
      "Tooltips reset successfully! Please restart the app to see changes.",
    );
  }

  @override
  Widget build(context, ref) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: ListView(
        children: [
          SettingsListTile(
            title: "Account",
            subtitle: "Manage password, delete account",
            icon: Icons.person_outline,
            onTap: () => navigate(const AccountSettingsScreen()),
          ),
          SettingsListTile(
            title: "Reset Tooltips",
            subtitle: "Reset all tooltips to show again",
            icon: Icons.refresh,
            onTap: _handleResetTooltips,
          ),
          SettingsListTile(
            title: "Logout",
            icon: Icons.login_outlined,
            onTap: () => customShowDialog(
              context: context,
              title: "Logout",
              content: "Are you sure you want to logout?",
              onPressed: () {
                _logout(context);
                navigateAndDisableBack(LandingScreen());
              },
              buttonText: "Logout",
            ),
            color: Colors.red,
          ),
          FutureBuilder(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final packageInfo = snapshot.data;
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
                      style: textTheme.bodySmall,
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
