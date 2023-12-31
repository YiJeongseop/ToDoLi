part of event_calendar;

void driveDialog(BuildContext context, bool isUpload) {
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: (!Get.isDarkMode) ? Colors.white : const Color(0xFF505458),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
          content: Text(
            isUpload ? AppLocalizations.of(context)!.saveToDriveQuestion : AppLocalizations.of(context)!.loadFromDriveQuestion,
            textAlign: TextAlign.center,
            style: AppLocalizations.of(context)!.localeName == 'ko'
                ? ko22.copyWith(color: Theme.of(context).primaryColorDark)
                : en22.copyWith(color: Theme.of(context).primaryColorDark),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (isUpload) {
                  uploadAppointmentsToDrive(_events.appointments! as List<Appointment>, context);
                } else {
                  Get.dialog(const LoadingOverlay(), barrierDismissible: false);

                  List<Appointment>? temp = await downloadAppointmentsFromDrive(context);
                  if(temp == null){
                    Get.back();
                  } else{
                    _events.appointments!.clear();

                    for (int i = 0; i < temp.length; i++) {
                      _events.appointments!.add(temp[i]);
                    }
                    _events.notifyListeners(CalendarDataSourceAction.add, temp);

                    dbHelper.insertAllData(temp);
                    Get.back();
                  }
                }
                Future.delayed(const Duration(milliseconds: 200), () {
                  Navigator.pop(context);
                });
              },
              child: Text(
                AppLocalizations.of(context)!.check,
                style: AppLocalizations.of(context)!.localeName == 'ko'
                    ? ko20.copyWith(color: Theme.of(context).primaryColorDark)
                    : en18.copyWith(color: Theme.of(context).primaryColorDark),
              ),
            ),
            TextButton(
              onPressed: () {
                Future.delayed(const Duration(milliseconds: 200), () {
                  Navigator.pop(context);
                });
              },
              child: Text(
                AppLocalizations.of(context)!.cancle,
                style: AppLocalizations.of(context)!.localeName == 'ko'
                    ? ko20.copyWith(color: Theme.of(context).primaryColorDark)
                    : en18.copyWith(color: Theme.of(context).primaryColorDark),
              ),
            ),
          ],
        );
      },
  );
}
