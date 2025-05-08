import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/models/relationship_model.dart';
import 'package:picture_that/providers/auth_provider.dart';

class RelationshipNotifier extends AsyncNotifier<
    ({List<RelationshipModel> followers, List<RelationshipModel> following})> {
  @override
  Future<
      ({
        List<RelationshipModel> followers,
        List<RelationshipModel> following
      })> build() async {
    // ensures auth state is loaded, will reset all state when auth changes
    ref.watch(authProvider);

    return await getRelationships();
  }

  bool isFollowing(String userId) {
    final currentState = state.valueOrNull;
    if (currentState == null) return false;

    return currentState.following.any((r) => r.following == userId);
  }

  bool isFollower(String userId) {
    final currentState = state.valueOrNull;
    if (currentState == null) return false;

    return currentState.followers.any((r) => r.follower == userId);
  }

  void addRelationship(RelationshipModel relationship) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncValue.data((
      followers: currentState.followers,
      following: [...currentState.following, relationship],
    ));
  }

  void removeRelationship(String userId) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncValue.data((
      followers: currentState.followers,
      following:
          currentState.following.where((r) => r.following != userId).toList(),
    ));
  }

  RelationshipModel? getRelationship(String userId) {
    final currentState = state.valueOrNull;
    if (currentState == null) return null;

    return currentState.following.firstWhere((r) => r.following == userId);
  }
}

final relationshipProvider = AsyncNotifierProvider<
    RelationshipNotifier,
    ({
      List<RelationshipModel> followers,
      List<RelationshipModel> following
    })>(() => RelationshipNotifier());
