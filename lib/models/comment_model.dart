import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picture_that/models/user_model.dart';

class CommentModel {
  final String id;
  final String submissionId;
  final UserModel user;
  final String text;
  final DateTime date;

  const CommentModel({
    required this.id,
    required this.submissionId,
    required this.user,
    required this.text,
    required this.date,
  });

  factory CommentModel.fromMap(Map<String, dynamic> data) {
    return CommentModel(
      id: data['id'],
      submissionId: data['submissionId'],
      user: data["user"],
      text: data['text'],
      date: (data["date"] as Timestamp).toDate(),
    );
  }
}

CommentModel getDummyComment({index = 0}) {
  return CommentModel(
    id: "skeleton",
    submissionId: "skeleton",
    date: DateTime.now(),
    text: "skeleton comment",
    user: getDummyUser(index: index),
  );
}
