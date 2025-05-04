import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/models/prompt_model.dart';
import 'package:picture_that/models/submission_model.dart';
import 'package:picture_that/models/user_model.dart';
import 'package:picture_that/providers/submission_provider.dart';
import 'package:picture_that/screens/search_screen.dart';
import 'package:picture_that/utils/navigate.dart';
import 'package:picture_that/widgets/custom_skeletonizer.dart';
import 'package:picture_that/widgets/custom_tooltip.dart';
import 'package:picture_that/widgets/submission.dart';
import 'package:picture_that/widgets/submission_list.dart';

final skeleton = CustomSkeletonizer(
  child: ListView.separated(
    itemBuilder: (context, index) {
      return Submission(
        heroContext: "skeleton$index",
        queryParam: SubmissionQueryParam(
          type: SubmissionQueryType.byRandom,
        ),
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
          user: UserModel(
            uid: "skeleton",
            firstName: "skeleton",
            lastName: "skeleton",
            followersCount: 0,
            followingCount: 0,
            submissionsCount: 0,
            profileImageUrl: "https://dummyimage.com/1x1/0011ff/0011ff.png",
            username: "skeleton",
          ),
        ),
      );
    },
    separatorBuilder: (context, index) => SizedBox(height: 30.0),
    itemCount: 3,
  ),
);

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

    final queryParam = SubmissionQueryParam(
      type: showFollowingScreen
          ? SubmissionQueryType.byFollowing
          : SubmissionQueryType.byRandom,
    );

    final submissionsAsync = ref.watch(submissionProvider(queryParam));

    Future<void> refreshSubmissions() async {
      ref.invalidate(submissionProvider(queryParam));
      await ref.read(submissionProvider(queryParam).future);
    }

    return Scaffold(
      appBar: AppBar(
        title: SegmentedButton(
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
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async => navigate(context, SearchScreen()),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: refreshSubmissions,
            child: submissionsAsync.when(
              loading: () => skeleton,
              error: (e, _) => Center(child: Text("Error: $e")),
              data: (submissions) => SubmissionListSliver(
                heroContext: showFollowingScreen ? "following" : "discover",
                submissionState: submissions,
                queryParam: queryParam,
                bottomPadding: true,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomTooltip(
              key: ValueKey(
                  showFollowingScreen ? "followingTooltip" : "discoverTooltip"),
              tooltipId:
                  showFollowingScreen ? "followingTooltip" : "discoverTooltip",
              title: showFollowingScreen ? "Following Feed" : "Discover Feed",
              message: showFollowingScreen
                  ? "Here, you will see the latest submissions from users you follow."
                  : "Here, you will see the top submissions from all users from within the past week.",
            ),
          ),
        ],
      ),
    );
  }
}
