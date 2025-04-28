import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/models/prompt_model.dart';
import 'package:picturethat/providers/prompt_provider.dart';
import 'package:picturethat/providers/submission_provider.dart';
import 'package:picturethat/utils/get_formatted_date.dart';
import 'package:picturethat/utils/is_today.dart';
import 'package:picturethat/utils/navigate.dart';
import 'package:picturethat/widgets/custom_tooltip.dart';
import 'package:picturethat/widgets/submission_list.dart';

/// TODO
/// change query to only get submissions from users that are followed

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with AutomaticKeepAliveClientMixin<FeedScreen> {
  bool showFollowingScreen = true;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // get prompt id from args
    // if prompt id is null, then we are on the main feed
    final promptId = ModalRoute.of(context)?.settings.arguments as String?;
    final bool isPrompt = promptId != null;
    final AsyncValue<PromptModel?> promptAsync = isPrompt
        ? ref.watch(promptProvider(promptId))
        : const AsyncValue.data(null); // watch only if isPrompt is true

    final SubmissionQueryParam queryParam = isPrompt
        ? (type: SubmissionQueryType.byPrompt, id: promptId, user: null)
        : (
            type: showFollowingScreen
                ? SubmissionQueryType.byFollowing
                : SubmissionQueryType.byRandom,
            id: null,
            user: null
          );

    final submissionAsync = ref.watch(submissionNotifierProvider(queryParam));

    Future<void> refreshSubmissions() async {
      ref.invalidate(submissionNotifierProvider(queryParam));
      await ref.read(submissionNotifierProvider(queryParam).future);
    }

    // only show a submit button if we are on today's prompt
    Widget? fab;
    if (isPrompt) {
      fab = promptAsync.when(
          loading: () => null,
          error: (e, _) => null,
          data: (prompt) {
            if (prompt != null && isToday(prompt.date)) {
              return FloatingActionButton(
                onPressed: () => navigate(
                  context,
                  "/submit_photo_screen",
                  arguments: prompt.id,
                ),
                child: Icon(Icons.add_photo_alternate_outlined),
              );
            } else {
              return null;
            }
          });
    }

    return Scaffold(
      appBar: AppBar(
        title: isPrompt
            ? promptAsync.when(
                loading: () => Text("Loading..."),
                error: (e, _) => Text("Error: $e"),
                data: (prompt) => Column(
                  crossAxisAlignment: Platform.isIOS
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    Text(prompt?.title ?? "Prompt"),
                    if (prompt != null)
                      Text(
                        getFormattedDate(prompt.date!),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              )
            : SegmentedButton(
                segments: [
                  ButtonSegment(
                    value: true,
                    label: Text("Following"),
                    icon: Icon(Icons.people),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text("Discover"),
                    icon: Icon(Icons.explore),
                  ),
                ],
                selected: {showFollowingScreen},
                onSelectionChanged: (p0) => {
                  setState(() => showFollowingScreen = p0.first),
                },
              ),
        actions: [
          if (!isPrompt)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async => navigate(context, "/search_screen"),
            ),
        ],
      ),
      floatingActionButton: fab,
      resizeToAvoidBottomInset: false,
      body: submissionAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (submissions) => Stack(
          children: [
            RefreshIndicator(
              onRefresh: refreshSubmissions,
              child: SubmissionListSliver(
                heroContext: promptId,
                submissionState: submissions,
                queryParam: queryParam,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Visibility(
                visible: !isPrompt,
                child: CustomTooltip(
                  key: ValueKey(showFollowingScreen
                      ? "followingTooltip"
                      : "discoverTooltip"),
                  tooltipId: showFollowingScreen
                      ? "followingTooltip"
                      : "discoverTooltip",
                  title:
                      showFollowingScreen ? "Following Feed" : "Discover Feed",
                  message: showFollowingScreen
                      ? "Here, you will see the latest submissions from users you follow."
                      : "Here, you will see the top submissions from all users from within the past week.",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
