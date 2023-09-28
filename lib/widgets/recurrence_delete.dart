part of '../screens/calendar.dart';

class RecurrenceDelete extends StatefulWidget {
  const RecurrenceDelete({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RecurrenceDeleteState();
  }
}

class _RecurrenceDeleteState extends State<RecurrenceDelete> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        side: BorderSide(color: Colors.black, width: 2.0),
      ),
      content: SizedBox(
        height: MediaQuery.of(context).size.height / 4,
        width: double.maxFinite,
        child: ListView.builder(
          padding: const EdgeInsets.all(5.0),
          itemCount: 3,
          // Delete all, Delete only one, Delete all since the appointment you choose.
          itemExtent: MediaQuery.of(context).size.height / 12,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: ListTile(
                tileColor: (!Get.isDarkMode) ? colorCollection[selectedColorIndex] : const Color(0xFF505458),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                title: Center(
                  child: Text(
                    _deleteOptionList[index],
                    style: (AppLocalizations.of(context)!.localeName == 'ko')
                        ? ko22.copyWith(color: Theme.of(context).primaryColorDark)
                        : en20.copyWith(color: Theme.of(context).primaryColorDark),
                    textAlign: TextAlign.center,
                  ),
                ),
                onTap: () {
                  setState(() {
                    List<Appointment> tempAppointments = <Appointment>[];
                    List<String> pieceOfRecurrenceRule = _selectedAppointment!.recurrenceRule!.split(';');
                    if (index == 0) { // Delete all
                      if (_selectedAppointment!.appointmentType == AppointmentType.pattern) {
                        dbHelper.deleteData(_selectedAppointment!.id.toString());
                        _events.appointments!.removeAt(_events.appointments!.indexOf(_selectedAppointment));
                        _events.notifyListeners(CalendarDataSourceAction.remove, <Appointment>[]..add(_selectedAppointment!));
                        _selectedAppointment = null;
                      }
                      // Only first appointment of Recurrence Appointments is in _events.appointments.
                      // If you didn't choose the first appointment, you have to find first appointment.
                      else {
                        for (Appointment firstAppt in _events.appointments!) {
                          if (firstAppt.id == _selectedAppointment!.id) {
                            dbHelper.deleteData(_selectedAppointment!.id.toString());
                            _events.appointments!.removeAt(_events.appointments!.indexOf(firstAppt));
                            _events.notifyListeners(CalendarDataSourceAction.remove, <Appointment>[]..add(firstAppt));
                            _selectedAppointment = null;
                            break;
                          }
                        }
                      }
                    }
                    else if (index == 1) { // Delete only one
                      Appointment apptToAddAgain;
                      for (Appointment firstAppt in _events.appointments!) {
                        if (firstAppt.id == _selectedAppointment!.id) {
                          firstAppt.recurrenceExceptionDates!.add(_selectedAppointment!.startTime);
                          apptToAddAgain = firstAppt;
                          dbHelper.deleteData(firstAppt.id.toString());
                          _events.appointments!.removeAt(_events.appointments!.indexOf(firstAppt));
                          _events.notifyListeners(CalendarDataSourceAction.remove, <Appointment>[]..add(firstAppt));

                          if(apptToAddAgain.recurrenceExceptionDates!.length != int.parse(pieceOfRecurrenceRule[2].substring(6))){
                            dbHelper.insertData(appointmentToJson(apptToAddAgain, false));
                            tempAppointments.add(apptToAddAgain);
                            _events.appointments!.add(tempAppointments[0]);
                            _events.notifyListeners(CalendarDataSourceAction.add, tempAppointments);
                          }
                          _selectedAppointment = null;
                          break;
                        }
                      }
                    }
                    else if (index == 2) { // Delete all since the appointment you choose
                      List<DateTime> daysToDelete;
                      Appointment apptToAddAgain;
                      for (Appointment firstAppt in _events.appointments!) {
                        if (firstAppt.id == _selectedAppointment!.id) {
                          daysToDelete = SfCalendar.getRecurrenceDateTimeCollection(firstAppt.recurrenceRule!, firstAppt.startTime);
                          for (DateTime i in daysToDelete) {
                            if (i.microsecondsSinceEpoch >= _selectedAppointment!.startTime.microsecondsSinceEpoch){
                              if (!firstAppt.recurrenceExceptionDates!.contains(i)) {
                                // Do not include date that already exist.
                                firstAppt.recurrenceExceptionDates!.add(i);
                              }
                            }
                          }
                          apptToAddAgain = firstAppt;
                          dbHelper.deleteData(firstAppt.id.toString());
                          _events.appointments!.removeAt(_events.appointments!.indexOf(firstAppt));
                          _events.notifyListeners(CalendarDataSourceAction.remove, <Appointment>[]..add(firstAppt));

                          if(apptToAddAgain.recurrenceExceptionDates!.length != int.parse(pieceOfRecurrenceRule[2].substring(6))){
                            dbHelper.insertData(appointmentToJson(apptToAddAgain, false));
                            tempAppointments.add(apptToAddAgain);
                            _events.appointments!.add(tempAppointments[0]);
                            _events.notifyListeners(CalendarDataSourceAction.add, tempAppointments);
                          }
                          _selectedAppointment = null;
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
