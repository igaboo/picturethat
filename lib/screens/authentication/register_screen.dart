import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/screens/authentication/login_screen.dart';
import 'package:picture_that/screens/tabs/home_screen.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/utils/show_snackbar.dart';
import 'package:picture_that/utils/image_utils.dart';
import 'package:picture_that/utils/text_validation.dart';
import 'package:picture_that/widgets/common/custom_button.dart';
import 'package:picture_that/widgets/common/custom_image.dart';
import 'package:picture_that/widgets/common/custom_text_field.dart';

final profileImageSize = 150.0;

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  XFile? _profileImage;
  bool _isLoading = false;

  void _register() async {
    try {
      if (!_formKey.currentState!.validate()) return;

      await signUpWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        username: _usernameController.text,
        profileImage: _profileImage,
      );

      if (mounted) navigateAndDisableBack(Home());
    } catch (e) {
      customShowSnackbar(e);
    }
  }

  void _selectProfileImage() async {
    setState(() => _isLoading = true);

    try {
      final image = await ImageUtils.pickImage(context);

      if (image != null) setState(() => _profileImage = image);
    } catch (e) {
      customShowSnackbar(
        "An error occurred while selecting an image. Please try again.",
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 10.0,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: GestureDetector(
                    onTap: _isLoading ? null : () => _selectProfileImage(),
                    child: Column(
                      spacing: 10,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            _profileImage == null
                                ? SizedBox(
                                    width: profileImageSize,
                                    height: profileImageSize,
                                    child: DottedBorder(
                                      borderType: BorderType.Circle,
                                      color: colorScheme.outlineVariant,
                                      dashPattern: const [10, 16],
                                      strokeWidth: 5,
                                      strokeCap: StrokeCap.round,
                                      child: Center(
                                        child: Visibility(
                                          visible: !_isLoading,
                                          child: Icon(
                                            Icons.mood,
                                            size: 60,
                                            color: colorScheme.outlineVariant,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : CustomImage(
                                    key: ValueKey(_profileImage?.path),
                                    imageProvider:
                                        FileImage(File(_profileImage!.path)),
                                    shape: CustomImageShape.circle,
                                    width: profileImageSize,
                                    height: profileImageSize,
                                  ),
                            if (_isLoading) CircularProgressIndicator(),
                          ],
                        ),
                        Text(
                          "Pick Profile Image",
                          style: textTheme.labelLarge!.copyWith(
                            color: colorScheme.primary,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
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
                Row(
                  spacing: 16.0,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _firstNameController,
                        label: "First Name",
                      ),
                    ),
                    Expanded(
                      child: CustomTextField(
                        controller: _lastNameController,
                        label: "Last Name",
                      ),
                    ),
                  ],
                ),
                CustomTextField(
                  controller: _usernameController,
                  autocorrect: false,
                  label: "Username",
                  prefix: const Text("@"),
                  validator: (value) => usernameValidator(value: value),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomButton(
                        label: "Create an Account",
                        onPressed: _register,
                      ),
                      CustomButton(
                        label: "Already have an account?",
                        onPressed: () => navigate(const LoginScreen()),
                        type: CustomButtonType.text,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
