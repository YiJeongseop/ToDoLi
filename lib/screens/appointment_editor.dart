part of event_calendar;

class AppointmentEditor extends StatefulWidget {
  const AppointmentEditor({super.key});

  @override
  AppointmentEditorState createState() => AppointmentEditorState();
}

// Here's more information.
// https://support.syncfusion.com/kb/article/9667/how-to-design-and-configure-your-appointment-editor-in-flutter-calendar
class AppointmentEditorState extends State<AppointmentEditor> {
  Widget _getAppointmentEditor(BuildContext context) {
    return Container(
      color: Colors.white,
      child: GestureDetector(
        // If you tap anywhere else on the screen, the keyboard disappears
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              leading: const Text(''),
              title: TextField(
                controller: TextEditingController(text: _subject),
                onChanged: (String value) {
                  _subject = value;
                },
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: (AppLocalizations.of(context)!.localeName == 'ko') ? ko26 : en26,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Add title',
                ),
              ),
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: const Icon(
                Icons.access_time,
                color: Colors.black54,
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      'TO-DO',
                      style: en24,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Switch(
                        value: _isAllDay,
                        onChanged: (bool value) {
                          setState(() {
                            _isAllDay = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: const Text(''),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 6,
                    child: GestureDetector(
                      child: (AppLocalizations.of(context)!.localeName == 'ko')
                          ? Text(
                              DateFormat('yyyy년 MMM d일, EEE', 'ko')
                                  .format(_startDate),
                              textAlign: TextAlign.left,
                              style: en18,
                            )
                          : Text(
                                  DateFormat('EEE, MMM dd yyyy')
                                      .format(_startDate),
                                  textAlign: TextAlign.left,
                                  style: en18,
                                ),
                      onTap: () async {
                        final DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2042),
                        );
                        if (date != null && date != _startDate) {
                          setState(
                            () {
                              final Duration difference =
                                  _endDate.difference(_startDate);
                              _startDate = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  _startTime.hour,
                                  _startTime.minute,
                                  0,
                                  0,
                                  0);
                              _endDate = _startDate.add(difference);
                              _endTime = TimeOfDay(
                                  hour: _endDate.hour, minute: _endDate.minute);
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
                            },
                          );
                        }
                      },
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: _isAllDay
                        ? const Text('')
                        : GestureDetector(
                            child: (AppLocalizations.of(context)!.localeName == 'ko')
                                ? Text(
                                    DateFormat('a hh:mm', 'ko')
                                        .format(_startDate),
                                    textAlign: TextAlign.right,
                                    style: en18,
                                  )
                                : Text(
                                        DateFormat('hh:mm a')
                                            .format(_startDate),
                                        textAlign: TextAlign.right,
                                        style: en18,
                                      ),
                            onTap: () async {
                              final TimeOfDay? time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(
                                      hour: _startTime.hour,
                                      minute: _startTime.minute));
                              if (time != null && time != _startTime) {
                                setState(
                                  () {
                                    _startTime = time;
                                    final Duration difference =
                                        _endDate.difference(_startDate);
                                    _startDate = DateTime(
                                        _startDate.year,
                                        _startDate.month,
                                        _startDate.day,
                                        _startTime.hour,
                                        _startTime.minute,
                                        0,
                                        0,
                                        0);
                                    _endDate = _startDate.add(difference);
                                    _endTime = TimeOfDay(
                                        hour: _endDate.hour,
                                        minute: _endDate.minute);
                                  },
                                );
                              }
                            },
                          ),
                  ),
                ],
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: const Text(''),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 6,
                    child: GestureDetector(
                      child: (AppLocalizations.of(context)!.localeName == 'ko')
                          ? Text(
                              DateFormat('yyyy년 MMM d일, EEE', 'ko')
                                  .format(_endDate),
                              textAlign: TextAlign.left,
                              style: en18,
                            )
                          : Text(
                                  DateFormat('EEE, MMM dd yyyy')
                                      .format(_endDate),
                                  textAlign: TextAlign.left,
                                  style: en18,
                                ),
                      onTap: () async {
                        final DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: _endDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        );
                        if (date != null && date != _endDate) {
                          setState(
                            () {
                              final Duration difference = _endDate.difference(_startDate);
                              _endDate = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  _endTime.hour,
                                  _endTime.minute,
                                  0,
                                  0,
                                  0);
                              if (_endDate.isBefore(_startDate)) {
                                _startDate = _endDate.subtract(difference);
                                _startTime = TimeOfDay(
                                    hour: _startDate.hour,
                                    minute: _startDate.minute);
                              }
                            },
                          );
                        }
                      },
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: _isAllDay
                        ? const Text('')
                        : GestureDetector(
                            child: (AppLocalizations.of(context)!.localeName == 'ko')
                                ? Text(
                                    DateFormat('a hh:mm', 'ko').format(_endDate),
                                    textAlign: TextAlign.right,
                                    style: en18,
                                  )
                                :Text(
                                        DateFormat('hh:mm a').format(_endDate),
                                        textAlign: TextAlign.right,
                                        style: en18,
                                      ),
                            onTap: () async {
                              final TimeOfDay? time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(
                                      hour: _endTime.hour,
                                      minute: _endTime.minute));
                              if (time != null && time != _endTime) {
                                setState(() {
                                    _endTime = time;
                                    final Duration difference = _endDate.difference(_startDate);
                                    _endDate = DateTime(
                                        _endDate.year,
                                        _endDate.month,
                                        _endDate.day,
                                        _endTime.hour,
                                        _endTime.minute,
                                        0,
                                        0,
                                        0);
                                    if (_endDate.isBefore(_startDate)) {
                                      _startDate = _endDate.subtract(difference);
                                      _startTime = TimeOfDay(
                                          hour: _startDate.hour,
                                          minute: _startDate.minute);
                                    }
                                  },
                                );
                              }
                            },
                          ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: const Icon(
                Icons.repeat,
                color: Colors.black54,
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.recurrence,
                      style: (AppLocalizations.of(context)!.localeName == 'ko')
                          ? ko26
                          : en22,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Switch(
                        value: _isRecurrence,
                        onChanged: (bool value) {
                          setState(() {
                            _isRecurrence = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isRecurrence)
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 2),
                leading: const Text(''),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DropdownButton(
                      menuMaxHeight: MediaQuery.of(context).size.height / 2.5,
                      value: _count,
                      items: _valueListCount.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(
                            '$item',
                            style: en18,
                          ),
                        );
                      }).toList(),
                      onChanged: (item) {
                        setState(
                          () {
                            _count = item!;
                          },
                        );
                      },
                    ),
                    Text(
                      AppLocalizations.of(context)!.timesEvery,
                      style: (AppLocalizations.of(context)!.localeName == 'ko')
                          ? ko20
                          : en18,
                    ),
                    DropdownButton(
                        menuMaxHeight: MediaQuery.of(context).size.height / 2.5,
                        value: _interval,
                        items: _valueListInterval.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(
                              '$item',
                              style: en18,
                            ),
                          );
                        }).toList(),
                        onChanged: (item) {
                          setState(() {
                            _interval = item!;
                          });
                        }),
                    DropdownButton(
                        value: _freq,
                        items: _valueListFreq.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: (item == 'DAILY')
                                ? Text(AppLocalizations.of(context)!.days,
                                    style: (AppLocalizations.of(context)!.localeName == 'ko')
                                        ? ko20
                                        : en18,
                                  )
                                : ((item == 'WEEKLY')
                                    ? Text(
                                        AppLocalizations.of(context)!.weeks,
                                        style: (AppLocalizations.of(context)!.localeName == 'ko')
                                            ? ko20
                                            : en18,
                                      )
                                    : Text(
                                        AppLocalizations.of(context)!.months,
                                        style: (AppLocalizations.of(context)!.localeName == 'ko')
                                            ? ko20
                                            : en18,
                                      )),
                          );
                        }).toList(),
                        onChanged: (item) {
                          setState(() {
                            _freq = item!;
                          });
                        }),
                    if (AppLocalizations.of(context)!.localeName == 'ko')
                      Text('마다', style: ko20),
                  ],
                ),
              ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: Icon(Icons.lens,
                  color: _colorCollection[_selectedColorIndex]),
              title: Text(
                _colorNames[_selectedColorIndex],
                style: (AppLocalizations.of(context)!.localeName == 'ko') ? ko26 : en22,
              ),
              onTap: () {
                showDialog<Widget>(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return _ColorPicker();
                  },
                ).then((dynamic value) => setState(() {}));
                // Use setState to make the changed color come out right away
              },
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            ListTile(
              contentPadding: const EdgeInsets.all(5),
              leading: const Icon(
                Icons.subject,
                color: Colors.black87,
              ),
              title: TextField(
                controller: TextEditingController(text: _notes),
                onChanged: (String value) {
                  _notes = value;
                },
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: (AppLocalizations.of(context)!.localeName == 'ko') ? ko23 : en20,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Add description',
                ),
              ),
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: _colorCollection[_selectedColorIndex],
          leading: IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                icon: const Icon(
                  Icons.done,
                  color: Colors.white,
                ),
                onPressed: () {
                  final List<Appointment> tempAppointments = <Appointment>[];

                  // Modify an appointment that you have already saved
                  if (_selectedAppointment != null) {
                    List<String>? pieceOfRecurrenceRule = _selectedAppointment?.recurrenceRule?.split(';');

                    // Case where count of the recurrenceRule is not 1 (Recurrence)
                    if (int.parse(pieceOfRecurrenceRule![2].substring(6)) != 1) {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return const RecurrenceChange();
                        },
                      ).then((dynamic value) => setState(() {
                            if (_selectedAppointment == null) {
                              Navigator.pop(context);
                            }
                          }));
                    }

                    // Case where count of the recurrenceRule is 1 (No Recurrence)
                    else if (int.parse(pieceOfRecurrenceRule[2].substring(6)) == 1) {
                      _events.appointments!.removeAt(_events.appointments!.indexOf(_selectedAppointment));
                      _events.notifyListeners(CalendarDataSourceAction.remove, <Appointment>[]..add(_selectedAppointment!));
                      tempAppointments.add(Appointment(
                        startTime: _startDate,
                        endTime: _endDate,
                        color: _colorCollection[_selectedColorIndex],
                        notes: _notes,
                        isAllDay: _isAllDay,
                        subject: _subject == ''
                            ? AppLocalizations.of(context)!.noTitle
                            : _subject,
                        recurrenceExceptionDates: _recurrenceExceptionDates,
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
                      Navigator.pop(context);
                    }
                  }

                  // Save the new appointment
                  else {
                    tempAppointments.add(Appointment(
                      startTime: _startDate,
                      endTime: _endDate,
                      color: _colorCollection[_selectedColorIndex],
                      notes: _notes,
                      isAllDay: _isAllDay,
                      subject: _subject == ''
                          ? AppLocalizations.of(context)!.noTitle
                          : _subject,
                      recurrenceExceptionDates: _recurrenceExceptionDates,
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
                    Navigator.pop(context);
                  }
                },
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
          child: Stack(
            children: [_getAppointmentEditor(context)],
          ),
        ),
        floatingActionButton: _selectedAppointment == null
            ? const Text('')
            : FloatingActionButton(
                onPressed: () {
                  List<String> pieceOfRecurrenceRule = _selectedAppointment!.recurrenceRule!.split(';');

                  // Delete an appointment that does not have a recurrence
                  if (int.parse(pieceOfRecurrenceRule[2].substring(6)) == 1) {
                    _events.appointments!.removeAt(_events.appointments!.indexOf(_selectedAppointment));
                    _events.notifyListeners(CalendarDataSourceAction.remove, <Appointment>[]..add(_selectedAppointment!));
                    _selectedAppointment = null;
                    uploadAppointmentsToDrive(_events.appointments! as List<Appointment>);
                    Navigator.pop(context);
                  }

                  // Delete an appointment that have a recurrence
                  else if (int.parse(pieceOfRecurrenceRule[2].substring(6)) != 1) {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return const RecurrenceDelete();
                      },
                    ).then(
                      (dynamic value) => setState(() {
                        if (_selectedAppointment == null) {
                          Navigator.pop(context);
                        }
                      }),
                    );
                  }
                },
                backgroundColor: Colors.red,
                child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
      ),
    );
  }
}