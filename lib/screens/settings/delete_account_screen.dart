import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/screens/authentication/landing_screen.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/utils/show_dialog.dart';
import 'package:picture_that/utils/show_snackbar.dart';
import 'package:picture_that/utils/text_validation.dart';
import 'package:picture_that/widgets/custom_button.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void handleDelete() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      await auth.currentUser?.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: password),
      );

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
    }
  }

  @override
  Widget build(BuildContext context) {
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
                "Please enter your email and password to confirm account deletion.",
                style: textTheme.bodyLarge,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: "Email",
                  helperText: ' ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => emailValidator(value: value),
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  helperText: ' ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => passwordValidator(value: value),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomButton(
                      label: "Delete Account",
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
