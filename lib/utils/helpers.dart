import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/main.dart';
import 'package:picture_that/models/submission_model.dart';
import 'package:picture_that/providers/prompt_provider.dart';
import 'package:picture_that/providers/relationship_provider.dart';
import 'package:picture_that/providers/submission_provider.dart';
import 'package:picture_that/providers/user_provider.dart';

///
/// Notifier helpers
///

void updateSubmissionNotifierIfInitialized({
  required BuildContext context,
  required WidgetRef ref,
  required SubmissionQueryParam queryParam,
  required Function(SubmissionNotifier) onInitialized,
}) {
  if (context.mounted == false) return;

  final container = ProviderScope.containerOf(context);
  final provider = submissionProvider(queryParam);
  final isInitialized = container.exists(provider);

  if (isInitialized) {
    final notifier = ref.read(provider.notifier);
    onInitialized(notifier);
  }
}

void updateUserNotifierIfInitialized({
  required BuildContext context,
  required WidgetRef ref,
  required String userId,
  required Function(UserNotifier) onInitialized,
}) {
  if (context.mounted == false) return;

  final container = ProviderScope.containerOf(context);
  final provider = userProvider(userId);
  final isInitialized = container.exists(provider);

  if (isInitialized) {
    final notifier = ref.read(provider.notifier);
    onInitialized(notifier);
  }
}

void updatePromptNotifierIfInitialized({
  required BuildContext context,
  required WidgetRef ref,
  required Function(PromptNotifier) onInitialized,
}) {
  if (context.mounted == false) return;

  final container = ProviderScope.containerOf(context);
  final provider = promptsProvider;
  final isInitialized = container.exists(provider);

  if (isInitialized) {
    final notifier = ref.read(provider.notifier);
    onInitialized(notifier);
  }
}

void updateCommentCountHelper({
  required BuildContext context,
  required WidgetRef ref,
  required bool isIncrementing,
  required SubmissionModel submission,
}) {
  if (context.mounted == false) return;

  void onInitialized(SubmissionNotifier notifier) {
    notifier.updateCommentCount(
      submissionId: submission.id,
      isIncrementing: isIncrementing,
    );
  }

  // update count for prompt submission
  updateSubmissionNotifierIfInitialized(
    context: context,
    ref: ref,
    queryParam: SubmissionQueryParam(
      type: SubmissionQueryType.byPrompt,
      id: submission.prompt.id,
    ),
    onInitialized: onInitialized,
  );

  // update count for user submission
  updateSubmissionNotifierIfInitialized(
    context: context,
    ref: ref,
    queryParam: SubmissionQueryParam(
      type: SubmissionQueryType.byUser,
      id: submission.user.uid,
    ),
    onInitialized: onInitialized,
  );

  // update count for discover feed submission
  updateSubmissionNotifierIfInitialized(
    context: context,
    ref: ref,
    queryParam: SubmissionQueryParam(
      type: SubmissionQueryType.byRandom,
    ),
    onInitialized: onInitialized,
  );

  // update count for following feed submission
  updateSubmissionNotifierIfInitialized(
    context: context,
    ref: ref,
    queryParam: SubmissionQueryParam(
      type: SubmissionQueryType.byFollowing,
    ),
    onInitialized: onInitialized,
  );
}

///
/// DateTime helpers
///

String getTimeLeft() {
  final now = DateTime.now();
  final tomorrowMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
  final timeLeft = tomorrowMidnight.difference(now);
  final totalHours = timeLeft.inHours;
  final remainingMinutes = timeLeft.inMinutes % 60;

  if (totalHours >= 1) {
    if (remainingMinutes > 0) {
      return "${totalHours}h ${remainingMinutes}m left";
    } else {
      return "${totalHours}h left";
    }
  } else {
    final totalMinutesLeft = timeLeft.inMinutes;

    if (totalMinutesLeft == 0 && timeLeft.inSeconds > 0) {
      return "1m left";
    }

    return "${totalMinutesLeft}m left";
  }
}

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

