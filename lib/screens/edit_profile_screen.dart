import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picture_that/providers/user_provider.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/utils/show_snackbar.dart';
import 'package:picture_that/utils/image_utils.dart';
import 'package:picture_that/utils/text_validation.dart';
import 'package:picture_that/widgets/custom_button.dart';
import 'package:picture_that/widgets/custom_image.dart';
import 'package:picture_that/widgets/custom_text_field.dart';

final profileImageSize = 150.0;

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
  bool _isLoading = false;
  bool _controllersInitialized = false;

  void _selectProfileImage() async {
    setState(() => _isLoading = true);

    try {
      final image = await ImageUtils.pickImage(context);

      if (image != null) setState(() => _profileImage = image);
    } catch (e) {
      customShowSnackbar(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateProfile() async {
    try {
      if (!_formKey.currentState!.validate()) return;

      // check if username has changed, and if so, check if it's available
      final currentUser = ref.read(userProvider((auth.currentUser!.uid))).value;
      final newUsername = _usernameController.text;
      final isUsernameChanged = currentUser?.username != newUsername;

      // update user in firebase
      final newValues = await updateUserProfile(
        firstName: _firstNameController.text == currentUser?.firstName
            ? null
            : _firstNameController.text,
        lastName: _lastNameController.text == currentUser?.lastName
            ? null
            : _lastNameController.text,
        username: isUsernameChanged ? newUsername : null,
        bio: _bioController.text == currentUser?.bio
            ? null
            : _bioController.text,
        url: _urlController.text == currentUser?.url
            ? null
            : _urlController.text,
        profileImage: _profileImage,
      );

      // update local user state
      ref.read(userProvider(auth.currentUser!.uid).notifier).updateUser({
        'firstName': newValues['firstName'],
        'lastName': newValues['lastName'],
        'username': newValues['username'],
        'bio': newValues['bio'],
        'url': newValues['url'],
        'profileImageUrl': newValues['profileImageUrl'],
      });

      navigateBack();
    } catch (e) {
      customShowSnackbar(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider((auth.currentUser?.uid)!));
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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

          if (!_controllersInitialized) {
            _firstNameController.text = user.firstName;
            _lastNameController.text = user.lastName;
            _usernameController.text = user.username;
            _bioController.text = user.bio ?? "";
            _urlController.text = user.url ?? "";

            setState(() => _controllersInitialized = true);
          }

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
                      onTap: _isLoading ? null : () => _selectProfileImage(),
                      child: Column(
                        spacing: 10,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomImage(
                                key: ValueKey(user.profileImageUrl),
                                imageProvider: _profileImage == null
                                    ? NetworkImage(user.profileImageUrl)
                                    : FileImage(File(_profileImage!.path)),
                                shape: CustomImageShape.circle,
                                width: profileImageSize,
                                height: profileImageSize,
                              ),
                              if (_isLoading) CircularProgressIndicator(),
                            ],
                          ),
                          Text(
                            "Pick Profile Image",
                            style: textTheme.labelLarge!
                                .copyWith(color: colorScheme.primary),
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
                  CustomTextField(
                    controller: _bioController,
                    label: "Bio",
                    maxLength: 150,
                    multiline: true,
                    validator: (value) => null,
                  ),
                  CustomTextField(
                    controller: _urlController,
                    label: "Website",
                    validator: (value) => urlValidator(value: value),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomButton(
                          label: "Save Changes",
                          onPressed: _updateProfile,
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
