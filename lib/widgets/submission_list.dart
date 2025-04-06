import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/models/submission_model.dart';
import 'package:picturethat/providers/pagination_provider.dart';
import 'package:picturethat/providers/submission_provider.dart';
import 'package:picturethat/widgets/empty_state.dart';
import 'package:picturethat/widgets/submission.dart';

Widget emptyState = const EmptyState(
  title: "No Submissions",
  icon: Icons.hide_image,
  subtitle: "Check back later!",
);

class SubmissionList extends ConsumerStatefulWidget {
  final PaginationState<SubmissionModel> submissionState;
  final SubmissionQueryParam queryParam;

  const SubmissionList({
    required this.submissionState,
    required this.queryParam,
    super.key,
  });

  @override
  ConsumerState<SubmissionList> createState() => _SubmissionListState();
}

class _SubmissionListState extends ConsumerState<SubmissionList> {
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
      ref
          .read(submissionNotifierProvider(widget.queryParam).notifier)
          .fetchNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final submissionState = widget.submissionState;

    if (submissionState.items.isEmpty && !submissionState.hasNextPage) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: emptyState,
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      itemCount: submissionState.items.length +
          (submissionState.hasNextPage || submissionState.nextPageError != null
              ? 1
              : 0),
      separatorBuilder: (context, index) => SizedBox(height: 30),
      itemBuilder: (context, index) {
        if (index == submissionState.items.length) {
          if (submissionState.isFetchingNextPage) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (submissionState.nextPageError != null) {
            return EmptyState(
              title: "A Problem Occurred",
              icon: Icons.error,
              subtitle: "Please try again later.",
            );
          } else {
            return const SizedBox.shrink();
          }
        }

        final submission = submissionState.items[index];
        return Submission(
          submission: submission,
          queryParam: widget.queryParam,
          key: ValueKey(submission.id),
        );
      },
    );
  }
}

class SubmissionListSliver extends ConsumerStatefulWidget {
  final Widget header;
  final PaginationState<SubmissionModel> submissionState;
  final SubmissionQueryParam queryParam;

  const SubmissionListSliver({
    required this.header,
    required this.submissionState,
    required this.queryParam,
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
      ref
          .read(submissionNotifierProvider(widget.queryParam).notifier)
          .fetchNextPage();
    }
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
          if (submissionsState.items.isNotEmpty)
            const SliverToBoxAdapter(
              child: SizedBox(height: 20.0),
            ),
          if (submissionsState.items.isEmpty && !submissionsState.hasNextPage)
            SliverFillRemaining(
              hasScrollBody: false,
              child: emptyState,
            )
          else
            SliverList.separated(
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
                    return Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: CircularProgressIndicator(),
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
                  queryParam: widget.queryParam,
                  key: ValueKey(submission.id),
                );
              },
            )
        ]);
  }
}
