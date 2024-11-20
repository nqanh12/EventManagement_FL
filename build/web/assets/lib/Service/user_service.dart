import 'dart:convert';
import 'package:eventmanagement/Service/localhost.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventmanagement/Class/user.dart';

class UserService {
  static const String apiUrl = '${baseUrl}api/users/listUsers';

  Future<List<Users>> fetchUsers() async {
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
            .toList();
        return users;
      } else {
        throw Exception('No users found');
      }
    } else {
      throw Exception('Failed to load users');
    }
  }
}