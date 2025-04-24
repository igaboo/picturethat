import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picturethat/firebase_service.dart';
import 'package:picturethat/models/submission_model.dart';
import 'package:picturethat/providers/prompt_provider.dart';
import 'package:picturethat/providers/user_provider.dart';
import 'package:picturethat/utils/handle_error.dart';
import 'package:picturethat/utils/image_utils.dart';
import 'package:picturethat/utils/text_validation.dart';
import 'package:picturethat/widgets/custom_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picturethat/providers/submission_provider.dart';

class SubmitPhotoScreen extends ConsumerStatefulWidget {
  const SubmitPhotoScreen({super.key});

  @override
  ConsumerState<SubmitPhotoScreen> createState() => _SubmitPhotoScreenState();
}

class _SubmitPhotoScreenState extends ConsumerState<SubmitPhotoScreen> {
  final _descriptionController = TextEditingController();
  XFile? _submissionImage;
  bool _isLoading = false;
  int? _submissionImageHeight;
  int? _submissionImageWidth;

  Future<void> _submitPhoto() async {
    if (_submissionImage == null) {
      handleError(context, "Please select an image.");
      return;
    }

    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final state = ref.watch(promptsProvider.notifier);
      final prompts = ref.read(promptsProvider).value!;
      final user = ref.watch(userProvider(auth.currentUser!.uid)).value;

      final userId = auth.currentUser!.uid;
      final todaysPrompt = prompts.items[0];
      final promptId = todaysPrompt.id;
      final promptTitle = todaysPrompt.title;

      final submissionId = db.collection("submissions").doc().id;
      print(submissionId);
      final imagePath = "submissions/$submissionId";
      final imageUrl = await uploadImage(
        path: imagePath,
        image: _submissionImage!,
      );

      final description = _descriptionController.text.trim();
      final submissionData = {
        "id": submissionId,
        "userId": userId,
        "prompt": {
          "id": promptId,
          "title": promptTitle,
        },
        "image": {
          "url": imageUrl,
          "height": _submissionImageHeight,
          "width": _submissionImageWidth
        },
        "caption": description,
        "date": Timestamp.now(),
        "likes": [],
      };

      await uploadDocument(
        id: submissionId,
        path: "submissions",
        data: submissionData,
      );

      // update state here!
      var submission = submissionData;
      submission.remove("userId");
      submission["user"] = user as Object;
      //state.addSubmission(submission);

      // --- 7. User Feedback (Success) ---
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Submission successful!")),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print(e);
      // if (mounted) handleError(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectSubmissionImage() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final image = await ImageUtils.pickImage();
      final decodeImage = await decodeImageFromList(await image!.readAsBytes());
      _submissionImageHeight = decodeImage.height;
      _submissionImageWidth = decodeImage.width;
      setState(() => _isLoading = false);

      if (image != null) setState(() => _submissionImage = image);
    } catch (e) {
      setState(() => _isLoading = false);
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
    final userAsync = ref.watch(userProvider(auth.currentUser!.uid));
    final promptsAsync = ref.watch(promptsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Photo"),
        leading: const BackButton(),
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("error: $e")),
        data: (user) {
          return promptsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("error: $e")),
            data: (prompts) {
              if (prompts.items.isEmpty) {
                return const Center(child: Text("No prompts available."));
              }

              final todaysPrompt = prompts.items[0];

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User + prompt row
                      Row(
                        children: [
                          CustomImage(
                            imageProvider: NetworkImage(user!.profileImageUrl),
                            shape: CustomImageShape.circle,
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "@${user.username}",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                todaysPrompt.title,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Placeholder image

                      // Description input
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: GestureDetector(
                          onTap: _selectSubmissionImage,
                          child: Column(
                            spacing: 10,
                            children: [
                              _submissionImage == null
                                  ? SizedBox(
                                      width: _submissionImageWidth
                                              ?.toDouble() ??
                                          MediaQuery.of(context).size.width -
                                              10.0,
                                      height: _submissionImageHeight
                                              ?.toDouble() ??
                                          MediaQuery.of(context).size.height *
                                              0.5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer,
                                            border: Border.all(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerHighest)),
                                        child: Center(
                                          child: _isLoading
                                              ? CircularProgressIndicator()
                                              : Icon(
                                                  Icons.image,
                                                  size: 60,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .outlineVariant,
                                                ),
                                        ),
                                      ),
                                    )
                                  : CustomImage(
                                      imageProvider:
                                          AssetImage(_submissionImage!.path),
                                      shape: CustomImageShape.squircle,
                                      width:
                                          _submissionImageWidth?.toDouble() ??
                                              double.infinity,
                                      height:
                                          _submissionImageHeight?.toDouble() ??
                                              double.infinity,
                                      maxWidth:
                                          MediaQuery.of(context).size.width -
                                              10.0,
                                      maxHeight:
                                          MediaQuery.of(context).size.height *
                                              0.5,
                                    ),
                            ],
                          ),
                        ),
                      ),

                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: "Photo Description",
                          helperText: ' ',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => textValidator(
                          value: value,
                          fieldName: "description",
                        ),
                      ),

                      // Submit Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FilledButton(
                              onPressed: _isLoading ? null : _submitPhoto,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text("Submit Photo"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
