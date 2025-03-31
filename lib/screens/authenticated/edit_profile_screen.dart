import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picturethat/providers/user_provider.dart';
import 'package:picturethat/firebase_service.dart';
import 'package:picturethat/utils/handle_error.dart';
import 'package:picturethat/utils/image_utils.dart';
import 'package:picturethat/widgets/custom_image.dart';

final PROFILE_IMAGE_SIZE = 150.0;

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _urlController = TextEditingController();
  XFile? _profileImage;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "An error occurred while selecting an image. Please try again."),
          ),
        );
      }
    }
  }

  void _updateProfile() async {
    try {
      if (!_formKey.currentState!.validate()) return;

      await updateUserProfile(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        username: _usernameController.text,
        bio: _bioController.text,
        url: _urlController.text,
        profileImage: _profileImage,
      );

      ref.invalidate(userProvider((auth.currentUser!.uid)));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) handleError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider((auth.currentUser?.uid)!));

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text("Error: $e"),
        data: (user) {
          if (user == null) {
            return const Text("No user found");
          }

          _firstNameController.text = user.firstName;
          _lastNameController.text = user.lastName;
          _usernameController.text = user.username;
          _bioController.text = user.bio ?? "";
          _urlController.text = user.url ?? "";

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
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
                                ? CustomNetworkImage(
                                    url: user.profileImageUrl,
                                    borderRadius: PROFILE_IMAGE_SIZE / 2,
                                  )
                                : CustomLocalImage(
                                    path: _profileImage!.path,
                                    borderRadius: PROFILE_IMAGE_SIZE / 2,
                                  ),
                          ),
                          Text(
                            "Pick Profile Image",
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          )
                        ],
                      ),
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
                      prefix: Text("@"),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter a username";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: "Bio",
                      helperText: ' ',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 150,
                    maxLines: null,
                  ),
                  TextFormField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: "Website",
                      helperText: ' ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return null;

                      final uri = Uri.tryParse(value.trim());
                      if (uri == null || !uri.isAbsolute) {
                        return "Enter a valid URL";
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
                          onPressed: () => _updateProfile(),
                          child: Text("Save Changes"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
