import 'package:eventmanagement/Component/diglog_load.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
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
        title: CustomText(text: "Đăng xuất ", fontSize: 20, color: Colors.black),
        content: CustomText(text: 'Bạn có muốn đăng xuất không?', fontSize: 16, color: Colors.black),
        actions: <Widget>[
          TextButton(
            child: CustomText(text: 'Hủy', fontSize: 16, color: Colors.blue),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: CustomText(text: 'Đăng xuất', fontSize: 16, color: Colors.blue),
            onPressed: () async {
              if (token != null) {
                await _loginService.logout(token);
              }
              Navigator.of(context).pop(true);
              showLod(context, 'Hết phiên đăng nhập', 'Bạn sẽ thoát trong giây lát ... ', '/login');
            },
          ),
        ],
      );
    },
  );
}