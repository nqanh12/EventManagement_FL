import 'package:eventmanagement/Component/button_access.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:eventmanagement/Service/crud_account_service.dart';
import 'package:eventmanagement/Service/info_account.dart';
import 'package:flutter/material.dart';
import 'package:eventmanagement/Component/text_field.dart';
import 'package:flutter/services.dart';

class FormAddAccountUserDialog extends StatefulWidget {
  final VoidCallback callback;
  const FormAddAccountUserDialog({super.key, required this.callback});

  @override
  FormAddAccountDialogState createState() => FormAddAccountDialogState();
}

class FormAddAccountDialogState extends State<FormAddAccountUserDialog> {
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _classIdController = TextEditingController();
  bool _isLoading = false;
  String? _selectedGender = 'Nam';
  final List<String> _genders = ['Nam', 'Nữ'];

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
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
  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
    });
    _showLoadingDialog(context);
    try {
      String userName = _userNameController.text;
      String email = _emailController.text;
      String fullName = _fullNameController.text;
      String classId = _classIdController.text;
      String? gender = _selectedGender;

      if (userName.isEmpty || email.isEmpty || fullName.isEmpty || classId.isEmpty || gender == null) {
        showWarningDialog(context, 'Lỗi', 'Có dữ liệu còn bỏ trống chưa điền !', Icons.warning, Colors.red);
        return;
      }

      if (userName.length < 6) {
        showWarningDialog(context, 'Lỗi', 'Tài khoản phải chứa ít nhất 6 kí tự', Icons.warning, Colors.red);
        return;
      }

      if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(email)) {
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

      final user = await CrudAccountService().createUser(
        userName: userName,
        fullName: fullName,
        password: '123456789',
        email: email,
        gender: gender,
        classId: classId,
      );

      if (user != null) {
        Navigator.of(context).pop();
        showWarningDialog(context, 'Thành công', 'Tạo tài khoản thành công', Icons.check_circle, Colors.green);
        Future.delayed(Duration(milliseconds: 800), () {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          widget.callback();
        });
      }
    } catch (e) {
      Navigator.of(context).pop();
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
            text: 'Thêm tài khoản sinh viên mới',
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
              labelText: 'Tài khoản(Mã sinh viên)',
              prefixIcon: Icons.person,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _fullNameController,
              labelText: 'Họ tên',
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
              controller: _classIdController,
              labelText: 'Lớp',
              prefixIcon: Icons.class_,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue!;
                });
              },
              items: _genders.map<DropdownMenuItem<String>>((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: CustomText(text: gender, fontSize: 16, color: Colors.black),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Giới tính',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
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