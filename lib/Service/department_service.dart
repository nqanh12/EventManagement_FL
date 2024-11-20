import 'dart:convert';
import 'package:eventmanagement/Class/department.dart';
import 'package:eventmanagement/Service/localhost.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DepartmentService {
  static const String apiUrl = '${baseUrl}api/department/getAllDepartments';

  Future<List<Department>> fetchDepartments() async {
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
        final List<Department> departments = (data['result'] as List)
            .map((departmentJson) => Department.fromJson(departmentJson))
            .toList();
        return departments;
      } else {
        throw Exception('No departments found');
      }
    } else {
      throw Exception('Failed to load departments');
    }
  }

  Future<String> getDepartmentName(String departmentId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${baseUrl}api/department/getDepartmentName/$departmentId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] == 1000) {
        return data['result'];
      } else {
        throw Exception('Failed to load department name');
      }
    } else {
      throw Exception('Failed to load department name');
    }
  }

  Future<Department> createDepartment(String departmentName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('${baseUrl}api/department/createDepartment'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'departmentName': departmentName}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] == 1000) {
        return Department.fromJson(data['result']);
      } else {
        throw Exception('Failed to create department');
      }
    } else {
      throw Exception('Failed to create department');
    }
  }

  Future<void> updateDepartment(String departmentId, String departmentName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.put(
      Uri.parse('${baseUrl}api/department/updateDepartment/$departmentId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'departmentName': departmentName}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update department');
    }
  }

  Future<void> deleteDepartment(String departmentId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.delete(
      Uri.parse('${baseUrl}api/department/delete/$departmentId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete department');
    }
  }
  Future<bool> checkDepartmentId(String departmentId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${baseUrl}api/department/checkDepartmentId/$departmentId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      if (data['code'] == 1000) {
        return data['result'];
      } else {
        throw Exception('Failed to check department ID');
      }
    } else {
      throw Exception('Failed to check department ID');
    }
  }
}