import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/models/notification_model.dart';
import 'package:picture_that/providers/auth_provider.dart';
import 'package:picture_that/providers/pagination_provider.dart';

class NotificationNotifier extends PaginatedAsyncNotifier<NotificationModel> {
  @override
  int get pageSize => 15;

  @override
  FetchPage<NotificationModel> get fetchPage => getNotifications;

  @override
  Future<PaginationState<NotificationModel>> build() async {
    // ensures auth state is loaded, will reset all state when auth changes
    ref.watch(authProvider);

    final result = await fetchPage(limit: pageSize, lastDocument: null);

    return PaginationState<NotificationModel>(
      items: result.items,
      lastDocument: result.lastDoc,
      hasNextPage: result.items.length == pageSize,
    );
  }
}

final notificationsProvider = AsyncNotifierProvider<NotificationNotifier,
    PaginationState<NotificationModel>>(
  () => NotificationNotifier(),
);
