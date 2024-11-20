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
        String role = responseData['result']['role'];
        String departmentId = responseData['result']['departmentId'];
        role = role.replaceAll('[', '').replaceAll(']', ''); // Remove square brackets
          // Save token to shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', responseData['result']['token']);
          await prefs.setString('role', role);
          await prefs.setString('departmentId', departmentId);
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
        await prefs.remove('role');
        await prefs.remove('departmentId');
      }
      return responseData;
    } else {
      throw Exception('Failed to logout: ${response.statusCode}');
    }
  }

  Future<void> getPassword(String userName, String password) async {
    final url = Uri.parse('${baseUrl}api/users/getPassword');
     // Replace with your actual Bearer token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userName': userName,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData;
    } else {
      throw Exception('Failed to logout: ${response.statusCode}');
    }
  }
}