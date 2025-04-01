import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:picturethat/providers/submission_provider.dart';
import 'package:picturethat/providers/user_provider.dart';
import 'package:picturethat/firebase_service.dart';
import 'package:picturethat/utils/get_clean_url.dart';
import 'package:picturethat/widgets/custom_image.dart';
import 'package:picturethat/widgets/submission_list.dart';
import 'package:url_launcher/url_launcher.dart';

/// TODO
/// add follow and unfollow logic
/// add share logic

final PROFILE_IMAGE_SIZE = 150.0;

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ModalRoute.of(context)?.settings.arguments as String?;
    final profileUserId = uid ?? auth.currentUser?.uid;
    final isSelf = profileUserId == auth.currentUser?.uid;
    final userAsync = ref.watch(userProvider(profileUserId!));

    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => isSelf
                ? [
                    PopupMenuItem(
                      value: "Settings",
                      child: Row(
                        spacing: 8.0,
                        children: [
                          Icon(Icons.settings),
                          Text("Settings"),
                        ],
                      ),
                      onTap: () =>
                          Navigator.pushNamed(context, "/settings_screen"),
                    ),
                  ]
                : [
                    PopupMenuItem(
                      value: "Report",
                      child: Row(
                        spacing: 8.0,
                        children: [
                          Icon(Icons.report),
                          Text("Report User"),
                        ],
                      ),
                      onTap: () {},
                    ),
                  ],
          )
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text("Error: $e"),
        data: (user) {
          if (user == null) {
            return const Text("No user found");
          }

          final userHasBio = user.bio != null && user.bio!.isNotEmpty;
          final userHasUrl = user.url != null && user.url!.isNotEmpty;

          final queryParam = (
            type: SubmissionQueryType.byUser,
            id: user.uid,
            user: user,
          );
          final feedAsync = ref.watch(submissionNotifierProvider(queryParam));

          Future<void> refreshSubmissions() async {
            ref.invalidate(submissionNotifierProvider(queryParam));
            await ref.read(submissionNotifierProvider(queryParam).future);
          }

          Future<void> handleButtonPress() async {
            if (isSelf) {
              Navigator.pushNamed(context, "/edit_profile_screen");
              return;
            }
            // follow user logic here
          }

          return feedAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text("Error: $e"),
            data: (submissions) {
              return RefreshIndicator(
                onRefresh: refreshSubmissions,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        spacing: 20.0,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomNetworkImage(
                            url: user.profileImageUrl,
                            height: PROFILE_IMAGE_SIZE,
                            width: PROFILE_IMAGE_SIZE,
                            borderRadius: PROFILE_IMAGE_SIZE / 2,
                          ),
                          Column(
                            children: [
                              Text(
                                "${user.firstName} ${user.lastName}",
                                textAlign: TextAlign.center,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              Row(
                                spacing: 5.0,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "@${user.username}",
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  if (userHasUrl) const Text("·"),
                                  if (userHasUrl)
                                    GestureDetector(
                                      onTap: () =>
                                          launchUrl(Uri.parse(user.url!)),
                                      child: Text(
                                        getCleanUrl(user.url!),
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                      ),
                                    ),
                                ],
                              )
                            ],
                          ),
                          if (userHasBio)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32.0),
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      Text(
                                        Intl.plural(
                                          user.submissionsCount,
                                          one: "submission",
                                          other: "submissions",
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => Navigator.pushNamed(
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
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                        Text(
                                          "followers",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => Navigator.pushNamed(
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
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                        Text(
                                          "following",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              spacing: 16.0,
                              children: [
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () => handleButtonPress(),
                                    child: Text(
                                      isSelf ? "Edit Profile" : "Follow",
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => {},
                                    child: Text("Share"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SubmissionListSliver(
                      submissions: submissions,
                      queryParam: queryParam,
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
