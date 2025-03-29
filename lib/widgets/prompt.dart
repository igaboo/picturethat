import 'package:flutter/material.dart';
import 'package:picturethat/models/prompt_model.dart';
import 'package:picturethat/utils/get_formatted_date.dart';
import 'package:picturethat/utils/get_formatted_number.dart';
import 'package:picturethat/utils/get_time_left.dart';
import 'package:picturethat/widgets/custom_image.dart';

final WIDGET_HEIGHT = 350.0;

class Prompt extends StatelessWidget {
  final PromptModel prompt;

  const Prompt({
    required this.prompt,
    super.key,
  });

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  @override
  Widget build(BuildContext context) {
    bool isToday = _isToday(prompt.date!);

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, "/feed_screen", arguments: prompt.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5.0,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: isToday ? 14.0 : 0.0),
              child: Text(
                getFormattedDate(prompt.date!),
                style: isToday
                    ? Theme.of(context).textTheme.titleLarge
                    : Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Stack(
              children: [
                CustomNetworkImage(
                  url: prompt.imageUrl!,
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
                        0.6,
                        0.85,
                        1.0,
                      ],
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(150),
                        Colors.black.withAlpha(230),
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
                          Container(
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
                                      .copyWith(
                                        color: Colors.white,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          // prompt title
                          Text(
                            prompt.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: Colors.white,
                                ),
                          ),
                          // submission count
                          Text(
                            "${getFormattedNumber(prompt.submissionCount!)} submissions",
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: Colors.white,
                                    ),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: isToday,
                        child: IconButton.filled(
                          onPressed: () {},
                          icon: Icon(Icons.add_a_photo),
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
