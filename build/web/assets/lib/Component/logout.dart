import 'package:eventmanagement/Component/diglog_load.dart';
import 'package:flutter/material.dart';
import 'package:eventmanagement/Service/login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final LoginService _loginService = LoginService();

Future<void> showLogoutDialog(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  showDialog(
    // ignore: use_build_context_synchronously
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Đăng xuất'),
        content: Text('Bạn có muốn đăng xuất không?'),
        actions: <Widget>[
          TextButton(
            child: Text('Hủy'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Đăng xuất'),
            onPressed: () async {
              if (token != null) {
                await _loginService.logout(token);
              }
              // ignore: use_build_context_synchronously
              showLod(context, "Đang đăng xuất ", "Vui lòng đợi giây lát....", '/login');
            },
          ),
        ],
      );
    },
  );
}