import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/screens/authentication/register_screen.dart';
import 'package:picture_that/screens/forgot_password.dart';
import 'package:picture_that/screens/tabs/home_screen.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/utils/show_snackbar.dart';
import 'package:picture_that/utils/text_validation.dart';
import 'package:picture_that/widgets/custom_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    try {
      if (!_formKey.currentState!.validate()) return;

      await signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) navigateAndDisableBack(Home());
    } catch (e) {
      customShowSnackbar(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 24.0,
            children: [
              Column(
                children: [
                  TextFormField(
                    autofocus: true,
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      helperText: ' ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => emailValidator(value: value),
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      helperText: ' ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => textValidator(
                      value: value,
                      fieldName: "password",
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => navigate(const ForgotPasswordScreen()),
                      child: Text(
                        "Forgot your password?",
                        style:
                            Theme.of(context).textTheme.labelMedium!.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomButton(
                      label: "Login",
                      onPressed: _login,
                    ),
                    CustomButton(
                      label: "Don't have an account?",
                      onPressed: () => navigate(RegisterScreen()),
                      type: CustomButtonType.text,
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
