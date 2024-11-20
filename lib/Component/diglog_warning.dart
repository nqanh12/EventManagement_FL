import 'package:flutter/material.dart';

class WarningDialog extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color? color;

  const WarningDialog({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    this.color = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 800), () {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(true);
    });

    return AlertDialog(
      title: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 10),
          Text(title),
        ],
      ),
      content: Text(content),
    );
  }
}

void showWarningDialog(BuildContext context, String title, String content, IconData icon, [Color? color]) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return WarningDialog(
        title: title,
        content: content,
        icon: icon,
        color: color,
      );
    },
  );
}