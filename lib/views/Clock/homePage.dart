import 'package:alarm/views/Clock/clock_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'vi';
    var now = DateTime.now();
    var formattedTime = DateFormat('HH:mm').format(now);
    var formattedDate = DateFormat('EEE, d MMM').format(now);
    var timezoneString = now.timeZoneOffset.toString().split('.').first;
    var offsetSign = '';
    if (!timezoneString.startsWith('-')) offsetSign = '+';

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 246, 246, 248),
      body: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(32),
            margin: EdgeInsets.symmetric(vertical: 30,horizontal: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Đồng hồ',
                  style: TextStyle(color: Colors.black, fontSize: 20,fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 32),
                Text(
                  formattedTime,
                  style: TextStyle(color: Colors.black, fontSize: 35),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                SizedBox(height: 32),
                ClockView(),
                SizedBox(height: 32),
                Text(
                  'Múi giờ',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.language,
                      color: Colors.black,
                    ),
                    SizedBox(width: 16),
                    Text(
                      'UTC' + offsetSign + timezoneString,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
