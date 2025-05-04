import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:picture_that/screens/edit_profile_screen.dart';
import 'package:picture_that/screens/followers_screen.dart';
import 'package:picture_that/screens/settings_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:picture_that/models/prompt_model.dart';
import 'package:picture_that/models/submission_model.dart';
import 'package:picture_that/models/user_model.dart';
import 'package:picture_that/providers/submission_provider.dart';
import 'package:picture_that/providers/user_provider.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/utils/get_clean_url.dart';
import 'package:picture_that/utils/navigate.dart';
import 'package:picture_that/widgets/custom_image.dart';
import 'package:picture_that/widgets/custom_skeletonizer.dart';
import 'package:picture_that/widgets/custom_tooltip.dart';
import 'package:picture_that/widgets/submission.dart';
import 'package:picture_that/widgets/submission_list.dart';

/// TODO
/// add follow and unfollow logic
/// add share logic

final profileImageSize = 150.0;

final skeleton = CustomSkeletonizer(
  child: ListView(
    physics: const NeverScrollableScrollPhysics(),
    children: [
      ProfileHeader(
        user: UserModel(
          uid: "skeleton",
          firstName: "skeleton",
          lastName: "skeleton",
          username: "skeleton",
          followersCount: 100,
          followingCount: 100,
          submissionsCount: 100,
          profileImageUrl: "https://dummyimage.com/1x1/0011ff/0011ff.png",
        ),
        isSelf: false,
        onEditProfile: () {},
        onFollowToggle: () {},
        onShare: () {},
      ),
      Submission(
        heroContext: "skeleton${DateTime.now().toString()}",
        queryParam: SubmissionQueryParam(
          type: SubmissionQueryType.byRandom,
        ),
        submission: SubmissionModel(
          id: "skeleton",
          date: DateTime.now(),
          image: SubmissionImageModel(
            url: "https://dummyimage.com/1x1/0011ff/0011ff.png",
            height: 200,
            width: 300,
          ),
          caption: "skeleton",
          isLiked: false,
          likes: [],
          prompt: PromptSubmissionModel(
            id: "skeleton",
            title: "skeleton",
          ),
          user: UserModel(
            uid: "skeleton",
            firstName: "skeleton",
            lastName: "skeleton",
            followersCount: 0,
            followingCount: 0,
            submissionsCount: 0,
            profileImageUrl: "https://dummyimage.com/1x1/0011ff/0011ff.png",
            username: "skeleton",
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.userId == null) {
      return const Center(child: Text("No user found"));
    }

    final profileUid = widget.userId!;
    final isSelf = profileUid == auth.currentUser?.uid;
    final userAsync = ref.watch(userProvider(profileUid));

    void onEditProfile() => navigate(context, EditProfileScreen());

    void onFollowToggle() {
      // follow user logic here
    }

    void onShare() {
      // this url is just a placeholder, replace with actual url
      // in future when deep linking is implemented
      final url = "https://picturethat.com/${userAsync.value?.username}";
      final subject = isSelf ? "my" : "${userAsync.value?.firstName}'s";

      SharePlus.instance.share(ShareParams(
        text: "Check out $subject profile on Picture That: $url",
      ));
    }

    void onReportUser() {
      // report user logic here
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => isSelf
                ? [
                    PopupMenuItem(
                      value: "Settings",
                      onTap: () => navigate(context, SettingsScreen()),
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
            loading: () => skeleton,
            error: (e, _) => Text("Error: $e"),
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
                  loading: () => skeleton,
                  error: (e, _) => Text("Error: $e"),
                  data: (submissions) => SubmissionListSliver(
                    heroContext: profileUid,
                    isOnProfileTab: isSelf,
                    submissionState: submissions,
                    queryParam: queryParam,
                    bottomPadding: true,
                    header: ProfileHeader(
                      user: user,
                      isSelf: isSelf,
                      onEditProfile: onEditProfile,
                      onFollowToggle: onFollowToggle,
                      onShare: onShare,
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

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final bool isSelf;
  final VoidCallback onEditProfile;
  final VoidCallback onFollowToggle;
  final VoidCallback onShare;

  const ProfileHeader({
    required this.user,
    required this.isSelf,
    required this.onEditProfile,
    required this.onFollowToggle,
    required this.onShare,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () => navigate(
                    context,
                    FollowersScreen(
                      type: FollowersScreenType.followers,
                      userId: user.uid,
                    ),
                  ),
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
                  onPressed: () => navigate(
                    context,
                    FollowersScreen(
                      type: FollowersScreenType.following,
                      userId: user.uid,
                    ),
                  ),
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
                child: FilledButton(
                  onPressed: isSelf ? onEditProfile : onFollowToggle,
                  child: Text(
                    isSelf ? "Edit Profile" : "Follow",
                  ),
                ),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: onShare,
                  child: Text("Share"),
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
