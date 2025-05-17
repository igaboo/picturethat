import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/models/prompt_model.dart';
import 'package:picture_that/providers/prompt_provider.dart';
import 'package:picture_that/providers/submission_provider.dart';
import 'package:picture_that/screens/submit_photo_screen.dart';
import 'package:picture_that/screens/tabs/feed_screen.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/widgets/custom_skeletonizer.dart';
import 'package:picture_that/widgets/empty_state.dart';
import 'package:picture_that/widgets/submission/submission_list.dart';

final appBarTitleSkeleton = CustomSkeletonizer(
  child: TitleText(prompt: getDummyPrompt()),
);

class PromptFeedScreen extends ConsumerStatefulWidget {
  final String promptId;

  const PromptFeedScreen({
    required this.promptId,
    super.key,
  });

  @override
  ConsumerState<PromptFeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<PromptFeedScreen> {
  bool showFollowingScreen = true;

  @override
  Widget build(BuildContext context) {
    final queryParam = SubmissionQueryParam(
      type: SubmissionQueryType.byPrompt,
      id: widget.promptId,
    );

    final promptAsync = ref.watch(promptProvider(widget.promptId));
    final submissionsAsync = ref.watch(submissionProvider(queryParam));
    final prompt = promptAsync.asData?.value;

    final fab = (prompt != null && isToday(prompt.date))
        ? FloatingActionButton(
            onPressed: () => navigate(const SubmitPhotoScreen()),
            child: Icon(Icons.add_a_photo),
          )
        : null;

    Future<void> refreshSubmissions() async {
      ref.invalidate(submissionProvider(queryParam));
      await ref.read(submissionProvider(queryParam).future);
    }

    return Scaffold(
      appBar: AppBar(
        title: promptAsync.when(
          loading: () => appBarTitleSkeleton,
          error: (e, _) => Text("Error: $e"),
          data: (prompt) => TitleText(prompt: prompt),
        ),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == "report") {
                // handle report action
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "report",
                child: Row(
                  spacing: 8.0,
                  children: [
                    Icon(Icons.report),
                    Text("Report Prompt"),
                  ],
                ),
              )
            ],
          )
        ],
      ),
      floatingActionButton: fab,
      resizeToAvoidBottomInset: false,
      body: submissionsAsync.when(
        loading: () => submissionListSkeleton,
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (submissions) => RefreshIndicator(
          onRefresh: refreshSubmissions,
          child: SubmissionListSliver(
            emptyState: isToday(prompt?.date)
                ? EmptyState(
                    icon: Icons.hide_image,
                    title: "No Submissions",
                    subtitle: "Be the first to submit your photo!",
                  )
                : null,
            heroContext: widget.promptId,
            submissionState: submissions,
            queryParam: queryParam,
            bottomPadding: true,
            padding: const EdgeInsets.only(top: 8.0),
          ),
        ),
      ),
    );
  }
}

class TitleText extends StatelessWidget {
  final PromptModel? prompt;

  const TitleText({
    required this.prompt,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment:
          Platform.isIOS ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(prompt?.title ?? ""),
        if (prompt != null)
          Text(
            getFormattedDate(prompt?.date ?? DateTime.now()),
            style: textTheme.bodySmall,
          ),
      ],
    );
  }
}
