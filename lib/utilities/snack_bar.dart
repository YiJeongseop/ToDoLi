import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import '../fonts.dart';

void showSnackbar(BuildContext context, String text, int sec) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        textAlign: TextAlign.center,
        style: (AppLocalizations.of(context)!.localeName == 'ko')
            ? ko16.copyWith(color: Theme.of(context).primaryColorLight)
            : en16.copyWith(color: Theme.of(context).primaryColorLight),
      ),
      showCloseIcon: true,
      closeIconColor: Get.isDarkMode ? Colors.black : Colors.white,
      duration: Duration(seconds: sec),
    ),
  );
}
