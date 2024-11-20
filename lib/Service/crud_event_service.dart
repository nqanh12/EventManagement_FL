import 'dart:convert';
import 'package:eventmanagement/Class/event.dart';
import 'package:eventmanagement/Service/localhost.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CrudEventService {
  static const String apiUrl = '${baseUrl}api/events/listEvent';
  static const String createEventUrl = '${baseUrl}api/events/createEvent';
  static const String updateEventUrl = '${baseUrl}api/events/update/';
  static const String deleteEventUrl = '${baseUrl}api/events/delete/';
  static const String listEventByDepartmentUrl = '${baseUrl}api/events/listEventByDepartment/';
  static const String urlParticipant = '${baseUrl}api/events/participants/';

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
      if (data['code'] == 1000) {
        final List<Event> events = (data['result'] as List)
            .map((eventJson) => Event.fromJson(eventJson))
            .toList();
        return events;
      } else {
        throw Exception('No events found');
      }
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<Event> createEvent(Event event) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    String bearerToken = 'Bearer $token';
    final response = await http.post(
      Uri.parse(createEventUrl),
      headers: {
        'Authorization': bearerToken,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': event.name,
        'departmentId': event.departmentId,
        'capacity': event.capacity,
        'currentParticipants': event.currentParticipants,
        'description': event.description,
        'locationId': event.locationId,
        'dateStart': event.dateStart.toIso8601String(),
        'dateEnd': event.dateEnd.toIso8601String(),
        'managerName': event.managerName,
        'course': event.courses.map((course) => {'courseId': course.courseId}).toList(),
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] == 1000) {
        return Event.fromJson(data['result']);
      } else {
        throw Exception('Failed to create event');
      }
    } else {
      throw Exception('Failed to create event');
    }
  }

  Future<Event> updateEvent(String eventId, Event event) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    String bearerToken = 'Bearer $token';
    final response = await http.put(
      Uri.parse('$updateEventUrl$eventId'),
      headers: {
        'Authorization': bearerToken,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': event.name,
        'departmentId': event.departmentId,
        'capacity': event.capacity,
        'description': event.description,
        'locationId': event.locationId,
        'dateStart': event.dateStart.toIso8601String(),
        'dateEnd': event.dateEnd.toIso8601String(),
        'managerName': event.managerName,
        'course': event.courses.map((course) => {'courseId': course.courseId}).toList(),
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] == 1000) {
        return Event.fromJson(data['result']);
      } else {
        throw Exception('Failed to update event');
      }
    } else {
      throw Exception('Failed to update event');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    String bearerToken = 'Bearer $token';
    final response = await http.delete(
      Uri.parse('$deleteEventUrl$eventId'),
      headers: {
        'Authorization': bearerToken,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] != 1000) {
        throw Exception('Failed to delete event');
      }
    } else {
      throw Exception('Failed to delete event');
    }
  }

  Future<List<Event>> fetchEventsByDepartment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final departmentId = prefs.getString('departmentId');
    String bearerToken = 'Bearer $token';
    final response = await http.get(
      Uri.parse('$listEventByDepartmentUrl$departmentId'),
      headers: {
        'Authorization': bearerToken,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] == 1000) {
        final List<Event> events = (data['result'] as List)
            .map((eventJson) => Event.fromJson(eventJson))
            .toList();
        events.sort((a, b) => b.dateStart.compareTo(a.dateStart)); // Sort in reverse order by dateStart
        return events;
      } else {
        throw Exception('No events found');
      }
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<void> getEventParticipants(String eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    String bearerToken = 'Bearer $token';
    final response = await http.get(
      Uri.parse('$urlParticipant$eventId'),
      headers: {
        'Authorization': bearerToken,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['code'] == 1000) {
        print('Participants fetched successfully');
      } else {
        throw Exception('Failed to fetch participants');
      }
    } else {
      throw Exception('Failed to fetch participants');
    }
  }
}