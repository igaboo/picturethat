import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picture_that/utils/constants.dart';

enum NotificationType { comment, like, follow }

class NotificationModel {
  final String id;
  final NotificationType type;
  final DateTime createdAt;
  final String recipientId;
  final String senderId;
  final String senderImageUrl;
  final String senderUsername;
  final String? submissionId;
  final String? submissionImageUrl;
  final String? commentId;
  final String? commentText;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.recipientId,
    required this.senderId,
    required this.senderImageUrl,
    required this.senderUsername,
    this.submissionId,
    this.submissionImageUrl,
    this.commentId,
    this.commentText,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> data) {
    return NotificationModel(
      id: data['id'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.comment,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      recipientId: data['recipientId'],
      senderId: data['senderId'],
      senderImageUrl: data['senderImageUrl'],
      senderUsername: data['senderUsername'],
      submissionId: data['submissionId'],
      submissionImageUrl: data['submissionImageUrl'],
      commentId: data['commentId'],
      commentText: data['commentText'],
    );
  }
}

NotificationModel getDummyNotification({index = 0}) {
  return NotificationModel(
    id: "dummy$index",
    type: NotificationType.values[index % NotificationType.values.length],
    createdAt: DateTime.now(),
    recipientId: "recipient$index",
    senderId: "sender$index",
    senderImageUrl: dummyImageUrl,
    senderUsername: "sender$index",
    submissionId: "submission$index",
    submissionImageUrl: dummyImageUrl,
    commentId: "comment$index",
    commentText: "This is a comment! $index",
  );
}
