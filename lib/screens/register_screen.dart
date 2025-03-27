import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picturethat/providers/firebase_provider.dart';
import 'package:picturethat/utils/handle_error.dart';
import 'package:picturethat/utils/image_utils.dart';
import 'package:picturethat/widgets/custom_image.dart';

final PROFILE_IMAGE_SIZE = 180.0;

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
      final firebaseService = ref.read(firebaseProvider);

      if (_profileImage == null) {
        handleError(
          context,
          "Select a profile image before continuing",
        );
      }

      bool isAvailable = await firebaseService.isUsernameAvailable(
        username: _usernameController.text,
      );

      if (mounted && !isAvailable) {
        handleError(context, "Username is already taken");
      }

      if (_formKey.currentState!.validate() &&
          _profileImage != null &&
          isAvailable) {
        await firebaseService.signUpWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          username: _usernameController.text,
          profileImage: _profileImage!,
        );

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            "/home_screen",
            (route) => false,
          );
        }
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
                      SizedBox(
                        width: PROFILE_IMAGE_SIZE,
                        height: PROFILE_IMAGE_SIZE,
                        child: _profileImage == null
                            ? DottedBorder(
                                borderType: BorderType.Circle,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                                dashPattern: const [15, 15],
                                strokeWidth: 5,
                                strokeCap: StrokeCap.round,
                                child: Center(
                                  child: Icon(
                                    Icons.mood,
                                    size: 42,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                  ),
                                ),
                              )
                            : CustomLocalImage(
                                path: _profileImage!.path,
                                borderRadius: PROFILE_IMAGE_SIZE / 2,
                              ),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter your email";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  helperText: ' ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter a password";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordConfirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                  helperText: ' ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter your password again";
                  }
                  if (value != _passwordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter your first name";
                        }
                        return null;
                      },
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter your last name";
                        }
                        return null;
                      },
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter a username";
                  }
                  return null;
                },
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
