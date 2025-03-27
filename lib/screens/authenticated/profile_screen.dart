import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/providers/user_provider.dart';
import 'package:picturethat/widgets/custom_image.dart';

final PROFILE_IMAGE_SIZE = 180.0;

class ProfileScreen extends ConsumerWidget {
  final String? uid;

  const ProfileScreen({
    this.uid,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

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

          return SingleChildScrollView(
            child: Container(
              width: double.infinity,
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
                        style: Theme.of(context).textTheme.headlineSmall,
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
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                "submissions",
                                style: Theme.of(context).textTheme.bodyMedium,
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
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  "followers",
                                  style: Theme.of(context).textTheme.bodyMedium,
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
                  // Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      spacing: 16.0,
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () => {},
                            child: Text("Follow"),
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
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
