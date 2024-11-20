import 'package:eventmanagement/Component/button_access.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:eventmanagement/Service/crud_account_service.dart';
import 'package:eventmanagement/Service/info_account.dart';
import 'package:eventmanagement/Service/department_service.dart';
import 'package:flutter/material.dart';
import 'package:eventmanagement/Component/text_field.dart';
import 'package:eventmanagement/Class/department.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormAddAccountManagerDialog extends StatefulWidget {
  final VoidCallback callback;
  const FormAddAccountManagerDialog({super.key, required this.callback});

  @override
  FormAddAccountManagerDialogState createState() => FormAddAccountManagerDialogState();
}

class FormAddAccountManagerDialogState extends State<FormAddAccountManagerDialog> {
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _classIdController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  List<Department> _departments = [];
  final List<String> _roles = ['MANAGER_DEPARTMENT'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _classIdController.dispose();
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
              Text("Đang tạo tài khoản, vui lòng đợi..."),
            ],
          ),
        );
      },
    );
  }

  Future<void> _registerManager() async {
    setState(() {
      _isLoading = true;
    });

    _showLoadingDialog(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      String userName = _userNameController.text;
      String email = " ";
      String password = _passwordController.text;
      String fullName = _fullNameController.text;
      String classId = " ";
      String? department = prefs.getString('departmentId');
      String? gender = " ";

      if (userName.isEmpty || email.isEmpty || password.isEmpty || fullName.isEmpty || classId.isEmpty || department == null) {
        Navigator.of(context).pop(); // Close the loading dialog
        showWarningDialog(context, 'Lỗi', 'Có dữ liệu còn bỏ trống chưa điền !', Icons.warning, Colors.red);
        return;
      }

      if (userName.length < 6) {
        Navigator.of(context).pop(); // Close the loading dialog
        showWarningDialog(context, 'Lỗi', 'Tài khoản phải chứa ít nhất 6 kí tự', Icons.warning, Colors.red);
        return;
      }


      bool userNameExists = await InfoAccountService().checkUserNameExist(userName);
      if (userNameExists) {
        Navigator.of(context).pop(); // Close the loading dialog
        showWarningDialog(context, 'Lỗi', 'Tài khoản đã tồn tại', Icons.warning, Colors.red);
        return;
      }

      final user = await CrudAccountService().createManager(
        userName: userName,
        fullName: fullName,
        password: password,
        email: email,
        gender: gender,
        classId: classId,
        roles: _roles,
      );

      if (user != null) {
        Navigator.of(context).pop(); // Close the loading dialog
        showWarningDialog(context, 'Thành công', 'Tạo tài khoản thành công', Icons.check_circle, Colors.green);
        Future.delayed(Duration(milliseconds: 800), () {
          Navigator.of(context).pop(); // Close the success dialog
          widget.callback();
        });
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close the loading dialog
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
            text: 'Thêm tài khoản quét mã QR cho sự kiện của khoa',
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
              labelText: 'Tài khoản để quét mã',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _fullNameController,
              labelText: 'Họ tên',
              prefixIcon: Icons.person,
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
          onPressed: _registerManager,
          text: 'Thêm',
          color: Colors.greenAccent,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}