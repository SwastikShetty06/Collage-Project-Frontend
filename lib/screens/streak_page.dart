import 'package:flutter/material.dart';

class StreakPage extends StatelessWidget {
  final String selectedMood;

  StreakPage({super.key, required this.selectedMood});

  final Map<String, Color> moodColors = {
    'happy': Colors.yellow,
    'sad': Colors.blue,
    'angry': Colors.red,
    'neutral': Colors.white,
    'excited': Colors.orange,
  };

  @override
  Widget build(BuildContext context) {
    final currentDay = DateTime.now().weekday;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final moodColor = moodColors[selectedMood.toLowerCase()] ?? Colors.blue;

    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final isToday = currentDay == index + 1;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                days[index],
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              CircleAvatar(
                radius: 20,
                backgroundColor: isToday ? moodColor : Colors.white,
                child: isToday ? const Icon(Icons.check_circle, color: Colors.blue) : null,
              ),
            ],
          );
        }),
      ),
    );
  }
}
