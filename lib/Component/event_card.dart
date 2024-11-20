// event_card.dart
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final ListTile listTile;
  const EventCard({
    super.key,
    required this.listTile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.symmetric(vertical: 20),
      elevation: 5,
      color: Color.fromARGB(255, 243, 245, 247),
      child: listTile
    );
  }
}