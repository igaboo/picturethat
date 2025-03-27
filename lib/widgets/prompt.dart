import 'package:flutter/material.dart';
import 'package:picturethat/utils/get_formatted_date.dart';
import 'package:picturethat/utils/get_formatted_number.dart';
import 'package:picturethat/widgets/custom_image.dart';

final WIDGET_HEIGHT = 450.0;

class Prompt extends StatelessWidget {
  final String id;
  final String title;
  final int submissionCount;
  final String imageUrl;
  final DateTime date;

  const Prompt({
    required this.id,
    required this.title,
    required this.submissionCount,
    required this.imageUrl,
    required this.date,
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
    bool isToday = _isToday(date);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/feed_screen", arguments: id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5.0,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: isToday ? 14.0 : 0.0),
              child: Text(
                getFormattedDate(date),
                style: isToday
                    ? Theme.of(context).textTheme.titleLarge
                    : Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Stack(
              children: [
                CustomNetworkImage(
                  url: imageUrl,
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
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            "${getFormattedNumber(submissionCount)} submissions",
                            style: Theme.of(context).textTheme.bodySmall,
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
