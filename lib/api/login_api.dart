import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiService.dart';
import 'login_request.dart';
import 'login_response.dart';


class LoginApi {
  static Future<LoginResponse> login(LoginRequest request) async {
    http.Response response = await ApiService.post(
      "/admin/login",
      request.toJson(),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Login failed");
    }
  }
}
