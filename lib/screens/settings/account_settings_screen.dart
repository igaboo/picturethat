import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/providers/auth_provider.dart';
import 'package:picture_that/providers/user_provider.dart';
import 'package:picture_that/screens/authentication/landing_screen.dart';
import 'package:picture_that/screens/forgot_password.dart';
import 'package:picture_that/screens/settings/connect_email_provider_screen.dart';
import 'package:picture_that/screens/settings/delete_account_screen.dart';
import 'package:picture_that/utils/constants.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/utils/show_dialog.dart';
import 'package:picture_that/utils/show_snackbar.dart';
import 'package:picture_that/widgets/custom_button.dart';
import 'package:picture_that/widgets/custom_image.dart';
import 'package:picture_that/widgets/settings_list_tile.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  AccountSettingsScreenState createState() => AccountSettingsScreenState();
}

class AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  Future<void> handleConnectProvider({
    required String providerId,
    required String providerName,
    required bool isConnecting,
    required Future<AuthCredential?> Function()? getCredential,
  }) async {
    try {
      if (isConnecting) {
        if (getCredential == null) {
          navigate(const ConnectEmailProviderScreen());
          return;
        }

        final credential = await getCredential();
        if (credential == null) return;

        await linkProvider(credential);
      } else {
        final providers = auth.currentUser?.providerData;

        if (providers?.length == 1) {
          customShowSnackbar(
            "Before disconnecting you $providerName account, please connect another provider.",
          );
          return;
        }

        await customShowDialog(
          title: "Disconnect Account",
          content:
              "Are you sure you want to disconnect your $providerName account?",
          onPressed: () => unlinkProvider(providerId),
        );
      }
    } catch (e) {
      customShowSnackbar(e);
    }
  }

  Future<void> _logout() async {
    try {
      await signOut();
      navigateAndDisableBack(LandingScreen());
    } catch (e) {
      customShowSnackbar(e);
    }
  }

  UserInfo? findProvider(List<UserInfo?>? providers, String id) {
    return providers
        ?.cast<UserInfo?>()
        .firstWhere((p) => p?.providerId == id, orElse: () => null);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final userAsync = ref.watch(userProvider(auth.currentUser?.uid));
    final userChangesAsync = ref.watch(userChangesProvider);
    final providers = userChangesAsync.asData?.value?.providerData;

    final emailProvider = findProvider(providers, "password");
    final googleProvider = findProvider(providers, "google.com");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
      ),
      body: ListView(
        children: [
          userAsync.when(
            loading: () => CircularProgressIndicator(),
            error: (error, _) => Text("Error: $error"),
            data: (user) {
              return SettingsListTile(
                title: "${user?.firstName} ${user?.lastName}",
                subtitle: "@${user?.username}",
                leading: CustomImage(
                  imageProvider: user?.profileImageUrl == null
                      ? defaultProfileImage
                      : NetworkImage(user?.profileImageUrl ?? dummyImageUrl),
                  width: 55,
                  height: 55,
                  shape: CustomImageShape.circle,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => customShowDialog(
                    title: "Logout",
                    content: "Are you sure you want to logout?",
                    onPressed: _logout,
                    buttonText: "Logout",
                  ),
                ),
              );
            },
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 16.0),
            child: Text(
              "Connected Accounts",
              style: textTheme.titleSmall!.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SettingsListTile(
            title: "Google",
            subtitle: googleProvider?.email ?? "Not connected",
            leading: Image.asset("assets/google.png", width: 24),
            trailing: CustomButton(
              label: googleProvider != null ? "Disconnect" : "Connect",
              onPressed: () => handleConnectProvider(
                providerId: "google.com",
                providerName: "Google",
                isConnecting: googleProvider == null,
                getCredential: getGoogleCredential,
              ),
              type: CustomButtonType.text,
            ),
          ),
          SettingsListTile(
            title: "Email & Password",
            subtitle: emailProvider?.email ?? "Not connected",
            leading: const Icon(Icons.email_outlined),
            trailing: CustomButton(
              label: emailProvider == null ? "Connect" : "Disconnect",
              onPressed: () => handleConnectProvider(
                providerId: "password",
                providerName: "Email & Password",
                isConnecting: emailProvider == null,
                getCredential: null,
              ),
              type: CustomButtonType.text,
            ),
          ),
          if (emailProvider != null)
            SettingsListTile(
              title: "Reset Password",
              subtitle: "Send a password reset email",
              onTap: () => navigate(const ForgotPasswordScreen()),
            ),
          SettingsListTile(
            title: "Delete Account",
            subtitle: "Delete all data and images",
            onTap: () => navigate(const DeleteAccountScreen()),
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
