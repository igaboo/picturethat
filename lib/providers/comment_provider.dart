import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/models/comment_model.dart';
import 'package:picture_that/providers/auth_provider.dart';
import 'package:picture_that/providers/pagination_provider.dart';

Future<({List<CommentModel> items, DocumentSnapshot? lastDoc})>
    getCommentsAdapter({
  required String arg,
  required int limit,
  DocumentSnapshot? lastDocument,
}) {
  return getComments(
    submissionId: arg,
    limit: limit,
    lastDocument: lastDocument,
  );
}

class CommentNotifier
    extends PaginatedFamilyAsyncNotifier<CommentModel, String> {
  @override
  int get pageSize => 6;

  @override
  FetchPageWithArg<CommentModel, String> get fetchPage => getCommentsAdapter;

  @override
  Future<PaginationState<CommentModel>> build(String arg) async {
    // ensures auth state is loaded, will reset all state when auth changes
    ref.watch(authProvider);

    final result = await fetchPage(
      arg: arg,
      limit: pageSize,
      lastDocument: null,
    );

    return PaginationState<CommentModel>(
      items: result.items,
      lastDocument: result.lastDoc,
      hasNextPage: result.items.length == pageSize,
    );
  }

  void addComment(CommentModel comment) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updatedItems = [comment, ...currentState.items];
    state = AsyncData(currentState.copyWith(items: updatedItems));
  }

  void removeComment(String commentId) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updatedItems =
        currentState.items.where((item) => item.id != commentId).toList();
    state = AsyncData(currentState.copyWith(items: updatedItems));
  }
}

final commentsProvider = AsyncNotifierProvider.family<CommentNotifier,
    PaginationState<CommentModel>, String>(() => CommentNotifier());
