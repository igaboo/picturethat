import 'package:flutter/material.dart';
import 'package:picturethat/models/prompt_model.dart';
import 'package:picturethat/utils/get_formatted_date.dart';
import 'package:picturethat/utils/get_formatted_number.dart';
import 'package:picturethat/utils/get_time_left.dart';
import 'package:picturethat/utils/is_today.dart';
import 'package:picturethat/utils/navigate.dart';
import 'package:picturethat/widgets/custom_image.dart';
import 'package:url_launcher/url_launcher.dart';

final WIDGET_HEIGHT = 300.0;

class Prompt extends StatelessWidget {
  final PromptModel prompt;

  const Prompt({
    required this.prompt,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isTodaysPrompt = isToday(prompt.date!);

    return GestureDetector(
      onTap: () => navigate(context, "/feed_screen", arguments: prompt.id),
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
                    ? Theme.of(context).textTheme.titleLarge
                    : Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Stack(
              children: [
                CustomImage(
                  imageProvider: NetworkImage(prompt.imageUrl!),
                  width: double.infinity,
                  height: WIDGET_HEIGHT,
                ),
                Container(
                  height: WIDGET_HEIGHT,
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
                          // time left pill
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Spacer(),
                          // prompt title
                          Text(
                            prompt.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(color: Colors.white),
                          ),
                          // submission count
                          Text(
                            getFormattedUnit(
                              number: prompt.submissionCount!,
                              unit: "submission",
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: Colors.white),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          // photo attribution
                          GestureDetector(
                            onTap: () =>
                                launchUrl(Uri.parse(prompt.imageAuthorUrl!)),
                            child: Text(
                              "Photo by ${prompt.imageAuthorName}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: Colors.white.withAlpha(150)),
                            ),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: isTodaysPrompt,
                        child: IconButton.filled(
                          onPressed: () =>
                              navigate(context, "/submit_photo_screen"),
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
