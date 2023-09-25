part of event_calendar;


void deleteDialog(BuildContext context){
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: (!Get.isDarkMode) ? Colors.white : const Color(0xFF505458),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
          content: Text(AppLocalizations.of(context)!.deleteAlert,
            textAlign: TextAlign.center,
            style: AppLocalizations.of(context)!.localeName == 'ko'
                  ? ko22.copyWith(color: Theme.of(context).primaryColorDark,)
                  : en22.copyWith(color: Theme.of(context).primaryColorDark,)),
          actions: [
            TextButton(
                onPressed: () {
                  _events.appointments!.clear();
                  _events.notifyListeners(CalendarDataSourceAction.reset, _events.appointments!);
                  uploadAppointmentsToDrive(_events.appointments! as List<Appointment>);
                  Future.delayed(const Duration(milliseconds: 200), () {
                    Navigator.pop(context);
                  });
                },
                child: Text(AppLocalizations.of(context)!.check,
                    style: AppLocalizations.of(context)!.localeName == 'ko'
                        ? ko20.copyWith(color: Theme.of(context).primaryColorDark,)
                        : en18.copyWith(color: Theme.of(context).primaryColorDark,))),
            TextButton(
                onPressed: () {
                  Future.delayed(const Duration(milliseconds: 200), () {
                    Navigator.pop(context);
                  });
                },
                child: Text(AppLocalizations.of(context)!.cancle,
                    style: AppLocalizations.of(context)!.localeName == 'ko'
                        ? ko20.copyWith(color: Theme.of(context).primaryColorDark,)
                        : en18.copyWith(color: Theme.of(context).primaryColorDark,))),
          ],
        );
      }
  );
}