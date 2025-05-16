import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picture_that/models/comment_model.dart';
import 'package:picture_that/models/notification_model.dart';
import 'package:picture_that/models/prompt_model.dart';
import 'package:picture_that/models/relationship_model.dart';
import 'package:picture_that/models/submission_model.dart';
import 'package:picture_that/models/user_model.dart';
import 'package:picture_that/providers/submission_provider.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore db = FirebaseFirestore.instance;
final FirebaseStorage storage = FirebaseStorage.instance;
final FirebaseMessaging messaging = FirebaseMessaging.instance;
GoogleSignIn googleSignIn = GoogleSignIn();

//
// miscellaneous
//

/// generate a unique username based on name
Future<String> generateUniqueUsername(String firstName, String lastName) async {
  String base =
      (firstName + lastName).toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  String username = base;
  int attempt = 0;

  while (true) {
    if (await isUsernameAvailable(username)) break;

    attempt++;
    username = "$base${Random().nextInt(1000) + attempt}";
  }

  return username;
}

// check if username is available
Future<bool> isUsernameAvailable(String username) async {
  final query =
      await db.collection("users").where("username", isEqualTo: username).get();
  return query.docs.isEmpty;
}

//
// Authentication
//

/// get a google credential
Future<AuthCredential?> getGoogleCredential() async {
  if (await googleSignIn.isSignedIn()) await googleSignIn.disconnect();

  final googleUser = await googleSignIn.signIn();
  final googleAuth = await googleUser?.authentication;

  if (googleAuth == null) return null;

  return GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
}

/// get an email & password credential
Future<AuthCredential> getEmailPasswordCredential({
  required String email,
  required String password,
}) async {
  return EmailAuthProvider.credential(
    email: email,
    password: password,
  );
}

/// link a login provider
Future<void> linkProvider(AuthCredential credential) async {
  await auth.currentUser?.linkWithCredential(credential);
}

/// unlink a login provider
Future<void> unlinkProvider(String providerId) async {
  await auth.currentUser?.unlink(providerId);
}

/// sign up with email & password
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

  if (!(await isUsernameAvailable(username))) {
    throw Exception("Username is already taken");
  }

  final credential = await auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  await uploadFcmToken(
    await messaging.getToken(),
    userId: credential.user?.uid,
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

/// sign in with email & password
Future<void> signInWithEmailAndPassword({
  required String email,
  required String password,
}) async {
  final credential = await auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );

  await uploadFcmToken(
    await messaging.getToken(),
    userId: credential.user?.uid,
  );
}

/// sign in/up with google
Future<AuthCredential?> signInWithGoogle() async {
  if (await googleSignIn.isSignedIn()) await googleSignIn.disconnect();

  final credential = await getGoogleCredential();
  if (credential == null) return null;

  final userCredential = await auth.signInWithCredential(credential);
  final additionalUserInfo = userCredential.additionalUserInfo;

  await uploadFcmToken(
    await messaging.getToken(),
    userId: userCredential.user?.uid,
  );

  if (additionalUserInfo?.isNewUser == true) {
    final firstName = additionalUserInfo?.profile!["given_name"] ?? "";
    final lastName = additionalUserInfo?.profile!["family_name"] ?? "";

    await uploadDocument(id: userCredential.user!.uid, path: "users", data: {
      "uid": userCredential.user?.uid,
      "firstName": firstName,
      "lastName": lastName,
      "username": await generateUniqueUsername(firstName, lastName),
      "bio": "",
      "url": "",
      "profileImageUrl": userCredential.user?.photoURL,
    });
  }

  return credential;
}

/// sign out
Future<void> signOut() async {
  if (await googleSignIn.isSignedIn()) await googleSignIn.disconnect();
  await deleteFcmToken(await messaging.getToken()); // delete device token
  await auth.signOut();
}

/// send password reset email
Future<void> sendPasswordResetEmail({required String email}) async {
  await auth.sendPasswordResetEmail(email: email);
}

/// delete user account, and all related data
Future<void> deleteAccount() async {
  final userId = auth.currentUser?.uid;
  if (userId == null) return;

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
  final fcmTokensSnapshot =
      await db.collection("fcmTokens").where("userId", isEqualTo: userId).get();

  // delete user auth
  await auth.currentUser?.delete();

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
  for (final doc in fcmTokensSnapshot.docs) {
    batch.delete(doc.reference);
  }
  batch.delete(userDocRef);
  await batch.commit();

  // delete all user images in storage
  final userStorageRef = storage.ref().child("users/$userId");
  final listResult = await userStorageRef.listAll();

  await Future.wait(
    listResult.items.map((item) async {
      await item.delete();
    }),
  );
}

//
// storage
//

/// upload image to storage
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

/// delete image from storage
Future<void> deleteImage({required String path}) async {
  final imgRef = storage.ref().child(
        "users/${auth.currentUser?.uid}/$path",
      );
  await imgRef.delete();
}

//
// Firestore
//

