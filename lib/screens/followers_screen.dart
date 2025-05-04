import 'package:flutter/material.dart';

/// TODO
/// fetch user relationships based off of following/followers
/// fetch user documents from relationship documents
/// display user documents in a list
///

enum FollowersScreenType { followers, following }

class FollowersScreen extends StatelessWidget {
  final FollowersScreenType type;
  final String userId;

  const FollowersScreen({
    required this.type,
    required this.userId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final typeString =
        type == FollowersScreenType.followers ? "Followers" : "Following";

    return Scaffold(
      appBar: AppBar(title: Text(typeString)),
      body: Center(child: Text("$typeString Screen")),
    );
  }
}
