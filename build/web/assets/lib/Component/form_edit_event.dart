import 'package:eventmanagement/Component/button_access.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventmanagement/Component/text_field.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';
import 'package:eventmanagement/Component/decription_text.dart';
import 'package:eventmanagement/Service/crud_event_service.dart';

class FormEditEventDialog extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final VoidCallback callback;

  const FormEditEventDialog({super.key, required this.initialData, required this.callback});

  @override
  FormEditEventDialogState createState() => FormEditEventDialogState();
}

class FormEditEventDialogState extends State<FormEditEventDialog> {
  late TextEditingController _eventNameController;
  late TextEditingController _eventCapacityController;
  late TextEditingController _eventDescriptionController;
  late TextEditingController _eventLocationIdController;
  late TextEditingController _eventDateStartController;
  late TextEditingController _eventDateEndController;
  late TextEditingController _eventManagerNameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _eventNameController = TextEditingController(text: widget.initialData['eventName'] ?? '');
    _eventCapacityController = TextEditingController(text: widget.initialData['capacity'] != null ? widget.initialData['capacity'].toString() : '');
    _eventDescriptionController = TextEditingController(text: widget.initialData['description'] ?? '');
    _eventLocationIdController = TextEditingController(text: widget.initialData['locationId'] ?? '');
    _eventDateStartController = TextEditingController(text: widget.initialData['dateStart'] ?? '');
    _eventDateEndController = TextEditingController(text: widget.initialData['dateEnd'] ?? '');
    _eventManagerNameController = TextEditingController(text: widget.initialData['managerName'] ?? '');
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventCapacityController.dispose();
    _eventDescriptionController.dispose();
    _eventLocationIdController.dispose();
    _eventDateStartController.dispose();
    _eventDateEndController.dispose();
    _eventManagerNameController.dispose();
    super.dispose();
  }

  Future<void> _updateEvent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String eventName = _eventNameController.text;
      int? capacity = int.tryParse(_eventCapacityController.text);
      if (capacity == null) {
        showWarningDialog(context, 'Lỗi', 'Sức chứa phải là số', Icons.warning, Colors.red);
        return;
      }
      String description = _eventDescriptionController.text;
      String locationId = _eventLocationIdController.text;
      DateTime dateStart = DateFormat('dd/MM/yyyy HH:mm').parse(_eventDateStartController.text);
      DateTime dateEnd = DateFormat('dd/MM/yyyy HH:mm').parse(_eventDateEndController.text);
      String managerName = _eventManagerNameController.text;
      if (eventName.isEmpty || description.isEmpty || locationId.isEmpty || managerName.isEmpty) {
        showWarningDialog(context, 'Lỗi', 'Vui lòng điền đầy đủ thông tin', Icons.warning, Colors.red);
        return;
      }

      Map<String, dynamic> eventData = {
        'name': eventName,
        'capacity': capacity,
        'description': description,
        'locationId': locationId,
        'dateStart': dateStart.toIso8601String(),
        'dateEnd': dateEnd.toIso8601String(),
        'managerName': managerName,
      };

      await CrudEventService().updateEvent(widget.initialData['eventId'], eventData);

      // ignore: use_build_context_synchronously
      showWarningDialog(context, 'Thành công', 'Cập nhật sự kiện thành công', Icons.check_circle, Colors.greenAccent);
      Future.delayed(Duration(milliseconds: 800), () {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        widget.callback();
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      showWarningDialog(context, 'Lỗi', 'Failed to update event: ${e.toString()}', Icons.warning, Colors.red);
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
              controller: _eventNameController,
              labelText: 'Tên sự kiện',
              prefixIcon: Icons.event,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _eventCapacityController,
              labelText: 'Sức chứa',
              prefixIcon: Icons.people,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            CustomTextArea(
              controller: _eventDescriptionController,
              labelText: 'Mô tả sự kiện',
              suffixIcon: Icon(Icons.description),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _eventLocationIdController,
              labelText: 'Địa điểm',
              prefixIcon: Icons.location_on,
            ),
            const SizedBox(height: 10),
            _buildDateTimePicker(context, _eventDateStartController, 'Ngày bắt đầu'),
            const SizedBox(height: 10),
            _buildDateTimePicker(context, _eventDateEndController, 'Ngày kết thúc'),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _eventManagerNameController,
              labelText: 'Người chủ trì',
              prefixIcon: Icons.person,
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
          onPressed: _updateEvent,
          text: 'Lưu',
          color: Colors.greenAccent,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildDateTimePicker(BuildContext context, TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.date_range),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          TimeOfDay? pickedTime = await showTimePicker(
            // ignore: use_build_context_synchronously
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
            );
            setState(() {
              controller.text = DateFormat('dd/MM/yyyy HH:mm').format(fullDateTime);
            });
          }
        }
      },
    );
  }
}