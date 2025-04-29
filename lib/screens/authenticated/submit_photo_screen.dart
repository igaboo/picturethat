import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picturethat/firebase_service.dart';
import 'package:picturethat/providers/prompt_provider.dart';
import 'package:picturethat/providers/user_provider.dart';
import 'package:picturethat/utils/handle_error.dart';
import 'package:picturethat/utils/image_utils.dart';
import 'package:picturethat/widgets/custom_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubmitPhotoScreen extends ConsumerStatefulWidget {
  const SubmitPhotoScreen({super.key});

  @override
  ConsumerState<SubmitPhotoScreen> createState() => _SubmitPhotoScreenState();
}

class _SubmitPhotoScreenState extends ConsumerState<SubmitPhotoScreen> {
  final _descriptionController = TextEditingController();
  XFile? _submissionImage;
  int? _submissionImageHeight;
  int? _submissionImageWidth;
  bool _isLoading = false;

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
      // state.addSubmission(submission);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) handleError(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectSubmissionImage() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final image = await ImageUtils.pickImage();
      if (image == null) {
        setState(() => _isLoading = false);
        return;
      }

      final decodedImage = await decodeImageFromList(await image.readAsBytes());
      _submissionImageHeight = decodedImage.height;
      _submissionImageWidth = decodedImage.width;

      setState(() {
        _isLoading = false;
        _submissionImage = image;
      });
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

    final maxImageHeight = MediaQuery.of(context).size.height * 0.5;
    final maxImageWidth = MediaQuery.of(context).size.width - 10.0;

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

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  spacing: 10.0,
                  children: [
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
                    GestureDetector(
                      onTap: _selectSubmissionImage,
                      child: Column(
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: maxImageHeight,
                              maxWidth: maxImageWidth,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                _submissionImage == null
                                    ? Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainer,
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                          ),
                                        ),
                                        child: Center(
                                          child: !_isLoading
                                              ? Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.image,
                                                      size: 60,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                    Text(
                                                      "Select an image",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelLarge!
                                                          .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                    ),
                                                  ],
                                                )
                                              : const SizedBox(),
                                        ),
                                      )
                                    : CustomImage(
                                        imageProvider:
                                            AssetImage(_submissionImage!.path),
                                        shape: CustomImageShape.squircle,
                                        width:
                                            _submissionImageWidth!.toDouble(),
                                        height:
                                            _submissionImageHeight!.toDouble(),
                                        maxHeight: maxImageHeight,
                                        maxWidth: maxImageWidth,
                                      ),
                                if (_isLoading) CircularProgressIndicator(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: "Photo Description",
                          helperText: ' ',
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 350,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FilledButton(
                            onPressed: _isLoading ? null : _submitPhoto,
                            child: const Text("Submit Photo"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
