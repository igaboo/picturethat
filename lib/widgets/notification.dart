import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/models/notification_model.dart';
import 'package:picture_that/providers/relationship_provider.dart';
import 'package:picture_that/screens/tabs/profile_screen.dart';
import 'package:picture_that/utils/constants.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/widgets/custom_button.dart';
import 'package:picture_that/widgets/custom_image.dart';

class CustomNotification extends ConsumerWidget {
  final NotificationModel notification;
  final bool isNotificationNew;

  const CustomNotification({
    required this.notification,
    required this.isNotificationNew,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // ensures widget is rebuilt when user is followed or
    ref.watch(relationshipProvider);
    final relationshipNotifier = ref.watch(relationshipProvider.notifier);
    final isFollowing = relationshipNotifier.isFollowing(notification.senderId);
    final isFollower = relationshipNotifier.isFollower(notification.senderId);

    return Container(
      color: isNotificationNew ? colorScheme.surfaceContainerHigh : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          spacing: 16.0,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () =>
                  navigate(ProfileScreen(userId: notification.senderId)),
              child: CustomImage(
                imageProvider: NetworkImage(notification.senderImageUrl),
                width: 45,
                height: 45,
                shape: CustomImageShape.circle,
              ),
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 45),
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    children: [
                      TextSpan(
                        text: notification.senderUsername,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => navigate(
                              ProfileScreen(userId: notification.senderId)),
                      ),
                      TextSpan(
                        text: notification.type == NotificationType.comment
                            ? " commented on your post: ${notification.commentText} "
                            : notification.type == NotificationType.like
                                ? " liked your post. "
                                : " started following you. ",
                      ),
                      TextSpan(
                        text: getTimeElapsed(notification.createdAt,
                            isShort: true),
                        style: textTheme.bodyMedium!.copyWith(
                          color: colorScheme.onSurface.withAlpha(155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            notification.type == NotificationType.follow
                ? SizedBox(
                    width: 130,
                    child: CustomButton(
                      label: isFollowing
                          ? "Unfollow"
                          : "Follow${isFollower ? " back" : ""}",
                      onPressed: () =>
                          toggleFollow(context, ref, notification.senderId),
                      type: isFollowing
                          ? CustomButtonType.outlined
                          : CustomButtonType.filled,
                    ),
                  )
                : GestureDetector(
                    onTap: () {
                      // navigate to the submission detail screen
                    },
                    child: CustomImage(
                      imageProvider: NetworkImage(
                          notification.submissionImageUrl ?? dummyImageUrl),
                      width: 45,
                      height: 45,
                      borderRadius: 10.0,
                    ),
                  )
          ],
        ),
      ),
    );

    //   return ListTile(
    //     onTap: () => navigate(ProfileScreen(userId: notification.senderId)),
    //     contentPadding: const EdgeInsets.symmetric(
    //       vertical: 16.0,
    //       horizontal: 16.0,
    //     ),
    //     // tileColor: colorScheme.surfaceContainerHigh,
    //     leading: CustomImage(
    //       imageProvider: NetworkImage(notification.senderImageUrl),
    //       width: 45,
    //       height: 45,
    //       shape: CustomImageShape.circle,
    //     ),
    //     trailing: notification.type == NotificationType.follow
    //         ? SizedBox(
    //             width: 130,
    //             child: CustomButton(
    //               label: isFollowing
    //                   ? "Unfollow"
    //                   : "Follow${isFollower ? " back" : ""}",
    //               onPressed: () =>
    //                   toggleFollow(context, ref, notification.senderId),
    //               type: isFollowing
    //                   ? CustomButtonType.outlined
    //                   : CustomButtonType.filled,
    //             ),
    //           )
    //         : CustomImage(
    //             imageProvider: NetworkImage(
    //                 notification.submissionImageUrl ?? dummyImageUrl),
    //             width: 45,
    //             height: 45,
    //             borderRadius: 10.0,
    //           ),
    //     title: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         RichText(
    //           text: TextSpan(
    //             style: textTheme.bodyMedium?.copyWith(
    //               color: colorScheme.onSurface,
    //             ),
    //             children: [
    //               TextSpan(
    //                 text: notification.senderUsername,
    //                 style: textTheme.bodyMedium?.copyWith(
    //                   fontWeight: FontWeight.bold,
    //                 ),
    //               ),
    //               TextSpan(
    //                 text: notification.type == NotificationType.comment
    //                     ? " commented on your post: ${notification.commentText} "
    //                     : notification.type == NotificationType.like
    //                         ? " liked your post. "
    //                         : " started following you. ",
    //               ),
    //               TextSpan(
    //                 text: getTimeElapsed(notification.createdAt),
    //                 style: textTheme.bodyMedium!.copyWith(
    //                   color: colorScheme.onSurface.withAlpha(155),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
  }
}
