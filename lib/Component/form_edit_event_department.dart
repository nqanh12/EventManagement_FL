import 'package:eventmanagement/Component/button_access.dart';
import 'package:eventmanagement/Component/decription_text.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:eventmanagement/Service/crud_event_service.dart';
import 'package:eventmanagement/Service/course_service.dart';
import 'package:flutter/material.dart';
import 'package:eventmanagement/Component/text_field.dart';
import 'package:eventmanagement/Class/course.dart';
import 'package:eventmanagement/Class/event.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventmanagement/Service/notification_service.dart';
class FormEditEventDepartmentDialog extends StatefulWidget {
  final Event event;
  final VoidCallback callback;
  const FormEditEventDepartmentDialog({super.key, required this.event, required this.callback});

  @override
  FormEditEventDepartmentDialogState createState() => FormEditEventDepartmentDialogState();
}

class FormEditEventDepartmentDialogState extends State<FormEditEventDepartmentDialog> {
  late TextEditingController _nameController;
  late TextEditingController _capacityController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationIdController;
  late TextEditingController _managerNameController;
  late TextEditingController _dateStartController;
  late TextEditingController _dateEndController;
  bool _isLoading = false;
  List<Courses> _courses = [];
  List<String> _selectedCourses = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event.name);
    _capacityController = TextEditingController(text: widget.event.capacity.toString());
    _descriptionController = TextEditingController(text: widget.event.description);
    _locationIdController = TextEditingController(text: widget.event.locationId);
    _managerNameController = TextEditingController(text: widget.event.managerName);
    _dateStartController = TextEditingController(
      text: DateFormat('dd/MM/yyyy HH:mm').format(widget.event.dateStart.add(const Duration(hours: 7)))
    );
    _dateEndController = TextEditingController(
      text: DateFormat('dd/MM/yyyy HH:mm').format(widget.event.dateEnd.add(const Duration(hours: 7)))
    );
    _selectedCourses = widget.event.courses.map((course) => course.courseId).toList();
    _fetchCourses();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    _locationIdController.dispose();
    _managerNameController.dispose();
    _dateStartController.dispose();
    _dateEndController.dispose();
    super.dispose();
  }

  Future<void> _fetchCourses() async {
    try {
      final courses = await CourseService().getAllCoursesFilter();
      setState(() {
        _courses = courses;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      showWarningDialog(context, 'Lỗi', 'Failed to load courses: ${e.toString()}', Icons.warning, Colors.red);
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
              Text("Đang cập nhật sự kiện, vui lòng đợi..."),
            ],
          ),
        );
      },
    );
  }
  Future<void> _editEvent() async {
    setState(() {
      _isLoading = true;
    });
    _showLoadingDialog(context);
    try {
      String name = _nameController.text;
      int capacity = int.parse(_capacityController.text);
      String description = _descriptionController.text;
      String locationId = _locationIdController.text;
      String managerName = _managerNameController.text;
      String dateStartText = _dateStartController.text;
      String dateEndText = _dateEndController.text;

      if (name.isEmpty || description.isEmpty || locationId.isEmpty || managerName.isEmpty || _selectedCourses.isEmpty || dateStartText.isEmpty || dateEndText.isEmpty) {
        showWarningDialog(context, 'Lỗi', 'Có dữ liệu còn bỏ trống chưa điền !', Icons.warning, Colors.red);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      DateTime dateStart = DateFormat('dd/MM/yyyy HH:mm').parse(dateStartText).subtract(const Duration(hours: 7));
      DateTime dateEnd = DateFormat('dd/MM/yyyy HH:mm').parse(dateEndText).subtract(const Duration(hours: 7));
      if (dateEnd.isBefore(dateStart) || dateEnd.isAtSameMomentAs(dateStart)) {
        Navigator.of(context).pop(); // Close the loading dialog
        showWarningDialog(context, 'Lỗi', 'Ngày kết thúc phải lớn hơn ngày bắt đầu và không được bằng nhau', Icons.warning, Colors.red);
        setState(() {
          _isLoading = false;
        });
        return;
      }
      List<Courses> selectedCourses = _courses.where((course) => _selectedCourses.contains(course.courseId)).toList();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String departmentId = prefs.getString('departmentId') ?? '';
      final event = Event(
        id: widget.event.id,
        eventId: widget.event.eventId,
        name: name,
        departmentId: departmentId,
        capacity: capacity,
        currentParticipants: widget.event.currentParticipants,
        description: description,
        locationId: locationId,
        dateStart: dateStart,
        dateEnd: dateEnd,
        managerName: managerName,
        participants: widget.event.participants,
        courses: selectedCourses,
      );
      await NotificationService().sendNotificationToDepartment(departmentId, 'Sự kiện ${event.name} được thay đổi .');
      await CrudEventService().updateEvent(widget.event.eventId, event);
      Navigator.of(context).pop();
      showWarningDialog(context, 'Thành công', 'Cập nhật sự kiện thành công', Icons.check_circle, Colors.green);
      Future.delayed(Duration(milliseconds: 800), () {
        Navigator.of(context).pop();
        widget.callback();
      });
    } catch (e) {
      Navigator.of(context).pop();
      showWarningDialog(context, 'Lỗi', 'Failed to update event: ${e.toString()}', Icons.warning, Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildDateTimePicker(BuildContext context, TextEditingController controller, String label, {bool isStartDate = false}) {
    bool isPastStartDate = isStartDate && DateTime.now().isAfter(widget.event.dateStart.subtract(const Duration(hours: 7)));

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.date_range),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      readOnly: true,
      onTap: isPastStartDate ? null : () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (pickedTime != null) {
            final DateTime fullDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            ).add(const Duration(hours: 7)); // Add 7 hours here
            setState(() {
              controller.text = DateFormat('dd/MM/yyyy HH:mm').format(fullDateTime);
            });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Icon(Icons.event, color: Colors.blueAccent),
          const SizedBox(width: 10),
          CustomText(
            text: 'Chỉnh sửa sự kiện',
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
              controller: _nameController,
              labelText: 'Tên sự kiện',
              prefixIcon: Icons.event,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _capacityController,
              labelText: 'Sức chứa',
              prefixIcon: Icons.people,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 10),
            CustomTextArea(
              controller: _descriptionController,
              labelText: 'Mô tả',
              suffixIcon: Icon(Icons.description),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _locationIdController,
              labelText: 'Địa điểm',
              prefixIcon: Icons.location_on,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _managerNameController,
              labelText: 'Người chủ trì',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 10),
            _buildDateTimePicker(context, _dateStartController, 'Ngày bắt đầu (dd/MM/yyyy HH:mm)', isStartDate: true),
            const SizedBox(height: 10),
            _buildDateTimePicker(context, _dateEndController, 'Ngày kết thúc (dd/MM/yyyy HH:mm)'),
            const SizedBox(height: 10),
            Column(
              children: _courses.map((Courses course) {
                return CheckboxListTile(
                  title: CustomText(text: course.courseName, fontSize: 16, color: Colors.black),
                  value: _selectedCourses.contains(course.courseId),
                  onChanged: (bool? value) {
                    setState(() {
                      if (course.courseId == "K0") {
                        if (value == true) {
                          _selectedCourses = ["K0"];
                        } else {
                          _selectedCourses.remove(course.courseId);
                        }
                      } else {
                        if (value == true) {
                          _selectedCourses.remove("K0");
                          _selectedCourses.add(course.courseId);
                        } else {
                          _selectedCourses.remove(course.courseId);
                        }
                      }
                    });
                  },
                );
              }).toList(),
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
          onPressed: _editEvent,
          text: 'Cập nhật',
          color: Colors.greenAccent,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}