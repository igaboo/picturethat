import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/models/prompt_model.dart';
import 'package:picture_that/models/submission_model.dart';
import 'package:picture_that/models/user_model.dart';
import 'package:picture_that/providers/pagination_provider.dart';
import 'package:picture_that/providers/submission_provider.dart';
import 'package:picture_that/widgets/custom_skeletonizer.dart';
import 'package:picture_that/widgets/empty_state.dart';
import 'package:picture_that/widgets/submission.dart';

final fetchingNextPageSkeleton = CustomSkeletonizer(
  child: Submission(
    heroContext: "skeleton",
    submission: SubmissionModel(
      id: "skeleton",
      date: DateTime.now(),
      image: SubmissionImageModel(
        url: "https://dummyimage.com/1x1/0011ff/0011ff.png",
        height: 200,
        width: 300,
      ),
      caption: "skeleton caption",
      isLiked: false,
      likes: [],
      prompt: PromptSubmissionModel(
        id: "skeleton",
        title: "skeleton prompt",
      ),
      user: getDummyUser(),
      commentsCount: 0,
    ),
  ),
);

class SubmissionListSliver extends ConsumerStatefulWidget {
  final PaginationState<SubmissionModel> submissionState;
  final SubmissionQueryParam queryParam;
  final String? heroContext;
  final Widget? header;
  final bool? isOnProfileTab;
  final bool? bottomPadding;
  final EmptyState? emptyState;
  final EdgeInsets? padding;

  const SubmissionListSliver({
    required this.submissionState,
    required this.queryParam,
    required this.heroContext,
    this.header,
    this.isOnProfileTab,
    this.bottomPadding,
    this.emptyState,
    this.padding,
    super.key,
  });

  @override
  ConsumerState<SubmissionListSliver> createState() =>
      _SubmissionListSliverState();
}

class _SubmissionListSliverState extends ConsumerState<SubmissionListSliver> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final offset = _scrollController.position;

      if (offset.pixels >= offset.maxScrollExtent * 0.9 &&
          !widget.submissionState.isFetchingNextPage) {
        ref
            .read(submissionProvider(widget.queryParam).notifier)
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
    final submissionsState = widget.submissionState;

    return CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: widget.header,
          ),
          if (submissionsState.items.isEmpty && !submissionsState.hasNextPage)
            SliverFillRemaining(
              hasScrollBody: false,
              child: widget.emptyState ??
                  const EmptyState(
                    title: "No Submissions",
                    icon: Icons.hide_image,
                    subtitle: "Check back later!",
                  ),
            )
          else
            SliverPadding(
              padding: widget.padding ?? EdgeInsets.zero,
              sliver: SliverList.separated(
                itemCount: submissionsState.items.length +
                    (submissionsState.hasNextPage ||
                            submissionsState.nextPageError != null
                        ? 1
                        : 0),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 30.0),
                itemBuilder: (context, index) {
                  if (index == submissionsState.items.length) {
                    if (submissionsState.isFetchingNextPage) {
                      return SizedBox(
                        height: 200.0,
                        child: OverflowBox(
                          minHeight: 200.0,
                          maxHeight: double.infinity,
                          alignment: Alignment.topCenter,
                          child: fetchingNextPageSkeleton,
                        ),
                      );
                    } else if (submissionsState.nextPageError != null) {
                      return EmptyState(
                        title: "A Problem Occurred",
                        icon: Icons.error,
                        subtitle: "Please try again later.",
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }

                  final submission = submissionsState.items[index];
                  return Submission(
                    submission: submission,
                    heroContext: widget.heroContext,
                    isOnProfileTab: widget.isOnProfileTab,
                    key: ValueKey(submission.id),
                  );
                },
              ),
            ),
          if (widget.bottomPadding == true && submissionsState.items.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.of(context).padding.bottom),
            ),
        ]);
  }
}
