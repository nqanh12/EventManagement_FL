import 'dart:convert';
import 'package:eventmanagement/Service/localhost.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  LoginService();

  Future<Map<String, dynamic>> loginApi(String userName, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userName': userName,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['code'] == 1000) {
        if (responseData['result']['role'].contains('ADMIN')) {
          // Save token to shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', responseData['result']['token']);
        }else{
          // Handle login error
          return {'code': 1001, 'message': 'Tài khoản không có quyền truy cập!'};
        }

      }
        return responseData;
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
  }

  Future<Map<String, dynamic>> logout(String token) async {
    final response = await http.post(
      Uri.parse('${baseUrl}auth/logout'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['code'] == 1000) {
        // Remove token from shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
      }
      return responseData;
    } else {
      throw Exception('Failed to login: ${response.statusCode}');
    }
  }
}