import 'dart:convert';
import 'package:eventmanagement/Service/localhost.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventmanagement/Class/event.dart';

class CrudEventService {
  Future<Event> updateEvent(String eventId, Map<String, dynamic> eventData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.put(
      Uri.parse('${baseUrl}api/events/update/$eventId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(eventData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] == 1000) {
        return Event.fromJson(data['result']);
      } else {
        throw Exception('Failed to update event');
      }
    } else {
      throw Exception('Failed to update event');
    }
  }
}