class AppUser {
  final String uid;
  final String email;
  final String token;
  final String firstName;
  final String lastName;
  final String username;
  final String? avatar;
  final String? avatarThumbnail;

  AppUser({
    required this.uid,
    required this.email,
    required this.token,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.avatar,
    this.avatarThumbnail,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'token': token,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'avatar': avatar,
      'avatarThumbnail': avatarThumbnail,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      uid: jsonUser['uid'] ?? '',
      email: jsonUser['email'] ?? '',
      token: jsonUser['token'] ?? '',
      firstName: jsonUser['firstName'] ?? '',
      lastName: jsonUser['lastName'] ?? '',
      username: jsonUser['username'] ?? '',
      avatar: jsonUser['avatar'],
      avatarThumbnail: jsonUser['avatarThumbnail'],
    );
  }
}
