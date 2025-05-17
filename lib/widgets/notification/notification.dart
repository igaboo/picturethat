import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/models/notification_model.dart';
import 'package:picture_that/providers/relationship_provider.dart';
import 'package:picture_that/screens/tabs/profile_screen.dart';
import 'package:picture_that/utils/constants.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/widgets/common/custom_button.dart';
import 'package:picture_that/widgets/common/custom_image.dart';

class CustomNotification extends ConsumerWidget {
  final NotificationModel notification;
  final bool isNotificationNew;

  const CustomNotification({
    required this.notification,
    required this.isNotificationNew,
    super.key,
  });

  String _getActionText() {
    switch (notification.type) {
      case NotificationType.comment:
        return " commented on your post: ${notification.commentText}";
      case NotificationType.like:
        return " liked your post.";
      case NotificationType.follow:
        return " started following you.";
    }
  }

  Widget _buildContent(ColorScheme colorScheme, TextTheme textTheme) {
    return RichText(
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
              ..onTap =
                  () => navigate(ProfileScreen(userId: notification.senderId)),
          ),
          TextSpan(text: _getActionText()),
          TextSpan(
            text: getTimeElapsed(notification.createdAt, isShort: true),
            style: textTheme.bodyMedium!.copyWith(
              color: colorScheme.onSurface.withAlpha(155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailing(
    BuildContext context,
    WidgetRef ref,
    bool isFollowing,
    bool isFollower,
  ) {
    if (notification.type == NotificationType.follow) {
      return SizedBox(
        width: 130, // Maintain consistent button width
        child: CustomButton(
          label:
              isFollowing ? "Unfollow" : "Follow${isFollower ? " back" : ""}",
          onPressed: () => toggleFollow(context, ref, notification.senderId),
          type:
              isFollowing ? CustomButtonType.outlined : CustomButtonType.filled,
        ),
      );
    }

    return CustomImage(
      imageProvider:
          NetworkImage(notification.submissionImageUrl ?? dummyImageUrl),
      width: 45,
      height: 45,
      borderRadius: 10.0,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // ensures widget is rebuilt when user is followed or unfollowed
    ref.watch(relationshipProvider);
    final relationshipNotifier = ref.watch(relationshipProvider.notifier);
    final isFollowing = relationshipNotifier.isFollowing(notification.senderId);
    final isFollower = relationshipNotifier.isFollower(notification.senderId);

    return ListTile(
      onTap: () {
        // navigate to the submission detail screen
      },
      tileColor: isNotificationNew ? colorScheme.surfaceContainerHigh : null,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      leading: GestureDetector(
        onTap: () => navigate(ProfileScreen(userId: notification.senderId)),
        child: CustomImage(
          imageProvider: NetworkImage(notification.senderImageUrl),
          width: 45,
          height: 45,
          shape: CustomImageShape.circle,
        ),
      ),
      title: _buildContent(colorScheme, textTheme),
      trailing: _buildTrailing(context, ref, isFollowing, isFollower),
    );
  }
}
