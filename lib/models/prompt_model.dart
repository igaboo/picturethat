import 'package:cloud_firestore/cloud_firestore.dart';

class PromptModel {
  String id;
  String title;
  int? submissionCount;
  String? imageUrl;
  String? imageAuthorUrl;
  String? imageAuthorName;
  DateTime? date;

  PromptModel({
    required this.id,
    required this.title,
    this.submissionCount,
    this.imageUrl,
    this.imageAuthorUrl,
    this.imageAuthorName,
    this.date,
  });

  factory PromptModel.fromMap(Map<String, dynamic> data) {
    return PromptModel(
      id: data['id'],
      title: data['title'],
      submissionCount: data['submissionCount'],
      imageUrl: data['imageUrl'],
      imageAuthorUrl: data['imageAuthorUrl'],
      imageAuthorName: data['imageAuthorName'],
      date: (data["date"] as Timestamp).toDate(),
    );
  }
}

class PromptSubmissionModel {
  String id;
  String title;

  PromptSubmissionModel({
    required this.id,
    required this.title,
  });

  factory PromptSubmissionModel.fromMap(Map<String, dynamic> data) {
    return PromptSubmissionModel(
      id: data['id'],
      title: data['title'],
    );
  }
}
