import 'package:eventmanagement/Component/button_crud.dart';
import 'package:eventmanagement/Component/diglog_loading_import.dart';
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
                  // ignore: use_build_context_synchronously
                  showLoading(context, 'Tải file', 'Đang tải đọc dữ lên hệ thống...');
                  try {
                    await ExcelService().createUsersFromExcelBytes(fileBytes);
                  } catch (e) {
                    // ignore: use_build_context_synchronously
                    showLoading(context, 'Lỗi', 'Tải file thất bại: $e');
                  } finally {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop(); // Close the loading dialog
                  }
                }
              } catch (e) {
                // ignore: use_build_context_synchronously
                showLoading(context, 'Lỗi', 'Tải file thất bại: $e');
              }
            } else {
              // ignore: use_build_context_synchronously
              showLoading(context, 'Hủy tải file', 'Đang thoát..',);
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