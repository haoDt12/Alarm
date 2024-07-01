import 'dart:async';

import 'package:flutter/material.dart';

class TimerDown extends StatefulWidget {
  const TimerDown({super.key});

  @override
  State<TimerDown> createState() => _TimerDownState();
}

class _TimerDownState extends State<TimerDown> with TickerProviderStateMixin {
  late AnimationController controller;
  TextEditingController hourController = TextEditingController(text: '00');
  TextEditingController minuteController = TextEditingController(text: '00');
  TextEditingController secondController = TextEditingController(text: '00');

  FocusNode hourFocusNode = FocusNode();
  FocusNode minuteFocusNode = FocusNode();
  FocusNode secondFocusNode = FocusNode();

  int seconds = 0;
  int minutes = 0;
  int hour = 0;
  Timer? timer;
  bool _showNewButtons = false;
  bool _timerRunning = false;

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when widget is disposed
    super.dispose();
  }

  double progress = 1.0;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(hours: 0, minutes: 0, seconds: 60),
    );
    controller.addListener(() {
      if (controller.isAnimating) {
        setState(() {
          progress = controller.value;
        });
      }
    });
    updateTimers();

    hourFocusNode.addListener(() {
      if (hourFocusNode.hasFocus) {
        hourController.selection = TextSelection(
            baseOffset: 0, extentOffset: hourController.text.length);
      }
    });
    minuteFocusNode.addListener(() {
      if (minuteFocusNode.hasFocus) {
        minuteController.selection = TextSelection(
            baseOffset: 0, extentOffset: minuteController.text.length);
      }
    });
    secondFocusNode.addListener(() {
      if (secondFocusNode.hasFocus) {
        secondController.selection = TextSelection(
            baseOffset: 0, extentOffset: secondController.text.length);
      }
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (hour > 0 || minutes > 0 || seconds > 0) {
          if (seconds > 0) {
            seconds--;
          } else if (minutes > 0) {
            minutes--;
            seconds = 59;
          } else if (hour > 0) {
            hour--;
            minutes = 59;
            seconds = 59;
          }
        } else {
          timer.cancel();
          _timerRunning = false; // Set timer running flag to false
          resetTimer();
          return; // Exit the function to prevent negative minutes
        }

        // Update the text in the controllers
        secondController.text = seconds.toString().padLeft(2, '0');
        minuteController.text = minutes.toString().padLeft(2, '0');
        hourController.text = hour.toString().padLeft(2, '0');
      });
    });

    setState(() {
      _timerRunning = true; // Set timer running flag to true
    });
  }

  void stopTimer() {
    timer?.cancel();
    setState(() {
      _timerRunning = false;
    });
  }
  void resetTimer() {
    timer?.cancel();
    setState(() {
      _timerRunning = false;
      _showNewButtons = false;
      hour = 0;
      minutes = 0;
      seconds = 0;
      hourController.text = '00';
      minuteController.text = '00';
      secondController.text = '00';
    });
  }

  void updateTimers() {
    setState(() {
      seconds = int.tryParse(secondController.text) ?? 0;
      minutes = int.tryParse(minuteController.text) ?? 0;
      hour = int.tryParse(hourController.text) ?? 0;

      if (seconds >= 60 || secondController.text.length > 2) {
        seconds = 59;
        secondController.text = '59';
      }
      if (minutes >= 60) {
        minutes = 59;
        minuteController.text = '59';
      }
      if (hour >= 100) {
        hour = 99;
        hourController.text = '99';
      }
    });
  }



  void moveToNextField(TextEditingController currentController,
      TextEditingController nextController) {
    if (currentController.text.length == 2) {
      if (currentController == hourController) {
        FocusScope.of(context).requestFocus(minuteFocusNode);
      } else if (currentController == minuteController) {
        FocusScope.of(context).requestFocus(secondFocusNode);
      }
    }
  }

  String startButtonText = 'Bắt đầu';
  String pauseButtonText = 'Tạm dừng';
  String deleteButtonText = 'Xóa';
  String continueButtontext = 'Tiếp tục';

  @override
  Widget build(BuildContext context) {
    bool isTimerZero = hour == 0 && minutes == 0 && seconds == 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      child: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _timerRunning
                        ? null
                        : () {
                      hourFocusNode.requestFocus();
                      hourController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: hourController.text.length,
                      );
                    },
                    child: Container(
                      width: 70,
                      color: Colors.transparent,
                      child: TextField(
                        controller: hourController,
                        focusNode: hourFocusNode,
                        keyboardType: TextInputType.number,
                        cursorColor: Colors.transparent,
                        decoration: InputDecoration(
                          hintText: 'HH',
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        showCursor: false,
                        textAlign: TextAlign.center,
                        enabled: !_timerRunning, // Disable editing when timer is running
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            updateTimers();
                            moveToNextField(hourController, minuteController);
                          }
                        },
                      ),
                    ),
                  ),
                  Text(
                    ':',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (!_timerRunning) {
                        minuteFocusNode.requestFocus();
                        minuteController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: minuteController.text.length,
                        );
                      }
                    },
                    child: Container(
                      width: 70,
                      color: Colors.transparent,
                      child: TextField(
                        controller: minuteController,
                        focusNode: minuteFocusNode,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'MM',
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ),
                        showCursor: false,
                        textAlign: TextAlign.center,
                        enabled: !_timerRunning, // Disable editing when timer is running
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            updateTimers();
                            moveToNextField(minuteController, secondController);
                          }
                        },
                      ),
                    ),
                  ),
                  Text(
                    ':',
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (!_timerRunning) {
                        secondFocusNode.requestFocus();
                        secondController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: secondController.text.length,
                        );
                      }
                    },
                    child: Container(
                      width: 70,
                      color: Colors.transparent,
                      child: TextField(
                        controller: secondController,
                        focusNode: secondFocusNode,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'SS',
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ),
                        textAlign: TextAlign.center,
                        showCursor: false,
                        enabled: !_timerRunning, // Disable editing when timer is running
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            updateTimers();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!_showNewButtons)
            ElevatedButton(
              onPressed: isTimerZero
                  ? null
                  : () {
                setState(() {
                  _showNewButtons = true;
                });
                startTimer(); // Start the timer when the start button is pressed
              },
              child: Text(
                startButtonText,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                minimumSize: Size(130, 50),
              ),
            ),
          if (_showNewButtons)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: resetTimer,
                  child: Text(
                    deleteButtonText,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                    minimumSize: Size(130, 50),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_timerRunning) {
                      stopTimer(); // Stop the timer when the pause button is pressed
                    } else {
                      startTimer(); // Resume the timer if it was paused
                    }
                  },
                  child: Text(
                    _timerRunning ? pauseButtonText : continueButtontext,
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                    backgroundColor: _timerRunning ? Colors.red[800] : Colors.purple,
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
