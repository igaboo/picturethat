import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/models/submission_model.dart';
import 'package:picturethat/providers/submission_provider.dart';
import 'package:picturethat/widgets/empty_state.dart';
import 'package:picturethat/widgets/submission.dart';

Widget emptyState = const EmptyState(
  title: "No Submissions",
  icon: Icons.image_outlined,
  subtitle: "Check back later!",
);

class SubmissionList extends ConsumerWidget {
  final List<SubmissionModel> submissions;
  final SubmissionQueryParam queryParam;

  const SubmissionList({
    required this.submissions,
    required this.queryParam,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (submissions.isEmpty) return emptyState;

    return ListView.separated(
      itemCount: submissions.length,
      separatorBuilder: (context, index) => SizedBox(height: 30),
      itemBuilder: (context, index) {
        final submission = submissions[index];

        return Submission(
          submission: submission,
          queryParam: queryParam,
          key: ValueKey(submission.id),
        );
      },
    );
  }
}

class SubmissionListSliver extends ConsumerWidget {
  final List<SubmissionModel> submissions;
  final SubmissionQueryParam queryParam;

  const SubmissionListSliver({
    required this.submissions,
    required this.queryParam,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (submissions.isEmpty) {
      return SliverToBoxAdapter(child: emptyState);
    }

    return SliverList.separated(
      itemBuilder: (context, index) {
        final submission = submissions[index];
        return Submission(
          submission: submission,
          queryParam: queryParam,
          key: ValueKey(submission.id),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 30),
      itemCount: submissions.length,
    );
  }
}
