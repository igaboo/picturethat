class RelationshipModel {
  final String id;
  final String follower;
  final String following;

  const RelationshipModel({
    required this.id,
    required this.follower,
    required this.following,
  });

  factory RelationshipModel.fromMap(Map<String, dynamic> data) {
    return RelationshipModel(
      id: data['id'],
      follower: data['follower'],
      following: data['following'],
    );
  }
}
