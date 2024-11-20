import 'package:eventmanagement/Component/button_access.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventmanagement/Component/text_field.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';

class FormAddEventDialog extends StatefulWidget {
  const FormAddEventDialog({super.key});

  @override
  FormAddEventDialogState createState() => FormAddEventDialogState();
}

class FormAddEventDialogState extends State<FormAddEventDialog> {
  final _eventNameController = TextEditingController();
  final _eventCapacityController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _eventLocationIdController = TextEditingController();
  final _eventDateStartController = TextEditingController();
  final _eventDateEndController = TextEditingController();
  final _eventManagerNameController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Icon(Icons.event, color: Colors.blueAccent),
          const SizedBox(width: 10),
          CustomText(
            text: 'Thêm sự kiện mới',
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
            CustomTextField(
              controller: _eventDescriptionController,
              labelText: 'Mô tả sự kiện',
              prefixIcon: Icons.description,
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
          onPressed: () {
            String eventName = _eventNameController.text;
            int? capacity = int.tryParse(_eventCapacityController.text);
            String description = _eventDescriptionController.text;
            String locationId = _eventLocationIdController.text;
            String dateStartText = _eventDateStartController.text;
            String dateEndText = _eventDateEndController.text;
            String managerName = _eventManagerNameController.text;

            if (eventName.isEmpty || capacity == null || description.isEmpty || locationId.isEmpty || dateStartText.isEmpty || dateEndText.isEmpty || managerName.isEmpty) {
              showWarningDialog(context, 'Lỗi', 'Có dữ liệu còn bỏ trống chưa điền !', Icons.warning);
              return;
            }

            DateFormat('dd/MM/yyyy HH:mm').parse(dateStartText);
            DateFormat('dd/MM/yyyy HH:mm').parse(dateEndText);

            Navigator.of(context).pop();
          },
          text: 'Thêm',
          color: Colors.greenAccent,
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
          firstDate: DateTime.now(),
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