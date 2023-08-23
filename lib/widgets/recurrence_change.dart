part of '../screens/calendar.dart';

class RecurrenceChange extends StatefulWidget {
  const RecurrenceChange({super.key});

  @override
  State<StatefulWidget> createState() {
    return RecurrenceChangeState();
  }
}

class RecurrenceChangeState extends State<RecurrenceChange> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
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
                tileColor: _colorCollection[_selectedColorIndex],
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1.5),
                  borderRadius: BorderRadius.circular(22),
                ),
                title: Center(
                  child: Text(
                    _changeOptionList[index],
                    style: (AppLocalizations.of(context)!.localeName == 'ko') ? ko24 : en24,
                    textAlign: TextAlign.center,
                  ),
                ),
                onTap: () {
                  setState(() {
                    List<DateTime> dateCollection;
                    List<Appointment> tempAppointments = <Appointment>[];
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
                          _events.appointments!.removeAt(_events.appointments!.indexOf(firstAppt));
                          _events.notifyListeners(CalendarDataSourceAction.remove, <Appointment>[]..add(firstAppt));
                          tempAppointments.add(apptToAddAgain);
                          _events.appointments!.add(tempAppointments[0]);
                          _events.notifyListeners(CalendarDataSourceAction.add, tempAppointments);
                          // Delete all appointments since the appointment you choose

                          // Add a new changed appointment
                          tempAppointments = <Appointment>[];
                          tempAppointments.add(Appointment(
                            startTime: _startDate,
                            endTime: _endDate,
                            color: _colorCollection[_selectedColorIndex],
                            notes: _notes,
                            isAllDay: _isAllDay,
                            subject: _subject == '' ? AppLocalizations.of(context)!.noTitle : _subject,
                            recurrenceExceptionDates: <DateTime>[],
                            recurrenceRule: _isRecurrence & (_freq == "DAILY")
                                ? 'FREQ=$_freq;INTERVAL=$_interval;COUNT=$_count'
                                : (_isRecurrence & (_freq == "WEEKLY")
                                    ? 'FREQ=$_freq;INTERVAL=$_interval;COUNT=$_count;BYDAY=$_byDay'
                                    : (_isRecurrence & (_freq == "MONTHLY")
                                        ? 'FREQ=$_freq;INTERVAL=$_interval;COUNT=$_count;BYMONTHDAY=${_startDate.day}'
                                        : 'FREQ=DAILY;INTERVAL=1;COUNT=1')),
                          ));
                          _events.appointments!.add(tempAppointments[0]);
                          _events.notifyListeners(CalendarDataSourceAction.add, tempAppointments);
                          _selectedAppointment = null;
                          uploadAppointmentsToDrive(_events.appointments! as List<Appointment>);
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
                          _events.appointments!.removeAt(_events.appointments!.indexOf(firstAppt));
                          _events.notifyListeners(CalendarDataSourceAction.remove, <Appointment>[]..add(firstAppt));
                          tempAppointments.add(apptToAddAgain);
                          _events.appointments!.add(tempAppointments[0]);
                          _events.notifyListeners(CalendarDataSourceAction.add, tempAppointments);

                          tempAppointments = <Appointment>[];
                          tempAppointments.add(Appointment(
                            startTime: _startDate,
                            endTime: _endDate,
                            color: _colorCollection[_selectedColorIndex],
                            notes: _notes,
                            isAllDay: _isAllDay,
                            subject: _subject == '' ? AppLocalizations.of(context)!.noTitle : _subject,
                            recurrenceExceptionDates: <DateTime>[],
                            recurrenceRule: _isRecurrence & (_freq == "DAILY")
                                ? 'FREQ=$_freq;INTERVAL=$_interval;COUNT=$_count'
                                : (_isRecurrence & (_freq == "WEEKLY")
                                    ? 'FREQ=$_freq;INTERVAL=$_interval;COUNT=$_count;BYDAY=$_byDay'
                                    : (_isRecurrence & (_freq == "MONTHLY")
                                        ? 'FREQ=$_freq;INTERVAL=$_interval;COUNT=$_count;BYMONTHDAY=${_startDate.day}'
                                        : 'FREQ=DAILY;INTERVAL=1;COUNT=1')),
                          ));
                          _events.appointments!.add(tempAppointments[0]);
                          _events.notifyListeners(CalendarDataSourceAction.add, tempAppointments);
                          _selectedAppointment = null;
                          uploadAppointmentsToDrive(_events.appointments! as List<Appointment>);
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
}
