import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DiaLogLoad extends StatelessWidget {
  final String title;
  final String content;

  const DiaLogLoad({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2E3034),
              Color(0xFF2E3034),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: Colors.white.withOpacity(0.5),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}

void showLod(BuildContext context, String title, String content, [String? routeName]) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside
    builder: (BuildContext context) {
      Future.delayed(Duration(milliseconds: 500), () {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(true);
        if (routeName != null) {
          context.go(routeName);
        }
      });
      return DiaLogLoad(
        title: title,
        content: content,
      );
    },
  );
}
