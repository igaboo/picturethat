import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/models/notification_model.dart';
import 'package:picture_that/providers/notification_provider.dart';
import 'package:picture_that/providers/pagination_provider.dart';
import 'package:picture_that/widgets/empty_state.dart';
import 'package:picture_that/widgets/notification/notification.dart';

final fetchingNextPageSkeleton = const Placeholder();

class NotificationsList extends ConsumerStatefulWidget {
  final PaginationState<NotificationModel> notificationState;
  final DateTime? previousLastSeenDate;

  const NotificationsList({
    required this.notificationState,
    required this.previousLastSeenDate,
    super.key,
  });

  @override
  ConsumerState<NotificationsList> createState() => _NotificationsListState();
}

class _NotificationsListState extends ConsumerState<NotificationsList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final offset = _scrollController.position;

      if (offset.pixels >= offset.maxScrollExtent * 0.9 &&
          !widget.notificationState.isFetchingNextPage) {
        ref.read(notificationsProvider.notifier).fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsState = widget.notificationState;

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (notificationsState.items.isEmpty && !notificationsState.hasNextPage)
          SliverFillRemaining(
            hasScrollBody: false,
            child: const EmptyState(
              title: "No Notifications",
              icon: Icons.hide_image,
              subtitle: "It's quiet here.",
            ),
          )
        else
          SliverList.builder(
            itemCount: notificationsState.items.length +
                (notificationsState.hasNextPage ||
                        notificationsState.nextPageError != null
                    ? 1
                    : 0),
            itemBuilder: (context, index) {
              if (index == notificationsState.items.length) {
                if (notificationsState.isFetchingNextPage) {
                  return fetchingNextPageSkeleton;
                } else if (notificationsState.nextPageError != null) {
                  return EmptyState(
                    title: "A Problem Occurred",
                    icon: Icons.error,
                    subtitle: "Please try again later.",
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }

              final notification = notificationsState.items[index];
              final isNotificationNew = widget.previousLastSeenDate != null &&
                  notification.createdAt.isAfter(widget.previousLastSeenDate!);

              return CustomNotification(
                notification: notification,
                isNotificationNew: isNotificationNew,
              );
            },
          ),
        if (notificationsState.items.isNotEmpty)
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.bottom),
          ),
      ],
    );
  }
}
