import 'package:eventmanagement/Component/button_access.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:eventmanagement/Service/crud_account_service.dart';
import 'package:flutter/material.dart';
import 'package:eventmanagement/Component/text_field.dart';
import 'package:flutter/services.dart';

class FormEditAccountUserDialog extends StatefulWidget {
  final VoidCallback callback;
  final String userName;
  final String email;
  final String fullName;
  final String classId;
  final String gender;
  final String phone;
  final String address;
  final List<String> roles;

  const FormEditAccountUserDialog({
    super.key,
    required this.callback,
    required this.userName,
    required this.email,
    required this.fullName,
    required this.classId,
    required this.gender,
    required this.phone,
    required this.address,
    required this.roles,
  });

  @override
  FormEditAccountDialogState createState() => FormEditAccountDialogState();
}

class FormEditAccountDialogState extends State<FormEditAccountUserDialog> {
  late TextEditingController _userNameController;
  late TextEditingController _emailController;
  late TextEditingController _fullNameController;
  late TextEditingController _classIdController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isLoading = false;
  String? _selectedGender;
  String? _selectedRole;
  final List<String> _genders = ['Nam', 'Nữ'];
  final Map<String, String> _roles = {
    'USER': 'Sinh viên',
    'MANAGER_DEPARTMENT': 'Quản lí sự kiện khoa',
  };

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: widget.userName);
    _emailController = TextEditingController(text: widget.email);
    _fullNameController = TextEditingController(text: widget.fullName);
    _classIdController = TextEditingController(text: widget.classId);
    _phoneController = TextEditingController(text: widget.phone);
    _addressController = TextEditingController(text: widget.address);
    _selectedGender = widget.gender;
    _selectedRole = widget.roles.isNotEmpty ? widget.roles.first : null;
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _classIdController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String userName = _userNameController.text;
      String email = _emailController.text;
      String fullName = _fullNameController.text;
      String classId = _classIdController.text;
      String phone = _phoneController.text;
      String address = _addressController.text;
      String? gender = _selectedGender;
      String? role = _selectedRole;

      if (userName.isEmpty || email.isEmpty || fullName.isEmpty || classId.isEmpty || gender == null || role == null) {
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

      await CrudAccountService().updateUser(
        userName: userName,
        fullName: fullName,
        email: email,
        gender: gender,
        classId: classId,
        phone: phone,
        address: address,
        roles: [role],
      );

      // ignore: use_build_context_synchronously
      showWarningDialog(context, 'Thành công', 'Cập nhật tài khoản thành công', Icons.check_circle, Colors.green);
      Future.delayed(Duration(milliseconds: 800), () {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        widget.callback();
      });
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
          borderRadius: BorderRadius.circular(20.0)),
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
            CustomTextField(
              controller: _phoneController,
              labelText: 'Số điện thoại',
              prefixIcon: Icons.phone,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _addressController,
              labelText: 'Địa chỉ',
              prefixIcon: Icons.home,
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
            DropdownButtonFormField<String>(
              value: _selectedRole,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue!;
                });
              },
              items: _roles.entries.map<DropdownMenuItem<String>>((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: CustomText(text: entry.value, fontSize: 16, color: Colors.black),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Vai trò',
                prefixIcon: Icon(Icons.security),
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