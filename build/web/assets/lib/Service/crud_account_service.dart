import 'dart:convert';
import 'package:eventmanagement/Class/user.dart';
import 'package:eventmanagement/Service/localhost.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CrudAccountService {
  final String _baseUrl = '${baseUrl}api/users/';

  Future<Users?> updateUserRole(String userName, List<String> roles) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.put(
      Uri.parse('${_baseUrl}updateRole/$userName'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'roles': roles,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] == 1000) {
        return Users.fromJson(data['result']);
      } else {
        throw Exception('Failed to update user role');
      }
    } else {
      throw Exception('Failed to update user role');
    }
  }

  Future<Users?> registerUser(String userName, String password, String email) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'userName': userName,
        'password': password,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] == 1000) {
        return Users.fromJson(data['result']);
      } else {
        throw Exception('Failed to register user');
      }
    } else {
      throw Exception('Failed to register user');
    }
  }
}