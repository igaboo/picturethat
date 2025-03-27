class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String username;
  final String profileImageUrl;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.profileImageUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      username: data['username'],
      profileImageUrl: data['profileImageUrl'],
    );
  }
}
