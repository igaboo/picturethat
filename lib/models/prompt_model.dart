import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picture_that/utils/constants.dart';

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

  // copy with method
  PromptModel copyWith({
    String? id,
    String? title,
    int? submissionCount,
    String? imageUrl,
    String? imageAuthorUrl,
    String? imageAuthorName,
    DateTime? date,
  }) {
    return PromptModel(
      id: id ?? this.id,
      title: title ?? this.title,
      submissionCount: submissionCount ?? this.submissionCount,
      imageUrl: imageUrl ?? this.imageUrl,
      imageAuthorUrl: imageAuthorUrl ?? this.imageAuthorUrl,
      imageAuthorName: imageAuthorName ?? this.imageAuthorName,
      date: date ?? this.date,
    );
  }
}

PromptModel getDummyPrompt({index = 0}) {
  return PromptModel(
    id: "dummy$index",
    title: "dummy prompt",
    submissionCount: 0,
    imageUrl: dummyImageUrl,
    imageAuthorUrl: dummyUrl,
    imageAuthorName: "dummy author",
    date: DateTime.now().subtract(Duration(days: index)),
  );
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

PromptSubmissionModel getDummyPromptSubmission({index = 0}) {
  return PromptSubmissionModel(
    id: "dummy$index",
    title: "dummy prompt",
  );
}
