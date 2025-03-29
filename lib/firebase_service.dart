import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picturethat/models/prompt_model.dart';
import 'package:picturethat/models/submission_model.dart';
import 'package:picturethat/models/user_model.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore db = FirebaseFirestore.instance;
final FirebaseStorage storage = FirebaseStorage.instance;

// sign up with email & password
Future<void> signUpWithEmailAndPassword({
  required String email,
  required String password,
  required String firstName,
  required String lastName,
  required String username,
  required XFile profileImage,
}) async {
  try {
    UserCredential credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String profileImageUrl = await uploadImage(
      path: "pfp",
      image: profileImage,
    );

    await uploadDocument(id: credential.user!.uid, path: "users", data: {
      "uid": credential.user?.uid,
      "firstName": firstName,
      "lastName": lastName,
      "username": username,
      "profileImageUrl": profileImageUrl,
    });
  } catch (e) {
    rethrow;
  }
}

// sign in with email & password
Future<void> signInWithEmailAndPassword({
  required String email,
  required String password,
}) async {
  try {
    await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  } catch (e) {
    rethrow;
  }
}

// sign out
Future<void> signOut() async {
  try {
    await auth.signOut();
  } catch (e) {
    rethrow;
  }
}

// get user given user id
Future<UserModel?> getUser({required String userId}) async {
  try {
    DocumentSnapshot userDoc = await db.collection("users").doc(userId).get();
    if (!userDoc.exists) return null;

    final followersCount = await getDocumentCount(
      query: db
          .collection("relationships")
          .where("followerUid", isEqualTo: userId),
    );

    final followingCount = await getDocumentCount(
      query: db
          .collection("relationships")
          .where("followingUid", isEqualTo: userId),
    );

    final userData = {
      ...userDoc.data() as Map<String, dynamic>,
      "followersCount": followersCount,
      "followingCount": followingCount,
    };

    return UserModel.fromMap(userData);
  } catch (e) {
    rethrow;
  }
}

// update user profile
Future<void> updateUserProfile({
  String? firstName,
  String? lastName,
  String? username,
  XFile? profileImage,
}) async {
  try {
    final profileImageUrl = profileImage != null
        ? await uploadImage(path: "pfp", image: profileImage)
        : null;

    final newValues = {
      if (firstName != null) "firstName": firstName,
      if (lastName != null) "lastName": lastName,
      if (username != null) "username": username,
      if (profileImageUrl != null) "profileImageUrl": profileImageUrl,
    };

    await db.collection("users").doc(auth.currentUser?.uid).update(newValues);
  } catch (e) {
    rethrow;
  }
}

// check if username is available
Future<bool> isUsernameAvailable({required String username}) async {
  try {
    final query = await db
        .collection("users")
        .where("username", isEqualTo: username)
        .get();
    return query.docs.isEmpty;
  } catch (e) {
    rethrow;
  }
}

// upload image to storage
Future<String> uploadImage({
  required String path,
  required XFile image,
}) async {
  try {
    final imgRef = storage.ref().child(
          "users/${auth.currentUser?.uid}/$path",
        );
    await imgRef.putFile(File(image.path));
    return await imgRef.getDownloadURL();
  } catch (e) {
    rethrow;
  }
}

// delete image from storage
Future<void> deleteImage({required String path}) async {
  try {
    final imgRef = storage.ref().child(
          "users/${auth.currentUser?.uid}/$path",
        );
    await imgRef.delete();
  } catch (e) {
    rethrow;
  }
}

// upload document to firestore
Future<void> uploadDocument({
  String? id,
  required String path,
  required Map<String, dynamic> data,
}) async {
  try {
    await db.collection(path).doc(id).set(data);
  } catch (e) {
    rethrow;
  }
}

// get count of documents from a query
Future<int> getDocumentCount({required Query query}) async {
  try {
    final countQuery = await query.count();
    final AggregateQuerySnapshot snapshot = await countQuery.get();
    return snapshot.count ?? 0;
  } catch (e) {
    rethrow;
  }
}

// toggle like on submission
Future<void> toggleLike({
  required String submissionId,
  required String uid,
  required bool isLiked,
}) async {
  try {
    final docRef = db.collection("submissions").doc(submissionId);

    if (isLiked) {
      await docRef.update({
        "likes": FieldValue.arrayRemove([uid]),
      });
    } else {
      await docRef.update({
        "likes": FieldValue.arrayUnion([uid]),
      });
    }
  } catch (e) {
    rethrow;
  }
}

// get submissions from a query
Future<List<SubmissionModel>> getSubmissions({
  required Query query,
  UserModel? user,
}) async {
  try {
    final snapshot = await query.get();

    return Future.wait(snapshot.docs.map((doc) async {
      final data = doc.data() as Map<String, dynamic>;

      final userData = user ?? await getUser(userId: data["userId"]);

      return SubmissionModel.fromMap({
        ...data,
        "isLiked": data["likes"].contains(auth.currentUser?.uid),
        "user": userData,
      });
    }));
  } catch (e) {
    rethrow;
  }
}

// get a single prompt
Future<PromptModel?> getPrompt({required String promptId}) async {
  final snapshot = await db.collection("prompts").doc(promptId).get();
  if (!snapshot.exists) return null;

  final submissionCount = await getDocumentCount(
    query: db.collection("submissions").where("prompt.id", isEqualTo: promptId),
  );
  final promptData = {
    ...snapshot.data() as Map<String, dynamic>,
    "submissionCount": submissionCount,
  };
  return PromptModel.fromMap(promptData);
}

// get all prompts
Future<List<PromptModel>> getPrompts() async {
  final snapshot = await db
      .collection("prompts")
      .where("date", isLessThan: DateTime.now())
      .orderBy("date", descending: true)
      .get();

  return Future.wait(snapshot.docs.map((doc) async {
    final submissionCount = await getDocumentCount(
      query: db.collection("submissions").where("prompt.id", isEqualTo: doc.id),
    );

    final promptData = {
      ...doc.data(),
      "submissionCount": submissionCount,
    };

    return PromptModel.fromMap(promptData);
  }));
}
