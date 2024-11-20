import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;
  final Color color;
  final Color textColor;
  final IconData? icon;
  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.color,
    this.isLoading = false,
    this.textColor = Colors.white,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final paddingHorizontal = screenWidth > 600 ? 100.0 : 20.0;
    final paddingVertical = screenWidth > 600 ? 20.0 : 15.0;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 10,
        shadowColor: const Color(0xFFD9E2E4),
        padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: color,
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      child: isLoading
          ? const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      )
          : Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor),
            const SizedBox(width: 6),
          ],
          CustomText(text: text, fontSize: 16, color: textColor),
        ],
      ),
    );
  }
}