import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final bool? isShadow;

  const CustomText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.color,
    this.isShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.pacifico(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color,
        shadows: isShadow == true
            ? [
          Shadow(
            offset: Offset(2.0, 2.0),
            blurRadius: 3.0,
            color: Colors.black,
          ),
        ]
            : [],
      ),
    );
  }
}