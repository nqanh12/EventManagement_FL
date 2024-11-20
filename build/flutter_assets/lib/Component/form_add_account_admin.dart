import 'package:eventmanagement/Component/button_access.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:eventmanagement/Service/crud_account_service.dart';
import 'package:eventmanagement/Service/info_account.dart';
import 'package:eventmanagement/Service/department_service.dart';
import 'package:flutter/material.dart';
import 'package:eventmanagement/Component/text_field.dart';
import 'package:eventmanagement/Class/department.dart';

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
  final _fullNameController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _selectedDepartment;
  String? _selectedGender = 'Nam';
  List<Department> _departments = [];
  final List<String> _genders = ['Nam', 'Nữ'];

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchDepartments() async {
    try {
      final departments = await DepartmentService().fetchDepartments();
      setState(() {
        // Loại bỏ trùng lặp và loại bỏ departmentId = "EN"
        final uniqueDepartments = departments
            .where((department) => department.departmentId != 'EN')
            .fold<Map<String, Department>>({}, (map, department) {
          map[department.departmentId] = department;
          return map;
        });
        _departments = uniqueDepartments.values.toList();

        if (_departments.isNotEmpty) {
          _selectedDepartment = _departments.first.departmentId;
        }
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      showWarningDialog(context, 'Lỗi', 'Failed to load departments: ${e.toString()}', Icons.warning, Colors.red);
    }
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
      String password = _passwordController.text;
      String fullName = _fullNameController.text;
      String? department = _selectedDepartment;
      String? gender = _selectedGender;

      if (userName.isEmpty || email.isEmpty || password.isEmpty || fullName.isEmpty || department == null || gender == null) {
        Navigator.of(context).pop(); // Close the loading dialog
        showWarningDialog(context, 'Lỗi', 'Có dữ liệu còn bỏ trống chưa điền !', Icons.warning, Colors.red);
        return;
      }

      if (userName.length < 6) {
        Navigator.of(context).pop(); // Close the loading dialog
        showWarningDialog(context, 'Lỗi', 'Tài khoản phải chứa ít nhất 6 kí tự', Icons.warning, Colors.red);
        return;
      }

      if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(email)) {
        Navigator.of(context).pop(); // Close the loading dialog
        showWarningDialog(context, 'Lỗi', 'Email sai định dạng', Icons.warning, Colors.red);
        return;
      }

      bool emailExists = await InfoAccountService().checkEmailExist(email);
      if (emailExists) {
        Navigator.of(context).pop(); // Close the loading dialog
        showWarningDialog(context, 'Lỗi', 'Email đã tồn tại', Icons.warning, Colors.red);
        return;
      }

      bool userNameExists = await InfoAccountService().checkUserNameExist(userName);
      if (userNameExists) {
        Navigator.of(context).pop(); // Close the loading dialog
        showWarningDialog(context, 'Lỗi', 'Tài khoản đã tồn tại', Icons.warning, Colors.red);
        return;
      }

      final user = await CrudAccountService().createAdmin(
        userName: userName,
        fullName: fullName,
        password: password,
        email: email,
        gender: gender,
        departmentId: department,
      );

      if (user != null) {
        Navigator.of(context).pop(); // Close the loading dialog
        showWarningDialog(context, 'Thành công', 'Tạo tài khoản thành công', Icons.check_circle, Colors.green);
        Future.delayed(Duration(milliseconds: 800), () {
          Navigator.of(context).pop(); // Close the success dialog
          Navigator.of(context).pop(); // Close the form dialog
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
              labelText: 'Tài khoản(Mã giảng viên )',
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
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedDepartment,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDepartment = newValue;
                });
              },
              items: _departments
                  .map<DropdownMenuItem<String>>((Department department) {
                return DropdownMenuItem<String>(
                  value: department.departmentId,
                  child: CustomText(
                    text: department.departmentName,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Khoa',
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
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