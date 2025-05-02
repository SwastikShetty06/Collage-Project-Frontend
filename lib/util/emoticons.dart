import 'package:flutter/material.dart';

class Emoticons extends StatelessWidget {
  final String emoticons;

  const Emoticons({Key? key, required this.emoticons}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[600],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      child: Center(child: Text(emoticons, style: TextStyle(fontSize: 28))),
    );
  }
}