/// upload document to firestore
Future<void> uploadDocument({
  String? id,
  required String path,
  required Map<String, dynamic> data,
}) async {
  await db.collection(path).doc(id).set(data);
}

/// get count of documents from a query
Future<int> getDocumentCount({required Query query}) async {
  final countQuery = query.count();
  final AggregateQuerySnapshot snapshot = await countQuery.get();
  return snapshot.count ?? 0;
}

/// get user given user id
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

/// update user profile
Future<Map<String, dynamic>> updateUserProfile({
  String? firstName,
  String? lastName,
  String? username,
  String? bio,
  String? url,
  XFile? profileImage,
}) async {
  if (username != null && !(await isUsernameAvailable(username))) {
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

  if (newValues.isNotEmpty) {
    await db.collection("users").doc(auth.currentUser?.uid).update(newValues);
  }

  return newValues;
}

/// toggle like on submission
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

/// get submissions from a query
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

/// get a single submission
Future<SubmissionModel?> getSubmission({required String submissionId}) async {
  final snapshot = await db.collection("submissions").doc(submissionId).get();
  if (!snapshot.exists) return null;

  final data = snapshot.data() as Map<String, dynamic>;
  final userData = await getUser(userId: data["userId"]);

  final commentsCount = await getDocumentCount(
    query: db
        .collection("comments")
        .where("submissionId", isEqualTo: submissionId),
  );

  return SubmissionModel.fromMap({
    ...data,
    "isLiked": data["likes"].contains(auth.currentUser?.uid),
    "commentsCount": commentsCount,
    "user": userData,
  });
}

/// get a single prompt
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

/// get a page of prompts
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

/// get a list of users from a username query
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

/// add a submission
Future<void> createSubmission({required SubmissionModel submission}) async {
  // move function from submit_photo_screen.dart to here
}

/// delete a submission
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

/// get comments
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

/// get a single comment
Future<CommentModel?> getComment({required String commentId}) async {
  final snapshot = await db.collection("comments").doc(commentId).get();
  if (!snapshot.exists) return null;

  final data = snapshot.data() as Map<String, dynamic>;
  final userData = await getUser(userId: data["userId"]);

  return CommentModel.fromMap({
    ...data,
    "user": userData,
  });
}

/// add a comment
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

/// delete a comment
Future<void> deleteComment({required String commentId}) async {
  final docRef = db.collection("comments").doc(commentId);
  await docRef.delete();
}

/// fetch all users relationships, both followers and following
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

/// create a relationship
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

/// delete a relationship
Future<void> deleteRelationship(String id) async {
  final docRef = db.collection("relationships").doc(id);
  await docRef.delete();
}

/// get a list of notifications from "notifications" collection
Future<({List<NotificationModel> items, DocumentSnapshot? lastDoc})>
    getNotifications({
  required int limit,
  DocumentSnapshot? lastDocument,
}) async {
  Query query = db
      .collection("notifications")
      .where("recipientId", isEqualTo: auth.currentUser?.uid)
      .orderBy("createdAt", descending: true)
      .limit(limit);

  if (lastDocument != null) {
    query = query.startAfterDocument(lastDocument);
  }

  final snapshot = await query.get();
  final docs = snapshot.docs;

  if (docs.isEmpty) return (items: <NotificationModel>[], lastDoc: null);

  final items = snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel.fromMap(data);
  }).toList();

  return (items: items, lastDoc: docs.last);
}

//
// Notifications
//

/// initialize firebase cloud messaging
///
/// NOTE: this function call will break ios currently, as ios
///   requires apns to be configured, which requires a paid developer account.
Future<void> initializeFcm() async {
  // request permission to send notifications
  await messaging.requestPermission();

  // listen for token refresh
  messaging.onTokenRefresh.listen(uploadFcmToken);

  // listen for messages when app is in foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // showDialog(
    //   context: navigatorKey.currentContext!,
    //   builder: (context) => AlertDialog(
    //     title: Text(message.notification?.title ?? ""),
    //     content: Text(message.notification?.body ?? ""),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.of(context).pop(),
    //         child: const Text("OK"),
    //       ),
    //     ],
    //   ),
    // );
  });
}

/// get device token and upload to firestore
Future<void> uploadFcmToken(String? token, {String? userId}) async {
  if (token == null) return;
  userId ??= auth.currentUser?.uid;

  final existing = await db
      .collection("fcmTokens")
      .where("token", isEqualTo: token)
      .limit(1)
      .get();

  if (existing.docs.isEmpty) {
    final docRef = db.collection("fcmTokens").doc();
    await docRef.set({
      "id": docRef.id,
      "token": token,
      "userId": userId,
      "date": DateTime.now().toUtc(),
    });
  }
}

/// delete device token from firestore
Future<void> deleteFcmToken(String? token) async {
  if (token == null) return;

  final snapshot = await db
      .collection("fcmTokens")
      .where("token", isEqualTo: token)
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    await snapshot.docs.first.reference.delete();
  }
}
