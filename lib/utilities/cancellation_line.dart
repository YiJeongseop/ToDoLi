part of event_calendar;

// If there is a '(-)' at the end of the subject, a cancellation line will be created.
void modifyCancellationLine(CalendarLongPressDetails details) {
  if (details.targetElement != CalendarElement.appointment) return;

  if (details.appointments != null && details.appointments!.length == 1){
    final Appointment selectedAppointment = details.appointments![0];
    Appointment? appointmentBeforeMod, appointmentAfterMod;
    List<String> pieceOfRecurrenceRule = selectedAppointment.recurrenceRule!.split(';');
    String subject = '';
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
      else if(selectedAppointment.subject.length < 3){
        appointmentAfterMod!.subject = "${selectedAppointment.subject}(-)";
      }

      // If you insert selectedAppointment, An error occurs. ( 35 Line )
      // You have to find selectedAppointment in _events.appointments and put it in. ( 12 Line )
      _events.appointments!.removeAt(_events.appointments!.indexOf(appointmentBeforeMod));
      _events.notifyListeners(CalendarDataSourceAction.remove, <Appointment>[]..add(appointmentBeforeMod!));
    }

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
              subject: "${_selectedAppointment!.subject}(-)",
              notes: selectedAppointment.notes,
              color: selectedAppointment.color,
              isAllDay: selectedAppointment.isAllDay,
              recurrenceExceptionDates: [],
              recurrenceRule: 'FREQ=DAILY;INTERVAL=1;COUNT=1'
          );
        }
      }

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

      Appointment temp = appointmentBeforeMod!;
      temp.recurrenceExceptionDates!.add(selectedAppointment.startTime);

      _events.appointments!.removeAt(_events.appointments!.indexOf(appointmentBeforeMod));
      _events.notifyListeners(CalendarDataSourceAction.remove, <Appointment>[]..add(appointmentBeforeMod));
      _events.appointments!.add(temp);
      _events.notifyListeners(CalendarDataSourceAction.add, <Appointment>[]..add(temp));
    }

    _events.appointments!.add(appointmentAfterMod);
    _events.notifyListeners(CalendarDataSourceAction.add, <Appointment>[]..add(appointmentAfterMod!));
    uploadAppointmentsToDrive(_events.appointments! as List<Appointment>);
  }
}