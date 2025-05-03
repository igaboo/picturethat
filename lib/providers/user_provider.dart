import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/models/user_model.dart';
import 'package:picturethat/firebase_service.dart';
import 'package:picturethat/providers/auth_provider.dart';

class UserNotifier extends FamilyAsyncNotifier<UserModel?, String> {
  @override
  Future<UserModel?> build(String arg) async {
    // ensures auth state is loaded, will reset all state when auth changes
    ref.watch(authProvider);
    return getUser(userId: arg);
  }

  Future<void> updateUser(Map<String, dynamic> updates) async {
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
}

final userProvider =
    AsyncNotifierProvider.family<UserNotifier, UserModel?, String>(
  () => UserNotifier(),
);
