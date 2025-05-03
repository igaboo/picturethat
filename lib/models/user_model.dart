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

  UserModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? username,
    String? profileImageUrl,
    int? followersCount,
    int? followingCount,
    int? submissionsCount,
    String? bio,
    String? url,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      submissionsCount: submissionsCount ?? this.submissionsCount,
      bio: bio ?? this.bio,
      url: url ?? this.url,
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
