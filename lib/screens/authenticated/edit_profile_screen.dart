import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picturethat/providers/user_provider.dart';
import 'package:picturethat/firebase_service.dart';
import 'package:picturethat/utils/handle_error.dart';
import 'package:picturethat/utils/image_utils.dart';
import 'package:picturethat/utils/text_validation.dart';
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
  bool _isLoading = false;

  void _selectProfileImage() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final image = await ImageUtils.pickImage();
      setState(() => _isLoading = false);

      if (image != null) {
        setState(() => _profileImage = image);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) handleError(context, e);
    }
  }

  void _updateProfile() async {
    try {
      if (!_formKey.currentState!.validate()) return;

      // check if username has changed, and if so, check if it's available
      final currentUser = ref.read(userProvider((auth.currentUser!.uid))).value;
      final newUsername = _usernameController.text;
      final isUsernameChanged = currentUser?.username != newUsername;

      await updateUserProfile(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        username: isUsernameChanged ? newUsername : null,
        bio: _bioController.text,
        url: _urlController.text,
        profileImage: _profileImage,
      );

      // refetch newly updated user data
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
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomImage(
                                imageProvider: _profileImage == null
                                    ? NetworkImage(user.profileImageUrl)
                                    : AssetImage(_profileImage!.path),
                                shape: CustomImageShape.circle,
                                width: PROFILE_IMAGE_SIZE,
                                height: PROFILE_IMAGE_SIZE,
                              ),
                              if (_isLoading) CircularProgressIndicator(),
                            ],
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
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: "Username",
                      helperText: ' ',
                      border: OutlineInputBorder(),
                      prefix: Text("@"),
                    ),
                    validator: (value) => usernameValidator(value: value),
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
                    validator: (value) => urlValidator(value: value),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton(
                          onPressed: _isLoading ? null : () => _updateProfile(),
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
