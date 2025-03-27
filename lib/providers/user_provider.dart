import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/models/user_model.dart';
import 'package:picturethat/providers/auth_provider.dart';
import 'package:picturethat/providers/firebase_provider.dart';

final userProvider = FutureProvider<UserModel?>((ref) async {
  final firebaseService = ref.read(firebaseProvider);
  final user = ref.watch(authProvider).value;

  if (user == null) return null;

  return await firebaseService.getUser(userId: user.uid);
});
