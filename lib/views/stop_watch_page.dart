import 'package:flutter/material.dart';
import 'package:alarm/helper/stop_watch_helper.dart';

class StopWatchPage extends StatefulWidget {
  const StopWatchPage({super.key});

  @override
  State<StopWatchPage> createState() => _StopWatchState();
}

class _StopWatchState extends State<StopWatchPage> {
  final StartWatch startWatch = StartWatch();


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    startWatch.dispose();
    super.dispose();
  }

  String mainButtonText = 'Bắt đầu';
  String secondaryButtonText = 'Đặt lại';

  void _mainButtonPressed(){
    setState(() {
      if (mainButtonText == 'Bắt đầu') {
        mainButtonText = 'Dừng';
        secondaryButtonText = 'Đặt lại';
      } else if (mainButtonText == 'Dừng') {
        mainButtonText = 'Tiếp tục';
        secondaryButtonText = 'Đặt lại';
      } else if (mainButtonText == 'Tiếp tục') {
        mainButtonText = 'Dừng';
        secondaryButtonText = 'Đặt lại';
      }
    });
  }
  void _secondaryButtonPressed() {
    setState(() {
      if (secondaryButtonText == 'Đặt lại') {
        mainButtonText = 'Bắt đầu';
        secondaryButtonText = 'Bấm';
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        child: Column(
          
          children: [
            Text(
              startWatch.currentTime,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    startWatch.resetStopwatch();
                    _secondaryButtonPressed();
                    setState(() {

                    });
                  },
                  child: Text(
                    secondaryButtonText,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    // primary: Colors.white70,
                    // onPrimary: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                    minimumSize: Size(130, 50),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: (){
                    _mainButtonPressed();
                    startWatch.startStopwatch(() {
                      setState(() {});
                    });
                  },
                  child: Text(
                    mainButtonText,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    // primary: startWatch.isRunning ? Colors.redAccent : Colors.purple,
                    // onPrimary: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                    minimumSize: Size(130, 50),
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }
}
