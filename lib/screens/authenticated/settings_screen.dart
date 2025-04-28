import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/firebase_service.dart';
import 'package:picturethat/utils/handle_error.dart';
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
            title: "Reset Tooltips",
            subtitle: "Reset all tooltips to show again",
            icon: Icons.refresh,
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (context.mounted) {
                handleError(context,
                    "Tooltips reset successfully! Please restart the app to see changes.");
              }
            },
          ),
          SettingsListTile(
            title: "Logout",
            icon: Icons.login_outlined,
            onTap: () => _logout(context, ref),
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
