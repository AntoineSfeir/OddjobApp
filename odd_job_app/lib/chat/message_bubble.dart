import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSender;
  const ChatBubble({super.key, required this.message, required this.isSender});

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints(
          maxWidth: 2 * (MediaQuery.of(context).size.width / 3),
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: getColor(), //getColor("2598D7"),
        ),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 20,
            color: isSender ? Colors.white : Colors.black),
        ));
  }

  Color getColor() {
    if (isSender) {
      return const Color(0xFF2499D7);
    }
    return const Color(0xFFC9D1D5);
  }

}
