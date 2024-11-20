import 'package:flutter/material.dart';

class IconCRUD extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  const IconCRUD({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onPressed, icon: Icon(icon, color: color, size: 30));
  }
}