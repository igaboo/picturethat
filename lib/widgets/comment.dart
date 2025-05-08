import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/models/comment_model.dart';
import 'package:picture_that/models/submission_model.dart';
import 'package:picture_that/providers/comment_provider.dart';
import 'package:picture_that/screens/tabs/profile_screen.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/utils/show_dialog.dart';
import 'package:picture_that/widgets/custom_image.dart';

class Comment extends ConsumerWidget {
  final CommentModel comment;
  final SubmissionModel? submission;
  final Function(String) handleReply;

  const Comment({
    required this.comment,
    required this.handleReply,
    this.submission,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isSelf = comment.user.uid == auth.currentUser?.uid;

    Future<void> handleDelete() async {
      if (submission == null) return;

      await deleteComment(commentId: comment.id);

      ref
          .read(commentsProvider(comment.submissionId).notifier)
          .removeComment(comment.id);

      updateCommentCountHelper(
        context: context,
        ref: ref,
        isIncrementing: false,
        submission: submission!,
      );
    }

    return Row(
      spacing: 8.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => navigate(ProfileScreen(userId: comment.user.uid)),
          child: CustomImage(
            imageProvider: NetworkImage(comment.user.profileImageUrl),
            shape: CustomImageShape.circle,
            width: 40,
            height: 40,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 8.0,
                children: [
                  GestureDetector(
                    onTap: () => navigate(
                      ProfileScreen(userId: comment.user.uid),
                    ),
                    child: Text(
                      "@${comment.user.username}",
                      style: textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  PopupMenuButton(
                    icon: Icon(
                      Icons.more_horiz,
                      color: colorScheme.primary,
                    ),
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      padding: WidgetStatePropertyAll(EdgeInsets.zero),
                      minimumSize: WidgetStatePropertyAll(Size.zero),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.center,
                    ),
                    onSelected: (value) {
                      if (value == "delete") {
                        customShowDialog(
                          context: context,
                          title: "Delete Comment",
                          content:
                              "Are you sure you want to delete this comment?",
                          onPressed: handleDelete,
                        );
                      } else if (value == "report") {
                        // Handle report action
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
                                    "Delete Comment",
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
                                  Text("Report Comment"),
                                ],
                              ),
                            ),
                    ],
                  ),
                ],
              ),
              Text(comment.text),
              const SizedBox(height: 4.0),
              Text(getTimeElapsed(comment.date), style: textTheme.bodySmall)
            ],
          ),
        ),
        IconButton(
          onPressed: () => handleReply(comment.user.username),
          icon: Icon(Icons.keyboard_return, color: colorScheme.primary),
        )
      ],
    );
  }
}
