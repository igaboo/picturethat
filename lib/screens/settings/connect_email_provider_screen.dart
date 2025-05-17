import 'package:flutter/material.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/utils/show_snackbar.dart';
import 'package:picture_that/utils/text_validation.dart';
import 'package:picture_that/widgets/common/custom_button.dart';
import 'package:picture_that/widgets/common/custom_text_field.dart';

class ConnectEmailProviderScreen extends StatefulWidget {
  const ConnectEmailProviderScreen({super.key});

  @override
  State<ConnectEmailProviderScreen> createState() =>
      _ConnectEmailProviderScreenState();
}

class _ConnectEmailProviderScreenState
    extends State<ConnectEmailProviderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  Future<void> handleConnect() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final credential = await getEmailPasswordCredential(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await linkProvider(credential);
      navigateBack();
    } catch (e) {
      customShowSnackbar(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Connect Email Account")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 10.0,
              children: [
                CustomTextField(
                  controller: _emailController,
                  label: "Email",
                  autofocus: true,
                  validator: (value) => emailValidator(value: value),
                ),
                CustomTextField(
                  controller: _passwordController,
                  label: "Password",
                  obscureText: true,
                  validator: (value) => passwordValidator(value: value),
                ),
                CustomTextField(
                  controller: _passwordConfirmController,
                  label: "Confirm Password",
                  obscureText: true,
                  validator: (value) => confirmPasswordValidator(
                    value: value,
                    password: _passwordController.text,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomButton(
                        label: "Connect Email Account",
                        onPressed: handleConnect,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
