import 'package:alarm/constants/theme_data.dart';
import 'package:alarm/data/models/alarm_info.dart';

List<AlarmInfo> alarms = [
  AlarmInfo(
    id: 1,
    title: 'DATABASE',
    alarmDateTime:  DateTime.now().add(Duration(hours: 1)),
    isPending: false,
    gradientColorIndex: 0,
  ),
  AlarmInfo(
    id: 2,
    title: 'ALARM',
    alarmDateTime:  DateTime.now().add(Duration(hours: 2)),
    isPending: true,
    gradientColorIndex: 1,
  ),
];
