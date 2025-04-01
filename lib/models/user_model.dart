class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String username;
  final String profileImageUrl;
  final int followersCount;
  final int followingCount;
  final int submissionsCount;
  final String? bio;
  final String? url;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.profileImageUrl,
    required this.followersCount,
    required this.followingCount,
    required this.submissionsCount,
    this.bio,
    this.url,
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
      submissionsCount: data['submissionsCount'],
      bio: data['bio'],
      url: data['url'],
    );
  }
}

class UserSearchResultModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String username;
  final String profileImageUrl;
  final String? bio;
  final String? url;

  UserSearchResultModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.profileImageUrl,
    this.bio,
    this.url,
  });

  factory UserSearchResultModel.fromMap(Map<String, dynamic> data) {
    return UserSearchResultModel(
      uid: data['uid'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      username: data['username'],
      profileImageUrl: data['profileImageUrl'],
      bio: data['bio'],
      url: data['url'],
    );
  }
}
