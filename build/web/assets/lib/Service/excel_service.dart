import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:logger/logger.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExcelService {
  final String apiUrl = 'http://localhost:8080/api/users/createUsersFromExcel';
  final Logger logger = Logger();

  Future<void> uploadExcelFile(File file) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        logger.e('Token not found');
        return;
      }

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType.parse(lookupMimeType(file.path) ?? 'application/octet-stream'),
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        logger.i('Response: $jsonResponse');
      } else {
        logger.e('Failed to upload file. Status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error: $e');
    }
  }
}