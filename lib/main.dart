import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'controllers/color_controller.dart';
import 'screens/home.dart';
import 'services/interstitial_ad_widget.dart';

// https://developers.google.com/admob/flutter/eu-consent?hl=en
final params = ConsentRequestParameters();
/*  for Test
ConsentDebugSettings debugSettings = ConsentDebugSettings(
    debugGeography: DebugGeography.debugGeographyEea,
    testIdentifiers: ['TEST-DEVICE-HASHED-ID']);
final params = ConsentRequestParameters(consentDebugSettings: debugSettings);
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final ColorController colorController = Get.put(ColorController());
  final String defaultLocale = Platform.localeName;

  _getThemeStatus() async {
    final isLightTheme = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('themeNumber') ?? 1;
    });
    Get.changeThemeMode((await isLightTheme) == 1 ? ThemeMode.light : ThemeMode.dark);
  }

  _getColorStatus() async {
    var number = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('colorNumber') ?? 0;
    });
    colorController.numberOfColor = await number;
  }

  MyApp() {
    _getColorStatus();
    _getThemeStatus();

    ConsentInformation.instance.requestConsentInfoUpdate(params, () async {
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        status = await ConsentInformation.instance.getConsentStatus();
      }
    }, (error) {});
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return GetMaterialApp(
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
      theme: ThemeData.light().copyWith(
          primaryColorLight: Colors.white,
          primaryColorDark: Colors.black,
          secondaryHeaderColor: Colors.black38),
      darkTheme: ThemeData.dark().copyWith(
          primaryColorLight: Colors.black,
          primaryColorDark: const Color(0xFFEBECEC),
          secondaryHeaderColor: Colors.white70),
      home: const Home(),
    );
  }
}
