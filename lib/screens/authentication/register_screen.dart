import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/screens/tabs/home_screen.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/utils/show_snackbar.dart';
import 'package:picture_that/utils/image_utils.dart';
import 'package:picture_that/utils/text_validation.dart';
import 'package:picture_that/widgets/custom_image.dart';

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
      setState(() => _isLoading = true);

      await signUpWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        username: _usernameController.text,
        profileImage: _profileImage,
      );

      if (mounted) navigateAndDisableBack(context, Home());
    } catch (e) {
      if (mounted) customShowSnackbar(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _selectProfileImage() async {
    setState(() => _isLoading = true);

    try {
      final image = await ImageUtils.pickImage(context);

      if (image != null) setState(() => _profileImage = image);
    } catch (e) {
      if (mounted) {
        customShowSnackbar(
          context,
          "An error occurred while selecting an image. Please try again.",
        );
      }
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
              TextFormField(
                controller: _emailController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: "Email",
                  helperText: ' ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => textValidator(
                  value: value,
                  fieldName: "email",
                ),
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
              TextFormField(
                controller: _passwordConfirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                  helperText: ' ',
                  border: OutlineInputBorder(),
                ),
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
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: "First Name",
                        helperText: ' ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => textValidator(
                        value: value,
                        fieldName: "first name",
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: "Last Name",
                        helperText: ' ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => textValidator(
                        value: value,
                        fieldName: "last name",
                      ),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                    labelText: "Username",
                    helperText: ' ',
                    border: OutlineInputBorder(),
                    prefix: Text("@")),
                validator: (value) => usernameValidator(value: value),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton(
                      onPressed: _isLoading ? null : () => _register(),
                      child: Text("Create an Account"),
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
