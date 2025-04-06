import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picturethat/models/prompt_model.dart';
import 'package:picturethat/models/submission_model.dart';
import 'package:picturethat/models/user_model.dart';
import 'package:picturethat/providers/submission_provider.dart';

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
  required XFile? profileImage,
}) async {
  if (profileImage == null) {
    throw Exception("Select a profile image before continuing");
  }

  if (!(await isUsernameAvailable(username: username))) {
    throw Exception("Username is already taken");
  }

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
    "bio": "",
    "url": "",
    "profileImageUrl": profileImageUrl,
  });
}

// sign in with email & password
Future<void> signInWithEmailAndPassword({
  required String email,
  required String password,
}) async {
  await auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
}

// sign out
Future<void> signOut() async {
  await auth.signOut();
}

// get user given user id
Future<UserModel?> getUser({required String userId}) async {
  DocumentSnapshot userDoc = await db.collection("users").doc(userId).get();
  if (!userDoc.exists) return null;

  final followersCount = await getDocumentCount(
    query:
        db.collection("relationships").where("followerUid", isEqualTo: userId),
  );

  final followingCount = await getDocumentCount(
    query:
        db.collection("relationships").where("followingUid", isEqualTo: userId),
  );

  final submissionsCount = await getDocumentCount(
    query: db.collection("submissions").where("userId", isEqualTo: userId),
  );

  final userData = {
    ...userDoc.data() as Map<String, dynamic>,
    "followersCount": followersCount,
    "followingCount": followingCount,
    "submissionsCount": submissionsCount,
  };

  return UserModel.fromMap(userData);
}

// update user profile
Future<void> updateUserProfile({
  String? firstName,
  String? lastName,
  String? username,
  String? bio,
  String? url,
  XFile? profileImage,
}) async {
  if (username != null && !(await isUsernameAvailable(username: username))) {
    throw Exception("Username is already taken");
  }

  final profileImageUrl = profileImage != null
      ? await uploadImage(path: "pfp", image: profileImage)
      : null;

  final newValues = {
    if (firstName != null) "firstName": firstName,
    if (lastName != null) "lastName": lastName,
    if (username != null) "username": username,
    if (bio != null) "bio": bio,
    if (url != null) "url": url,
    if (profileImageUrl != null) "profileImageUrl": profileImageUrl,
  };

  await db.collection("users").doc(auth.currentUser?.uid).update(newValues);
}

// check if username is available
Future<bool> isUsernameAvailable({required String username}) async {
  final query =
      await db.collection("users").where("username", isEqualTo: username).get();
  return query.docs.isEmpty;
}

// upload image to storage
Future<String> uploadImage({
  required String path,
  required XFile image,
}) async {
  final imgRef = storage.ref().child(
        "users/${auth.currentUser?.uid}/$path",
      );
  await imgRef.putFile(File(image.path));
  return await imgRef.getDownloadURL();
}

// delete image from storage
Future<void> deleteImage({required String path}) async {
  final imgRef = storage.ref().child(
        "users/${auth.currentUser?.uid}/$path",
      );
  await imgRef.delete();
}

// upload document to firestore
Future<void> uploadDocument({
  String? id,
  required String path,
  required Map<String, dynamic> data,
}) async {
  await db.collection(path).doc(id).set(data);
}

// get count of documents from a query
Future<int> getDocumentCount({required Query query}) async {
  final countQuery = query.count();
  final AggregateQuerySnapshot snapshot = await countQuery.get();
  return snapshot.count ?? 0;
}

// toggle like on submission
Future<void> toggleLike({
  required String submissionId,
  required String uid,
  required bool isLiked,
}) async {
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
}

// get submissions from a query
Future<({List<SubmissionModel> items, DocumentSnapshot? lastDoc})>
    getSubmissions({
  required SubmissionQueryParam queryParam,
  required int limit,
  DocumentSnapshot? lastDocument,
  UserModel? user,
}) async {
  Query query = db.collection("submissions");
  switch (queryParam.type) {
    case SubmissionQueryType.byUser:
      query = query.where("userId", isEqualTo: queryParam.id);
      break;
    case SubmissionQueryType.byPrompt:
      query = query.where("prompt.id", isEqualTo: queryParam.id);
      break;
    case SubmissionQueryType.all:
      // filter by followed users
      break;
  }

  query = query.orderBy("date", descending: true).limit(limit);

  if (lastDocument != null) {
    query = query.startAfterDocument(lastDocument);
  }

  final snapshot = await query.get();
  final docs = snapshot.docs;

  if (docs.isEmpty) {
    return (items: <SubmissionModel>[], lastDoc: null);
  }

  final items = await Future.wait(docs.map((doc) async {
    final data = doc.data() as Map<String, dynamic>;

    final userData = user ?? await getUser(userId: data["userId"]);

    return SubmissionModel.fromMap({
      ...data,
      "isLiked": data["likes"].contains(auth.currentUser?.uid),
      "user": userData,
    });
  }));

  return (items: items, lastDoc: docs.last);
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

// get a page of prompts
Future<({List<PromptModel> items, DocumentSnapshot? lastDoc})> getPrompts({
  required int limit,
  DocumentSnapshot? lastDocument,
}) async {
  final now = DateTime.now();
  final startOfTomorrow = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
  final cutoff = Timestamp.fromDate(startOfTomorrow.toUtc());

  Query query = db
      .collection("prompts")
      .where("date", isLessThan: cutoff)
      .orderBy("date", descending: true)
      .limit(limit);

  if (lastDocument != null) {
    query = query.startAfterDocument(lastDocument);
  }

  final snapshot = await query.get();
  final docs = snapshot.docs;

  if (docs.isEmpty) {
    return (items: <PromptModel>[], lastDoc: null);
  }

  final items = await Future.wait(docs.map((doc) async {
    final submissionCount = await getDocumentCount(
      query: db.collection("submissions").where("prompt.id", isEqualTo: doc.id),
    );

    final promptData = {
      ...doc.data() as Map<String, dynamic>,
      "submissionCount": submissionCount,
    };

    return PromptModel.fromMap(promptData);
  }));

  return (items: items, lastDoc: docs.last);
}

// get a list of users from a username query
Future<List<UserSearchResultModel>> searchUsers({required String query}) async {
  final snapshot = await db
      .collection("users")
      .where("username", isGreaterThanOrEqualTo: query)
      .where("username", isLessThanOrEqualTo: "$query\uf8ff")
      .limit(5)
      .get();

  return snapshot.docs
      .map((doc) => UserSearchResultModel.fromMap(doc.data()))
      .toList();
}
