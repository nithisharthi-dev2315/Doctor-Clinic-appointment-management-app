import 'user_model.dart';

class LoginResponse {
  final bool success;
  final UserModel user;
  final String token;

  LoginResponse({
    required this.success,
    required this.user,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json["success"],
      user: UserModel.fromJson(json["user"]),
      token: json["token"],
    );
  }
}
