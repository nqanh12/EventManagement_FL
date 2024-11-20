import 'dart:convert';
import 'package:eventmanagement/Service/localhost.dart';
import 'package:http/http.dart' as http;
import 'package:eventmanagement/Class/event.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParticipantListService {
  final String _baseUrl = '${baseUrl}api/events/participants/';

  Future<List<Participant>> fetchParticipants(String eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$_baseUrl$eventId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return (data['result']['participants'] as List<dynamic>?)
          ?.map((participant) => Participant.fromJson(participant))
          .toList() ?? [];
    } else {
      throw Exception('Failed to load participants');
    }
  }
}