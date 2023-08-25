library event_calendar;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import "package:http/http.dart" as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:todoli/controllers/color_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:confetti/confetti.dart';

import '../fonts.dart';

part '../widgets/color_picker.dart';
part 'appointment_editor.dart';
part '../widgets/recurrence_delete.dart';
part '../widgets/recurrence_change.dart';
part 'login.dart';
part '../services/google_drive.dart';
part '../utilities/cancellation_line.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => CalendarState();
}

late List<Color> _colorCollection;
late List<String> _colorNames;
late DataSource _events;
late List<String> _deleteOptionList;
late List<String> _changeOptionList;
late Appointment? _selectedAppointment;
late int _selectedColorIndex;
late DateTime _startDate;
late TimeOfDay _startTime;
late DateTime _endDate;
late TimeOfDay _endTime;
late bool _isAllDay;
late String _subject;
late String _notes;
late String _recurrenceRule;
late bool _isRecurrence;
late String _freq;
late int _interval;
late int _count;
late String _byDay;
late int _byMonthDay;
late List<DateTime> _recurrenceExceptionDates;

final _valueListFreq = ['DAILY', 'WEEKLY', 'MONTHLY'];
final _valueListInterval = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
final _valueListCount = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30];

class CalendarState extends State<Calendar> {
  bool isLoading = true; // It is used to get data from Google Drive at first.

  CalendarState();

  CalendarController calendarController = CalendarController();
  final ColorController controller = Get.put(ColorController());
  final List<Color> colorList = [
    const Color(0xFF97D7E1),
    const Color(0xFFE5C1F5),
    const Color(0xFFECB7B2),
    const Color(0xFFECDD83),
    const Color(0xFF8BD39A)
  ];

  Future<void> _initializeAsyncStuff() async {
    _events = DataSource(await downloadAppointmentsFromDrive());
    setState(() {
      isLoading = false;
    });
  }

