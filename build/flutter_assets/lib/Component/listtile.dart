import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:flutter/material.dart';

class ListTileItem extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final IconData icon;
  final bool selected; // Add a selected property

  const ListTileItem({
    super.key,
    required this.onTap,
    required this.title,
    required this.icon,
    this.selected = false, // Default value for selected
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: selected ? Colors.white : Colors.grey), // Change icon color if selected
      title: CustomText(text: title, fontSize: 20, color: selected ? Colors.white : Color(0xFF2E3034)), // Change text color if selected
      tileColor: selected ? Color(0xFF2E3034).withOpacity(0.6) : null, // Change background color if selected
      onTap: onTap,
    );
  }
}