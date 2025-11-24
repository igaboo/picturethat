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
import 'package:picture_that/utils/preference_utils.dart';

///
/// Notifier helpers
///

void updateSubmissionNotifierIfInitialized({
  required WidgetRef ref,
  required SubmissionQueryParam queryParam,
  required Function(SubmissionNotifier) onInitialized,
}) {
  final context = navigatorKey.currentContext!;
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
  required WidgetRef ref,
  required String userId,
  required Function(UserNotifier) onInitialized,
}) {
  final context = navigatorKey.currentContext!;
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
  required WidgetRef ref,
  required Function(PromptNotifier) onInitialized,
}) {
  final context = navigatorKey.currentContext!;
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
  required WidgetRef ref,
  required bool isIncrementing,
  required SubmissionModel submission,
}) {
  final context = navigatorKey.currentContext!;
  if (context.mounted == false) return;

  for (final q in [
    SubmissionQueryParam(
      type: SubmissionQueryType.byPrompt,
      id: submission.prompt.id,
    ),
    SubmissionQueryParam(
      type: SubmissionQueryType.byUser,
      id: submission.user.uid,
    ),
    SubmissionQueryParam(
      type: SubmissionQueryType.byRandom,
    ),
    SubmissionQueryParam(
      type: SubmissionQueryType.byFollowing,
    ),
  ]) {
    updateSubmissionNotifierIfInitialized(
      ref: ref,
      queryParam: q,
      onInitialized: (notifier) => notifier.updateCommentCount(
        submissionId: submission.id,
        isIncrementing: isIncrementing,
      ),
    );
  }
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

String getTimeElapsed(DateTime pastTime, {bool? isShort}) {
  final diff = DateTime.now().difference(pastTime);

  final units = [
    [diff.inSeconds, 60, 's', 'Just now', 'second'],
    [diff.inMinutes, 60, 'm', null, 'minute'],
    [diff.inHours, 24, 'h', null, 'hour'],
    [diff.inDays, 30, 'd', null, 'day'],
    [(diff.inDays / 30).round(), 12, 'mo', null, 'month'],
    [(diff.inDays / 365).round(), double.infinity, 'y', null, 'year'],
  ];

  for (final unit in units) {
    final value = unit[0] as int;
    final max = unit[1] as num;
    final shortLabel = unit[2] as String;
    final fallback = unit[3] as String?;
    final longLabel = unit[4] as String;

    if (value < max) {
      if (fallback != null) return fallback;
      if (isShort == true) return "$value$shortLabel";
      return "$value $longLabel${value > 1 ? 's' : ''} ago";
    }
  }

  return '';
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

String? getCurrentRouteName() {
  final navigator = navigatorKey.currentState;
  if (navigator == null) return null;

  Route? currentRoute;
  navigator.popUntil((route) {
    currentRoute = route;
    return true;
  });

  return currentRoute?.settings.name;
}

void navigate(Widget screen) {
  final routeName = screen.runtimeType.toString();
  final currentRouteName = getCurrentRouteName();

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
    case "credential-already-in-use":
      return "This provider is already linked to another account.";
    case "network-request-failed":
      return "Network error. Please check your internet connection.";
    case "firebase_firestore":
      return "There was an error fetching data. Please try again later.";
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
    ref: ref,
    userId: auth.currentUser!.uid,
    onInitialized: (notifier) => notifier.updateFollowingCount(!isFollowing),
  );

  // update their profile to show the new follower count
  updateUserNotifierIfInitialized(
    ref: ref,
    userId: profileUid,
    onInitialized: (notifier) => notifier.updateFollowersCount(!isFollowing),
  );

  // invalidate the following feed
  ref.invalidate(submissionProvider(
    SubmissionQueryParam(type: SubmissionQueryType.byFollowing),
  ));
}

///
/// Notification helpers
///

Future<void> updateLastSeenNotifications() async {
  final now = DateTime.now();
  await setString('lastSeenNotifications', now.toIso8601String());
}

Future<DateTime?> getLastSeenNotifications() async {
  final lastSeen = await getString('lastSeenNotifications') ?? "";
  if (lastSeen.isEmpty) return null;

  return DateTime.tryParse(lastSeen);
}
