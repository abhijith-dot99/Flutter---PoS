class Users {
  late final String username;
  Users({
    required this.username,
  });

  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      username: map['username'] ?? '',
      // category: map['category'] ?? '',
    );
  }
}
