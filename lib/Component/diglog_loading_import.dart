import 'package:flutter/material.dart';

class DiaLogLoading extends StatelessWidget {
  final String title;
  final String content;

  const DiaLogLoading({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blueAccent,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            content,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          CircularProgressIndicator(
            color: Colors.blueAccent,
          ),
        ],
      ),
    );
  }
}

void showLoading(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside
    builder: (BuildContext context) {
      Future.delayed(Duration(milliseconds: 500), () {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(true);
      });
      return DiaLogLoading(
        title: title,
        content: content,
      );
    },
  );
}