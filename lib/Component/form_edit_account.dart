import 'package:eventmanagement/Component/button_access.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:eventmanagement/Service/crud_account_service.dart';
import 'package:eventmanagement/Service/department_service.dart';
import 'package:flutter/material.dart';
import 'package:eventmanagement/Component/text_field.dart';
import 'package:eventmanagement/Class/department.dart';
import 'package:eventmanagement/Class/user.dart';

class FormEditAccountDialog extends StatefulWidget {
  final Users user;
  final VoidCallback callback;
  const FormEditAccountDialog({super.key, required this.user, required this.callback});

  @override
  FormEditAccountDialogState createState() => FormEditAccountDialogState();
}

class FormEditAccountDialogState extends State<FormEditAccountDialog> {
  late TextEditingController _userNameController;
  late TextEditingController _emailController;
  late TextEditingController _fullNameController;
  bool _isLoading = false;
  String? _selectedDepartment;
  String? _selectedGender;
  String? _selectedRole;
  List<Department> _departments = [];
  final List<String> _genders = ['Nam', 'Nữ'];
  final Map<String, String> roleLabels = {
    'Tất cả': 'Tất cả',
    'ADMIN_DEPARTMENT': 'Quản lí khoa',
    'USER': 'Sinh viên',
    'MANAGER_ENTIRE': 'Quản lí sự kiện toàn trường',
    'MANAGER_DEPARTMENT': 'Quản lí sự kiện khoa',
  };

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: widget.user.userName);
    _emailController = TextEditingController(text: widget.user.email);
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _selectedDepartment = widget.user.departmentId;
    _selectedGender = widget.user.gender;
    _selectedRole = widget.user.roles.isNotEmpty ? widget.user.roles.first : null;
    _fetchDepartments();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchDepartments() async {
    try {
      final departments = await DepartmentService().fetchDepartments();
      setState(() {
        _departments = departments;
        if (_departments.isNotEmpty && _selectedDepartment == null) {
          _selectedDepartment = _departments.first.departmentId;
        }
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      showWarningDialog(context, 'Lỗi', 'Failed to load departments: ${e.toString()}', Icons.warning, Colors.red);
    }
  }

  Future<void> _updateUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String userName = _userNameController.text;
      String email = _emailController.text;
      String fullName = _fullNameController.text;
      String? department = _selectedDepartment;
      String? gender = _selectedGender;
      String? role = _selectedRole;

      if (userName.isEmpty || email.isEmpty || fullName.isEmpty || department == null || gender == null || role == null) {
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

      final user = await CrudAccountService().updateAdmin(
        userName: userName,
        fullName: fullName,
        email: email,
        gender: gender,
        departmentId: department,
        roles: [role],
      );

      if (user != null) {
        // ignore: use_build_context_synchronously
        showWarningDialog(context, 'Thành công', 'Cập nhật tài khoản thành công', Icons.check_circle,Colors.green);
        Future.delayed(Duration(milliseconds: 800), () {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
          widget.callback();
        });
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showWarningDialog(context, 'Lỗi', 'Failed to update user: ${e.toString()}', Icons.warning, Colors.red);
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
            text: 'Chỉnh sửa tài khoản',
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
              enabled: false,
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
            DropdownButtonFormField<String>(
              value: _selectedDepartment,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDepartment = newValue!;
                });
              },
              items: _departments.map<DropdownMenuItem<String>>((Department department) {
                return DropdownMenuItem<String>(
                  value: department.departmentId,
                  child: CustomText(text: department.departmentName, fontSize: 16, color: Colors.black),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Khoa',
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
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
            const SizedBox(height: 10),
            if (!widget.user.roles.contains('ADMIN_ENTIRE') && !widget.user.roles.contains('ADMIN_DEPARTMENT'))
              DropdownButtonFormField<String>(
                value: _selectedRole,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue!;
                  });
                },
                items: roleLabels.entries.map<DropdownMenuItem<String>>((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: CustomText(text: entry.value, fontSize: 16, color: Colors.black),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Vai trò',
                  prefixIcon: Icon(Icons.person_outline),
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
          onPressed: _updateUser,
          text: 'Cập nhật',
          color: Colors.greenAccent,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}