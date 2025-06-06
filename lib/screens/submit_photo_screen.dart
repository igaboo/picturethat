import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/models/prompt_model.dart';
import 'package:picture_that/models/submission_model.dart';
import 'package:picture_that/models/user_model.dart';
import 'package:picture_that/providers/prompt_provider.dart';
import 'package:picture_that/providers/submission_provider.dart';
import 'package:picture_that/providers/user_provider.dart';
import 'package:picture_that/utils/constants.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/utils/show_snackbar.dart';
import 'package:picture_that/utils/image_utils.dart';
import 'package:picture_that/widgets/common/custom_button.dart';
import 'package:picture_that/widgets/common/custom_image.dart';
import 'package:picture_that/widgets/custom_skeletonizer.dart';
import 'package:picture_that/widgets/common/custom_text_field.dart';

final headerSkeleton = CustomSkeletonizer(
  child: SubmitPhotoScreenHeader(
    user: getDummyUser(),
    promptTitle: "dummy title",
  ),
);

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
      customShowSnackbar("Please select an image.");
      return;
    }

    final prompts = ref.read(promptsProvider).value!;
    final user = ref.watch(userProvider(auth.currentUser?.uid)).value;

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
        commentsCount: 0,
      );

      // update prompt list
      updateSubmissionNotifierIfInitialized(
        ref: ref,
        queryParam: SubmissionQueryParam(
          type: SubmissionQueryType.byPrompt,
          id: promptId,
        ),
        onInitialized: (notifier) => notifier.addSubmission(newSubmission),
      );

      // update user list
      updateSubmissionNotifierIfInitialized(
        ref: ref,
        queryParam: SubmissionQueryParam(
          type: SubmissionQueryType.byUser,
          id: userId,
        ),
        onInitialized: (notifier) => notifier.addSubmission(newSubmission),
      );

      // update user submission count
      updateUserNotifierIfInitialized(
        ref: ref,
        userId: userId,
        onInitialized: (notifier) => notifier.updateSubmissionsCount(true),
      );

      // update prompt submission count
      updatePromptNotifierIfInitialized(
        ref: ref,
        onInitialized: (notifier) => notifier.updateSubmissionCount(
          promptId: promptId,
          isIncrementing: true,
        ),
      );

      // navigate back to the previous screen
      navigateBack();
    } catch (e) {
      customShowSnackbar(e);
    }
  }

  void _selectSubmissionImage() async {
    setState(() => _isLoading = true);

    try {
      final image = await ImageUtils.pickImage(context);
      if (image == null) return;

      final decodedImage = await decodeImageFromList(await image.readAsBytes());
      _submissionImageHeight = decodedImage.height;
      _submissionImageWidth = decodedImage.width;

      if (mounted) setState(() => _submissionImage = image);
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
    final userAsync = ref.watch(userProvider(auth.currentUser?.uid));
    final promptsAsync = ref.watch(promptsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final maxImageHeight = MediaQuery.of(context).size.height * 0.5;
    final maxImageWidth = MediaQuery.of(context).size.width - 10.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Photo"),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          minimum: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            spacing: 10.0,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: userAsync.when(
                  loading: () => headerSkeleton,
                  error: (e, _) => Center(child: Text("error: $e")),
                  data: (user) => promptsAsync.when(
                    loading: () => headerSkeleton,
                    error: (e, _) => Center(child: Text("error: $e")),
                    data: (prompts) => SubmitPhotoScreenHeader(
                      user: user,
                      promptTitle: prompts.items[0].title,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _isLoading ? null : () => _selectSubmissionImage(),
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: _submissionImageHeight?.toDouble() ??
                            maxImageHeight,
                        maxWidth:
                            _submissionImageWidth?.toDouble() ?? maxImageWidth,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _submissionImage == null
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    color: colorScheme.surfaceContainer,
                                    border: Border.all(
                                      color:
                                          colorScheme.surfaceContainerHighest,
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
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                              Text(
                                                "Select an image",
                                                style: textTheme.labelLarge!
                                                    .copyWith(
                                                  color: colorScheme
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
                                  imageProvider:
                                      FileImage(File(_submissionImage!.path)),
                                  shape: CustomImageShape.squircle,
                                  width: _submissionImageWidth!.toDouble(),
                                  height: _submissionImageHeight!.toDouble(),
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
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 16.0),
                child: CustomTextField(
                  controller: _descriptionController,
                  label: "Photo Description",
                  maxLength: 350,
                  multiline: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomButton(
                      label: "Submit Photo",
                      onPressed: _submitPhoto,
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

class SubmitPhotoScreenHeader extends StatelessWidget {
  final UserModel? user;
  final String promptTitle;

  const SubmitPhotoScreenHeader({
    required this.user,
    required this.promptTitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        CustomImage(
          key: ValueKey(user?.uid),
          imageProvider: NetworkImage(user?.profileImageUrl ?? dummyImageUrl),
          shape: CustomImageShape.circle,
          width: 40,
          height: 40,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "@${user?.username}",
              style:
                  textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              promptTitle,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}
