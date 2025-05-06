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
import 'package:picture_that/widgets/submission_list.dart';

final titleSkeleton = CustomSkeletonizer(
  child: TitleText(
    prompt: PromptModel(
      id: "skeleton",
      title: "skeleton title",
      date: DateTime.now(),
      imageAuthorName: "skeleton",
      imageAuthorUrl: "https://dummyimage.com/1x1/0011ff/0011ff.png",
      imageUrl: "https://dummyimage.com/1x1/0011ff/0011ff.png",
      submissionCount: 0,
    ),
  ),
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
    final promptAsync = ref.watch(promptProvider(widget.promptId));
    final colorScheme = Theme.of(context).colorScheme;

    final queryParam = SubmissionQueryParam(
      type: SubmissionQueryType.byPrompt,
      id: widget.promptId,
    );

    final submissionsAsync = ref.watch(submissionProvider(queryParam));

    Future<void> refreshSubmissions() async {
      ref.invalidate(submissionProvider(queryParam));
      await ref.read(submissionProvider(queryParam).future);
    }

    Widget? fab;
    fab = promptAsync.when(
      loading: () => null,
      error: (e, _) => null,
      data: (prompt) {
        if (prompt != null && isToday(prompt.date)) {
          return FloatingActionButton(
            onPressed: () => navigate(context, const SubmitPhotoScreen()),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            child: Icon(Icons.add_photo_alternate_outlined),
          );
        } else {
          return null;
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: promptAsync.when(
          loading: () => titleSkeleton,
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
        loading: () => skeleton,
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (submissions) => Stack(
          children: [
            RefreshIndicator(
              onRefresh: refreshSubmissions,
              child: SubmissionListSliver(
                heroContext: widget.promptId,
                submissionState: submissions,
                queryParam: queryParam,
                bottomPadding: true,
                padding: const EdgeInsets.only(top: 8.0),
              ),
            ),
          ],
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
