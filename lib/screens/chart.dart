part of event_calendar;

class Chart extends StatefulWidget {
  const Chart({Key? key, required this.appBarColor}) : super(key: key);

  final Color appBarColor;

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  Future<List<List<dynamic>>> getTodoListData() async {
    List<List<dynamic>> doneCountPerDay = [
      [0, 0, AppLocalizations.of(context)!.total], // Total - Done, Not done
      [0, 0, AppLocalizations.of(context)!.mon], // Monday
      [0, 0, AppLocalizations.of(context)!.tue], // Tuesday
      [0, 0, AppLocalizations.of(context)!.wed], // Wednesday
      [0, 0, AppLocalizations.of(context)!.thu], // Thursday
      [0, 0, AppLocalizations.of(context)!.fri], // Friday
      [0, 0, AppLocalizations.of(context)!.sat], // Saturday
      [0, 0, AppLocalizations.of(context)!.sun], // Sunday
    ];

    for (Appointment i in _events.appointments!) {
      if (i.isAllDay) {
        List<String> pieceOfRecurrenceRule = i.recurrenceRule!.split(';');

        if (int.parse(pieceOfRecurrenceRule[2].substring(6)) != 1) {
          int numberToAdd = int.parse(pieceOfRecurrenceRule[2].substring(6)) -
              i.recurrenceExceptionDates!.length;
          List<DateTime> dateCollection =
              SfCalendar.getRecurrenceDateTimeCollection(
                  i.recurrenceRule!, i.startTime);
          if (i.subject.length > 2) {
            int done =
                (i.subject.substring(i.subject.length - 3) == '(-)') ? 0 : 1;
            doneCountPerDay[0][done] += numberToAdd;
            for (DateTime j in dateCollection) {
              if (!i.recurrenceExceptionDates!.contains(j)) {
                doneCountPerDay[j.weekday][done] += 1;
              }
            }
          } else {
            doneCountPerDay[0][1] += numberToAdd;
            for (DateTime j in dateCollection) {
              if (!i.recurrenceExceptionDates!.contains(j)) {
                doneCountPerDay[j.weekday][1] += 1;
              }
            }
          }
        } else {
          // No recurrence
          if (i.subject.length > 2) {
            int done =
                (i.subject.substring(i.subject.length - 3) == '(-)') ? 0 : 1;
            doneCountPerDay[0][done] += 1;
            doneCountPerDay[i.startTime.weekday][done] += 1;
          } else {
            doneCountPerDay[0][1] += 1;
            doneCountPerDay[i.startTime.weekday][1] += 1;
          }
        }
      }
    }

    return doneCountPerDay;
  }

  @override
  Widget build(BuildContext context) {
    Color appBarColor = widget.appBarColor;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          size: 35,
          color: Color(0xFFFFFFFF),
        ),
        backgroundColor: appBarColor,
        elevation: 0.0,
      ),
      body: FutureBuilder<List<List<dynamic>>>(
        future: getTodoListData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final data = snapshot.data;
            return Column(
              children: [
                Flexible(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    // https://help.syncfusion.com/winui/cartesian-charts/overview
                    child: SfCartesianChart(
                      legend: Legend(
                        position: LegendPosition.bottom,
                        isVisible: true,
                        textStyle: AppLocalizations.of(context)!.localeName == 'ko' ? ko20 : en18,
                      ),
                      primaryXAxis: CategoryAxis(
                        labelStyle: AppLocalizations.of(context)!.localeName == 'ko' ? ko20 : en18,
                      ),
                      primaryYAxis: NumericAxis(
                        labelStyle: AppLocalizations.of(context)!.localeName == 'ko' ? ko20 : en18,
                      ),
                      axes: <ChartAxis>[
                        NumericAxis(opposedPosition: true),
                      ],
                      series: <ChartSeries>[
                        ColumnSeries<List<dynamic>, String>(
                            dataSource: data!,
                            name: AppLocalizations.of(context)!.done,
                            xValueMapper: (List<dynamic> value, _) =>
                                value[2].toString(),
                            yValueMapper: (List<dynamic> value, _) =>
                                value[0] as int,
                            yAxisName: 'Primary Y-Axis',
                            gradient: const LinearGradient(
                                colors: [Color(0xA418B2BE), Color(0x9418B2BE)],
                                stops: [0.1, 0.9])),
                        ColumnSeries<List<dynamic>, String>(
                            dataSource: data,
                            name: AppLocalizations.of(context)!.notDone,
                            xValueMapper: (List<dynamic> value, _) =>
                                value[2].toString(),
                            yValueMapper: (List<dynamic> value, _) =>
                                value[1] as int,
                            yAxisName: 'Secondary Y-Axis',
                            gradient: const LinearGradient(
                                colors: [Color(0xCFFD82F7), Color(0x9FFD82F7)],
                                stops: [0.1, 0.9]))
                      ],
                    ),
                  ),
                ),
                Flexible(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ChartRow(data: data, num: 0, num2: 4),
                          ChartRow(data: data, num: 1, num2: 5),
                          ChartRow(data: data, num: 2, num2: 6),
                          ChartRow(data: data, num: 3, num2: 7),
                        ],
                      ),
                    )),
              ],
            );
          }
        },
      ),
    );
  }
}

class ChartRow extends StatelessWidget {
  const ChartRow(
      {Key? key, required this.data, required this.num, required this.num2})
      : super(key: key);

  final data, num, num2;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 30),
          padding: const EdgeInsets.all(3.0),
          width: MediaQuery.of(context).size.width / 2.5,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              color: (data[num][2] == AppLocalizations.of(context)!.total)
                  ? const Color(0xFFFFE6CC)
                  : const Color(0xF6FFF4E4),
              border: Border.all(color: Colors.black),),
          child: Text(
            "${data[num][2]}: ${data[num][0]}/${data[num][0] + data[num][1]}",
            style: AppLocalizations.of(context)!.localeName == 'ko' ? ko22 : en20,
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 30),
          padding: const EdgeInsets.all(3.0),
          width: MediaQuery.of(context).size.width / 2.5,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            color: const Color(0xF6FFF4E4),
            border: Border.all(
              color: Colors.black,
            ),
          ),
          child: Text(
            "${data[num2][2]}: ${data[num2][0]}/${data[num2][0] + data[num2][1]}",
            style: AppLocalizations.of(context)!.localeName == 'ko' ? ko22 : en20,
          ),
        ),
      ],
    );
  }
}
