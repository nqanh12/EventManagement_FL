import 'package:eventmanagement/Component/button_access.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:eventmanagement/Service/info_account.dart';
import 'package:eventmanagement/Service/login_service.dart';
import 'package:flutter/material.dart';
import 'package:eventmanagement/Component/text_field.dart';

class FormResetPasswordDialog extends StatefulWidget {
  final VoidCallback callback;
  const FormResetPasswordDialog({super.key, required this.callback});

  @override
  FormResetPasswordDialogState createState() => FormResetPasswordDialogState();
}

class FormResetPasswordDialogState extends State<FormResetPasswordDialog> {
  late TextEditingController _userNameController;
  late TextEditingController _passwordController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text("Đang đặt lại mật khẩu, vui lòng đợi..."),
            ],
          ),
        );
      },
    );
  }
  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
    });
    _showLoadingDialog(context);
    try {
      String userName = _userNameController.text;
      String password = _passwordController.text;

      if (userName.isEmpty || password.isEmpty) {
        showWarningDialog(context, 'Lỗi', 'Tên người dùng và mật khẩu không được để trống!', Icons.warning, Colors.red);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      bool userExists = await InfoAccountService().checkUserNameExist(userName);
      if (!userExists) {
        showWarningDialog(context, 'Lỗi', 'Tên người dùng không tồn tại!', Icons.warning, Colors.red);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await LoginService().getPassword(userName, password);
      if (!mounted) return;
      Navigator.of(context).pop();
      showWarningDialog(context, 'Thành công', 'Đặt lại mật khẩu thành công', Icons.check_circle, Colors.green);
      Future.delayed(Duration(milliseconds: 800), () {
        if (!mounted) return;
        Navigator.of(context).pop();
        widget.callback();
      });
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      showWarningDialog(context, 'Lỗi', 'Failed to reset password: ${e.toString()}', Icons.warning, Colors.red);
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Icon(Icons.lock_reset, color: Colors.blueAccent),
          const SizedBox(width: 10),
          CustomText(
            text: 'Đặt lại mật khẩu',
            fontSize: 18,
            color: Colors.blueAccent,
          )
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _userNameController,
              labelText: 'Tên người dùng',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _passwordController,
              labelText: 'Mật khẩu mới',
              prefixIcon: Icons.lock,
              obscureText: true,
            ),
          ],
        ),
      ),
      actions: [
        CustomElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          text: 'Hủy',
          color: Colors.redAccent,
        ),
        CustomElevatedButton(
          onPressed: _resetPassword,
          text: 'Đặt lại',
          color: Colors.greenAccent,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}