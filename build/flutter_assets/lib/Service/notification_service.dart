import 'dart:convert';
import 'package:eventmanagement/Service/localhost.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventmanagement/Class/user.dart'; // Import the Notification class

class NotificationService {
  final String _baseUrl = '${baseUrl}api/users';

  Future<List<Notifications>> getNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('$_baseUrl/getNotifications'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonMap = json.decode(utf8.decode(response.bodyBytes));
      if (jsonMap['result'] != null && jsonMap['result']['notifications'] != null) {
        List<dynamic> jsonList = jsonMap['result']['notifications'];
        List<Notifications> notifications = jsonList.map((json) => Notifications.fromJson(json)).toList();
        return notifications.reversed.toList(); // Reverse the list before returning
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<void> sendNotificationToDepartment(String departmentId, String message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('$_baseUrl/sendNotificationToDepartment/$departmentId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'message': message,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send notification');
    }
  }

  Future<int> countUnreadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('$_baseUrl/countUnreadNotifications'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonMap = json.decode(utf8.decode(response.bodyBytes));
      if (jsonMap['result'] != null && jsonMap['result']['quantity'] != null) {
        return jsonMap['result']['quantity'];
      } else {
        return 0;
      }
    } else {
      throw Exception('Failed to count unread notifications');
    }
  }
}