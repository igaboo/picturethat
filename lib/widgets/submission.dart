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

    void navigateToScreen(String route, routeId) {
      Navigator.pushNamed(context, route, arguments: routeId);
    }

    return Column(
      spacing: 10.0,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 8.0),
          child: Row(
            spacing: 10.0,
            children: [
              GestureDetector(
                onTap: () =>
                    navigateToScreen("/profile_screen", submission.user.uid),
                child: CustomImage(
                  imageProvider: NetworkImage(submission.user.profileImageUrl),
                  shape: CustomImageShape.circle,
                  width: 30,
                  height: 30,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => navigateToScreen(
                          "/profile_screen", submission.user.uid),
                      child: Text(
                        "@${submission.user.username}",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => navigateToScreen(
                          "/feed_screen", submission.prompt.id),
                      child: Text(submission.prompt.title),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: Icon(Icons.more_horiz),
                style: ButtonStyle(visualDensity: VisualDensity.compact),
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
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: CustomImage(
            imageProvider: NetworkImage(submission.image.url),
            width: submission.image.width.toDouble(),
            height: submission.image.height.toDouble(),
            aspectRatio: submission.image.width / submission.image.height,
            maxHeight: 400.0,
          ),
        ),
        // Footer
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (submission.caption != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  submission.caption!,
                  textAlign: TextAlign.center,
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        style:
                            ButtonStyle(visualDensity: VisualDensity.compact),
                        onPressed: () => state.toggleSubmissionLike(
                          submissionId: submission.id,
                          isLiked: submission.isLiked,
                        ),
                        icon: submission.isLiked
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
                  IconButton(
                    style: ButtonStyle(visualDensity: VisualDensity.compact),
                    onPressed: () {},
                    icon: Icon(Icons.share),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                getTimeElapsed(submission.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
