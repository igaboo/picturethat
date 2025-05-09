import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picture_that/models/comment_model.dart';
import 'package:picture_that/models/prompt_model.dart';
import 'package:picture_that/models/relationship_model.dart';
import 'package:picture_that/models/submission_model.dart';
import 'package:picture_that/models/user_model.dart';
import 'package:picture_that/providers/submission_provider.dart';

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
    query: db.collection("relationships").where("following", isEqualTo: userId),
  );

  final followingCount = await getDocumentCount(
    query: db.collection("relationships").where("follower", isEqualTo: userId),
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
Future<Map<String, dynamic>> updateUserProfile({
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

  return newValues;
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
  await imgRef.putData(await image.readAsBytes());
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
  List<RelationshipModel>? following,
}) async {
  Query query = db.collection("submissions");
  switch (queryParam.type) {
    case SubmissionQueryType.byUser:
      query = query
          .where("userId", isEqualTo: queryParam.id)
          .orderBy("date", descending: true);
      break;
    case SubmissionQueryType.byPrompt:
      query = query
          .where("prompt.id", isEqualTo: queryParam.id)
          .orderBy("date", descending: true);
      break;
    case SubmissionQueryType.byFollowing:

      // firebase has a limitation of 30 whereIn clauses,
      // so this will only work for 30 followed users.
      // in the future, we need to switch to a different
      // database (SQL, supabase) to support more than 30 followers.

      final followedUsers = following?.map((u) => u.following).toList() ?? [];

      if (followedUsers.isEmpty) {
        return (items: <SubmissionModel>[], lastDoc: null);
      }

      query = query
          .where("userId", whereIn: followedUsers)
          .orderBy("date", descending: true);

      break;
    case SubmissionQueryType.byRandom:
      // get top liked submissions in the last week
      // not including the current user's submissions
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 7));
      final cutoff = Timestamp.fromDate(startDate.toUtc());

      query = query
          .where("userId", isNotEqualTo: auth.currentUser?.uid)
          .where("date", isGreaterThan: cutoff)
          .orderBy("likes", descending: true)
          .orderBy("date", descending: true)
          .orderBy("userId", descending: true);

      break;
  }

  query = query.limit(limit);

  if (lastDocument != null) {
    query = query.startAfterDocument(lastDocument);
  }

  final snapshot = await query.get();
  final docs = snapshot.docs;

  if (docs.isEmpty) return (items: <SubmissionModel>[], lastDoc: null);

  final items = await Future.wait(docs.map((doc) async {
    final data = doc.data() as Map<String, dynamic>;

    final userData = await getUser(userId: data["userId"]);

    final commentsCount = await getDocumentCount(
      query: db.collection("comments").where("submissionId", isEqualTo: doc.id),
    );

    return SubmissionModel.fromMap({
      ...data,
      "isLiked": data["likes"].contains(auth.currentUser?.uid),
      "commentsCount": commentsCount,
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

// delete a submission
Future<void> deleteSubmission({required String submissionId}) async {
  final docRef = db.collection("submissions").doc(submissionId);

  final commentsSnapshot = await db
      .collection("comments")
      .where("submissionId", isEqualTo: submissionId)
      .get();

  final batch = db.batch();

  for (final commentDoc in commentsSnapshot.docs) {
    batch.delete(commentDoc.reference);
  }

  await Future.wait([
    batch.commit(),
    docRef.delete(),
    deleteImage(path: "submissions/$submissionId"),
  ]);
}

// add a submission
Future<void> createSubmission({required SubmissionModel submission}) async {}

// get comments
Future<({List<CommentModel> items, DocumentSnapshot? lastDoc})> getComments({
  required String submissionId,
  required int limit,
  DocumentSnapshot? lastDocument,
}) async {
  Query query = db
      .collection("comments")
      .where("submissionId", isEqualTo: submissionId)
      .orderBy("date", descending: true)
      .limit(limit);

  if (lastDocument != null) {
    query = query.startAfterDocument(lastDocument);
  }

  final snapshot = await query.get();
  final docs = snapshot.docs;

  if (docs.isEmpty) return (items: <CommentModel>[], lastDoc: null);

  final items = await Future.wait(docs.map((doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final userData = await getUser(userId: data["userId"]);

    return CommentModel.fromMap({
      ...data,
      "user": userData,
    });
  }));

  return (items: items, lastDoc: docs.last);
}

// add a comment
Future<String> createComment({
  required String submissionId,
  required String userId,
  required String text,
}) async {
  final docRef = db.collection("comments").doc();

  await docRef.set({
    "id": docRef.id,
    "submissionId": submissionId,
    "userId": userId,
    "text": text,
    "date": DateTime.now().toUtc(),
  });

  return docRef.id;
}

// delete a comment
Future<void> deleteComment({required String commentId}) async {
  final docRef = db.collection("comments").doc(commentId);
  await docRef.delete();
}

// send password reset email
Future<void> sendPasswordResetEmail({required String email}) async {
  await auth.sendPasswordResetEmail(email: email);
}

// fetch all users relationships, both followers and following
Future<({List<RelationshipModel> followers, List<RelationshipModel> following})>
    getRelationships() async {
  final relationshipsSnapshot = await db
      .collection("relationships")
      .where(Filter.or(
        Filter("follower", isEqualTo: auth.currentUser?.uid),
        Filter("following", isEqualTo: auth.currentUser?.uid),
      ))
      .get();

  final followers = <RelationshipModel>[];
  final following = <RelationshipModel>[];

  for (final doc in relationshipsSnapshot.docs) {
    final data = doc.data();

    data["follower"] == auth.currentUser?.uid
        ? following.add(RelationshipModel.fromMap(data))
        : followers.add(RelationshipModel.fromMap(data));
  }

  return (followers: followers, following: following);
}

// create a relationship
Future<RelationshipModel> createRelationship(String following) async {
  final docRef = db.collection("relationships").doc();

  await docRef.set({
    "id": docRef.id,
    "follower": auth.currentUser?.uid,
    "following": following,
  });

  return RelationshipModel(
    id: docRef.id,
    follower: auth.currentUser!.uid,
    following: following,
  );
}

// delete a relationship
Future<void> deleteRelationship(String id) async {
  final docRef = db.collection("relationships").doc(id);
  await docRef.delete();
}

Future<void> deleteAccount() async {
  final userId = auth.currentUser?.uid;
  if (userId == null) return;

  // delete all the users submissions, comments, and relationships
  final batch = db.batch();

  final userDocRef = db.collection("users").doc(userId);
  final submissionsSnapshot = await db
      .collection("submissions")
      .where("userId", isEqualTo: userId)
      .get();
  final commentsSnapshot =
      await db.collection("comments").where("userId", isEqualTo: userId).get();
  final relationshipsSnapshot = await db
      .collection("relationships")
      .where(Filter.or(
        Filter("follower", isEqualTo: auth.currentUser?.uid),
        Filter("following", isEqualTo: auth.currentUser?.uid),
      ))
      .get();

  // delete all user documents in firestore
  for (final doc in submissionsSnapshot.docs) {
    batch.delete(doc.reference);
  }
  for (final doc in commentsSnapshot.docs) {
    batch.delete(doc.reference);
  }
  for (final doc in relationshipsSnapshot.docs) {
    batch.delete(doc.reference);
  }
  batch.delete(userDocRef);
  await batch.commit();

  // delete all user images in storage
  final userStorageRef = storage.ref().child("users/$userId");
  final listResult = await userStorageRef.listAll();
  for (final item in listResult.items) {
    await item.delete();
  }

  // delete user auth
  await auth.currentUser?.delete();
}
