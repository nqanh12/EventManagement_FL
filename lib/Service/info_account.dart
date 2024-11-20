import 'dart:convert';
import 'package:eventmanagement/Service/localhost.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventmanagement/Class/user.dart';

class InfoAccountService {
  final String _url = '${baseUrl}api/users/myInfo';
  Future<Users?> fetchUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse(_url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] == 1000) {
        return Users.fromJson(data['result']);
      } else {
        throw Exception('Failed to load user info');
      }
    } else {
      throw Exception('Failed to load user info');
    }
  }
  Future<Map<String, String?>> fetchFullNameAndClass(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('${baseUrl}api/users/getFullName/$userName'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] == 1000) {
        return {
          'fullName': data['result']['full_Name'],
          'classId': data['result']['classId'],
        };
      } else {
        throw Exception('Failed to load full name and class');
      }
    } else {
      throw Exception('Failed to load full name and class');
    }
  }
  Future<bool> checkEmailExist(String email) async {
    final response = await http.post(
      Uri.parse('${baseUrl}api/users/checkMailExist'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'email': email}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] == 1000) {
        return data['result'];
      } else {
        throw Exception('Failed to check email existence');
      }
    } else {
      throw Exception('Failed to check email existence');
    }
  }
  Future<bool> checkUserNameExist(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      Uri.parse('${baseUrl}api/users/checkUserNameExist'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'userName': userName}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] == 1000) {
        return data['result'];
      } else {
        throw Exception('Failed to check username existence');
      }
    } else {
      throw Exception('Failed to check username existence');
    }
  }
  Future<Users?> updateUserInfo(String fullName, String gender, String email, String phone, String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.put(
      Uri.parse('${baseUrl}api/users/updateInfo'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'full_Name': fullName,
        'gender': gender,
        'email': email,
        'phone': phone,
        'address': address,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] == 1000) {
        return Users.fromJson(data['result']);
      } else {
        throw Exception('Failed to update user info');
      }
    } else {
      throw Exception('Failed to update user info');
    }
  }
  Future<Users?> updateUserInfoNotMail(String fullName, String gender, String phone, String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.put(
      Uri.parse('${baseUrl}api/users/updateInfoNotMail'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'full_Name': fullName,
        'gender': gender,
        'phone': phone,
        'address': address,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] == 1000) {
        return Users.fromJson(data['result']);
      } else {
        throw Exception('Failed to update user info');
      }
    } else {
      throw Exception('Failed to update user info');
    }
  }
  Future<Users?> changePassword(String oldPassword, String newPassword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.put(
      Uri.parse('${baseUrl}api/users/changePassword'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] == 1000) {
        return Users.fromJson(data['result']);
      } else {
        throw Exception('Failed to change password');
      }
    } else {
      throw Exception('Failed to change password');
    }
  }
}