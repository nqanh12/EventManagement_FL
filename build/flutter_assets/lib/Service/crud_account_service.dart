import 'dart:convert';
import 'package:eventmanagement/Class/user.dart';
import 'package:eventmanagement/Service/localhost.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CrudAccountService {
  final String _baseUrl = '${baseUrl}api/users/';

  Future<Users?> createAdmin({
    required String userName,
    required String fullName,
    required String password,
    required String email,
    required String gender,
    required String departmentId,
  }) async {
    final url = Uri.parse('${_baseUrl}createAdmin');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userName': userName,
        'fullName': fullName,
        'password': password,
        'email': email,
        'gender': gender,
        'departmentId': departmentId,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['code'] == 1000) {
        return Users.fromJson(responseData['result']);
      } else {
        throw Exception('Failed to create admin: ${responseData['message']}');
      }
    } else {
      throw Exception('Failed to create admin: ${response.reasonPhrase}');
    }
  }

  Future<Users?> createUser({
    required String userName,
    required String password,
    required String fullName,
    required String email,
    required String gender,
    required String classId,
  }) async {
    final url = Uri.parse('${_baseUrl}createUser');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final departmentId = prefs.getString('departmentId') ?? '';
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userName': userName,
        'password': password,
        'fullName': fullName,
        'email': email,
        'departmentId': departmentId,
        'gender': gender,
        'class_id': classId,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['code'] == 1000) {
        return Users.fromJson(responseData['result']);
      } else {
        throw Exception('Failed to create user: ${responseData['message']}');
      }
    } else {
      throw Exception('Failed to create user: ${response.reasonPhrase}');
    }
  }
  Future<Users?> createManager({
    required String userName,
    required String password,
    required String fullName,
    required String email,
    required String gender,
    required String classId,
    required List<String> roles,
  }) async {
    final url = Uri.parse('${_baseUrl}createManager');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final departmentId = prefs.getString('departmentId') ?? '';
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userName': userName,
        'password': password,
        'fullName': fullName,
        'email': email,
        'departmentId': departmentId,
        'gender': gender,
        'class_id': classId,
        'roles': roles,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['code'] == 1000) {
        return Users.fromJson(responseData['result']);
      } else {
        throw Exception('Failed to create user: ${responseData['message']}');
      }
    } else {
      throw Exception('Failed to create user: ${response.reasonPhrase}');
    }
  }

  Future<Users?> updateAdmin({
    required String userName,
    required String fullName,
    required String email,
    required String gender,
    required String departmentId,
    required List<String> roles,
  }) async {
    final url = Uri.parse('${_baseUrl}updateAdmin/$userName');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'full_Name': fullName,
        'email': email,
        'gender': gender,
        'departmentId': departmentId,
        'roles': roles,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['code'] == 1000) {
        return Users.fromJson(responseData['result']);
      } else {
        throw Exception('Failed to update admin: ${responseData['message']}');
      }
    } else {
      throw Exception('Failed to update admin: ${response.reasonPhrase}');
    }
  }

  Future<List<Users>> listUsers() async {
    final url = Uri.parse('${_baseUrl}listUsers');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['code'] == 1000) {
        final List<dynamic> results = responseData['result'];
        return results.map((user) => Users.fromJson(user))
            .toList()
            .reversed
            .toList();
      } else {
        throw Exception('Failed to fetch users: ${responseData['message']}');
      }
    } else {
      throw Exception('Failed to fetch users: ${response.reasonPhrase}');
    }
  }

  Future<List<Users>> listUsersByDepartment({int page = 1, int pageSize = 50}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final departmentId = prefs.getString('departmentId') ?? '';
    final url = Uri.parse('${_baseUrl}listUsersByDepartment/$departmentId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(utf8.decode(response.bodyBytes));
      if (responseData['code'] == 1000) {
        final List<dynamic> results = responseData['result'];
        return results.map((user) => Users.fromJson(user))
            .toList()
            .reversed
            .toList();
      } else {
        throw Exception('Failed to fetch users by department: ${responseData['message']}');
      }
    } else {
      throw Exception('Failed to fetch users by department: ${response.reasonPhrase}');
    }
  }
  Future<void> updateUser({
    required String userName,
    required String fullName,
    required String email,
    required String gender,
    required String classId,
    required String phone,
    required String address,
    required List<String> roles,
  }) async {
    final String url = '${baseUrl}api/users/updateUserbyAdmin/$userName';
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'full_Name': fullName,
        'phone': phone,
        'class_id': classId,
        'email': email,
        'gender': gender,
        'address': address,
        'roles': roles,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['code'] == 1000) {
        print('User updated successfully: ${responseData['result']}');
      } else {
        print('Failed to update user: ${responseData['message']}');
      }
    } else {
      print('Failed to update user: ${response.reasonPhrase}');
    }
  }
}