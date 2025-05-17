import 'package:flutter/material.dart';

class StreakPage extends StatelessWidget {
  final String selectedMood;

  StreakPage({required this.selectedMood});

  @override
  Widget build(BuildContext context) {
    final currentDay = DateTime.now().weekday; // 1 = Monday, ..., 7 = Sunday
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Daily Streak'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            final isToday = currentDay == index + 1;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(days[index], style: TextStyle(color: Colors.white)),
                SizedBox(height: 8),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isToday ? Colors.blue : Colors.grey,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
