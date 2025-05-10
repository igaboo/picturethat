import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/screens/authentication/landing_screen.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/utils/show_dialog.dart';
import 'package:picture_that/utils/show_snackbar.dart';
import 'package:picture_that/utils/text_validation.dart';
import 'package:picture_that/widgets/custom_button.dart';
import 'package:picture_that/widgets/custom_text_field.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  // most of this can be moved into the firebase_service.dart file
  void handleDelete() async {
    final providerId = auth.currentUser?.providerData[0].providerId;
    final isEmailProvider = providerId == "password";

    AuthCredential? credential;

    if (isEmailProvider) {
      if (!_formKey.currentState!.validate()) return;
      final password = _passwordController.text;

      credential = EmailAuthProvider.credential(
        email: auth.currentUser?.email ?? "",
        password: password,
      );
    } else {
      credential = await getGoogleCredential();
    }

    if (credential == null) return;

    try {
      await auth.currentUser?.reauthenticateWithCredential(credential);

      await customShowDialog(
        context: context,
        title: "Delete Account",
        content:
            "Are you sure you want to delete your account? All images and comments will be permanently deleted. This cannot be undone.",
        onPressed: () async {
          await deleteAccount();
          customShowSnackbar("Account deleted successfully. Goodbye!");
          navigateAndDisableBack(LandingScreen());
        },
        buttonText: "Delete",
      );
    } catch (e) {
      customShowSnackbar(e);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerId = auth.currentUser?.providerData[0].providerId;
    final isEmailProvider = providerId == "password";

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 10.0,
            children: [
              Text(
                isEmailProvider
                    ? "For your security, please enter your password to delete your account."
                    : "For your security, please sign in through Google to delete your account.",
                style: textTheme.bodyLarge,
              ),
              SizedBox(height: 16.0),
              if (isEmailProvider)
                CustomTextField(
                  controller: _passwordController,
                  label: "Password",
                  autofocus: true,
                  obscureText: true,
                  validator: (value) => passwordValidator(value: value),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomButton(
                      label: "Authenticate and Delete",
                      onPressed: handleDelete,
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
