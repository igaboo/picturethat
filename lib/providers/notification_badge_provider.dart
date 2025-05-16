import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picture_that/firebase_service.dart';
import 'package:picture_that/utils/helpers.dart';

final lastSeenNotificationsProvider = FutureProvider<Timestamp?>(
  (ref) async {
    final localTime = await getLastSeenNotifications();
    return localTime != null ? Timestamp.fromDate(localTime) : null;
  },
);

final hasUnseenNotificationsProvider = StreamProvider.autoDispose<bool>((ref) {
  final lastSeenAsync = ref.watch(lastSeenNotificationsProvider);

  return lastSeenAsync.when(
    loading: () => const Stream.empty(),
    error: (e, _) => const Stream.empty(),
    data: (lastSeen) {
      Query query = db
          .collection("notifications")
          .where('recipientId', isEqualTo: auth.currentUser!.uid);

      if (lastSeen != null) {
        query = query.where('createdAt', isGreaterThan: lastSeen);
      }

      query = query.orderBy('createdAt', descending: true);

      return query.snapshots().map((s) => s.docs.isNotEmpty);
    },
  );
});
