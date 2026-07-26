class AppUser {
  final String uid;
  final String email;
  final String token;

  AppUser({required this.uid, required this.email, required this.token});

  // Convert app user -> json
  Map<String, dynamic> toJson() {
    return {'uid': uid, 'email': email, 'token': token};
  }

  // Convert json -> app user
  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      uid: jsonUser['uid'] ?? '',
      email: jsonUser['email'] ?? '',
      token: jsonUser['token'] ?? '',
    );
  }
}
