import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/models/comment_model.dart';
import 'package:picture_that/models/submission_model.dart';
import 'package:picture_that/providers/comment_provider.dart';
import 'package:picture_that/providers/pagination_provider.dart';
import 'package:picture_that/widgets/comment.dart';
import 'package:picture_that/widgets/custom_skeletonizer.dart';
import 'package:picture_that/widgets/empty_state.dart';
import 'package:picture_that/widgets/submission.dart';

final fetchingNextPageSkeleton = CustomSkeletonizer(
    child: SizedBox(
  height: 100.0,
  child: OverflowBox(
    minHeight: 100.0,
    maxHeight: 500.0,
    alignment: Alignment.topCenter,
    child: commentsListSkeleton,
  ),
));

class CommentsListSliver extends ConsumerStatefulWidget {
  final PaginationState<CommentModel> commentState;
  final SubmissionModel submission;
  final Function(String) handleReply;
  final ScrollController? scrollController;

  const CommentsListSliver({
    required this.commentState,
    required this.submission,
    required this.handleReply,
    this.scrollController,
    super.key,
  });

  @override
  ConsumerState<CommentsListSliver> createState() => _CommentsListSliverState();
}

class _CommentsListSliverState extends ConsumerState<CommentsListSliver> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.scrollController != null) {
      _scrollController = widget.scrollController!;
    }
    _scrollController.addListener(() {
      final offset = _scrollController.position;

      if (offset.pixels >= offset.maxScrollExtent * 0.9 &&
          !widget.commentState.isFetchingNextPage) {
        ref
            .read(commentsProvider(widget.submission.id).notifier)
            .fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsState = widget.commentState;

    return CustomScrollView(
      controller: _scrollController,
      physics: AlwaysScrollableScrollPhysics(),
      slivers: [
        if (commentsState.items.isEmpty && !commentsState.hasNextPage)
          SliverFillRemaining(
            hasScrollBody: false,
            child: const EmptyState(
              title: "No Comments",
              icon: Icons.hide_image,
              subtitle: "Start the conversation!",
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList.separated(
              itemCount: commentsState.items.length +
                  (commentsState.hasNextPage ||
                          commentsState.nextPageError != null
                      ? 1
                      : 0),
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 16.0),
              itemBuilder: (context, index) {
                if (index == commentsState.items.length) {
                  if (commentsState.isFetchingNextPage) {
                    return fetchingNextPageSkeleton;
                  } else if (commentsState.nextPageError != null) {
                    return EmptyState(
                      title: "A Problem Occurred",
                      icon: Icons.error,
                      subtitle: "Please try again later.",
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }

                final comment = commentsState.items[index];
                return Comment(
                  key: ValueKey(comment.id),
                  comment: comment,
                  handleReply: widget.handleReply,
                  submission: widget.submission,
                );
              },
            ),
          ),
      ],
    );
  }
}
