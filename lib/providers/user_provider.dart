import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/models/user_model.dart';
import 'package:picturethat/firebase_service.dart';
import 'package:picturethat/providers/auth_provider.dart';

final userProvider =
    FutureProvider.family<UserModel?, String>((ref, userId) async {
  // ensures auth state is loaded, will reset all state when auth changes
  ref.watch(authProvider);

  return getUser(userId: userId);
});
