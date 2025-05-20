import 'package:flutter/material.dart';

class Emoticons extends StatelessWidget {
  final String emoticon;

  const Emoticons({super.key, required this.emoticon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[600],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(emoticon, style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}
