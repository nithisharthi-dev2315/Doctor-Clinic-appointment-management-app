class UserModel {
  final String id;
  final String username;
  final String email;
  final String mobileNo;
  final String role;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.mobileNo,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["_id"],
      username: json["username"],
      email: json["email"],
      mobileNo: json["mobile_no"],
      role: json["role"],
    );
  }
}
