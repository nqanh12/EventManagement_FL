import 'package:eventmanagement/Component/button_crud.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';
import 'package:eventmanagement/Service/excel_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FilePickerButton extends StatefulWidget {
  const FilePickerButton({super.key});

  @override
  FilePickerButtonState createState() => FilePickerButtonState();
}

class FilePickerButtonState extends State<FilePickerButton> {
  String? _fileName;

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Đang tải..."),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomElevatedButtonCRUD(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['xlsx'],
            );

            if (result != null) {
              final fileBytes = result.files.first.bytes;
              final fileName = result.files.first.name;
              setState(() {
                _fileName = fileName;
              });
              try {
                if (fileBytes != null) {
                  showLoadingDialog(context);
                  try {
                    await ExcelService().createUsersFromExcelBytes(fileBytes);
                    Navigator.of(context).pop(); // Close the loading dialog
                    showWarningDialog(context, "Success", "Tải file thành công", Icons.check_circle, Colors.green);
                  } catch (e) {
                    Navigator.of(context).pop(); // Close the loading dialog
                    showWarningDialog(context, "Lỗi", "Tải file thất bại: $e", Icons.error, Colors.red);
                  }
                }
              } catch (e) {
                showWarningDialog(context, "Lỗi", "Tải file thất bại: $e", Icons.error, Colors.red);
              }
            } else {
              showWarningDialog(context, "Hủy tải file", "Đang thoát...", Icons.warning, Colors.orange);
            }
          },
          color: Colors.white,
          icon: "assets/images/excel.png",
          textColor: Colors.green,
        ),
      ],
    );
  }
}