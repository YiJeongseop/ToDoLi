part of '../screens/calendar.dart';

class RecurrenceChange extends StatefulWidget {
  const RecurrenceChange({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RecurrenceChangeState();
  }
}

class _RecurrenceChangeState extends State<RecurrenceChange> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          side: BorderSide(color: Colors.black, width: 2.0),
      ),
      content: SizedBox(
        height: MediaQuery.of(context).size.height / 6,
        width: double.maxFinite,
        child: ListView.builder(
          padding: const EdgeInsets.all(5.0),
          itemCount: 2, // Change all since the appointment you choose, Change only one
          itemExtent: MediaQuery.of(context).size.height / 12,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                tileColor: (!Get.isDarkMode) ? colorCollection[selectedColorIndex] : const Color(0xFF505458),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1.0),
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Center(
                  child: Text(
                    _changeOptionList[index],
                    style: (AppLocalizations.of(context)!.localeName == 'ko')
                        ? ko22.copyWith(color: Theme.of(context).primaryColorDark)
                        : en20.copyWith(color: Theme.of(context).primaryColorDark),
                    textAlign: TextAlign.center,
                  ),
                ),
                onTap: () {
                  setState(() {
                    List<DateTime> dateCollection;
                    List<Appointment> tempAppointments = <Appointment>[];
                    _byMonthDay = _startDate.day;
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
                    if (index == 0) { // Change all since the appointment you choose
                      Appointment apptToAddAgain;
                      for (Appointment firstAppt in _events.appointments!) {
                        if (firstAppt.id == _selectedAppointment!.id) {
                          dateCollection = SfCalendar.getRecurrenceDateTimeCollection(firstAppt.recurrenceRule!, firstAppt.startTime);
                          for (DateTime i in dateCollection) {
                            if (i.microsecondsSinceEpoch >= _selectedAppointment!.startTime.microsecondsSinceEpoch) {
                              if (!firstAppt.recurrenceExceptionDates!.contains(i)) {
                                firstAppt.recurrenceExceptionDates!.add(i);
                              }
                            }
                          }
                          apptToAddAgain = firstAppt;
                          dbHelper.deleteData(firstAppt.id.toString());
                          _events.appointments!.removeAt(_events.appointments!.indexOf(firstAppt));
                          _events.notifyListeners(CalendarDataSourceAction.remove, <Appointment>[]..add(firstAppt));

                          List<String> pieceOfRecurrenceRule = apptToAddAgain.recurrenceRule!.split(';');
                          if(apptToAddAgain.recurrenceExceptionDates!.length != int.parse(pieceOfRecurrenceRule[2].substring(6))){
                            tempAppointments.add(apptToAddAgain);
                            dbHelper.insertData(appointmentToJson(tempAppointments[0], false));
                            _events.appointments!.add(tempAppointments[0]);
                            _events.notifyListeners(CalendarDataSourceAction.add, tempAppointments);
                          }
                          // Delete all appointments since the appointment you choose

                          // Add a new changed appointment
                          addAppointmentInChange(<Appointment>[]);
                          break;
                        }
                      }
                    }
                    else if (index == 1) { // Change only one
                      Appointment apptToAddAgain;
                      for (Appointment firstAppt in _events.appointments!) {
                        if (firstAppt.id == _selectedAppointment!.id) {
                          if (!firstAppt.recurrenceExceptionDates!.contains(_selectedAppointment!.startTime)) {
                            firstAppt.recurrenceExceptionDates!.add(_selectedAppointment!.startTime);
                          }
                          apptToAddAgain = firstAppt;
                          dbHelper.deleteData(firstAppt.id.toString());
                          _events.appointments!.removeAt(_events.appointments!.indexOf(firstAppt));
                          _events.notifyListeners(CalendarDataSourceAction.remove, <Appointment>[]..add(firstAppt));

                          List<String> pieceOfRecurrenceRule = apptToAddAgain.recurrenceRule!.split(';');
                          if(apptToAddAgain.recurrenceExceptionDates!.length != int.parse(pieceOfRecurrenceRule[2].substring(6))){
                            tempAppointments.add(apptToAddAgain);
                            dbHelper.insertData(appointmentToJson(tempAppointments[0], false));
                            _events.appointments!.add(tempAppointments[0]);
                            _events.notifyListeners(CalendarDataSourceAction.add, tempAppointments);
                          }

                          addAppointmentInChange(<Appointment>[]);
                          break;
                        }
                      }
                    }
                  });

                  Future.delayed(const Duration(milliseconds: 200), () {
                    Navigator.pop(context);
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void addAppointmentInChange(List<Appointment> tempAppointments){
    tempAppointments.add(Appointment(
      startTime: _startDate,
      endTime: _endDate,
      color: colorCollection[selectedColorIndex],
      notes: _notes,
      isAllDay: _isAllDay,
      subject: isCanceled ? (_subject == '' ? "${AppLocalizations.of(context)!.noTitle}(-)" : "${_subject}(-)") :
      (_subject == '' ? AppLocalizations.of(context)!.noTitle : _subject),
      recurrenceExceptionDates: <DateTime>[],
      recurrenceRule: _isRecurrence & (_freq == "DAILY")
          ? 'FREQ=$_freq;INTERVAL=$_interval;COUNT=$_count'
          : (_isRecurrence & (_freq == "WEEKLY")
          ? 'FREQ=$_freq;INTERVAL=$_interval;COUNT=$_count;BYDAY=$_byDay'
          : (_isRecurrence & (_freq == "MONTHLY")
          ? 'FREQ=$_freq;INTERVAL=$_interval;COUNT=$_count;BYMONTHDAY=${_startDate.day}'
          : 'FREQ=DAILY;INTERVAL=1;COUNT=1')),
    ));
    dbHelper.insertData(appointmentToJson(tempAppointments[0], false));
    _events.appointments!.add(tempAppointments[0]);
    _events.notifyListeners(CalendarDataSourceAction.add, tempAppointments);
    _selectedAppointment = null;
  }
}
