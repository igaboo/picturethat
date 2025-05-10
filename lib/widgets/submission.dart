import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/models/comment_model.dart';
import 'package:picture_that/models/submission_model.dart';
import 'package:picture_that/providers/comment_provider.dart';
import 'package:picture_that/providers/relationship_provider.dart';
import 'package:picture_that/providers/submission_provider.dart';
import 'package:picture_that/providers/user_provider.dart';
import 'package:picture_that/screens/prompt_feed_screen.dart';
import 'package:picture_that/screens/tabs/profile_screen.dart';
import 'package:picture_that/utils/constants.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/utils/show_dialog.dart';
import 'package:picture_that/utils/show_snackbar.dart';
import 'package:picture_that/widgets/comment.dart';
import 'package:picture_that/widgets/comments_list.dart';
import 'package:picture_that/widgets/custom_image.dart';
import 'package:picture_that/widgets/custom_skeletonizer.dart';
import 'package:picture_that/widgets/custom_text_input.dart';
import 'package:picture_that/widgets/empty_state.dart';
import 'package:picture_that/widgets/labeled_icon_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

final commentsListSkeleton = CustomSkeletonizer(
  child: ListView.separated(
    itemCount: 10,
    separatorBuilder: (context, index) => const SizedBox(height: 16.0),
    itemBuilder: (context, index) {
      return Comment(
        comment: getDummyComment(),
        handleReply: (_) {},
      );
    },
  ),
);

final profileImageSkeleton = CustomSkeletonizer(
  child: CustomImage(
    imageProvider: const NetworkImage(dummyImageUrl),
    shape: CustomImageShape.circle,
    width: 40,
    height: 40,
  ),
);

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
    ref.watch(relationshipProvider);
    final isFollowing = ref
        .read(relationshipProvider.notifier)
        .isFollowing(submission.user.uid);

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final isSelf = submission.user.uid == auth.currentUser?.uid;

    void navigateToProfile(String userId) {
      if (isOnProfileTab == true) return;
      navigate(ProfileScreen(userId: userId));
    }

    void handleLike() {
      void onInitialized(SubmissionNotifier notifier) {
        notifier.toggleSubmissionLike(
          submissionId: submission.id,
          isLiked: submission.isLiked,
        );
      }

      // update firestore (no await, not necessary)
      toggleLike(
        submissionId: submission.id,
        uid: auth.currentUser!.uid,
        isLiked: submission.isLiked,
      );

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

      // update discover feed list
      updateSubmissionNotifierIfInitialized(
        context: context,
        ref: ref,
        queryParam: SubmissionQueryParam(
          type: SubmissionQueryType.byRandom,
        ),
        onInitialized: onInitialized,
      );

      // update following feed list
      updateSubmissionNotifierIfInitialized(
        context: context,
        ref: ref,
        queryParam: SubmissionQueryParam(
          type: SubmissionQueryType.byFollowing,
        ),
        onInitialized: onInitialized,
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

    void showCommentSheet() {
      // open bottom sheet
      showModalBottomSheet(
        context: context,
        builder: (context) => CommentBottomSheet(submission: submission),
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
                onTap: () async {
                  if (!isFollowing && !isSelf) {
                    await toggleFollow(context, ref, submission.user.uid);

                    customShowSnackbar(
                      "Now following @${submission.user.username}",
                      action: SnackBarAction(
                        label: "Undo",
                        onPressed: () => toggleFollow(
                          context,
                          ref,
                          submission.user.uid,
                        ),
                      ),
                    );

                    return;
                  }

                  navigateToProfile(submission.user.uid);
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CustomImage(
                      key: ValueKey(submission.user.profileImageUrl),
                      imageProvider:
                          NetworkImage(submission.user.profileImageUrl),
                      shape: CustomImageShape.circle,
                      width: 40,
                      height: 40,
                    ),
                    if (!isFollowing && !isSelf)
                      Positioned(
                        bottom: -3,
                        right: -3,
                        child: Skeleton.ignore(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorScheme.primary,
                              border: Border.all(
                                color: colorScheme.surface,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 18,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      )
                  ],
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
                      onPressed: showCommentSheet,
                      icon: Icons.chat_bubble_outline,
                      label: submission.commentsCount.toString(),
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

class CommentBottomSheet extends ConsumerStatefulWidget {
  final SubmissionModel submission;

  const CommentBottomSheet({
    required this.submission,
    super.key,
  });

  @override
  ConsumerState<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends ConsumerState<CommentBottomSheet> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isCommentControllerEmpty = true;
  bool _isLoading = false;

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

  void handleComment() async {
    final commentNotifier =
        ref.read(commentsProvider(widget.submission.id).notifier);
    final user = ref.read(userProvider((auth.currentUser?.uid)!)).valueOrNull;
    if (user == null) return;

    try {
      setState(() => _isLoading = true);

      final docId = await createComment(
        submissionId: widget.submission.id,
        userId: user.uid,
        text: _commentController.text,
      );

      updateCommentCountHelper(
        context: context,
        ref: ref,
        isIncrementing: true,
        submission: widget.submission,
      );

      final comment = CommentModel(
        id: docId,
        submissionId: widget.submission.id,
        user: user,
        text: _commentController.text,
        date: DateTime.now(),
      );

      commentNotifier.addComment(comment);
      _commentController.clear();
      // scroll to top
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOutQuint,
      );
    } catch (e) {
      customShowSnackbar(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void handleReaction(String reaction) {
    _commentController.text += reaction;
  }

  void handleReply(String username) {
    _commentController.text = "@$username ${_commentController.text}";
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider((auth.currentUser?.uid)!));
    final commentsAsync = ref.watch(commentsProvider(widget.submission.id));
    final textTheme = Theme.of(context).textTheme;
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;

    Future<void> refreshComments() async {
      ref.invalidate(commentsProvider(widget.submission.id));
      await ref.read(commentsProvider(widget.submission.id).future);
    }

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
                      onPressed: navigateBack,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1.0),
            Expanded(
              child: RefreshIndicator(
                onRefresh: refreshComments,
                child: commentsAsync.when(
                  loading: () => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: commentsListSkeleton,
                  ),
                  error: (e, _) => const EmptyState(
                    title: "Error",
                    icon: Icons.error,
                    subtitle: "Something went wrong!",
                  ),
                  data: (comments) => CommentsListSliver(
                    commentState: comments,
                    submission: widget.submission,
                    handleReply: handleReply,
                    scrollController: _scrollController,
                  ),
                ),
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
                      ...commentReactions.map((reaction) {
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
                        loading: () => profileImageSkeleton,
                        error: (e, _) => const SizedBox(height: 40, width: 40),
                        data: (user) => CustomImage(
                          imageProvider: NetworkImage(user!.profileImageUrl),
                          shape: CustomImageShape.circle,
                          width: 40,
                          height: 40,
                        ),
                      ),
                      Expanded(
                        child: CustomTextInput(
                          controller: _commentController,
                          hintText: "Add a comment...",
                          trailingButton: IconButton(
                            icon: Icon(Icons.send),
                            onPressed: _isCommentControllerEmpty || _isLoading
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
