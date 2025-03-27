import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picturethat/models/user_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // upload document to firestore
  Future<void> uploadDocument({
    String? id,
    required String path,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db.collection(path).doc(id).set(data);
    } catch (e) {
      rethrow;
    }
  }

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
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
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
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  // sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // get user given user id
  Future<UserModel?> getUser({required String userId}) async {
    try {
      DocumentSnapshot userDoc =
          await _db.collection("users").doc(userId).get();
      if (!userDoc.exists) return null;
      return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
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

      await _db
          .collection("users")
          .doc(_auth.currentUser?.uid)
          .update(newValues);
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
      final imgRef = _storage.ref().child(
            "users/${_auth.currentUser?.uid}/$path",
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
      final imgRef = _storage.ref().child(
            "users/${_auth.currentUser?.uid}/$path",
          );
      await imgRef.delete();
    } catch (e) {
      rethrow;
    }
  }

  // check if username is available
  Future<bool> isUsernameAvailable({required String username}) async {
    try {
      final query = await _db
          .collection("users")
          .where("username", isEqualTo: username)
          .get();
      return query.docs.isEmpty;
    } catch (e) {
      rethrow;
    }
  }
}
