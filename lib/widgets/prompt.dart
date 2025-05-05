import 'package:flutter/material.dart';
import 'package:picture_that/models/prompt_model.dart';
import 'package:picture_that/screens/prompt_feed_screen.dart';
import 'package:picture_that/screens/submit_photo_screen.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/widgets/custom_image.dart';
import 'package:url_launcher/url_launcher.dart';

final widgetHeight = 300.0;

class Prompt extends StatelessWidget {
  final PromptModel prompt;

  const Prompt({
    required this.prompt,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    bool isTodaysPrompt = isToday(prompt.date!);

    return GestureDetector(
      onTap: () => navigate(
        context,
        PromptFeedScreen(promptId: prompt.id),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5.0,
          children: [
            Padding(
              padding:
                  EdgeInsets.symmetric(vertical: isTodaysPrompt ? 14.0 : 0.0),
              child: Text(
                getFormattedDate(prompt.date!),
                style: isTodaysPrompt
                    ? textTheme.titleLarge
                    : textTheme.titleMedium,
              ),
            ),
            Stack(
              children: [
                CustomImage(
                  key: ValueKey(prompt.imageUrl),
                  imageProvider: NetworkImage(prompt.imageUrl!),
                  width: double.infinity,
                  height: widgetHeight,
                ),
                Container(
                  height: widgetHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [
                        0.0,
                        0.5,
                        1.0,
                      ],
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withAlpha(225),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                Positioned(
                  top: 16.0,
                  bottom: 16.0,
                  left: 16.0,
                  right: 16.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 16.0,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                            visible: isTodaysPrompt,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 10.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(150),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                spacing: 8.0,
                                children: [
                                  Container(
                                    width: 8.0,
                                    height: 8.0,
                                    decoration: BoxDecoration(
                                      color: Colors.lightGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Text(
                                    getTimeLeft(),
                                    style: textTheme.bodySmall!
                                        .copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            prompt.title,
                            style: textTheme.titleMedium!
                                .copyWith(color: Colors.white),
                          ),
                          Text(
                            getFormattedUnit(
                              number: prompt.submissionCount!,
                              unit: "submission",
                            ),
                            style: textTheme.bodySmall!
                                .copyWith(color: Colors.white),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          GestureDetector(
                            onTap: () =>
                                launchUrl(Uri.parse(prompt.imageAuthorUrl!)),
                            child: Row(
                              spacing: 4.0,
                              children: [
                                Icon(
                                  Icons.link,
                                  size: 12,
                                  color: Colors.white.withAlpha(150),
                                ),
                                Text(
                                  "Photo by ${prompt.imageAuthorName}",
                                  style: textTheme.bodySmall!.copyWith(
                                    color: Colors.white.withAlpha(150),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: isTodaysPrompt,
                        child: IconButton.filled(
                          onPressed: () => navigate(
                            context,
                            SubmitPhotoScreen(),
                          ),
                          icon: Icon(Icons.add_photo_alternate_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
