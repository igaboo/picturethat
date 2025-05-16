import 'package:flutter/material.dart';
import 'package:picture_that/utils/show_snackbar.dart';
import 'package:picture_that/widgets/settings_list_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BehaviorSettingsScreen extends StatelessWidget {
  const BehaviorSettingsScreen({super.key});

  void _handleResetTooltips() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();

    customShowSnackbar(
      "Tooltips reset successfully! Please restart the app to see changes.",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Behavior Settings")),
      body: ListView(
        children: [
          SettingsListHeader(title: "Miscellaneous"),
          SettingsListTile(
            title: "Reset Tooltips",
            subtitle: "Show all tooltips again",
            onTap: _handleResetTooltips,
          ),
        ],
      ),
    );
  }
}
