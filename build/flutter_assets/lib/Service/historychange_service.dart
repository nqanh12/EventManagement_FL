import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventmanagement/Service/localhost.dart';

class HistoryChangeService {
  Future<List<ChangeStoreHistory>> fetchChangeStoreHistory(String eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token is missing');
    }

    String bearerToken = 'Bearer $token';
    String url = '${baseUrl}api/changeStore/history/$eventId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': bearerToken,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> data = responseData['result'] as List<dynamic>;
      return data.map((json) => ChangeStoreHistory.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch change store history: ${response.statusCode}');
    }
  }
}

class ChangeStoreHistory {
  final String eventId;
  final String userName;
  final DateTime createdDate;
  final String content;
  final String userNameChange;

  ChangeStoreHistory({
    required this.eventId,
    required this.userName,
    required this.createdDate,
    required this.content,
    required this.userNameChange,
  });

  factory ChangeStoreHistory.fromJson(Map<String, dynamic> json) {
    return ChangeStoreHistory(
      eventId: json['eventId'].toString(),
      userName: json['userName'] ?? '',
      createdDate: DateTime.parse(json['createdDate']),
      content: json['content'] ?? '',
      userNameChange: json['userNameChange'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'userName': userName,
      'createdDate': createdDate.toIso8601String(),
      'content': content,
      'userNameChange': userNameChange,
    };
  }
}