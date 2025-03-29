import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/models/submission_model.dart';
import 'package:picturethat/providers/submission_provider.dart';
import 'package:picturethat/utils/get_time_elapsed.dart';
import 'package:picturethat/widgets/custom_image.dart';

class Submission extends ConsumerWidget {
  final SubmissionModel submission;
  final SubmissionQueryParam queryParam;

  const Submission({
    required this.submission,
    required this.queryParam,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(submissionNotifierProvider(queryParam).notifier);

    void _navigateToScreen(String route, routeId) {
      Navigator.pushNamed(context, route, arguments: routeId);
    }

    return Column(
      spacing: 10.0,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            spacing: 10.0,
            children: [
              GestureDetector(
                onTap: () =>
                    _navigateToScreen("/profile_screen", submission.user.uid),
                child: CustomNetworkImage(
                  url: submission.user.profileImageUrl,
                  width: 30,
                  height: 30,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _navigateToScreen(
                          "/profile_screen", submission.user.uid),
                      child: Text(
                        "@${submission.user.username}",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _navigateToScreen(
                          "/feed_screen", submission.prompt.id),
                      child: Text(submission.prompt.title),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                style: ButtonStyle(visualDensity: VisualDensity.compact),
                icon: Icon(Icons.more_horiz),
                onSelected: (value) {
                  if (value == "Report") {
                    // Handle report action
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: "Report",
                    child: Row(
                      spacing: 8.0,
                      children: [
                        Icon(Icons.report),
                        Text("Report"),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        // Body
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: CustomNetworkImage(
            url: submission.imageUrl,
            maxHeight: 400,
          ),
        ),
        // Footer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            spacing: 5.0,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                submission.caption,
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 5.0,
                    children: [
                      GestureDetector(
                        onTap: () => state.toggleSubmissionLike(
                          submissionId: submission.id,
                          isLiked: submission.isLiked,
                        ),
                        child: submission.isLiked
                            ? Icon(
                                Icons.favorite,
                                color: Colors.red,
                              )
                            : Icon(
                                Icons.favorite_border,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                      ),
                      Text(
                        "${submission.likes.length}",
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Icon(Icons.share),
                  ),
                ],
              ),
              Text(
                getTimeElapsed(submission.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
