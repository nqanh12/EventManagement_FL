import 'package:eventmanagement/Component/button_access.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:eventmanagement/Service/info_account.dart';
import 'package:flutter/material.dart';
import 'package:eventmanagement/Component/text_field.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';
import 'package:eventmanagement/Service/crud_account_service.dart';

class FormAddAccountDialog extends StatefulWidget {
  final VoidCallback callback;
  const FormAddAccountDialog({super.key, required this.callback});

  @override
  FormAddAccountDialogState createState() => FormAddAccountDialogState();
}

class FormAddAccountDialogState extends State<FormAddAccountDialog> {
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String userName = _userNameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;

      if (userName.isEmpty || email.isEmpty || password.isEmpty) {
        showWarningDialog(context, 'Lỗi', 'Có dữ liệu còn bỏ trống chưa điền !', Icons.warning, Colors.red);
        return;
      }

      if (!RegExp(r'^\d+$').hasMatch(userName)) {
        showWarningDialog(context, 'Lỗi', 'Tài khoản chỉ được chứa số', Icons.warning, Colors.red);
        return;
      }

      if (!email.endsWith('@gmail.com')) {
        showWarningDialog(context, 'Lỗi', 'Email sai định dạng', Icons.warning, Colors.red);
        return;
      }

      bool emailExists = await InfoAccountService().checkEmailExist(email);
      if (emailExists) {
        // ignore: use_build_context_synchronously
        showWarningDialog(context, 'Lỗi', 'Email đã tồn tại', Icons.warning, Colors.red);
        return;
      }

      bool userNameExists = await InfoAccountService().checkUserNameExist(userName);
      if (userNameExists) {
        // ignore: use_build_context_synchronously
        showWarningDialog(context, 'Lỗi', 'Tài khoản đã tồn tại', Icons.warning, Colors.red);
        return;
      }

      final user = await CrudAccountService().registerUser(userName, password, email);

      if (user != null) {
        // ignore: use_build_context_synchronously
        showWarningDialog(context, 'Thành công', 'Tạo tài khoản thành công', Icons.check_circle);
        Future.delayed(Duration(milliseconds: 800), () {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
          widget.callback();
        });
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showWarningDialog(context, 'Lỗi', 'Failed to register user: ${e.toString()}', Icons.warning, Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Icon(Icons.person_add, color: Colors.blueAccent),
          const SizedBox(width: 10),
          CustomText(
            text: 'Thêm tài khoản mới',
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
              labelText: 'Tài khoản(MSSV)',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _emailController,
              labelText: 'Email',
              prefixIcon: Icons.email,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _passwordController,
              labelText: 'Mật khẩu',
              prefixIcon: Icons.lock,
              obscureText: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
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
          onPressed: _registerUser,
          text: 'Thêm',
          color: Colors.greenAccent,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}