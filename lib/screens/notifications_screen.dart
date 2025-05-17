import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/providers/notification_badge_provider.dart';
import 'package:picture_that/providers/notification_provider.dart';
import 'package:picture_that/utils/helpers.dart';
import 'package:picture_that/widgets/notification/notifications_list.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  DateTime? previousLastSeenDate;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final storedDate = await getLastSeenNotifications();
      setState(() => previousLastSeenDate = storedDate);

      _markNotificationsAsSeen(); // mark notifications as seen when the screen is opened
    });
  }

  Future<void> _markNotificationsAsSeen() async {
    final hasUpdates =
        await ref.read(hasUnseenNotificationsProvider.future) == true;

    if (hasUpdates) {
      ref.invalidate(notificationsProvider); // refresh notifications
      ref.invalidate(lastSeenNotificationsProvider); // update last seen date
      await updateLastSeenNotifications(); // update value in local storage
    }
  }

  Future<void> _handleRefresh() async {
    await _markNotificationsAsSeen();

    ref.invalidate(notificationsProvider); // refresh notifications
    return ref.read(notificationsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (notifications) {
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: NotificationsList(
              notificationState: notifications,
              previousLastSeenDate: previousLastSeenDate,
            ),
          );
        },
      ),
    );
  }
}
