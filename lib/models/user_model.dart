class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String username;
  final String profileImageUrl;
  final int followersCount;
  final int followingCount;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.profileImageUrl,
    required this.followersCount,
    required this.followingCount,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      username: data['username'],
      profileImageUrl: data['profileImageUrl'],
      followersCount: data['followersCount'],
      followingCount: data['followingCount'],
    );
  }
}
