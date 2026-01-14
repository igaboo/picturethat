import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:picture_that/providers/notification_badge_provider.dart';
import 'package:picture_that/providers/relationship_provider.dart';
import 'package:picture_that/screens/edit_profile_screen.dart';
import 'package:picture_that/screens/followers_screen.dart';
import 'package:picture_that/screens/notifications_screen.dart';
import 'package:picture_that/screens/settings/settings_screen.dart';
import 'package:picture_that/screens/submit_photo_screen.dart';
import 'package:picture_that/screens/tabs/feed_screen.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/widgets/common/custom_button.dart';
import 'package:picture_that/widgets/empty_state.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:picture_that/models/submission_model.dart';
import 'package:picture_that/models/user_model.dart';
import 'package:picture_that/providers/submission_provider.dart';
import 'package:picture_that/providers/user_provider.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/widgets/common/custom_image.dart';
import 'package:picture_that/widgets/custom_skeletonizer.dart';
import 'package:picture_that/widgets/common/custom_tooltip.dart';
import 'package:picture_that/widgets/submission/submission.dart';
import 'package:picture_that/widgets/submission/submission_list.dart';

/// TODO
/// add follow and unfollow logic
/// add share logic

final profileImageSize = 150.0;

final profileSkeleton = CustomSkeletonizer(
  child: ListView(
    physics: const NeverScrollableScrollPhysics(),
    children: [
      ProfileHeader(
        user: getDummyUser(),
        isSelf: false,
        onEditProfile: () {},
        toggleFollow: () {},
        onShare: () {},
      ),
      Submission(
        heroContext: "skeleton${DateTime.now().toString()}",
        submission: getDummySubmission(),
      ),
    ],
  ),
);

