import 'package:flutter/material.dart';

class CustomTextArea extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final Widget? suffixIcon;
  const CustomTextArea({
    super.key,
    required this.controller,
    required this.labelText,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: controller,
        maxLines: null, // Allows the text field to grow as the user types
        decoration: InputDecoration(
          labelStyle: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.01,
            color: Colors.black54,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          labelText: labelText,
          prefixIcon: suffixIcon,
        ),
      );
  }
}