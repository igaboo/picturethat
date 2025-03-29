String getTimeElapsed(DateTime pastTime) {
  final Duration diff = DateTime.now().difference(pastTime);

  if (diff.inSeconds < 60) {
    return "${diff.inSeconds} seconds ago";
  } else if (diff.inMinutes < 60) {
    return "${diff.inMinutes} minutes ago";
  } else if (diff.inHours < 24) {
    return "${diff.inHours} hours ago";
  } else if (diff.inDays < 7) {
    return "${diff.inDays} days ago";
  } else if (diff.inDays < 30) {
    return "${(diff.inDays / 7).floor()} weeks ago";
  } else if (diff.inDays < 365) {
    return "${(diff.inDays / 30).floor()} months ago";
  } else {
    return "${(diff.inDays / 365).floor()} years ago";
  }
}
