import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/message.dart';

class ChatScreen extends StatelessWidget {
  final List<Message> buffer;

  ChatScreen({required this.buffer});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: buffer.length,
      itemBuilder: (context, index) {
        return BubbleSpecialThree(
          color: buffer[index].sender == 1 ? Colors.white70 : Colors.lightBlueAccent,
          text: buffer[index].text!,
          isSender: buffer[index].sender == 1,
          textStyle: TextStyle(color: buffer[index].sender == 1 ? Colors.black : Colors.white),
        );
      },
    );
  }
}