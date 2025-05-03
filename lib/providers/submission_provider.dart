import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/models/submission_model.dart';
import 'package:picturethat/firebase_service.dart';
import 'package:picturethat/providers/auth_provider.dart';
import 'package:picturethat/providers/pagination_provider.dart';

enum SubmissionQueryType { byUser, byPrompt, byFollowing, byRandom }

// typedef SubmissionQueryParam = ({
//   SubmissionQueryType type,
//   String? id,
// });

class SubmissionQueryParam {
  final SubmissionQueryType type;
  final String? id;

  const SubmissionQueryParam({
    required this.type,
    this.id,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SubmissionQueryParam &&
        other.type == type &&
        other.id == id;
  }

  @override
  int get hashCode => type.hashCode ^ (id?.hashCode ?? 0);
}

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

  void addSubmission(SubmissionModel submission) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updatedItems = [submission, ...currentState.items];
    state = AsyncData(currentState.copyWith(items: updatedItems));
  }

  void deleteSubmission(String submissionId) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updatedItems = currentState.items
        .where((submission) => submission.id != submissionId)
        .toList();
    state = AsyncData(currentState.copyWith(items: updatedItems));
  }
}

final submissionNotifierProvider = AsyncNotifierProvider.family<
    SubmissionNotifier,
    PaginationState<SubmissionModel>,
    SubmissionQueryParam>(() => SubmissionNotifier());
