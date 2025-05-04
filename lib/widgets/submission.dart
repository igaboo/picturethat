import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/models/submission_model.dart';
import 'package:picture_that/providers/prompt_provider.dart';
import 'package:picture_that/providers/submission_provider.dart';
import 'package:picture_that/providers/user_provider.dart';
import 'package:picture_that/screens/prompt_feed_screen.dart';
import 'package:picture_that/screens/tabs/profile_screen.dart';
import 'package:picture_that/utils/get_time_elapsed.dart';
import 'package:picture_that/utils/show_snackbar.dart';
import 'package:picture_that/utils/navigate.dart';
import 'package:picture_that/utils/show_dialog.dart';
import 'package:picture_that/widgets/custom_image.dart';
import 'package:picture_that/widgets/labeled_icon_button.dart';
import 'package:share_plus/share_plus.dart';

class Submission extends ConsumerWidget {
  final SubmissionModel submission;
  final SubmissionQueryParam queryParam;
  final String? heroContext;
  final bool? isOnProfileTab;

  const Submission({
    required this.submission,
    required this.queryParam,
    required this.heroContext,
    this.isOnProfileTab,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(submissionProvider(queryParam).notifier);
    final textTheme = Theme.of(context).textTheme;

    final isSelf = submission.user.uid == auth.currentUser?.uid;

    void navigateToProfile(String userId) {
      if (isOnProfileTab == true) return;
      navigate(context, ProfileScreen(userId: userId));
    }

    void handleLike() {
      state.toggleSubmissionLike(
        submissionId: submission.id,
        isLiked: submission.isLiked,
      );
    }

    void handleDelete() async {
      await deleteSubmission(submissionId: submission.id).catchError((e) {
        if (context.mounted) {
          customShowSnackbar(
            context,
            "Error deleting submission, please try again later.",
          );

          return;
        }
      });

      // remove the submission from its list
      state.deleteSubmission(submission.id);

      if (queryParam.type == SubmissionQueryType.byUser) {
        // remove the submission from the prompt it was submitted to
        final promptSubmissions =
            ref.read(submissionProvider(SubmissionQueryParam(
          type: SubmissionQueryType.byPrompt,
          id: submission.prompt.id,
        )).notifier);
        promptSubmissions.deleteSubmission(submission.id);
      } else if (queryParam.type == SubmissionQueryType.byPrompt) {
        // remove the submission from the user it was submitted by
        final userSubmissions =
            ref.read(submissionProvider(SubmissionQueryParam(
          type: SubmissionQueryType.byUser,
          id: submission.user.uid,
        )).notifier);
        userSubmissions.deleteSubmission(submission.id);
      }

      // update the prompt submission count
      final promptNotifier = ref.read(promptsProvider.notifier);
      promptNotifier.updateSubmissionCount(
        promptId: submission.prompt.id,
        isIncrementing: false,
      );

      // update the user submission count
      final userAsync = ref.read(userProvider(submission.user.uid)).valueOrNull;
      if (userAsync == null) return;
      ref.read(userProvider(userAsync.uid).notifier).updateUser({
        "submissionsCount": userAsync.submissionsCount - 1,
      });
    }

    void handleShare() {
      // this url is just a placeholder, replace with actual url
      // in future when deep linking is implemented
      final url =
          "https://picturethat.com/submission/${submission.user.username}";
      final subject = isSelf ? "my" : "${submission.user.firstName}'s";

      SharePlus.instance.share(ShareParams(
        text: "Check out $subject photo on Picture That: $url",
      ));
    }

    return Column(
      spacing: 10.0,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 8.0),
          child: Row(
            spacing: 10.0,
            children: [
              GestureDetector(
                onTap: () => navigateToProfile(submission.user.uid),
                child: CustomImage(
                  key: ValueKey(submission.user.profileImageUrl),
                  imageProvider: NetworkImage(submission.user.profileImageUrl),
                  shape: CustomImageShape.circle,
                  width: 30,
                  height: 30,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => navigateToProfile(submission.user.uid),
                      child: Text(
                        "@${submission.user.username}",
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => navigate(
                        context,
                        PromptFeedScreen(promptId: submission.prompt.id),
                      ),
                      child: Text(submission.prompt.title),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: Icon(Icons.more_horiz),
                style: ButtonStyle(visualDensity: VisualDensity.compact),
                onSelected: (value) {
                  if (value == "report") {
                    // Handle report action
                  }
                  if (value == "delete") {
                    customShowDialog(
                      context: context,
                      title: "Delete Submission",
                      content:
                          "Are you sure you want to delete this submission?",
                      onPressed: handleDelete,
                      buttonText: "Delete",
                    );
                  }
                },
                itemBuilder: (context) => [
                  isSelf
                      ? PopupMenuItem(
                          value: "delete",
                          child: Row(
                            spacing: 8.0,
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              Text(
                                "Delete Post",
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        )
                      : PopupMenuItem(
                          value: "report",
                          child: Row(
                            spacing: 8.0,
                            children: [
                              Icon(Icons.report),
                              Text("Report"),
                            ],
                          ),
                        ),
                ],
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: CustomImageViewer(
            heroTag: "${heroContext}_${submission.id}",
            customImage: CustomImage(
              key: ValueKey(submission.image.url),
              imageProvider: NetworkImage(submission.image.url),
              width: submission.image.width.toDouble(),
              height: submission.image.height.toDouble(),
              maxWidth: MediaQuery.of(context).size.width - 10.0,
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: LabeledIconButton(
                      onPressed: handleLike,
                      icon: Icons.favorite_outline,
                      selectedIcon: Icons.favorite,
                      label: "${submission.likes.length}",
                      isSelected: submission.isLiked,
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: LabeledIconButton(
                      onPressed: () {},
                      icon: Icons.chat_bubble_outline,
                      label: "0",
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: LabeledIconButton(
                      onPressed: handleShare,
                      icon: Icons.share_outlined,
                    ),
                  ),
                ],
              ),
            ),
            if (submission.caption?.isNotEmpty == true)
              Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 5.0),
                child: RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "@${submission.user.username} ",
                        style: textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap =
                              () => navigateToProfile(submission.user.uid),
                      ),
                      TextSpan(
                        text: submission.caption!,
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                getTimeElapsed(submission.date),
                style: textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
