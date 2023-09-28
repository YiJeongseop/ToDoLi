part of event_calendar;

bool isCanceled = false;

// If there is a '(-)' at the end of the subject, a cancellation line will be created.
void modifyCancellationLine(CalendarLongPressDetails details) {
  if (details.targetElement != CalendarElement.appointment) return;

  if (details.appointments != null && details.appointments!.length == 1){
    final Appointment selectedAppointment = details.appointments![0];
    Appointment? appointmentBeforeMod, appointmentAfterMod;
    List<String> pieceOfRecurrenceRule = selectedAppointment.recurrenceRule!.split(';');
    String subject = '';
    // You have to find selectedAppointment in _events.appointments.
    for(Appointment i in _events.appointments!){
      if(i.id == selectedAppointment.id){
        appointmentBeforeMod = i;
        appointmentAfterMod = appointmentBeforeMod;
        break;
      }
    }

    // selectedAppointment - no recurrence
    if(int.parse(pieceOfRecurrenceRule[2].substring(6)) == 1){
      if(selectedAppointment.subject.length > 2){
        if(selectedAppointment.subject.substring(selectedAppointment.subject.length - 3) == '(-)'){
          appointmentAfterMod!.subject = selectedAppointment.subject.substring(0, selectedAppointment.subject.length - 3);
        } else{
          appointmentAfterMod!.subject = "${selectedAppointment.subject}(-)";
        }
      }
      // If the length is less than 3, there cannot be a (-).
      else if(selectedAppointment.subject.length < 3){
        appointmentAfterMod!.subject = "${selectedAppointment.subject}(-)";
      }

      dbHelper.deleteData(appointmentBeforeMod!.id.toString());

      // If you insert selectedAppointment, An error occurs.
      _events.appointments!.removeAt(_events.appointments!.indexOf(appointmentBeforeMod));
      _events.notifyListeners(CalendarDataSourceAction.remove, <Appointment>[]..add(appointmentBeforeMod));
    }

    // selectedAppointment - recurrence
    else if(int.parse(pieceOfRecurrenceRule[2].substring(6)) != 1){
      // The type of the first appointment among repeated appointments is pattern.
      if(selectedAppointment.appointmentType == AppointmentType.pattern){
        if(selectedAppointment.subject.length > 2){
          if(selectedAppointment.subject.substring(selectedAppointment.subject.length - 3) == '(-)'){
            subject = selectedAppointment.subject.substring(0, selectedAppointment.subject.length - 3);
          } else{
            subject = "${selectedAppointment.subject}(-)";
          }

          appointmentAfterMod = Appointment(
            startTime: selectedAppointment.startTime,
            endTime: selectedAppointment.endTime,
            subject: subject,
            notes: selectedAppointment.notes,
            color: selectedAppointment.color,
            isAllDay: selectedAppointment.isAllDay,
            recurrenceExceptionDates: [],
            recurrenceRule: 'FREQ=DAILY;INTERVAL=1;COUNT=1'
          );
        }
        else if(selectedAppointment.subject.length < 3){
          appointmentAfterMod = Appointment(
              startTime: selectedAppointment.startTime,
              endTime: selectedAppointment.endTime,
              subject: "${selectedAppointment.subject}(-)",
              notes: selectedAppointment.notes,
              color: selectedAppointment.color,
              isAllDay: selectedAppointment.isAllDay,
              recurrenceExceptionDates: [],
              recurrenceRule: 'FREQ=DAILY;INTERVAL=1;COUNT=1'
          );
        }
      }

      // Other types of appointments are occurence.
      else if(selectedAppointment.appointmentType == AppointmentType.occurrence){
        if(selectedAppointment.subject.length > 2){
          if(selectedAppointment.subject.substring(selectedAppointment.subject.length - 3) == '(-)'){
            subject = selectedAppointment.subject.substring(0, selectedAppointment.subject.length - 3);
          } else{
            subject = "${selectedAppointment.subject}(-)";
          }
          appointmentAfterMod = Appointment(
              startTime: selectedAppointment.startTime,
              endTime: selectedAppointment.endTime,
              subject: subject,
              notes: selectedAppointment.notes,
              color: selectedAppointment.color,
              isAllDay: selectedAppointment.isAllDay,
              recurrenceExceptionDates: [],
              recurrenceRule: 'FREQ=DAILY;INTERVAL=1;COUNT=1'
          );
        }
        else if(selectedAppointment.subject.length < 3){
          appointmentAfterMod = Appointment(
              startTime: selectedAppointment.startTime,
              endTime: selectedAppointment.endTime,
              subject: "${selectedAppointment.subject}(-)",
              notes: selectedAppointment.notes,
              color: selectedAppointment.color,
              isAllDay: selectedAppointment.isAllDay,
              recurrenceExceptionDates: [],
              recurrenceRule: 'FREQ=DAILY;INTERVAL=1;COUNT=1'
          );
        }
      }

      dbHelper.deleteData(appointmentBeforeMod!.id.toString());

      Appointment temp = appointmentBeforeMod;
      temp.recurrenceExceptionDates!.add(selectedAppointment.startTime);

      _events.appointments!.removeAt(_events.appointments!.indexOf(appointmentBeforeMod));
      _events.notifyListeners(CalendarDataSourceAction.remove, <Appointment>[]..add(appointmentBeforeMod));

      // If all dates of recurrence appointment are excluded, you do not need to add it.
      if(temp.recurrenceExceptionDates!.length !=
          int.parse(pieceOfRecurrenceRule[2].substring(6))){
        dbHelper.insertData(appointmentToJson(temp, false));
        _events.appointments!.add(temp);
        _events.notifyListeners(CalendarDataSourceAction.add, <Appointment>[]..add(temp));
      }
    }

    dbHelper.insertData(appointmentToJson(appointmentAfterMod!, false));
    _events.appointments!.add(appointmentAfterMod);
    _events.notifyListeners(CalendarDataSourceAction.add, <Appointment>[]..add(appointmentAfterMod));
  }
}