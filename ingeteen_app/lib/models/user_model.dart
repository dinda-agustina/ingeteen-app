class UserModel {
  final int id;
  final String username;

  const UserModel({required this.id, required this.username});

  // Password sengaja tidak disimpan di model client.
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(id: json['id'], username: json['username']);

  Map<String, dynamic> toJson() => {'id': id, 'username': username};
}