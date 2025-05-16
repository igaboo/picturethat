import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/models/user_model.dart';
import 'package:picture_that/providers/relationship_provider.dart';
import 'package:picture_that/screens/tabs/profile_screen.dart';
import 'package:picture_that/utils/show_snackbar.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/widgets/custom_image.dart';
import 'package:picture_that/widgets/custom_button.dart';
import 'package:picture_that/widgets/empty_state.dart';
import 'package:picture_that/widgets/custom_skeletonizer.dart';

enum FollowersScreenType { followers, following }

class FollowersScreen extends ConsumerStatefulWidget {
  final FollowersScreenType type;
  final String userId;

  const FollowersScreen({
    super.key,
    required this.type,
    required this.userId,
  });

  @override
  ConsumerState<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends ConsumerState<FollowersScreen> {
  List<UserSearchResultModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final results = await getRelationshipsForUser(
          userId: widget.userId,
          getFollowers: widget.type == FollowersScreenType.followers);
      if (mounted) setState(() => _users = results);
    } catch (e) {
      customShowSnackbar(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == FollowersScreenType.followers
        ? "Followers"
        : "Following";

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: CustomSkeletonizer(
          child: ListTile(title: Text("Loading...")),
        ),
      );
    }

    if (_users.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: EmptyState(
          title: widget.type == FollowersScreenType.followers
              ? "No followers yet"
              : "Not following anyone yet",
          icon: Icons.person_off,
          subtitle: widget.type == FollowersScreenType.followers
              ? "Once someone follows, they’ll show up here"
              : "Once you follow someone, they’ll show up here",
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          return FollowerItem(user: _users[index]);
        },
      ),
    );
  }
}

class FollowerItem extends ConsumerWidget {
  final UserSearchResultModel user;

  const FollowerItem({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(relationshipProvider);
    final relationshipNotifier = ref.read(relationshipProvider.notifier);
    final isFollowing = relationshipNotifier.isFollowing(user.uid);
    final isFollower = relationshipNotifier.isFollower(user.uid);
    final isSelf = user.uid == auth.currentUser?.uid;

    return ListTile(
      leading: CustomImage(
        imageProvider: NetworkImage(user.profileImageUrl),
        shape: CustomImageShape.circle,
        width: 40,
        height: 40,
      ),
      title: Text("${user.firstName} ${user.lastName}"),
      subtitle: Text("@${user.username}"),
      trailing: isSelf
          ? null
          : SizedBox(
              width: 130,
              child: CustomButton(
                label: isFollowing
                    ? "Unfollow"
                    : "Follow${isFollower ? " back" : ""}",
                onPressed: () => toggleFollow(context, ref, user.uid),
                type: isFollowing
                    ? CustomButtonType.outlined
                    : CustomButtonType.filled,
              ),
            ),
      onTap: () => navigate(ProfileScreen(userId: user.uid)),
    );
  }
}
