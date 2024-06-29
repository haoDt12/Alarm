import 'package:intl/intl.dart';

class AlarmInfo {
  int? id;
  String? title;
  DateTime? alarmDateTime;
  bool? isPending;
  int? gradientColorIndex;

  AlarmInfo({
    this.id,
    this.title,
    this.alarmDateTime,
    this.isPending,
    this.gradientColorIndex,
  });

  String get formattedAlarmTime {
    if (alarmDateTime != null) {
      return DateFormat('hh:mm a', 'en_US').format(alarmDateTime!);
    } else {
      return '';
    }
  }

  factory AlarmInfo.fromJson(Map<String, dynamic> json) => AlarmInfo(
        id: json["id"],
        title: json["title"],
        alarmDateTime: DateTime.parse(json["alarmDateTime"]),
        isPending: json["isPending"]==1,
        gradientColorIndex: json["gradientColorIndex"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "alarmDateTime": alarmDateTime!.toIso8601String(),
        "isPending": isPending ==true ? 1 : 0,
        "gradientColorIndex": gradientColorIndex,
      };
}