class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId;

  const ProfileScreen({
    required this.userId,
    super.key,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with AutomaticKeepAliveClientMixin<ProfileScreen> {
  @override
  bool get wantKeepAlive => true;

  void onEditProfile() => navigate(const EditProfileScreen());

  void onShare(UserModel? user, bool isSelf) {
    // this url is just a placeholder, replace with actual url
    // in future when deep linking is implemented
    final url = "https://picturethat.com/${user?.username}";
    final subject = isSelf ? "my" : "${user?.firstName}'s";

    SharePlus.instance.share(ShareParams(
      text: "Check out $subject profile on Picture That: $url",
    ));
  }

  void onReportUser() {
    // report user logic here
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.userId == null) {
      return const Center(child: Text("No user found"));
    }

    final profileUid = widget.userId!;
    final isSelf = profileUid == auth.currentUser?.uid;
    final userAsync = ref.watch(userProvider(profileUid));
    final notificationsStreamAsync = ref.watch(hasUnseenNotificationsProvider);

    Future<void> refreshUser() async {
      ref.invalidate(userProvider(profileUid));
      await ref.read(userProvider(profileUid).future);
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (isSelf)
            notificationsStreamAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
              data: (isNew) {
                return IconButton(
                  icon: Badge(
                    isLabelVisible: isNew,
                    smallSize: 10.0,
                    child: const Icon(Icons.notifications_outlined),
                  ),
                  onPressed: () => navigate(const NotificationsScreen()),
                );
              },
            ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => isSelf
                ? [
                    PopupMenuItem(
                      value: "Settings",
                      onTap: () => navigate(const SettingsScreen()),
                      child: Row(
                        spacing: 8.0,
                        children: [
                          Icon(Icons.settings),
                          Text("Settings"),
                        ],
                      ),
                    ),
                  ]
                : [
                    PopupMenuItem(
                      value: "Report",
                      onTap: onReportUser,
                      child: Row(
                        spacing: 8.0,
                        children: [
                          Icon(Icons.report),
                          Text("Report User"),
                        ],
                      ),
                    ),
                  ],
          )
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          userAsync.when(
            loading: () => profileSkeleton,
            error: (e, _) => ErrorEmptyState(
              callback: refreshUser,
              description:
                  "An error occurred while fetching the user profile. Try again later.",
            ),
            data: (user) {
              if (user == null) return const Text("No user found");

              final queryParam = SubmissionQueryParam(
                type: SubmissionQueryType.byUser,
                id: user.uid,
              );
              final feedAsync = ref.watch(submissionProvider(queryParam));

              Future<void> refreshSubmissions() async {
                ref.invalidate(userProvider(profileUid));
                ref.invalidate(submissionProvider(queryParam));

                await Future.wait([
                  ref.read(userProvider(profileUid).future),
                  ref.read(submissionProvider(queryParam).future),
                ]);
              }

              return RefreshIndicator(
                onRefresh: refreshSubmissions,
                child: feedAsync.when(
                  loading: () => profileSkeleton,
                  error: (e, _) => ErrorEmptyState(
                    callback: refreshSubmissions,
                    description:
                        "An error occurred while fetching the submissions list. Try again later.",
                  ),
                  data: (submissions) => SubmissionListSliver(
                    emptyState: isSelf
                        ? EmptyState(
                            title: "No Submissions",
                            icon: Icons.hide_image,
                            subtitle:
                                "You haven't submitted any photos yet. Upload your first photo to today's prompt!",
                            action: (
                              label: "Upload Photo",
                              onPressed: () {
                                navigate(const SubmitPhotoScreen());
                              }
                            ),
                          )
                        : null,
                    heroContext: profileUid,
                    isOnProfileTab: isSelf,
                    submissionState: submissions,
                    queryParam: queryParam,
                    bottomPadding: true,
                    header: ProfileHeader(
                      user: user,
                      isSelf: isSelf,
                      onEditProfile: onEditProfile,
                      toggleFollow: () async =>
                          await toggleFollow(context, ref, profileUid),
                      onShare: () => onShare(user, isSelf),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomTooltip(
              key: ValueKey(isSelf ? "profileTooltip" : "otherProfileTooltip"),
              tooltipId: isSelf ? "profileTooltip" : "otherProfileTooltip",
              title: isSelf ? "Your Profile" : "User Profiles",
              message: isSelf
                  ? "This is your profile, where other users can find your submissions and see your connections."
                  : "Here, you can see other's submissions and follow them to see their new submissions in your feed.",
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileHeader extends ConsumerWidget {
  final UserModel user;
  final bool isSelf;
  final VoidCallback onEditProfile;
  final VoidCallback toggleFollow;
  final VoidCallback onShare;

  const ProfileHeader({
    required this.user,
    required this.isSelf,
    required this.onEditProfile,
    required this.toggleFollow,
    required this.onShare,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ensures widget is rebuilt when user is followed or unfollowed
    ref.watch(relationshipProvider);
    final relationshipNotifier = ref.watch(relationshipProvider.notifier);
    final isFollowing = relationshipNotifier.isFollowing(user.uid);
    final isFollower = relationshipNotifier.isFollower(user.uid);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final userHasBio = user.bio != null && user.bio!.isNotEmpty;
    final userHasUrl = user.url != null && user.url!.isNotEmpty;

    return Column(
      spacing: 20.0,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomImageViewer(
          heroTag: user.uid,
          actions: [
            if (isSelf)
              CustomButton(
                label: "Edit Profile Image",
                onPressed: () {
                  navigateBack();
                  navigate(const EditProfileScreen());
                },
              ),
            IconButton.filledTonal(
              icon: const Icon(Icons.share),
              onPressed: onShare,
            ),
          ],
          customImage: CustomImage(
            key: ValueKey(user.uid),
            imageProvider: NetworkImage(user.profileImageUrl),
            shape: CustomImageShape.circle,
            height: profileImageSize,
            width: profileImageSize,
          ),
        ),
        Column(
          children: [
            Text(
              "${user.firstName} ${user.lastName}",
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall,
            ),
            Row(
              spacing: 5.0,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "@${user.username}",
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                if (userHasUrl) const Text("·"),
                if (userHasUrl)
                  GestureDetector(
                    onTap: () => launchUrl(Uri.parse(user.url!)),
                    child: Text(
                      getCleanUrl(user.url!),
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium!.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            )
          ],
        ),
        if (userHasBio)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      user.submissionsCount.toString(),
                      style: textTheme.titleLarge,
                    ),
                    Text(
                      Intl.plural(
                        user.submissionsCount,
                        one: "submission",
                        other: "submissions",
                      ),
                      style: textTheme.bodyMedium,
                    )
                  ],
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => navigate(FollowersScreen(
                    type: FollowersScreenType.followers,
                    userId: user.uid,
                  )),
                  child: Column(
                    children: [
                      Text(
                        user.followersCount.toString(),
                        style: textTheme.titleLarge,
                      ),
                      Text(
                        Intl.plural(
                          user.followersCount,
                          one: "follower",
                          other: "followers",
                        ),
                        style: textTheme.bodyMedium,
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => navigate(FollowersScreen(
                    type: FollowersScreenType.following,
                    userId: user.uid,
                  )),
                  child: Column(
                    children: [
                      Text(
                        user.followingCount.toString(),
                        style: textTheme.titleLarge,
                      ),
                      Text("following", style: textTheme.bodyMedium)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            spacing: 16.0,
            children: [
              Expanded(
                child: CustomButton(
                  label: isSelf
                      ? "Edit Profile"
                      : isFollowing
                          ? "Unfollow"
                          : "Follow${isFollower ? " back" : ""}",
                  onPressed: isSelf ? onEditProfile : toggleFollow,
                  type: isSelf
                      ? CustomButtonType.outlined
                      : isFollowing
                          ? CustomButtonType.outlined
                          : CustomButtonType.filled,
                ),
              ),
              Expanded(
                child: CustomButton(
                  label: "Share",
                  onPressed: onShare,
                  type: CustomButtonType.outlined,
                ),
              ),
            ],
          ),
        ),
        SizedBox.shrink() // Placeholder for spacing
      ],
    );
  }
}
