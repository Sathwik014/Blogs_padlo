class UserModel {
  final String uid;
  final String username;
  final String email;
  final String mobileNo;
  final String profilePicUrl;
  final List<String> followers;
  final List<String> following;
  final List<String> blogs;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.mobileNo,
    required this.profilePicUrl,
    required this.followers,
    required this.following,
    required this.blogs,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      username: map['username'],
      email: map['email'],
      mobileNo: map['mobileNo'],
      profilePicUrl: map['profilePicUrl'],
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
      blogs: List<String>.from(map['blogs'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'mobileNo': mobileNo,
      'profilePicUrl': profilePicUrl,
      'followers': followers,
      'following': following,
      'blogs': blogs,
    };
  }
}
