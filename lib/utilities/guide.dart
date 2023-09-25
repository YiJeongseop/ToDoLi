import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';

import '../fonts.dart';


void guideDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: (!Get.isDarkMode) ? Colors.white : const Color(0xFF505458),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'images/cancellation_line_guide.png',
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width * 0.6,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(AppLocalizations.of(context)!.guideText,
                style: AppLocalizations.of(context)!.localeName == 'ko'
                    ? ko18.copyWith(color: Theme.of(context).primaryColorDark,)
                    : en18.copyWith(color: Theme.of(context).primaryColorDark,)),
          ],
        ),
      );
    },
  );
}
