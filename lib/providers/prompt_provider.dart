import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/firebase_service.dart';
import 'package:picturethat/models/prompt_model.dart';
import 'package:picturethat/providers/auth_provider.dart';
import 'package:picturethat/providers/pagination_provider.dart';

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

  ///
  /// add state updates here reference submission_provider.dart fetch submissions function
  ///

  Future<void> addSubmission() async {
    final currentState = state.valueOrNull;
  }

  Future<void> deleteSubmission() async {
    final currentState = state.valueOrNull;
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

  final prompt = await getPrompt(promptId: promptId);

  return prompt;
});
