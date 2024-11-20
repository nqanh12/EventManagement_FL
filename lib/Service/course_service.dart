import 'dart:convert';
import 'package:eventmanagement/Service/localhost.dart';
import 'package:http/http.dart' as http;
import 'package:eventmanagement/Class/course.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseService {
  final String _baseUrl = '${baseUrl}api/courses';

  Future<List<Courses>> getAllCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('$_baseUrl/getAllCourses'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] == 1000) {
        final List<dynamic> results = data['result'];
        return results.map((course) => Courses.fromJson(course)).toList();
      } else {
        throw Exception('Failed to load courses');
      }
    } else {
      throw Exception('Failed to load courses');
    }
  }

  Future<List<Courses>> getAllCoursesFilter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('$_baseUrl/getAllCoursesFilter'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] == 1000) {
        final List<dynamic> results = data['result'];
        return results.map((course) => Courses.fromJson(course)).toList();
      } else {
        throw Exception('Failed to load courses');
      }
    } else {
      throw Exception('Failed to load courses');
    }
  }

  Future<String> getCourseName(int courseId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('$_baseUrl/getCourseName/$courseId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] == 1000) {
        return data['result'];
      } else {
        throw Exception('Failed to load course name');
      }
    } else {
      throw Exception('Failed to load course name');
    }
  }

  Future<Courses> createCourse(String courseName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('$_baseUrl/createCourse'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'courseName': courseName,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] == 1000) {
        return Courses.fromJson(data['result']);
      } else {
        throw Exception('Failed to create course');
      }
    } else {
      throw Exception('Failed to create course');
    }
  }

  Future<void> deleteCourse(String courseId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.delete(
      Uri.parse('$_baseUrl/deleteCourse/$courseId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] != 1000) {
        throw Exception('Failed to delete course');
      }
    } else {
      throw Exception('Failed to delete course');
    }
  }
}