import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picturethat/models/prompt_model.dart';
import 'package:picturethat/models/user_model.dart';

class SubmissionModel {
  String id;
  UserModel user;
  String imageUrl;
  PromptSubmissionModel prompt;
  DateTime date;
  List<String> likes;
  String caption;
  bool isLiked;

  SubmissionModel({
    required this.id,
    required this.user,
    required this.imageUrl,
    required this.prompt,
    required this.date,
    required this.likes,
    required this.caption,
    required this.isLiked,
  });

  SubmissionModel copyWith({
    String? id,
    UserModel? user,
    String? imageUrl,
    PromptSubmissionModel? prompt,
    DateTime? date,
    List<String>? likes,
    String? caption,
    bool? isLiked,
  }) {
    return SubmissionModel(
      id: id ?? this.id,
      user: user ?? this.user,
      imageUrl: imageUrl ?? this.imageUrl,
      prompt: prompt ?? this.prompt,
      date: date ?? this.date,
      likes: likes ?? this.likes,
      caption: caption ?? this.caption,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  factory SubmissionModel.fromMap(Map<String, dynamic> data) {
    return SubmissionModel(
      id: data['id'],
      user: data['user'],
      imageUrl: data['imageUrl'],
      prompt: PromptSubmissionModel.fromMap(data['prompt']),
      date: (data["date"] as Timestamp).toDate(),
      likes: List<String>.from(data['likes']),
      caption: data['caption'],
      isLiked: data['isLiked'],
    );
  }
}
