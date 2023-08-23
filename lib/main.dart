import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:todoli/screens/home.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoli/controllers/color_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

import 'screens/calendar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final ColorController controller = Get.put(ColorController());
  final String defaultLocale = Platform.localeName;

  _getThemeStatus() async {
    var number = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('colorNumber') ?? 0;
    });
    controller.numberOfColor = (await number);
  }

  MyApp() {
    _getThemeStatus();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // https://help.syncfusion.com/flutter/calendar/localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
      ],
      locale: (defaultLocale == 'ko_KR') ? const Locale('ko') : const Locale('en'),
      debugShowCheckedModeBanner: false,
      title: 'ToDoLi',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const LoginPage();
          } else {
            return const Home();
          }
        },
      ),
    );
  }
}
