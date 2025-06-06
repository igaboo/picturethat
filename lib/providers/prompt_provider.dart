import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/models/prompt_model.dart';
import 'package:picture_that/providers/auth_provider.dart';
import 'package:picture_that/providers/pagination_provider.dart';

class PromptNotifier extends PaginatedAsyncNotifier<PromptModel> {
  @override
  int get pageSize => 3;

  @override
  FetchPage<PromptModel> get fetchPage => getPrompts;

  @override
  Future<PaginationState<PromptModel>> build() async {
    // ensures auth state is loaded, will reset all state when auth changes
    ref.watch(authProvider);

    final result = await fetchPage(limit: pageSize, lastDocument: null);

    return PaginationState<PromptModel>(
      items: result.items,
      lastDocument: result.lastDoc,
      hasNextPage: result.items.length == pageSize,
    );
  }

  void updateSubmissionCount({
    required String promptId,
    required bool isIncrementing,
  }) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final promptIndex = currentState.items.indexWhere((p) => p.id == promptId);
    if (promptIndex == -1) return;

    final prompt = currentState.items[promptIndex];
    final updatedPrompt = prompt.copyWith(
      submissionCount:
          (prompt.submissionCount ?? 0) + (isIncrementing ? 1 : -1),
    );

    final updatedItems = [...currentState.items];
    updatedItems[promptIndex] = updatedPrompt;

    state = AsyncValue.data(currentState.copyWith(items: updatedItems));
  }
}

final promptsProvider =
    AsyncNotifierProvider<PromptNotifier, PaginationState<PromptModel>>(
  () => PromptNotifier(),
);

final promptProvider =
    FutureProvider.family<PromptModel?, String>((ref, promptId) async {
  // ensures auth state is loaded, will reset all state when auth changes
  ref.watch(authProvider);

  final promptsAsync = ref.watch(promptsProvider);
  final promptInList = promptsAsync.valueOrNull?.items
      .cast<PromptModel?>()
      .firstWhere((p) => p?.id == promptId, orElse: () => null);

  if (promptInList != null) return promptInList;
  return await getPrompt(promptId: promptId);
});
