// custom_title_text.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextList extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight? fontWeight; // Make fontWeight nullable

  const CustomTextList({
    super.key,
    required this.text,
    required this.fontSize,
    required this.color,
    this.fontWeight, // Optional parameter
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.lobster(
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.normal, // Provide a default value
        color: color,
      ),
    );
  }
}