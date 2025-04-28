import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/models/submission_model.dart';
import 'package:picturethat/models/user_model.dart';
import 'package:picturethat/firebase_service.dart';
import 'package:picturethat/providers/auth_provider.dart';
import 'package:picturethat/providers/pagination_provider.dart';

enum SubmissionQueryType { byUser, byPrompt, byFollowing, byRandom }

typedef SubmissionQueryParam = ({
  SubmissionQueryType type,
  String? id,
  UserModel? user
});

Future<({List<SubmissionModel> items, DocumentSnapshot? lastDoc})>
    getSubmissionsAdapter({
  required SubmissionQueryParam arg,
  required int limit,
  DocumentSnapshot? lastDocument,
}) {
  return getSubmissions(
    queryParam: arg,
    limit: limit,
    lastDocument: lastDocument,
    user: arg.user,
  );
}

class SubmissionNotifier extends PaginatedFamilyAsyncNotifier<SubmissionModel,
    SubmissionQueryParam> {
  @override
  int get pageSize => 3;

  @override
  FetchPageWithArg<SubmissionModel, SubmissionQueryParam> get fetchPage =>
      getSubmissionsAdapter;

  @override
  Future<PaginationState<SubmissionModel>> build(
    SubmissionQueryParam arg,
  ) async {
    // ensures auth state is loaded, will reset all state when auth changes
    ref.watch(authProvider);

    final result = await fetchPage(
      arg: arg,
      limit: pageSize,
      lastDocument: null,
    );

    return PaginationState<SubmissionModel>(
      items: result.items,
      lastDocument: result.lastDoc,
      hasNextPage: result.items.length == pageSize,
    );
  }

  Future<void> toggleSubmissionLike({
    required String submissionId,
    required bool isLiked,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updatedItems = currentState.items.map((submission) {
      if (submission.id == submissionId) {
        return submission.copyWith(
          isLiked: !isLiked,
          likes: isLiked
              ? submission.likes
                  .where((id) => id != auth.currentUser!.uid)
                  .toList()
              : [...submission.likes, auth.currentUser!.uid],
        );
      }
      return submission;
    }).toList();

    state = AsyncData(currentState.copyWith(items: updatedItems));

    await toggleLike(
      submissionId: submissionId,
      uid: auth.currentUser!.uid,
      isLiked: isLiked,
    );
  }
}

final submissionNotifierProvider = AsyncNotifierProvider.family<
    SubmissionNotifier,
    PaginationState<SubmissionModel>,
    SubmissionQueryParam>(() => SubmissionNotifier());
