import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picturethat/repository/firebase_service.dart';

final firebaseProvider = Provider<FirebaseService>(
  (ref) => FirebaseService(),
);
