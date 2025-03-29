import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/models/submission_model.dart';
import 'package:picturethat/models/user_model.dart';
import 'package:picturethat/firebase_service.dart';
import 'package:picturethat/providers/auth_provider.dart';

enum SubmissionQueryType {
  all,
  byUser,
  byPrompt,
}

typedef SubmissionQueryParam = ({
  SubmissionQueryType type,
  String? id,
  UserModel? user
});

class SubmissionNotifier
    extends FamilyAsyncNotifier<List<SubmissionModel>, SubmissionQueryParam> {
  @override
  Future<List<SubmissionModel>> build(SubmissionQueryParam arg) async {
    // ensures auth state is loaded, will reset all state when auth changes
    ref.watch(authProvider);

    Query query;

    switch (arg.type) {
      case SubmissionQueryType.byUser:
        query = db.collection("submissions").where("userId", isEqualTo: arg.id);
        break;
      case SubmissionQueryType.byPrompt:
        query =
            db.collection("submissions").where("prompt.id", isEqualTo: arg.id);
        break;
      case SubmissionQueryType.all:
        query = db.collection("submissions");
    }

    query = query.orderBy("date", descending: true);

    return await getSubmissions(query: query, user: arg.user);
  }

  Future<void> toggleSubmissionLike({
    required String submissionId,
    required bool isLiked,
  }) async {
    state = AsyncValue.data([
      for (SubmissionModel submission in state.valueOrNull ?? [])
        if (submission.id == submissionId)
          submission.copyWith(
            isLiked: !isLiked,
            likes: isLiked
                ? submission.likes
                    .where((id) => id != auth.currentUser!.uid)
                    .toList()
                : [...submission.likes, auth.currentUser!.uid],
          )
        else
          submission,
    ]);

    await toggleLike(
      submissionId: submissionId,
      uid: auth.currentUser!.uid,
      isLiked: isLiked,
    );
  }
}

final submissionNotifierProvider = AsyncNotifierProvider.family<
    SubmissionNotifier, List<SubmissionModel>, SubmissionQueryParam>(() {
  return SubmissionNotifier();
});
