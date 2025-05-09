import 'package:flutter/material.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/screens/forgot_password.dart';
import 'package:picture_that/screens/settings/delete_account_screen.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/widgets/settings_list_tile.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final providers = auth.currentUser?.providerData;
    final hasEmailProvider =
        providers?.any((p) => p.providerId == "password") ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
      ),
      body: ListView(
        children: [
          if (hasEmailProvider)
            SettingsListTile(
              title: "Reset Password",
              subtitle: "Send a password reset email",
              icon: Icons.key,
              onTap: () => navigate(const ForgotPasswordScreen()),
            ),
          SettingsListTile(
            title: "Delete Account",
            subtitle: "Delete all data and images",
            icon: Icons.delete_outline,
            onTap: () => navigate(const DeleteAccountScreen()),
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
