import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picturethat/firebase_service.dart';
import 'package:picturethat/models/prompt_model.dart';
import 'package:picturethat/models/submission_model.dart';
import 'package:picturethat/providers/prompt_provider.dart';
import 'package:picturethat/providers/submission_provider.dart';
import 'package:picturethat/providers/user_provider.dart';
import 'package:picturethat/utils/handle_error.dart';
import 'package:picturethat/utils/image_utils.dart';
import 'package:picturethat/widgets/custom_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picturethat/widgets/empty_state.dart';

class SubmitPhotoScreen extends ConsumerStatefulWidget {
  final SubmissionQueryParam? sourceQueryParam;

  const SubmitPhotoScreen({this.sourceQueryParam, super.key});

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

    final prompts = ref.read(promptsProvider).value!;
    final user = ref.watch(userProvider(auth.currentUser!.uid)).value;

    try {
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
      final date = Timestamp.now();

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
        "date": date,
        "likes": [],
      };

      await uploadDocument(
        id: submissionId,
        path: "submissions",
        data: submissionData,
      );

      final newSubmission = SubmissionModel(
        id: submissionId,
        user: user!,
        image: SubmissionImageModel(
          url: imageUrl,
          height: _submissionImageHeight!,
          width: _submissionImageWidth!,
        ),
        prompt: PromptSubmissionModel(
          id: promptId,
          title: promptTitle,
        ),
        date: date.toDate(),
        likes: [],
        caption: description,
        isLiked: false,
      );

      // note that the following query params must match the
      // query params used in their respective screens in order
      // for the refresh to work properly

      // update the submission list
      final promptSubmissions =
          ref.read(submissionNotifierProvider(SubmissionQueryParam(
        type: SubmissionQueryType.byPrompt,
        id: promptId,
      )).notifier);
      promptSubmissions.addSubmission(newSubmission);

      // update the user submission list
      final userSubmissions =
          ref.read(submissionNotifierProvider(SubmissionQueryParam(
        type: SubmissionQueryType.byUser,
        id: userId,
      )).notifier);
      userSubmissions.addSubmission(newSubmission);

      // update the user submission count
      ref.read(userProvider(userId).notifier).updateUser({
        "submissionsCount": user.submissionsCount + 1,
      });

      // update the prompt submission count
      final promptNotifier = ref.read(promptsProvider.notifier);
      promptNotifier.updateSubmissionCount(
        promptId: promptId,
        isIncrementing: true,
      );

      // navigate back to the previous screen
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) handleError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

      if (mounted) {
        setState(() {
          _isLoading = false;
          _submissionImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
                return EmptyState(
                  title: "No prompts available",
                  subtitle: "Please check back later",
                  icon: Icons.photo_camera,
                );
              }

              final todaysPrompt = prompts.items[0];

              return SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                child: Column(
                  spacing: 10.0,
                  children: [
                    Row(
                      children: [
                        CustomImage(
                          key: ValueKey(user?.uid),
                          imageProvider: NetworkImage(user!.profileImageUrl),
                          shape: CustomImageShape.circle,
                          width: 30,
                          height: 30,
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
                                        key: ValueKey(_submissionImage?.path),
                                        imageProvider: FileImage(
                                            File(_submissionImage!.path)),
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
