import 'package:flutter/material.dart';
import 'package:project_frontend/util/emoticons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      body: SafeArea(
        child: Column(
          children: [
            //greetings
            Row(
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi Sanvi!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '25 April 2025',
                          style: TextStyle(color: Colors.blue[100]),
                        ),
                      ],
                    ),

                    //Notification
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[600],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.notifications, color: Colors.white),
                    ),
                  ],
                ),

                //search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.white),
                      SizedBox(width: 5),
                      Text('Search', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                SizedBox(height: 25),

                //how do you feel about studying
                Row(
                  children: [
                    Text(
                      'How do you feel about studying?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.more_horiz, color: Colors.white),
                  ],
                ),
                SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //bad
                    Column(
                      children: [
                        Emoticons(emoticons: '😭'),
                        SizedBox(height: 8),
                        Text('Bad', style: TextStyle(color: Colors.white)),
                      ],
                    ),

                    //boring
                    Column(
                      children: [
                        Emoticons(emoticons: '🥱'),
                        SizedBox(height: 8),
                        Text('Boring', style: TextStyle(color: Colors.white)),
                      ],
                    ),

                    //snoozing
                    Column(
                      children: [
                        Emoticons(emoticons: '😴'),
                        SizedBox(height: 8),
                        Text('Sleepy', style: TextStyle(color: Colors.white)),
                      ],
                    ),

                    //enthusiatic
                    Column(
                      children: [
                        Emoticons(emoticons: '😁'),
                        SizedBox(height: 8),
                        Text(
                          'Enthusiatic',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
