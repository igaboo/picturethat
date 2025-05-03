import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/models/prompt_model.dart';
import 'package:picture_that/providers/pagination_provider.dart';
import 'package:picture_that/providers/prompt_provider.dart';
import 'package:picture_that/widgets/empty_state.dart';
import 'package:picture_that/widgets/prompt.dart';

class PromptList extends ConsumerStatefulWidget {
  final PaginationState<PromptModel> promptState;
  final Widget? header;

  const PromptList({
    required this.promptState,
    this.header,
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

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: widget.header,
        ),
        if (promptState.items.isEmpty && !promptState.hasNextPage)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              title: "No Prompts Available",
              icon: Icons.error,
              subtitle: "Please come back tomorrow!",
            ),
          )
        else
          SliverList.separated(
            itemCount: promptState.items.length +
                (promptState.hasNextPage || promptState.nextPageError != null
                    ? 1
                    : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 30.0),
            itemBuilder: (context, index) {
              if (index == promptState.items.length) {
                if (promptState.isFetchingNextPage) {
                  return Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: CircularProgressIndicator()),
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
          ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 100.0),
        ),
      ],
    );
  }
}
