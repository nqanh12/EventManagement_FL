import 'package:flutter/material.dart';

class CustomElevatedButtonCRUD extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final Color color;
  final String? icon;
  final Color textColor;

  const CustomElevatedButtonCRUD({
    super.key,
    required this.onPressed,
    required this.color,
    this.isLoading = false,
    this.icon,
    this.textColor = Colors.white,
  });

  @override
  CustomElevatedButtonCRUDState createState() => CustomElevatedButtonCRUDState();
}

class CustomElevatedButtonCRUDState extends State<CustomElevatedButtonCRUD> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        child: ElevatedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: EdgeInsets.zero,
            minimumSize: Size(MediaQuery.of(context).size.width * 0.05, MediaQuery.of(context).size.width * 0.05), // 20% of screen width
            maximumSize: Size(MediaQuery.of(context).size.width * 0.05, MediaQuery.of(context).size.width * 0.05), // 20% of screen width
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            backgroundColor: _isHovered ? widget.color.withOpacity(0.8) : widget.color,
            foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          ),
          child: widget.isLoading
              ? const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          )
              : widget.icon != null
              ? Image.asset(
            widget.icon.toString(), // Replace with your image path
            width: MediaQuery.of(context).size.width * 0.03,
            height: MediaQuery.of(context).size.width * 0.03,
            color: widget.textColor,
          )
              : Container(),
        ),
      ),
    );
  }
}