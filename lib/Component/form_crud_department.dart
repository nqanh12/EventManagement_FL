import 'package:eventmanagement/Component/button_access.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';
import 'package:eventmanagement/Component/show_log_delete.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:eventmanagement/Service/department_service.dart';
import 'package:flutter/material.dart';
import 'package:eventmanagement/Component/text_field.dart';
import 'package:eventmanagement/Class/department.dart';

class FormEditDepartmentDialog extends StatefulWidget {
  final Department? department;
  final VoidCallback callback;
  const FormEditDepartmentDialog({super.key, this.department, required this.callback});

  @override
  FormEditDepartmentDialogState createState() => FormEditDepartmentDialogState();
}

class FormEditDepartmentDialogState extends State<FormEditDepartmentDialog> {
  late TextEditingController _departmentNameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _departmentNameController = TextEditingController(text: widget.department?.departmentName ?? '');
  }

  @override
  void dispose() {
    _departmentNameController.dispose();
    super.dispose();
  }
  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message),
            ],
          ),
        );
      },
    );
  }
  Future<void> _saveDepartment() async {
    setState(() {
      _isLoading = true;
    });
    _showLoadingDialog(context, widget.department == null ? "Đang tạo khoa mới, vui lòng đợi..." : "Đang cập nhật khoa, vui lòng đợi...");
    try {
      String departmentName = _departmentNameController.text;

      if (departmentName.isEmpty) {
        showWarningDialog(context, 'Lỗi', 'Tên khoa không được để trống!', Icons.warning, Colors.red);
        return;
      }

      if (widget.department == null) {
        await DepartmentService().createDepartment(departmentName);
        Navigator.of(context).pop();
        showWarningDialog(context, 'Thành công', 'Thêm khoa thành công', Icons.check_circle, Colors.green);
      } else {
        if (departmentName == widget.department!.departmentName) {
          showWarningDialog(context, 'Lỗi', 'Dữ liệu không thay đổi!', Icons.warning, Colors.red);
          return;
        }
        await DepartmentService().updateDepartment(widget.department!.id, departmentName);
        Navigator.of(context).pop();
        showWarningDialog(context, 'Thành công', 'Cập nhật khoa thành công', Icons.check_circle, Colors.green);
      }

      Future.delayed(Duration(milliseconds: 800), () {
        Navigator.of(context).pop();
        widget.callback();
      });
    } catch (e) {
      Navigator.of(context).pop();
      showWarningDialog(context, 'Lỗi', 'Mã khoa đã tồn tại trong hệ thống ${e.toString()}', Icons.warning, Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDepartment() async {
    setState(() {
      _isLoading = true;
    });
    _showLoadingDialog(context, "Đang xóa khoa, vui lòng đợi...");
    try {
      final showLogDelete = ShowLogDeleteState();
      await showLogDelete.showConfirmationDialog(
        context: context,
        title: 'Xác nhận xóa',
        content: 'Bạn có chắc chắn muốn xóa khoa này không?',
        onConfirm: () async {
          await DepartmentService().deleteDepartment(widget.department!.id);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          widget.callback();
        },
      );
    } catch (e) {
      Navigator.of(context).pop();
      showWarningDialog(context, 'Lỗi', 'Failed to delete department: ${e.toString()}', Icons.warning, Colors.red);
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
          Icon(Icons.edit, color: Colors.blueAccent),
          const SizedBox(width: 10),
          CustomText(
            text: widget.department == null ? 'Thêm khoa' : 'Chỉnh sửa khoa',
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
              controller: _departmentNameController,
              labelText: 'Tên khoa(Mã khoa tự động tạo theo chữ cái đầu của tên khoa)',
              prefixIcon: Icons.school,
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
        if (widget.department != null)
          CustomElevatedButton(
            onPressed: _deleteDepartment,
            text: 'Xóa',
            color: Colors.red,
            isLoading: _isLoading,
          ),
        CustomElevatedButton(
          onPressed: _saveDepartment,
          text: widget.department == null ? 'Thêm' : 'Cập nhật',
          color: Colors.greenAccent,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}