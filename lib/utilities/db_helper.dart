import 'dart:ui';

import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';


const String tableAppointment = 'tableAppointment';
const String columnSubject = 'subject';
const String columnNotes = 'notes';
const String columnColor = 'color';
const String columnIsAllDay = 'isAllDay';
const String columnStartTime = 'startTime';
const String columnEndTime = 'endTime';
const String columnRecurrenceRule = 'recurrenceRule';
const String columnRecurrenceExceptionDates = 'recurrenceExceptionDates';
const String columnId = 'id';

class DBHelper {
  Database? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'todoli5.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $tableAppointment( 
            $columnSubject TEXT,
            $columnNotes TEXT,
            $columnColor TEXT NOT NULL,
            $columnIsAllDay TEXT NOT NULL,
            $columnStartTime TEXT NOT NULL,
            $columnEndTime TEXT NOT NULL,
            $columnRecurrenceRule TEXT NOT NULL,
            $columnRecurrenceExceptionDates TEXT,
            $columnId TEXT PRIMARY KEY)
        ''');
      }
    );
  }

  Future<void> insertData(Map<String, dynamic> data) async {
    final db = await database;
    final batch = db!.batch();
    batch.insert(tableAppointment, data);
    await batch.commit();
  }

  Future<void> deleteData(String id) async {
    final db = await database;
    await db!.delete(tableAppointment, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<void> deleteAllData() async {
    final db = await database;
    await db!.rawDelete("DELETE FROM $tableAppointment");
  }

  Future<List<Appointment>> getData() async { // List<Appointment>
    final db = await database;
    final List<Map<String, dynamic>> appointmentsList = await db!.query(tableAppointment);
    final List<Appointment> returnList = [];
    List<DateTime> dateTimeOfRedList = [];
    if(appointmentsList == []) return [];

    for (Map<String, dynamic> appt in appointmentsList) {
      print(appt);
      String stringOfHexValue = appt['color'].split('(0x')[1].split(')')[0];
      int hexValue = int.parse(stringOfHexValue, radix: 16);
      final tempList = appt['recurrenceExceptionDates'].split(','); // List<String>
      if(tempList[0] != ''){
        final redList = tempList.map((date) => DateTime.parse(date)).toList();
        dateTimeOfRedList = List.generate(redList.length, (index) => redList[index] as DateTime);
      } else {
        dateTimeOfRedList = [];
      }
      List<String> pieceOfRecurrenceRule = appt['recurrenceRule'].split(';');

      print(dateTimeOfRedList.length);
      print(int.parse(pieceOfRecurrenceRule[2].substring(6)));
      if(dateTimeOfRedList.length != int.parse(pieceOfRecurrenceRule[2].substring(6))) {
        returnList.add(
          Appointment(
              subject: appt['subject'],
              notes: appt['notes'],
              color: Color(hexValue),
              isAllDay: appt['isAllDay'] == "true",
              startTime: DateTime.parse(appt['startTime']),
              endTime: DateTime.parse(appt['endTime']),
              recurrenceRule: appt['recurrenceRule'],
              recurrenceExceptionDates: dateTimeOfRedList,
              id: int.parse(appt['id'])),
        );
      }
    }

    return returnList;
  }
}