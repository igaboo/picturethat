import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picturethat/firebase_service.dart';
import 'package:picturethat/utils/handle_error.dart';
import 'package:picturethat/utils/image_utils.dart';
import 'package:picturethat/utils/text_validation.dart';
import 'package:picturethat/widgets/custom_image.dart';

final PROFILE_IMAGE_SIZE = 150.0;

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

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/home_screen",
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) handleError(context, e);
    }
  }

  void _selectProfileImage() async {
    try {
      final image = await ImageUtils.pickImage();
      if (image != null) {
        setState(() {
          _profileImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        handleError(
          context,
          "An error occurred while selecting an image. Please try again.",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  onTap: _selectProfileImage,
                  child: Column(
                    spacing: 10,
                    children: [
                      _profileImage == null
                          ? SizedBox(
                              width: PROFILE_IMAGE_SIZE,
                              height: PROFILE_IMAGE_SIZE,
                              child: DottedBorder(
                                borderType: BorderType.Circle,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                                dashPattern: const [10, 16],
                                strokeWidth: 5,
                                strokeCap: StrokeCap.round,
                                child: Center(
                                  child: Icon(
                                    Icons.mood,
                                    size: 60,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                  ),
                                ),
                              ),
                            )
                          : CustomImage(
                              imageProvider: AssetImage(_profileImage!.path),
                              shape: CustomImageShape.circle,
                              width: PROFILE_IMAGE_SIZE,
                              height: PROFILE_IMAGE_SIZE,
                            ),
                      Text(
                        "Pick Profile Image",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      )
                    ],
                  ),
                ),
              ),
              TextFormField(
                controller: _emailController,
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
                      onPressed: () => _register(),
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
