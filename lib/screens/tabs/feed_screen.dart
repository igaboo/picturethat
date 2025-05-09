import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/models/submission_model.dart';
import 'package:picture_that/providers/relationship_provider.dart';
import 'package:picture_that/providers/submission_provider.dart';
import 'package:picture_that/screens/search_screen.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/widgets/custom_skeletonizer.dart';
import 'package:picture_that/widgets/custom_tooltip.dart';
import 'package:picture_that/widgets/empty_state.dart';
import 'package:picture_that/widgets/submission.dart';
import 'package:picture_that/widgets/submission_list.dart';

final submissionListSkeleton = CustomSkeletonizer(
  child: ListView.separated(
    itemCount: 3,
    separatorBuilder: (context, index) => SizedBox(height: 30.0),
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Submission(
          heroContext: "skeleton$index",
          submission: getDummySubmission(index: index),
        ),
      );
    },
  ),
);

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with AutomaticKeepAliveClientMixin<FeedScreen> {
  int _currentPageIndex = 0;
  late PageController _pageController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (mounted) setState(() => _currentPageIndex = index);
  }

  void _onSegmentSelected(Set newSelection) {
    final newIndex = newSelection.first;
    if (newIndex != _currentPageIndex) {
      setState(() => _currentPageIndex = newIndex);

      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutQuad,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isFollowingEmpty =
        ref.watch(relationshipProvider).valueOrNull?.following.isEmpty == true;

    final title = isFollowingEmpty ? "Not Following Anyone" : "No Submissions";
    final subtitle = isFollowingEmpty
        ? "Check out the Discover feed to find new users, or search by their username!"
        : "The users you follow haven't uploaded anything yet. Once they do you'll see their submissions here.";
    final icon = isFollowingEmpty ? Icons.people : Icons.hide_image;
    final action = (
      label: "Visit Discover Feed",
      onPressed: () => _onSegmentSelected({1}),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: SegmentedButton<int>(
          segments: const [
            ButtonSegment(
              value: 0,
              label: Text("Following"),
              icon: Icon(Icons.people),
            ),
            ButtonSegment(
              value: 1,
              label: Text("Discover"),
              icon: Icon(Icons.explore),
            ),
          ],
          selected: {_currentPageIndex},
          onSelectionChanged: _onSegmentSelected,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async => navigate(const SearchScreen()),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              FeedPageContent(
                key: const ValueKey('following_feed'),
                queryType: SubmissionQueryType.byFollowing,
                heroContextPrefix: "following",
                emptyState: EmptyState(
                  title: title,
                  subtitle: subtitle,
                  icon: icon,
                  action: action,
                ),
                tooltip: CustomTooltip(
                  tooltipId: "followingTooltip",
                  title: "Following Feed",
                  message:
                      "Here, you will see the latest submissions from users you follow.",
                ),
              ),
              FeedPageContent(
                key: const ValueKey('discover_feed'),
                queryType: SubmissionQueryType.byRandom,
                heroContextPrefix: "discover",
                tooltip: CustomTooltip(
                  tooltipId: "discoverTooltip",
                  title: "Discover Feed",
                  message:
                      "Here, you will see the top submissions from all users from within the past week.",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FeedPageContent extends ConsumerStatefulWidget {
  final SubmissionQueryType queryType;
  final String heroContextPrefix;
  final CustomTooltip tooltip;
  final EmptyState? emptyState;

  const FeedPageContent({
    required Key key,
    required this.queryType,
    required this.heroContextPrefix,
    required this.tooltip,
    this.emptyState,
  }) : super(key: key);

  @override
  ConsumerState<FeedPageContent> createState() => _FeedPageContentState();
}

class _FeedPageContentState extends ConsumerState<FeedPageContent>
    with AutomaticKeepAliveClientMixin<FeedPageContent> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final queryParam = SubmissionQueryParam(type: widget.queryType);
    final submissionsAsync = ref.watch(submissionProvider(queryParam));

    Future<void> refreshSubmissions() async {
      ref.invalidate(submissionProvider(queryParam));
      await ref.read(submissionProvider(queryParam).future);
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: refreshSubmissions,
          child: submissionsAsync.when(
            loading: () => submissionListSkeleton,
            error: (e, _) => EmptyState(
              title: "Error",
              subtitle: "An error occurred while loading submissions.",
              icon: Icons.error,
              action: (label: "Retry", onPressed: refreshSubmissions),
            ),
            data: (submissions) {
              return SubmissionListSliver(
                emptyState: widget.emptyState,
                heroContext: widget.heroContextPrefix,
                submissionState: submissions,
                queryParam: queryParam,
                bottomPadding: true,
                padding: const EdgeInsets.only(top: 8.0),
              );
            },
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: widget.tooltip,
        ),
      ],
    );
  }
}
