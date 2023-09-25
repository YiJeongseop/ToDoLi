import 'dart:ui';
import 'dart:convert';

import 'package:get/get_connect/http/src/request/request.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import "package:http/http.dart" as http;
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../screens/calendar.dart';

Future<drive.DriveApi?> _getDriveApi() async {
  final googleUser = await googleSignIn.signInSilently();
  final headers = await googleUser?.authHeaders;
  final client = GoogleAuthClient(headers!);
  final driveApi = drive.DriveApi(client);
  return driveApi;
}

Future<void> uploadAppointmentsToDrive(List<Appointment> appointments) async {
  final driveApi = await _getDriveApi();

  List<Map<String, dynamic>> jsonList = appointmentsToJsonList(appointments);
  final appointmentsJson1 = jsonEncode(jsonList);
  final appointmentsJson2 = utf8.encode(appointmentsJson1);

  final driveFile = drive.File();
  driveFile.name = 'appointments.json';

  final media = drive.Media(Stream.value(utf8.encode(appointmentsJson1)), appointmentsJson2.length);
  await driveApi!.files.create(driveFile, uploadMedia: media);
}

Future<List<Appointment>> downloadAppointmentsFromDrive() async {
  final List<Appointment> returnList = [];
  final driveApi = await _getDriveApi();

  final fileId = await getFileIdByName('appointments.json');
  if(fileId == null) return [];

  final response = await driveApi!.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media?;

  final appointmentsJson = utf8.decode((await response?.stream.toBytes()) as List<int>);
  final appointmentsList = List<Map<String, dynamic>>.from(jsonDecode(appointmentsJson));

  for (Map<String, dynamic> appt in appointmentsList) {
    String stringOfHexValue = appt['color'].split('(0x')[1].split(')')[0];
    int hexValue = int.parse(stringOfHexValue, radix: 16);
    final redList = appt['recurrenceExceptionDates']
        .map((date) => DateTime.parse(date))
        .toList();
    List<DateTime> dateTimeOfRedList = List.generate(redList.length, (index) => redList[index] as DateTime);
    List<String> pieceOfRecurrenceRule = appt['recurrenceRule'].split(';');

    if(pieceOfRecurrenceRule.length == 4){
      if(pieceOfRecurrenceRule[3] == 'BYDAY=' || pieceOfRecurrenceRule[3] == 'BYMONTHDAY=') continue;
    }

    // It does not import a fully deleted appointment
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

Future<String?> getFileIdByName(String fileName) async {
    final driveApi = await _getDriveApi();
    final fileList = await driveApi?.files.list(q: "name = '$fileName'");

    if (fileList!.files!.isNotEmpty) {
      final fileId = fileList.files!.first.id;
      return fileId;
    } else {
      return null;
    }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
