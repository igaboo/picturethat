import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/providers/user_provider.dart';
import 'package:picturethat/widgets/custom_image.dart';

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
                    height: 120.0,
                    width: 120.0,
                    borderRadius: 120.0 / 2.0,
                  ),
                  Column(
                    children: [
                      Text(
                        "${user.firstName} ${user.lastName}",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        user.username,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
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
                        Column(
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
                      ],
                    ),
                  ),
                  // Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      spacing: 10.0,
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
