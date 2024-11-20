import 'package:eventmanagement/Component/button_access.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:eventmanagement/Service/course_service.dart';
import 'package:flutter/material.dart';
import 'package:eventmanagement/Component/text_field.dart';

class FormAddCourseDialog extends StatefulWidget {
  final VoidCallback callback;
  const FormAddCourseDialog({super.key, required this.callback});

  @override
  FormAddCourseDialogState createState() => FormAddCourseDialogState();
}

class FormAddCourseDialogState extends State<FormAddCourseDialog> {
  late TextEditingController _courseNameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _courseNameController = TextEditingController();
  }

  @override
  void dispose() {
    _courseNameController.dispose();
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
              Text("Đang tạo khóa học mới, vui lòng đợi..."),
            ],
          ),
        );
      },
    );
  }
  Future<void> _saveCourse() async {
    setState(() {
      _isLoading = true;
    });
    _showLoadingDialog(context);
    try {
      String courseName = _courseNameController.text;

      if (courseName.isEmpty) {
        showWarningDialog(context, 'Lỗi', 'Tên khóa không được để trống!', Icons.warning, Colors.red);
        return;
      }

      // Create new course
      await CourseService().createCourse(courseName);
      Navigator.of(context).pop();
      showWarningDialog(context, 'Thành công', 'Thêm khóa thành công', Icons.check_circle, Colors.green);

      Future.delayed(Duration(milliseconds: 800), () {
        Navigator.of(context).pop();
        widget.callback();
      });
    } catch (e) {
      Navigator.of(context).pop();
      showWarningDialog(context, 'Lỗi', 'Mã khóa đã tồn tại trong hệ thống ${e.toString()}', Icons.warning, Colors.red);
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
          Icon(Icons.school, color: Colors.blueAccent),
          const SizedBox(width: 10),
          CustomText(
            text: 'Thêm khóa',
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
              controller: _courseNameController,
              labelText: 'Tên khóa',
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
        CustomElevatedButton(
          onPressed: _saveCourse,
          text: 'Thêm',
          color: Colors.greenAccent,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}