String getFormattedDate(DateTime date) {
  final nowLocal = DateTime.now();
  final dateLocal = date.toLocal();

  final startOfTodayLocal = DateTime(
    nowLocal.year,
    nowLocal.month,
    nowLocal.day,
  );
  final startOfDateLocal = DateTime(
    dateLocal.year,
    dateLocal.month,
    dateLocal.day,
  );

  final differenceInCalendarDays =
      startOfTodayLocal.difference(startOfDateLocal).inDays;

  final formattedDatePart =
      "${DateFormat('MMMM d').format(dateLocal)}${_getDaySuffix(dateLocal.day)}";

  if (differenceInCalendarDays == 0) {
    return "Today, $formattedDatePart";
  } else if (differenceInCalendarDays == 1) {
    return "Yesterday, $formattedDatePart";
  } else {
    return formattedDatePart;
  }
}

String _getDaySuffix(int day) {
  if (day >= 11 && day <= 13) {
    return 'th';
  }
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

bool isToday(DateTime? date) {
  if (date == null) return false;
  final now = DateTime.now();
  final dateLocal = date.toLocal();
  return dateLocal.year == now.year &&
      dateLocal.month == now.month &&
      dateLocal.day == now.day;
}

///
/// Number helpers
///

String getFormattedUnit({
  required int number,
  required String unit,
}) {
  final locale = Intl.getCurrentLocale();

  final compactNumberFormat = NumberFormat.compact(locale: locale);
  compactNumberFormat.maximumFractionDigits = 1;
  final String formattedCount = compactNumberFormat.format(number);

  final String pluralizedUnit = Intl.plural(
    number,
    one: unit,
    other: "${unit}s",
    locale: locale,
  );

  return "$formattedCount $pluralizedUnit";
}

///
/// Navigation helpers
///

void navigate(Widget screen) {
  final context = navigatorKey.currentContext!;

  final routeName = screen.runtimeType.toString();
  final currentRouteName = ModalRoute.of(context)?.settings.name;
  if (currentRouteName == routeName) return;

  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (context) => screen,
      settings: RouteSettings(name: routeName),
    ),
  );
}

void navigateAndDisableBack(Widget screen) {
  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => screen,
      settings: RouteSettings(name: screen.runtimeType.toString()),
    ),
    (route) => false,
  );
}

void navigateBack<T>({T? result}) {
  navigatorKey.currentState?.pop(result);
}

///
/// String helpers
///

String getErrorMessage(String errorCode) {
  switch (errorCode) {
    case "invalid-credential":
      return "Your email or password is incorrect.";
    case "invalid-email":
      return "Please enter a valid email.";
    case "email-already-in-use":
      return "This email is already in use. Please login or use a different email.";
    case "too-many-requests":
      return "Too many requests. Please try again later.";
    case "weak-password":
      return "Please enter a stronger password.";
    case "user-mismatch":
      return "That was the wrong google account. Please try again.";
    default:
      return "An unknown error occurred. Please try again later.";
  }
}

String getCleanUrl(String url) {
  url = url.replaceFirst(RegExp(r'^(https?:\/\/)?(www\.)?'), '');
  final match = RegExp(r'^[^\/]+\/[^\/]+').firstMatch(url);
  return match != null ? match.group(0)! : url.split('/')[0];
}

///
/// Relationship helpers
///

Future<void> toggleFollow(
  BuildContext context,
  WidgetRef ref,
  String profileUid,
) async {
  if (context.mounted == false) return;

  final notifier = ref.read(relationshipProvider.notifier);
  final isFollowing = notifier.isFollowing(profileUid);

  if (isFollowing) {
    final relationship = notifier.getRelationship(profileUid);
    if (relationship == null) return;

    await deleteRelationship(relationship.id);
    notifier.removeRelationship(profileUid);
  } else {
    final relationship = await createRelationship(profileUid);
    notifier.addRelationship(relationship);
  }

  // update profile to show the new following count
  updateUserNotifierIfInitialized(
    context: context,
    ref: ref,
    userId: auth.currentUser!.uid,
    onInitialized: (notifier) => notifier.updateFollowingCount(!isFollowing),
  );

  // update their profile to show the new follower count
  updateUserNotifierIfInitialized(
    context: context,
    ref: ref,
    userId: profileUid,
    onInitialized: (notifier) => notifier.updateFollowersCount(!isFollowing),
  );

  // invalidate the following feed
  ref.invalidate(submissionProvider(
    SubmissionQueryParam(type: SubmissionQueryType.byFollowing),
  ));
}
