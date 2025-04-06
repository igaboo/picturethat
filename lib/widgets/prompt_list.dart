import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/models/prompt_model.dart';
import 'package:picturethat/providers/pagination_provider.dart';
import 'package:picturethat/providers/prompt_provider.dart';
import 'package:picturethat/widgets/empty_state.dart';
import 'package:picturethat/widgets/prompt.dart';

class PromptList extends ConsumerStatefulWidget {
  final PaginationState<PromptModel> promptState;

  const PromptList({
    required this.promptState,
    super.key,
  });

  @override
  ConsumerState<PromptList> createState() => _PromptListState();
}

class _PromptListState extends ConsumerState<PromptList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      ref.read(promptsProvider.notifier).fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final promptState = widget.promptState;

    if (promptState.items.isEmpty && !promptState.hasNextPage) {
      return EmptyState(
        title: "No Prompts Available",
        icon: Icons.error,
        subtitle: "Please come back tomorrow!",
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100.0),
      controller: _scrollController,
      itemCount: promptState.items.length +
          (promptState.hasNextPage || promptState.nextPageError != null
              ? 1
              : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 30.0),
      itemBuilder: (context, index) {
        if (index == promptState.items.length) {
          if (promptState.isFetchingNextPage) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (promptState.nextPageError != null) {
            return EmptyState(
              title: "A Problem Occurred",
              icon: Icons.error,
              subtitle: "Please try again later.",
            );
          } else {
            return const SizedBox.shrink();
          }
        }

        final prompt = promptState.items[index];
        return Prompt(
          prompt: prompt,
          key: ValueKey(prompt.id),
        );
      },
    );
  }
}
