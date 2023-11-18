import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSender;
  const ChatBubble({super.key, required this.message, required this.isSender});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 2* (MediaQuery.of(context).size.width / 3),
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: getColor(), //getColor("2598D7"),
        
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 20)
      )
    );
  }


  Color getColor() {
    if(isSender) {
      return Colors.blue;
    }
    return Colors.grey;
  }
}