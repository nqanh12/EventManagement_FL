import 'package:eventmanagement/Component/button_access.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:eventmanagement/Service/crud_account_service.dart';
import 'package:flutter/material.dart';
import 'package:eventmanagement/Component/text_field.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';

class FormEditRoleDialog extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final VoidCallback callback;

  const FormEditRoleDialog({super.key, required this.initialData, required this.callback});

  @override
  FormEditRoleDialogState createState() => FormEditRoleDialogState();
}

class FormEditRoleDialogState extends State<FormEditRoleDialog> {
  late TextEditingController _userNameController;
  late TextEditingController _emailController;
  String _selectedRole = 'USER';
  late BuildContext _dialogContext;
  bool _isLoading = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dialogContext = context;
  }

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: widget.initialData['userName'] ?? '');
    _emailController = TextEditingController(text: widget.initialData['email'] ?? '');
    _selectedRole = (widget.initialData['roles'] is List && widget.initialData['roles'].isNotEmpty)
        ? widget.initialData['roles'][0]
        : 'USER';
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateUserRole(String userName, String role) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await CrudAccountService().updateUserRole(userName, [role]);
      widget.callback();
      Future.delayed(Duration(milliseconds: 800), () {
        // ignore: use_build_context_synchronously
        Navigator.of(_dialogContext).pop();
      });
      // ignore: use_build_context_synchronously
      showWarningDialog(_dialogContext, 'Thành công', 'Cập nhật tài khoản thành công', Icons.check_circle, Colors.green);

    } catch (e) {
      // ignore: use_build_context_synchronously
      showWarningDialog(_dialogContext, 'Lỗi', 'Cập nhật tài khoản thất bại: ${e.toString()}', Icons.warning);
    }finally {
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
          Icon(Icons.person, color: Colors.blueAccent),
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
              labelText: 'Tài khoản',
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
              value: _selectedRole,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue!;
                });
              },
              items: <String>['ADMIN', 'MANAGER', 'USER']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Role',
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
          onPressed: () async {
            String userName = _userNameController.text;
            String email = _emailController.text;
            String role = _selectedRole;
            if (userName.isEmpty || email.isEmpty || role.isEmpty) {
              showWarningDialog(context, 'Lỗi', 'Vui lòng điền đầy đủ thông tin', Icons.warning);
              return;
            }
            await _updateUserRole(userName, role);
          },
          text: 'Lưu',
          color: Colors.greenAccent,
          isLoading: _isLoading,

        ),
      ],
    );
  }
}