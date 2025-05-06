import 'package:flutter/material.dart';
import 'package:picture_that/screens/forgot_password.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/utils/show_dialog.dart';
import 'package:picture_that/widgets/settings_list_tile.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
      ),
      body: ListView(
        children: [
          SettingsListTile(
            title: "Reset Password",
            subtitle: "Send a password reset email",
            icon: Icons.key,
            onTap: () => navigate(context, const ForgotPasswordScreen()),
          ),
          SettingsListTile(
            title: "Delete Account",
            subtitle: "Delete all data and images",
            icon: Icons.delete_outline,
            onTap: () => customShowDialog(
              context: context,
              title: "Delete Account",
              content:
                  "Are you sure you want to delete your account? All images will be permanently deleted. This cannot be undone.",
              onPressed: () {},
              buttonText: "Delete",
            ),
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
