import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/providers/firebase_provider.dart';
import 'package:picturethat/utils/handle_error.dart';
import 'package:picturethat/widgets/settings_list_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _logout(BuildContext context, WidgetRef ref) async {
    try {
      final firebaseService = ref.read(firebaseProvider);
      await firebaseService.signOut();

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
      appBar: AppBar(
        title: Text("Settings"),
        actions: [
          // logout button
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
      body: ListView(
        children: [
          SettingsListTile(
            title: "Example title",
            subtitle: "Example subtitle",
            icon: Icons.question_mark,
            onTap: () => {},
          ),
        ],
      ),
    );
  }
}
