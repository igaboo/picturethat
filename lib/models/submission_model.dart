import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picture_that/models/prompt_model.dart';
import 'package:picture_that/models/user_model.dart';
import 'package:picture_that/utils/constants.dart';

class SubmissionImageModel {
  String url;
  int height;
  int width;

  SubmissionImageModel({
    required this.url,
    required this.height,
    required this.width,
  });

  factory SubmissionImageModel.fromMap(Map<String, dynamic> data) {
    return SubmissionImageModel(
      url: data['url'],
      height: data['height'],
      width: data['width'],
    );
  }
}

SubmissionImageModel getDummySubmissionImage() {
  return SubmissionImageModel(
    url: dummyImageUrl,
    height: 200,
    width: 300,
  );
}

class SubmissionModel {
  String id;
  UserModel user;
  SubmissionImageModel image;
  PromptSubmissionModel prompt;
  DateTime date;
  List<String> likes;
  String? caption;
  bool isLiked;
  int commentsCount;

  SubmissionModel({
    required this.id,
    required this.user,
    required this.image,
    required this.prompt,
    required this.date,
    required this.likes,
    required this.caption,
    required this.isLiked,
    required this.commentsCount,
  });

  SubmissionModel copyWith({
    String? id,
    UserModel? user,
    SubmissionImageModel? image,
    PromptSubmissionModel? prompt,
    DateTime? date,
    List<String>? likes,
    String? caption,
    bool? isLiked,
    int? commentsCount,
  }) {
    return SubmissionModel(
      id: id ?? this.id,
      user: user ?? this.user,
      image: image ?? this.image,
      prompt: prompt ?? this.prompt,
      date: date ?? this.date,
      likes: likes ?? this.likes,
      caption: caption ?? this.caption,
      isLiked: isLiked ?? this.isLiked,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }

  factory SubmissionModel.fromMap(Map<String, dynamic> data) {
    return SubmissionModel(
      id: data['id'],
      user: data['user'],
      image: SubmissionImageModel.fromMap(data['image']),
      prompt: PromptSubmissionModel.fromMap(data['prompt']),
      date: (data["date"] as Timestamp).toDate(),
      likes: List<String>.from(data['likes']),
      caption: data['caption'],
      isLiked: data['isLiked'],
      commentsCount: data['commentsCount'],
    );
  }
}

SubmissionModel getDummySubmission({index = 0}) {
  return SubmissionModel(
    id: "dummy$index",
    date: DateTime.now(),
    image: getDummySubmissionImage(),
    caption: "dummy caption",
    isLiked: false,
    likes: [],
    prompt: getDummyPromptSubmission(),
    user: getDummyUser(),
    commentsCount: 0,
  );
}
