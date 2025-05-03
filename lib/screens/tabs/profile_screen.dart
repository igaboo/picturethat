import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:picturethat/models/prompt_model.dart';
import 'package:picturethat/models/submission_model.dart';
import 'package:picturethat/models/user_model.dart';
import 'package:picturethat/providers/submission_provider.dart';
import 'package:picturethat/providers/user_provider.dart';
import 'package:picturethat/firebase_service.dart';
import 'package:picturethat/utils/get_clean_url.dart';
import 'package:picturethat/utils/navigate.dart';
import 'package:picturethat/widgets/custom_image.dart';
import 'package:picturethat/widgets/custom_skeletonizer.dart';
import 'package:picturethat/widgets/custom_tooltip.dart';
import 'package:picturethat/widgets/submission.dart';
import 'package:picturethat/widgets/submission_list.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

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
  const ProfileScreen({super.key});

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

    final uid = ModalRoute.of(context)?.settings.arguments as String?;
    final profileUserId = uid ?? auth.currentUser?.uid;
    final isSelf = profileUserId == auth.currentUser?.uid;
    final userAsync = ref.watch(userProvider(profileUserId!));

    void onEditProfile() {
      navigate(context, "/edit_profile_screen");
    }

    void onFollowToggle() {
      // follow user logic here
    }

    void onShare() {
      // share user profile logic here
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
                      onTap: () => navigate(context, "/settings_screen"),
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
              final feedAsync =
                  ref.watch(submissionNotifierProvider(queryParam));

              Future<void> refreshSubmissions() async {
                ref.invalidate(userProvider(profileUserId));
                ref.invalidate(submissionNotifierProvider(queryParam));

                await Future.wait([
                  ref.read(userProvider(profileUserId).future),
                  ref.read(submissionNotifierProvider(queryParam).future),
                ]);
              }

              return RefreshIndicator(
                onRefresh: refreshSubmissions,
                child: feedAsync.when(
                  loading: () => skeleton,
                  error: (e, _) => Text("Error: $e"),
                  data: (submissions) => SubmissionListSliver(
                    heroContext: profileUserId,
                    disableNavigation: isSelf,
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
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Row(
              spacing: 5.0,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "@${user.username}",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (userHasUrl) const Text("·"),
                if (userHasUrl)
                  GestureDetector(
                    onTap: () => launchUrl(Uri.parse(user.url!)),
                    child: Text(
                      getCleanUrl(user.url!),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
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
              style: Theme.of(context).textTheme.bodyMedium,
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
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      Intl.plural(
                        user.submissionsCount,
                        one: "submission",
                        other: "submissions",
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  ],
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => navigate(
                    context,
                    "/followers_screen",
                    arguments: {
                      "type": "Followers",
                      "uid": user.uid,
                    },
                  ),
                  child: Column(
                    children: [
                      Text(
                        user.followersCount.toString(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        Intl.plural(
                          user.followersCount,
                          one: "follower",
                          other: "followers",
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => navigate(
                    context,
                    "/followers_screen",
                    arguments: {
                      "type": "Following",
                      "uid": user.uid,
                    },
                  ),
                  child: Column(
                    children: [
                      Text(
                        user.followingCount.toString(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        "following",
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
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
