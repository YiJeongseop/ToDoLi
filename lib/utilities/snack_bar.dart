import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import '../fonts.dart';

void showSnackbar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        (AppLocalizations.of(context)!.localeName == 'ko')
            ? '업데이트 후에 저장하신 일정들이 사라지셨다면, 로그인하셔서 불러오기(구글 드라이브)를 클릭해주세요!'
            : 'If your saved schedule has disappeared after the update, please login and click Load(Google Drive)!',
        textAlign: TextAlign.center,
        style: (AppLocalizations.of(context)!.localeName == 'ko')
            ? ko16.copyWith(color: Theme.of(context).primaryColorLight)
            : en16.copyWith(color: Theme.of(context).primaryColorLight),
      ),
      showCloseIcon: true,
      closeIconColor: Get.isDarkMode ? Colors.black : Colors.white,
      duration: const Duration(seconds: 15),
    ),
  );
}
