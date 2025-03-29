import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/providers/submission_provider.dart';
import 'package:picturethat/providers/user_provider.dart';
import 'package:picturethat/firebase_service.dart';
import 'package:picturethat/widgets/custom_image.dart';
import 'package:picturethat/widgets/submission_list.dart';

final PROFILE_IMAGE_SIZE = 150.0;

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ModalRoute.of(context)?.settings.arguments as String?;
    final profileUserId = uid ?? auth.currentUser?.uid;
    final userAsync = ref.watch(userProvider(profileUserId!));

    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == "Edit") {
                Navigator.pushNamed(context, "/edit_profile_screen");
              } else if (value == "Settings") {
                Navigator.pushNamed(context, "/settings_screen");
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "Edit",
                child: Row(
                  spacing: 8.0,
                  children: [
                    Icon(Icons.edit),
                    Text("Edit Profile"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "Settings",
                child: Row(
                  spacing: 8.0,
                  children: [
                    Icon(Icons.settings),
                    Text("Settings"),
                  ],
                ),
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

          final queryParam =
              (type: SubmissionQueryType.byUser, id: user.uid, user: user);
          final feedAsync = ref.watch(submissionNotifierProvider(queryParam));

          Future<void> refreshSubmissions() async {
            ref.invalidate(submissionNotifierProvider(queryParam));
            await ref.read(submissionNotifierProvider(queryParam).future);
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
                              Text(
                                "@${user.username}",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          // Stats
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                // Submissions
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        "0",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      Text(
                                        "submissions",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      )
                                    ],
                                  ),
                                ),
                                // Followers
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
                                // Following
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
                          // Buttons
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              spacing: 16.0,
                              children: [
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      "/edit_profile_screen",
                                    ),
                                    child: Text(
                                      "Edit Profile",
                                    ), // "follow" if not self
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
                    SliverPadding(
                      padding: EdgeInsets.only(top: 20.0),
                      sliver: SubmissionListSliver(
                        submissions: submissions,
                        queryParam: queryParam,
                      ),
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