  @override
  initState() {
    _initializeAsyncStuff();
    _selectedAppointment = null;
    _selectedColorIndex = 0;

    _colorCollection = <Color>[];
    _colorCollection.add(const Color(0xFFA9D39E)); // Pistachio Green
    _colorCollection.add(const Color(0xFFC89ED3)); // Light Purple
    _colorCollection.add(const Color(0xFFFFFACD)); // Chiffon Yellow
    _colorCollection.add(const Color(0xFFF4C2C2)); // Baby Pink
    _colorCollection.add(const Color(0xFFFBB474)); // Soft Orange
    _colorCollection.add(const Color(0xFF89CFF0)); // Baby Blue
    _colorCollection.add(const Color(0xFFC8F3CD)); // Creamy Mint
    _colorCollection.add(const Color(0xFFFFE5B4)); // Peach
    _colorCollection.add(const Color(0xFFFF8680)); // Pastel Red

    _colorNames = <String>[];
    _colorNames.add('Pistachio Green');
    _colorNames.add('Light Purple');
    _colorNames.add('Chiffon Yellow');
    _colorNames.add('Baby Pink');
    _colorNames.add('Soft Orange');
    _colorNames.add('Baby Blue');
    _colorNames.add('Creamy Mint');
    _colorNames.add('Peach');
    _colorNames.add('Pastel Red');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _deleteOptionList = <String>[];
    _deleteOptionList.add(AppLocalizations.of(context)!.deleteAllAppointments);
    _deleteOptionList.add(AppLocalizations.of(context)!.deleteThisOnly);
    _deleteOptionList.add(AppLocalizations.of(context)!.deleteSinceThis);

    _changeOptionList = <String>[];
    _changeOptionList.add(AppLocalizations.of(context)!.changeSinceThis);
    _changeOptionList.add(AppLocalizations.of(context)!.changeThisOnly);

    return GetBuilder<ColorController>(
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                    child: getEventCalendar(_events, onCalendarTapped),
                  ),
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'addAppointment',
                backgroundColor: colorList[controller.numberOfColor],
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  weight: 20,
                  size: 40,
                ),
                onPressed: () {
                  setState(() {
                      _selectedAppointment = null;
                      _selectedColorIndex = 0;

                      final DateTime date = calendarController.selectedDate!;
                      _startDate = date;
                      _endDate = date.add(const Duration(hours: 1));
                      _startTime = TimeOfDay(
                          hour: _startDate.hour, minute: _startDate.minute);
                      _endTime = TimeOfDay(
                          hour: _endDate.hour, minute: _endDate.minute);
                      _byMonthDay = _startDate.day;
                      _isAllDay = false;
                      _subject = '';
                      _notes = '';
                      _recurrenceExceptionDates = <DateTime>[];
                      _recurrenceRule = 'FREQ=DAILY;INTERVAL=1;COUNT=1';
                      _isRecurrence = false;
                      _freq = 'DAILY';
                      _interval = 1;
                      _count = 1;

                      switch (_startDate.weekday) {
                        case 1:
                          _byDay = 'MO';
                        case 2:
                          _byDay = 'TU';
                        case 3:
                          _byDay = 'WE';
                        case 4:
                          _byDay = 'TH';
                        case 5:
                          _byDay = 'FR';
                        case 6:
                          _byDay = 'SA';
                        case 7:
                          _byDay = 'SU';
                      }

                      Navigator.push<Widget>(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const AppointmentEditor()),
                      );
                    },
                  );
                },
              ),
              const SizedBox(
                height: 20,
              ),
              FloatingActionButton(
                heroTag: 'changeView',
                backgroundColor: colorList[controller.numberOfColor],
                child: (calendarController.view == CalendarView.month)
                    ? const Icon(
                        Icons.list_alt,
                        color: Colors.white,
                        weight: 20,
                        size: 40,
                      )
                    : const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        weight: 20,
                        size: 40,
                      ),
                onPressed: () {
                  setState(
                    () {
                      if (calendarController.view == CalendarView.month) {
                        calendarController.view = CalendarView.schedule;
                      } else {
                        calendarController.view = CalendarView.month;
                      }
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  GetBuilder<ColorController> getEventCalendar(
      CalendarDataSource calendarDataSource,
      CalendarTapCallback calendarTapCallback) {
    return GetBuilder<ColorController>(
      builder: (controller) {
        return SfCalendar(
          view: CalendarView.month,
          controller: calendarController,
          dataSource: calendarDataSource,
          onTap: calendarTapCallback,
          onLongPress: onCalendarLongPressed,
          scheduleViewSettings: ScheduleViewSettings( // https://help.syncfusion.com/flutter/calendar/schedule-view
            appointmentItemHeight: 52,
            hideEmptyScheduleWeek: true,
            monthHeaderSettings: MonthHeaderSettings(
              textAlign: TextAlign.center,
              height: 95,
              backgroundColor: colorList[controller.numberOfColor],
              monthTextStyle: (AppLocalizations.of(context)!.localeName == 'ko') ? ko28 : en26,
            ),
            weekHeaderSettings: WeekHeaderSettings(
              height: 20,
              textAlign: TextAlign.start,
              weekTextStyle: (AppLocalizations.of(context)!.localeName == 'ko') ? ko20 : en20,
            ),
            dayHeaderSettings: DayHeaderSettings(
              dayTextStyle: (AppLocalizations.of(context)!.localeName == 'ko') ? ko16 : en16,
              dateTextStyle: (AppLocalizations.of(context)!.localeName == 'ko') ? ko18 : en18,
            ),
          ),
          appointmentTimeTextFormat: 'HH:mm',
          // https://support.syncfusion.com/kb/article/10679/how-to-customize-the-appointments-using-custom-builder-in-the-flutter-calendar
          appointmentBuilder: (context, calendarAppointmentDetails) {
            final Appointment appointments = calendarAppointmentDetails.appointments.first;
            return Container(
              decoration: (calendarController.view == CalendarView.month)
                  ? BoxDecoration(
                      color: appointments.color.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black12, width: 1))
                  : BoxDecoration(
                      color: appointments.color.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(3.5),
                      border: Border.all(color: Colors.black12, width: 1)),
              child: Padding(
                padding: (calendarController.view != CalendarView.week)
                    ? const EdgeInsets.fromLTRB(8, 0, 0, 0)
                    : const EdgeInsets.fromLTRB(1, 0, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (calendarController.view == CalendarView.month || calendarController.view == CalendarView.schedule)
                      if(appointments.subject.length > 2)
                        Flexible(
                        child: (appointments.subject.substring(appointments.subject.length - 3) == '(-)') ?
                        Text(
                          appointments.subject.substring(0, appointments.subject.length - 3),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: (AppLocalizations.of(context)!.localeName == 'ko') ?
                          ko20subject.copyWith(decoration: TextDecoration.lineThrough,) :
                          en20.copyWith(decoration: TextDecoration.lineThrough,),
                        ) : Text(
                          appointments.subject,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: (AppLocalizations.of(context)!.localeName == 'ko') ? ko20subject : en20,
                          ),
                        ),
                      if(appointments.subject.length < 3)
                        Flexible(
                          child: Text(
                            appointments.subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: (AppLocalizations.of(context)!.localeName == 'ko') ? ko20subject : en20,
                          ),
                        ),
                    if ((appointments.isAllDay == false) & (appointments.startTime.year != appointments.endTime.year))
                      Flexible(
                        child: Text(
                            '${appointments.startTime.year.toString().substring(2)}/${appointments.startTime.month.toString()}/${appointments.startTime.day.toString()} ${appointments.startTime.hour.toString().padLeft(2, '0')}:${appointments.startTime.minute.toString().padLeft(2, '0')} - '
                            '${appointments.endTime.year.toString().substring(2)}/${appointments.endTime.month.toString()}/${appointments.endTime.day.toString()} ${appointments.endTime.hour.toString().padLeft(2, '0')}:${appointments.endTime.minute.toString().padLeft(2, '0')}',
                            style: (AppLocalizations.of(context)!.localeName == 'ko') ? ko19 : en17),
                      ),
                    if ((appointments.isAllDay == false) &
                        (appointments.startTime.year == appointments.endTime.year) &
                        ((appointments.startTime.month != appointments.endTime.month) || (appointments.startTime.day != appointments.endTime.day)))
                      Flexible(
                        child: Text(
                            '${appointments.startTime.month.toString()}/${appointments.startTime.day.toString()} ${appointments.startTime.hour.toString().padLeft(2, '0')}:${appointments.startTime.minute.toString().padLeft(2, '0')} - '
                            '${appointments.endTime.month.toString()}/${appointments.endTime.day.toString()} ${appointments.endTime.hour.toString().padLeft(2, '0')}:${appointments.endTime.minute.toString().padLeft(2, '0')}',
                            style: (AppLocalizations.of(context)!.localeName == 'ko') ? ko19 : en17),
                      ),
                    if ((appointments.isAllDay == false) &
                        (appointments.startTime.year == appointments.endTime.year) &
                        (appointments.startTime.month == appointments.endTime.month) &
                        (appointments.startTime.day == appointments.endTime.day))
                      Flexible(
                        child: Text(
                            '${appointments.startTime.hour.toString().padLeft(2, '0')}:${appointments.startTime.minute.toString().padLeft(2, '0')} - '
                            '${appointments.endTime.hour.toString().padLeft(2, '0')}:${appointments.endTime.minute.toString().padLeft(2, '0')}',
                            style: (AppLocalizations.of(context)!.localeName == 'ko') ? ko19 : en17),
                      ),
                  ],
                ),
              ),
            );
          },
          initialDisplayDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0),
          initialSelectedDate: DateTime.now(),
          backgroundColor: Colors.white,
          todayHighlightColor: Colors.black,
          minDate: DateTime(2023, 1, 1, 0, 1),
          maxDate: DateTime(2052, 12, 31, 23, 59),
          selectionDecoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: const Color(0xFFFDBC75), width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            shape: BoxShape.rectangle,
          ),
          viewHeaderStyle: ViewHeaderStyle(
              backgroundColor: colorList[controller.numberOfColor],
              dayTextStyle: (AppLocalizations.of(context)!.localeName == 'ko') ? ko19 : en18),
          monthViewSettings: MonthViewSettings( // https://help.syncfusion.com/flutter/calendar/month-view
            agendaItemHeight: 57,
            showAgenda: true,
            agendaViewHeight: MediaQuery.of(context).size.height / 3,
            appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
            agendaStyle: AgendaStyle(
              backgroundColor: Colors.white,
              dateTextStyle: (AppLocalizations.of(context)!.localeName == 'ko') ? ko22 : en20,
              dayTextStyle: (AppLocalizations.of(context)!.localeName == 'ko') ? ko24 : en22,
              placeholderTextStyle: const TextStyle( // Make "No events" a invisible in Month View.
                color: Colors.transparent,
              ),
            ),
            monthCellStyle: MonthCellStyle(
              textStyle: (AppLocalizations.of(context)!.localeName == 'ko') ? ko20 : en18,
              trailingDatesTextStyle: (AppLocalizations.of(context)!.localeName == 'ko') ?
                  GoogleFonts.poorStory(
                    fontSize: 17,
                    color: const Color(0xFFB7B7B7),
                    fontWeight: FontWeight.w500,
                  )
                  : GoogleFonts.pangolin(
                fontSize: 16,
                color: const Color(0xFFB7B7B7),
                fontWeight: FontWeight.w500,
              ),
              leadingDatesTextStyle: (AppLocalizations.of(context)!.localeName == 'ko') ?
              GoogleFonts.poorStory(
                fontSize: 17,
                color: const Color(0xFFB7B7B7),
                fontWeight: FontWeight.w500,
              )
                  : GoogleFonts.pangolin(
                fontSize: 16,
                color: const Color(0xFFB7B7B7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          headerStyle: CalendarHeaderStyle(
            textStyle: (AppLocalizations.of(context)!.localeName == 'ko') ? GoogleFonts.poorStory(
              fontSize: 28,
              color: (calendarController.view == CalendarView.month ||
                  calendarController.view == null)
              // The screen appears before the CalendarView value is initially included in the calendarController.view in the first time.
                  ? Colors.black87
                  : Colors.transparent,
              fontWeight: FontWeight.w500,
            ) : GoogleFonts.pangolin(
              fontSize: 24,
              color: (calendarController.view == CalendarView.month ||
                      calendarController.view == null)
                  // The screen appears before the CalendarView value is initially included in the calendarController.view in the first time.
                  ? Colors.black87
                  : Colors.transparent,
              fontWeight: FontWeight.w300,
            ),
          ),
          todayTextStyle: (AppLocalizations.of(context)!.localeName == 'ko') ? GoogleFonts.poorStory(
            fontSize: 19,
            color: Colors.white
          )
              : GoogleFonts.pangolin(
            fontSize: 18,
            color: Colors.white,
          ),
        );
      },
    );
  }

  // Modify an appointment that exists.
  void onCalendarTapped(CalendarTapDetails calendarTapDetails) {
    if (calendarTapDetails.targetElement != CalendarElement.appointment) return;

    setState(() {
      _freq = 'DAILY';
      _interval = 1;
      _count = 1;
      _byDay = '';
      _byMonthDay = 0;

      if (calendarTapDetails.appointments != null && calendarTapDetails.appointments!.length == 1) {
        final Appointment meetingDetails = calendarTapDetails.appointments![0];
        _startDate = meetingDetails.startTime;
        _endDate = meetingDetails.endTime;
        _isAllDay = meetingDetails.isAllDay;
        _recurrenceExceptionDates = meetingDetails.recurrenceExceptionDates!;
        _recurrenceRule = meetingDetails.recurrenceRule!;
        if (_recurrenceRule == 'FREQ=DAILY;INTERVAL=1;COUNT=1') {
          _isRecurrence = false;
        } else {
          _isRecurrence = true;
          List<String> pieceOfRecurrenceRule = _recurrenceRule.split(';');
          _freq = pieceOfRecurrenceRule[0].substring(5);
          _interval = int.parse(pieceOfRecurrenceRule[1].substring(9));
          _count = int.parse(pieceOfRecurrenceRule[2].substring(6));
          if (_freq == "WEEKLY") {
            _byDay = pieceOfRecurrenceRule[3].substring(6);
          } else if (_freq == "MONTHLY") {
            _byMonthDay = int.parse(pieceOfRecurrenceRule[3].substring(11));
          }
        }
        _selectedColorIndex = _colorCollection.indexOf(meetingDetails.color);
        _subject =
            meetingDetails.subject == AppLocalizations.of(context)!.noTitle
                ? ''
                : meetingDetails.subject;
        _notes = meetingDetails.notes!;
        _selectedAppointment = meetingDetails;
      }
      _startTime = TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
      _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);
      Navigator.push<Widget>(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => const AppointmentEditor()),
      );
    });
  }

  // Add Cancellation Line
  void onCalendarLongPressed(CalendarLongPressDetails details) {
    modifyCancellationLine(details);
    setState(() {});
  }
}

class DataSource extends CalendarDataSource {
  DataSource(List<Appointment> source) {
    appointments = source;
  }
}

Map<String, dynamic> appointmentToJson(Appointment appointment) {
  return {
    'subject': appointment.subject,
    'notes': appointment.notes,
    'color': appointment.color.toString(),
    'isAllDay': appointment.isAllDay.toString(),
    'startTime': appointment.startTime.toIso8601String(),
    'endTime': appointment.endTime.toIso8601String(),
    'recurrenceRule': appointment.recurrenceRule,
    'recurrenceExceptionDates': appointment.recurrenceExceptionDates!
        .map((datetime) => datetime.toIso8601String())
        .toList(),
    'id': appointment.id.toString(),
  };
}

List<Map<String, dynamic>> appointmentsToJsonList(
    List<Appointment> appointments) {
  List<Map<String, dynamic>> jsonList = [];
  for (var appointment in appointments) {
    jsonList.add(appointmentToJson(appointment));
  }
  return jsonList;
}
