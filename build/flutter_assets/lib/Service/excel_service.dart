import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventmanagement/Service/localhost.dart';
import 'dart:typed_data';

class ExcelService {
  final String _baseUrl = '${baseUrl}api/users';

  Future<void> createUsersFromExcelBytes(Uint8List fileBytes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$_baseUrl/createUsersFromExcel');

    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: 'file.xlsx'));

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to create users from Excel');
    }
  }
}