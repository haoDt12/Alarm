import 'package:alarm/constants/theme_data.dart';
import 'package:alarm/data/data.dart';
import 'package:alarm/data/models/alarm_info.dart';
import 'package:alarm/helper/alarm_helper.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:alarm/helper/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:alarm/views/Alarm/add_alarm.dart';

class AlarmPage extends StatefulWidget {
  final VoidCallback onShowTap;
  final VoidCallback onHideTap;

  const AlarmPage(
      {super.key, required this.onHideTap, required this.onShowTap});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  DateTime? _alarmTime;
  AlarmHelper _alarmHelper = AlarmHelper();
  Future<List<AlarmInfo>>? _alarms;
  Set<int> _selectedAlarms = Set<int>();
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _alarmTime = DateTime.now();
    _alarmHelper.initializeDatabase().then((value) {
      print('---------database intialized');
      loadAlarms();
    });
  }

  void notification() async {
    await checkAndUpdateAlarmDates();
    List<AlarmInfo> alarms = await _alarmHelper.getAlarm();
    setState(() {
      _alarms = Future.value(alarms);
    });
    for (var alarm in alarms) {
       if (alarm.isPending == true ) {
        // Check if it's time to show notification
        scheduleAlarm(
          alarm.id!,
          alarm.title!,
          alarm.title!,
          alarm.alarmDateTime!,
        );
      }
       if(alarms.length != null){
         print('AlarmNew: ${alarm.title} --- ${alarm.isPending} --- ${alarm.alarmDateTime}');
       }else{
         print('Khong co');
       }
      print('------------------------');
    }
  }
  void loadAlarms() async {
    await _alarmHelper.initializeDatabase();
    //_refreshAlarmList()
    _refreshAlarmList().then((_) {
      notification();
    });
    await checkAndUpdateAlarmDates();
  }

  Future<void> _refreshAlarmList() async {
    // for (var alarm in alarms) {
    List<AlarmInfo> alarms = await _alarmHelper.getAlarm();
    setState(() {
      _alarms = Future.value(alarms);
    });

  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedAlarms.contains(index)) {
        _selectedAlarms.remove(index);
      } else {
        _selectedAlarms.add(index);
      }
    });
  }
  Future<void> checkAndUpdateAlarmDates() async {
    List<AlarmInfo> alarms = await _alarmHelper.getAlarm();
    DateTime now = DateTime.now();

    for (var alarm in alarms) {
      DateTime alarmDateTime = alarm.alarmDateTime!;

      // Compare current time with alarm time
      if (now.isAfter(alarmDateTime)) {
        // Calculate next day at the same time
        DateTime nextDay = DateTime(
          alarmDateTime.year,
          alarmDateTime.month,
          alarmDateTime.day + 1,
          alarmDateTime.hour,
          alarmDateTime.minute,
        );

        // Update alarmDateTime in database
        await _alarmHelper.updateAlarmDateTime(alarm.id!, nextDay);
        alarm.alarmDateTime = nextDay;

      }
    }
    setState(() {
      _alarms = Future.value(alarms);
    });
  }


  void _exitSelectionMode() {
    setState(() {
      _selectedAlarms.clear();
      _isSelectionMode = false;
    });
    widget.onShowTap();
  }

  void deleteSelectedAlarms() async {
    // Wait for the Future to complete
    List<AlarmInfo> alarms = await _alarms!;

    // Convert set of indices to list to avoid concurrent modification error
    List<int> selectedIndices = _selectedAlarms.toList();

    // Delete selected alarms
    for (int index in selectedIndices) {
      if (index < alarms.length) { // Ensure index is valid
        int alarmId = alarms[index].id!;
        _alarmHelper.delete(alarmId);
        await flutterLocalNotificationsPlugin.cancel(alarmId);
      }
    }

    _exitSelectionMode();

    _refreshAlarmList();
    notification();
  }
  void _toggleAlarmStatus(int id, bool currentStatus) async {
    bool newStatus = !currentStatus; // Toggle the current status

    // Update the UI immediately
    setState(() {
      _alarms!.then((value) {
        value!.firstWhere((element) => element.id == id).isPending = newStatus;
      });
    });

    // Update the database
    await _alarmHelper.updateAlarmPendingStatus(id, newStatus);

    // If turning off (false), cancel the notification
    if (!newStatus) {
      await flutterLocalNotificationsPlugin.cancel(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(left: 20,top: 30,right: 20,bottom: 0),
        color: Color.fromARGB(255, 246, 246, 248),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Alarm',
                  style: TextStyle(
                      fontFamily: 'anenir',
                      fontWeight: FontWeight.w700,
                      color: CustomColors.menuBackgroundColor,
                      fontSize: 24),
                ),
                IconButton(
                  icon: Image.asset(
                    'assets/add_alarm.png',
                    scale: 1.5,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddAlarm(),
                      ),
                    ).then((value) {
                      if (value != null && value as bool) {
                        // Reload alarms after adding or editing
                        loadAlarms();
                      }
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder(
                future: _alarms,
                builder: (context, AsyncSnapshot<List<AlarmInfo>> snapshot) {
                  if (snapshot.hasData)
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        if (index >= snapshot.data!.length) {
                          return Container();  // Handle invalid index
                        }
                        var alarm = snapshot.data![index];
                        var alarmTime = DateFormat('hh:mm a', 'en_US')
                            .format(alarm.alarmDateTime!);
                        var alarmDay = DateFormat('EEE, d\'th\' M', 'vi_VN')
                            .format(alarm.alarmDateTime!);
                        var gradientColor = GradientTemplate
                            .gradientTemplate[alarm.gradientColorIndex!].colors;
                        var isSelected = _selectedAlarms.contains(index);

                        return GestureDetector(
                          onTap: () {
                            widget.onHideTap();
                            setState(() {
                              _isSelectionMode = true;
                              _toggleSelection(index);
                            });
                            print('du lieu: $_selectedAlarms');
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 32),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: gradientColor,
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          gradientColor.last.withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                      offset: Offset(4, 4)),
                                ],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(24))),
                            child: Row(
                              children: [
                                if (_isSelectionMode)
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        _toggleSelection(index);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8.0),
                                        child: isSelected
                                            ? Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                              )
                                            : Icon(
                                                Icons.radio_button_off,
                                                color: Colors.blueGrey,
                                              ),
                                      ),
                                    ),
                                  ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.label,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            alarm.title!,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'avenir'),
                                          ),
                                        ],
                                      ),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              alarmDay,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'avenir'),
                                            ),
                                            Switch(
                                              value: alarm.isPending!,
                                              onChanged: (bool value) {
                                                _toggleAlarmStatus(alarm.id!, alarm.isPending!);
                                              },
                                              activeColor: Colors.white,
                                            ),
                                          ]),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            alarmTime,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'avenir',
                                              fontWeight: FontWeight.w700,
                                              fontSize: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  else
                    return Center(
                      child: Text(
                        'Loading...',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: _isSelectionMode,
            child: BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: _exitSelectionMode,
                    child: Text(
                      'Exit',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        deleteSelectedAlarms();
                      });
                    },
                    child: Text(
                      'Delete',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> scheduleAlarm(
      int id, String title, String body, DateTime scheduledTime) async {
    final tz.TZDateTime scheduledNotificationDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

    print('Scheduling alarm with ID: $id');
    print('Title: $title');
    print('Body: $body');
    print('Scheduled Time: $scheduledNotificationDateTime');

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_notifi',
      'alarm_notifi',
      importance: Importance.high,
      priority: Priority.high,
      fullScreenIntent: true,
      ticker: 'ticker',
      icon: 'clock_logo',
      sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
      largeIcon: DrawableResourceAndroidBitmap('codex_logo'),
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        htmlFormatContent: true,
        htmlFormatContentTitle: true,
      ),

    actions: <AndroidNotificationAction>[
      AndroidNotificationAction('action_pause', 'Tạm dừng'),
      AndroidNotificationAction('action_dismiss', 'Bỏ qua'),
    ],
  );

    var iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      sound: 'a_long_cold_sting.wav',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
}
