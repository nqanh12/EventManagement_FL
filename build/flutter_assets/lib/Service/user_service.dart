import 'dart:convert';
import 'package:eventmanagement/Service/localhost.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventmanagement/Class/user.dart';

class UserService {
  static const String apiUrl = '${baseUrl}api/users/listUsers';

  Future<List<Users>> fetchUsers({int page = 1, int pageSize = 50}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    String bearerToken = 'Bearer $token';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': bearerToken,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['result'] != null) {
        final List<Users> users = (data['result'] as List)
            .map((userJson) => Users.fromJson(userJson))
            .where((user) => !user.roles.contains("ADMIN_ENTIRE"))
            .toList()
            .reversed
            .toList();
        return users;
      } else {
        throw Exception('No users found');
      }
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> deleteEventAllUsers(String eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    String bearerToken = 'Bearer $token';
    final response = await http.delete(
      Uri.parse('${baseUrl}api/users/deleteEventAllUSers/$eventId'),
      headers: {
        'Authorization': bearerToken,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] != 1000) {
        throw Exception('Failed to delete users for event');
      }
    } else {
      throw Exception('Failed to delete users for event');
    }
  }
}