import 'package:eventmanagement/Class/feedback.dart';
import 'package:eventmanagement/Service/localhost.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedbackService {
  Future<List<Feedbacks>> fetchFeedbacks(String eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('No token found');
    }

    String bearerToken = 'Bearer $token';
    final response = await http.get(
      Uri.parse('${baseUrl}api/feedback/getAllFeedback/$eventId'),
      headers: {
        'Authorization': bearerToken,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] == 1000) {
        final List<Feedbacks> feedbacks = (data['result'] as List)
            .map((feedbackJson) => Feedbacks.fromJson(feedbackJson))
            .toList();
        return feedbacks;
      } else {
        throw Exception('Failed to fetch feedbacks');
      }
    } else {
      throw Exception('Failed to fetch feedbacks');
    }
  }

  Future<void> changeFeedbackConfirmStatus(String feedbackId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('No token found');
    }

    String bearerToken = 'Bearer $token';
    final response = await http.put(
      Uri.parse('${baseUrl}api/feedback/changeIsConfirm/$feedbackId'),
      headers: {
        'Authorization': bearerToken,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to change feedback confirmation status');
    }
  }
}