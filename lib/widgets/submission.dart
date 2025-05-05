import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/models/submission_model.dart';
import 'package:picture_that/providers/submission_provider.dart';
import 'package:picture_that/providers/user_provider.dart';
import 'package:picture_that/screens/prompt_feed_screen.dart';
import 'package:picture_that/screens/tabs/profile_screen.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/utils/show_dialog.dart';
import 'package:picture_that/widgets/custom_image.dart';
import 'package:picture_that/widgets/custom_text_field.dart';
import 'package:picture_that/widgets/empty_state.dart';
import 'package:picture_that/widgets/labeled_icon_button.dart';
import 'package:share_plus/share_plus.dart';

class Submission extends ConsumerWidget {
  final SubmissionModel submission;
  final String? heroContext;
  final bool? isOnProfileTab;

  const Submission({
    required this.submission,
    required this.heroContext,
    this.isOnProfileTab,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    final isSelf = submission.user.uid == auth.currentUser?.uid;

    void navigateToProfile(String userId) {
      if (isOnProfileTab == true) return;
      navigate(context, ProfileScreen(userId: userId));
    }

    void handleLike() {
      void onInitialized(SubmissionNotifier notifier) {
        notifier.toggleSubmissionLike(
          submissionId: submission.id,
          isLiked: submission.isLiked,
        );
      }

      // update prompt list
      updateSubmissionNotifierIfInitialized(
        context: context,
        ref: ref,
        queryParam: SubmissionQueryParam(
          type: SubmissionQueryType.byPrompt,
          id: submission.prompt.id,
        ),
        onInitialized: onInitialized,
      );

      // update user list
      updateSubmissionNotifierIfInitialized(
        context: context,
        ref: ref,
        queryParam: SubmissionQueryParam(
          type: SubmissionQueryType.byUser,
          id: submission.user.uid,
        ),
        onInitialized: onInitialized,
      );

      // update feed list
      updateSubmissionNotifierIfInitialized(
        context: context,
        ref: ref,
        queryParam: SubmissionQueryParam(
          type: SubmissionQueryType.byRandom,
        ),
        onInitialized: onInitialized,
      );

      // update firestore
      toggleLike(
        submissionId: submission.id,
        uid: auth.currentUser!.uid,
        isLiked: submission.isLiked,
      );
    }

    void handleDelete() async {
      void onInitialized(SubmissionNotifier notifier) {
        notifier.deleteSubmission(submission.id);
      }

      // update firestore
      await deleteSubmission(submissionId: submission.id);

      // update prompt list
      updateSubmissionNotifierIfInitialized(
        context: context,
        ref: ref,
        queryParam: SubmissionQueryParam(
          type: SubmissionQueryType.byPrompt,
          id: submission.prompt.id,
        ),
        onInitialized: onInitialized,
      );

      // update user list
      updateSubmissionNotifierIfInitialized(
        context: context,
        ref: ref,
        queryParam: SubmissionQueryParam(
          type: SubmissionQueryType.byUser,
          id: submission.user.uid,
        ),
        onInitialized: onInitialized,
      );

      // update feed list
      updateSubmissionNotifierIfInitialized(
        context: context,
        ref: ref,
        queryParam: SubmissionQueryParam(
          type: SubmissionQueryType.byRandom,
        ),
        onInitialized: onInitialized,
      );

      // update submission count for prompt
      updatePromptNotifierIfInitialized(
        context: context,
        ref: ref,
        onInitialized: (notifier) => notifier.updateSubmissionCount(
          promptId: submission.prompt.id,
          isIncrementing: false,
        ),
      );

      // update submission count for user
      updateUserNotifierIfInitialized(
        context: context,
        ref: ref,
        userId: submission.user.uid,
        onInitialized: (notifier) => notifier.updateSubmissionsCount(false),
      );
    }

    void handleComment() {
      // open bottom sheet
      showModalBottomSheet(
        context: context,
        builder: (context) => CommentBottomSheet(submissionId: submission.id),
        isScrollControlled: true,
        useSafeArea: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.0),
          ),
        ),
      );
    }

    void handleShare() {
      // this url is just a placeholder, replace with actual url
      // in future when deep linking is implemented
      final url = "https://picturethat.com/submission/${submission.id}";
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
            onDoubleTap: handleLike,
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
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 70),
                    child: LabeledIconButton(
                      onPressed: handleLike,
                      icon: Icons.favorite_outline,
                      selectedIcon: Icons.favorite,
                      label: "${submission.likes.length}",
                      isSelected: submission.isLiked,
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 70),
                    child: LabeledIconButton(
                      onPressed: handleComment,
                      icon: Icons.chat_bubble_outline,
                      label: "0",
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 70),
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

const List<String> reactions = [
  "❤️",
  "🔥",
  "🙌",
  "👏",
  "👍",
  "😍",
  "😮",
  "😊",
];

class CommentBottomSheet extends ConsumerStatefulWidget {
  final String submissionId;

  const CommentBottomSheet({
    required this.submissionId,
    super.key,
  });

  @override
  ConsumerState<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends ConsumerState<CommentBottomSheet> {
  final _commentController = TextEditingController();
  bool _isCommentControllerEmpty = true;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() {
        _isCommentControllerEmpty = _commentController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void handleComment() {
    _commentController.clear();
  }

  void handleReaction(String reaction) {
    _commentController.text += reaction;
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider((auth.currentUser?.uid)!));
    final textTheme = Theme.of(context).textTheme;
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    // if ios, center, if android, left
                    alignment:
                        isAndroid ? Alignment.centerLeft : Alignment.center,
                    child: Padding(
                      padding: isAndroid
                          ? EdgeInsets.only(left: 8.0)
                          : EdgeInsets.zero,
                      child: Text(
                        "Comments",
                        style: textTheme.titleLarge,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1.0),
            Expanded(
              child: CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    child: EmptyState(
                      title: "No Comments",
                      subtitle: "Start the conversation!",
                      icon: Icons.chat_bubble_outline,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1.0),
            SafeArea(
              minimum: EdgeInsets.all(16.0),
              child: Column(
                spacing: 16.0,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ...reactions.map((reaction) {
                        return GestureDetector(
                          key: ValueKey(reaction),
                          onTap: () => handleReaction(reaction),
                          child: Text(
                            reaction,
                            style: TextStyle(fontSize: 22.0),
                          ),
                        );
                      })
                    ],
                  ),
                  Row(
                    spacing: 8.0,
                    children: [
                      userAsync.when(
                        loading: () => const SizedBox(
                          height: 40,
                          width: 40,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                        error: (e, _) => const SizedBox(height: 40, width: 40),
                        data: (user) => CustomImage(
                          imageProvider: NetworkImage(user!.profileImageUrl),
                          shape: CustomImageShape.circle,
                          width: 40,
                          height: 40,
                        ),
                      ),
                      Expanded(
                        child: CustomTextField(
                          controller: _commentController,
                          hintText: "Add a comment...",
                          trailingButton: IconButton(
                            icon: Icon(Icons.send),
                            onPressed: _isCommentControllerEmpty
                                ? null
                                : () => handleComment(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
