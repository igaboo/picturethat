import 'package:flutter/material.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/utils/show_snackbar.dart';
import 'package:picture_that/utils/text_validation.dart';
import 'package:picture_that/widgets/custom_button.dart';
import 'package:picture_that/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await sendPasswordResetEmail(email: _emailController.text);

      customShowSnackbar(
        "Password reset email sent to ${_emailController.text}.",
      );

      navigateBack();
    } catch (e) {
      customShowSnackbar("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 10.0,
            children: [
              Text(
                "Enter the email associated with your account, and we'll send you a link to reset your password.",
                style: textTheme.bodyLarge,
              ),
              SizedBox(height: 16.0),
              CustomTextField(
                controller: _emailController,
                label: "Email",
                autofocus: true,
                validator: (value) => emailValidator(value: value),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomButton(
                      label: "Send Reset Email",
                      onPressed: _resetPassword,
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
