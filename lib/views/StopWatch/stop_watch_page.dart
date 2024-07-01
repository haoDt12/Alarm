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

  String startButtonText = 'Bắt đầu';
  String resetButtonText = 'Đặt lại';

  void _startButtonPressed(){
    setState(() {
      if (startButtonText == 'Bắt đầu') {
        startButtonText = 'Dừng';
        resetButtonText = 'Đặt lại';
      } else if (startButtonText == 'Dừng') {
        startButtonText = 'Tiếp tục';
        resetButtonText = 'Đặt lại';
      } else if (startButtonText == 'Tiếp tục') {
        startButtonText = 'Dừng';
        resetButtonText = 'Đặt lại';
      }
    });
  }
  void _resetButtonPressed() {
    setState(() {
      if (resetButtonText == 'Đặt lại') {
        startButtonText = 'Bắt đầu';
        resetButtonText = 'Bấm';
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  startWatch.currentTime,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
                ),
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    startWatch.resetStopwatch();
                    _resetButtonPressed();
                    setState(() {

                    });
                  },
                  child: Text(
                    resetButtonText,
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
                    _startButtonPressed();
                    startWatch.startStopwatch(() {
                      setState(() {});
                    });
                  },
                  child: Text(
                    startButtonText,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    // primary: startWatch.isRunning ? Colors.redAccent : Colors.purple,
                    // onPrimary: Colors.white,
                    backgroundColor: startWatch.isRunning ? Colors.red[800] : Colors.purple,
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
