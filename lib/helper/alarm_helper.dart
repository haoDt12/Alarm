import 'package:alarm/data/models/alarm_info.dart';
import 'package:alarm/helper/alarm_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';


final String tableAlarm = 'alarm';
final String columnId = 'id';
final String columnTitle = 'title';
final String columnDateTime = 'alarmDateTime';
final String columnPending = 'isPending';
final String columnColorIndex = 'gradientColorIndex';


class AlarmHelper {
  static Database? _database;
  static AlarmHelper? _alarmHelper;


  AlarmHelper._createInstance();
  factory AlarmHelper(){
    if(_alarmHelper == null){
      _alarmHelper = AlarmHelper._createInstance();
    }
    return _alarmHelper!;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    var dir = await getDatabasesPath();
    var path = dir + "alarm1.db";


    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          create table $tableAlarm(
          $columnId integer primary key autoincrement,
          $columnTitle text not null,
          $columnDateTime text not null,
          $columnPending integer,
          $columnColorIndex integer)
        ''');
      },
    );
    return database;
  }


  void insertAlarm(AlarmInfo alarmInfo) async{
    var db = await this.database;
    var result = await db.insert(tableAlarm, alarmInfo.toJson());
    print('result: $result');
  }
  Future<List<AlarmInfo>> getAlarm() async{
    List<AlarmInfo> _alarms = [];
    var db = await this.database;
    var result = await db.query(tableAlarm);
    result.forEach((element){
      var alarmInfo = AlarmInfo.fromJson(element);
      _alarms.add(alarmInfo);
    });
    return _alarms;
  }
  Future<int> delete(int id) async {
    var db = await this.database;
    return await db.delete(tableAlarm, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(AlarmInfo alarmInfo) async {
  var db = await this.database;
    return await db.update(tableAlarm, alarmInfo.toJson(),
        where: '$columnId = ?', whereArgs: [alarmInfo.id]);
  }
  Future<int> updateAlarmPendingStatus(int id, bool isPending) async {
    var db = await this.database;
    return await db.update(
      tableAlarm,
      {'$columnPending': isPending ? 1 : 0}, // 1 for true, 0 for false
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
  Future<AlarmInfo?> getAlarmById(int id) async {
    var db = await this.database;
    var result = await db.query(tableAlarm, where: '$columnId = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return AlarmInfo.fromJson(result.first);
    } else {
      return null;
    }
  }
  Future<int> updateAlarmDateTime(int id, DateTime newDateTime) async {
    var db = await this.database;
    return await db.update(
      tableAlarm,
      {columnDateTime: newDateTime.toIso8601String()}, // Convert DateTime to ISO 8601 string
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }


}
