import 'dart:convert';
import 'package:eventmanagement/Service/localhost.dart';
import 'package:http/http.dart' as http;
import 'package:eventmanagement/Class/event.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventService {
  static const String apiUrl = '${baseUrl}api/events/listEvent';

  Future<List<Event>> fetchEvents() async {
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
        final List<Event> events = (data['result'] as List)
            .map((eventJson) => Event.fromJson(eventJson))
            .toList();

        // Sort events by start date
        events.sort((b, a) => a.dateStart.compareTo(b.dateStart));

        return events;
      } else {
        throw Exception('No events found');
      }
    } else {
      throw Exception('Failed to load events');
    }
  }
}