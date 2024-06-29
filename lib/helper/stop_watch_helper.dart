import 'dart:async';

class StartWatch {
  late Timer _timer;
  int _milliseconds = 0;
  bool _isRunning = false;

  String get currentTime => _formatTime(_milliseconds);

  bool get isRunning => _isRunning;

  void startStopwatch(Function callback) {
    if (!_isRunning) {
      _timer = Timer.periodic(Duration(milliseconds: 10), (timer) {
        _milliseconds += 10;
        callback();
      });
      _isRunning = true;
    } else {
      _timer.cancel();
      _isRunning = false;
    }
  }

  void resetStopwatch() {
    _timer.cancel();
    _milliseconds = 0;
    _isRunning = false;
  }

  String _formatTime(int milliseconds) {
    int minutes = (milliseconds ~/ 60000) % 60;
    int seconds = (milliseconds ~/ 1000) % 60;
    int centiseconds = (milliseconds ~/ 10) % 100;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${centiseconds.toString().padLeft(2, '0')}';
  }

  void dispose() {
    _timer.cancel();
  }
}
