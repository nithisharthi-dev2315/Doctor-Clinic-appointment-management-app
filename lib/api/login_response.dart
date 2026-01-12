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
class ClinicLoginResponse {
  final bool success;
  final ClinicUser clinic;

  ClinicLoginResponse({
    required this.success,
    required this.clinic,
  });

  factory ClinicLoginResponse.fromJson(Map<String, dynamic> json) {
    return ClinicLoginResponse(
      success: json['success'] ?? false,
      clinic: ClinicUser.fromJson(json['user'] ?? {}),
    );
  }
}
class ClinicUser {
  final String id;           // _id
  final String clinicName;   // clinic_name
  final String username;     // username
  final String role;         // role
  final String ownerRole;    // ownerRole
  final String? email;       // email (nullable)
  final String mobileNo;     // mobile_no

  ClinicUser({
    required this.id,
    required this.clinicName,
    required this.username,
    required this.role,
    required this.ownerRole,
    this.email,
    required this.mobileNo,
  });

  factory ClinicUser.fromJson(Map<String, dynamic> json) {
    return ClinicUser(
      id: json['_id'] ?? '',
      clinicName: json['clinic_name'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      ownerRole: json['ownerRole'] ?? '',
      email: json['email'],
      mobileNo: json['mobile_no'] ?? '',
    );
  }
}
UserModel clinicUserToUserModel(ClinicUser clinic) {
  return UserModel(
    id: clinic.id,
    username: clinic.username,
    role: clinic.role,
    email: clinic.email ?? "",
    mobileNo: clinic.mobileNo,
  );
}
