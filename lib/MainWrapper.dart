import 'package:alarm/views/Alarm/alarm_page.dart';
import 'package:alarm/views/Timer/TimerDown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alarm/views/Clock/homePage.dart';
import 'package:alarm/views/StopWatch/stop_watch_page.dart';


class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  MainWrapperState createState() => MainWrapperState();
}

class MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  bool _isBottomNavVisible = true;

  void _onHideTapped() {
    setState(() {
      _isBottomNavVisible = false;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
      _isBottomNavVisible = true; // Show BottomNavigationBar when switching screens
    });
  }

  void _onShowTapped() {
    setState(() {
      _isBottomNavVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _isBottomNavVisible
          ? Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white, width: 1.0),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: Colors.white,
            labelTextStyle: MaterialStateProperty.all(
              TextStyle(color: Colors.white),
            ),
          ),
          child: NavigationBar(
            backgroundColor: Color.fromARGB(255, 45, 47, 65),
            onDestinationSelected: _onPageChanged,
            selectedIndex: _selectedIndex,
            destinations: [
              NavigationDestination(
                icon: SizedBox(
                  width: 24,
                  height: 24,
                  child: Image.asset(
                    'assets/clock_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
                label: 'Clock',
              ),
              NavigationDestination(
                icon: SizedBox(
                  width: 24,
                  height: 24,
                  child: Image.asset(
                    'assets/alarm_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
                label: 'Alarm',
              ),
              NavigationDestination(
                icon: SizedBox(
                  width: 24,
                  height: 24,
                  child: Image.asset(
                    'assets/timer_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
                label: 'Timer',
              ),
              NavigationDestination(
                icon: SizedBox(
                  width: 24,
                  height: 24,
                  child: Image.asset(
                    'assets/stopwatch_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
                label: 'Stopwatch',
              ),
            ],
          ),
        ),
      )
          : null,
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: <Widget>[
            HomePage(),
            AlarmPage(onHideTap: _onHideTapped, onShowTap: _onShowTapped),
            TimerDown(),
            StopWatchPage(),
          ],
        ),
      ),
    );
  }
}
