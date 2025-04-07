import 'package:intl/intl.dart';

String getTimeElapsed(DateTime pastTime) {
  final Duration diff = DateTime.now().difference(pastTime);

  if (diff.inSeconds < 60) {
    return "Just now";
  } else if (diff.inMinutes < 60) {
    return Intl.plural(
      diff.inMinutes,
      one: "1 minute ago",
      other: "${diff.inMinutes} minutes ago",
    );
  } else if (diff.inHours < 24) {
    return Intl.plural(
      diff.inHours,
      one: "1 hour ago",
      other: "${diff.inHours} hours ago",
    );
  } else if (diff.inDays < 7) {
    return Intl.plural(
      diff.inDays,
      one: "1 day ago",
      other: "${diff.inDays} days ago",
    );
  } else if (diff.inDays < 30) {
    final int weeks = (diff.inDays / 7).floor();
    return Intl.plural(
      weeks,
      one: "1 week ago",
      other: "$weeks weeks ago",
    );
  } else if (diff.inDays < 365) {
    final int months = (diff.inDays / 30).floor();
    return Intl.plural(
      months,
      one: "1 month ago",
      other: "$months months ago",
    );
  } else {
    final int years = (diff.inDays / 365).floor();
    return Intl.plural(
      years,
      one: "1 year ago",
      other: "$years years ago",
    );
  }
}
