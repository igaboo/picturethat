import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/models/user_model.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/providers/auth_provider.dart';

class UserNotifier extends FamilyAsyncNotifier<UserModel?, String?> {
  @override
  Future<UserModel?> build(String? arg) async {
    // ensures auth state is loaded, will reset all state when auth changes
    ref.watch(authProvider);

    if (arg == null) return null;

    return getUser(userId: arg);
  }

  void updateUser(Map<String, dynamic> updates) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updatedUser = currentState.copyWith(
      firstName: updates['firstName'],
      lastName: updates['lastName'],
      bio: updates['bio'],
      profileImageUrl: updates['profileImageUrl'],
      url: updates['url'],
      username: updates['username'],
      followersCount: updates['followersCount'],
      followingCount: updates['followingCount'],
      submissionsCount: updates['submissionsCount'],
    );

    state = AsyncData(updatedUser);
  }

  void updateSubmissionsCount(bool isIncrementing) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updatedUser = currentState.copyWith(
      submissionsCount:
          currentState.submissionsCount + (isIncrementing ? 1 : -1),
    );

    state = AsyncData(updatedUser);
  }

  void updateFollowingCount(bool isIncrementing) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updatedUser = currentState.copyWith(
      followingCount: currentState.followingCount + (isIncrementing ? 1 : -1),
    );

    state = AsyncData(updatedUser);
  }

  void updateFollowersCount(bool isIncrementing) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updatedUser = currentState.copyWith(
      followersCount: currentState.followersCount + (isIncrementing ? 1 : -1),
    );

    state = AsyncData(updatedUser);
  }
}

final userProvider =
    AsyncNotifierProvider.family<UserNotifier, UserModel?, String?>(
  () => UserNotifier(),
);
