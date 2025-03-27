import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/models/user_model.dart';
import 'package:picturethat/providers/firebase_provider.dart';

final userProvider = FutureProvider<UserModel?>((ref) async {
  final firebaseService = ref.read(firebaseProvider);
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return null;

  return await firebaseService.getUser(userId: user.uid);
});
