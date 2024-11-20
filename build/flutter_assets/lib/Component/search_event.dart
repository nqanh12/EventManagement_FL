// lib/Component/search_event.dart
import 'package:flutter/material.dart';

class SearchEvent extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onChanged;

  const SearchEvent({
    super.key,
    required this.searchController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 20.0, left: 20.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                hintText: 'Tìm kiếm theo tên sự kiện',
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.2)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
              onChanged: onChanged,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
          const SizedBox(width: 8.0),
        ],
      ),
    );
  }
}