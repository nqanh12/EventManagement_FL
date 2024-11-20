import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final containerColor = theme.brightness == Brightness.dark ? Colors.grey[800] : color;

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04, // 3% of screen width
        vertical: MediaQuery.of(context).size.height * 0.02, // 3% of screen height
      ),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CustomText(text: value, fontSize: MediaQuery.of(context).size.width * 0.02, color: Colors.white),
          const SizedBox(height: 10),
          CustomText(text: title, fontSize: MediaQuery.of(context).size.width * 0.008, color: Colors.white),
        ],
      ),
    );
  }
}