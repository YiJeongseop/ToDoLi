import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:todoli/utilities/snack_bar.dart';
import '../screens/calendar.dart';
import '../controllers/color_controller.dart';
import '../services/interstitial_ad_widget.dart';
import '../fonts.dart';
import '../widgets/guide.dart';

class Home extends StatefulWidget {
  const Home({Key? key,}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

bool isLogined = false;

class _HomeState extends State<Home> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ColorController colorController = Get.put(ColorController());
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  StreamController<ConsentStatus> consentController = StreamController<ConsentStatus>();
  final List<Color> colorList = [
    const Color(0xFF97D7E1),
    const Color(0xFFE5C1F5),
    const Color(0xFFECB7B2),
    const Color(0xFFECDD83),
    const Color(0xFF8BD39A)
  ];
  int snack130_3 = 0;

  _saveColorStatus(int value) async {
    SharedPreferences pref = await _prefs;
    pref.setInt('colorNumber', value);
  }

  _saveThemeStatus(int value) async {
    SharedPreferences pref = await _prefs;
    pref.setInt('themeNumber', value);
  }

  _getSnackStatus() async {
    var number = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('snack130_3') ?? 0;
    });
    snack130_3 = await number;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(snack130_3 == 0){
        showSnackbar(context, AppLocalizations.of(context)!.updateMessage, 15);
        snack130_3 = 1;
        _saveSnackStatus(snack130_3);
      }
    });
  }

  _saveSnackStatus(int value) async {
    SharedPreferences pref = await _prefs;
    pref.setInt('snack130_3', value);
  }

  @override
  void initState() {
    super.initState();
    loadInterstitialAd();
    _getSnackStatus();
    setStatus();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ColorController>(builder: (colorController) {
      return Scaffold(
        onDrawerChanged: (isOpened) async {
          // Without these two lines, (Cancle) Consent button will not come out properly.
          colorController.justUpdate();
          setStatus();
        },
        backgroundColor: Theme.of(context).primaryColorLight,
        appBar: AppBar(
          iconTheme: const IconThemeData(
            size: 35,
            color: Colors.white,
          ),
          backgroundColor: (!Get.isDarkMode)
              ? colorList[colorController.numberOfColor]
              : const Color(0xFF3D4146),
          actions: [
            if (!Get.isDarkMode)
              Row(
                children: [
                  colorButton(color: colorList[0], number: 0),
                  colorButton(color: colorList[1], number: 1),
                  colorButton(color: colorList[2], number: 2),
                  colorButton(color: colorList[3], number: 3),
                  colorButton(color: colorList[4], number: 4),
                ],
              )
          ],
          elevation: 0.0,
        ),
        drawer: SizedBox(
              width: MediaQuery.of(context).size.width / 1.75,
              child: Drawer(
                backgroundColor: (!Get.isDarkMode) ? Colors.white : const Color(0xFF505458),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          Stack(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 7.2 - 15,
                                child: StreamBuilder<User?>(
                                  stream: _auth.authStateChanges(),
                                  builder: (context, snapshot) {
                                    if(snapshot.connectionState == ConnectionState.active && !snapshot.hasData){
                                      isLogined = false;
                                    }
                                    if(snapshot.hasData || isLogined){
                                      isLogined = true;
                                      return userAccountsDrawerHeader(displayName: _auth.currentUser!.displayName!,
                                      email: _auth.currentUser!.email!);
                                    } else{
                                      return userAccountsDrawerHeader(displayName: 'ToDoLi',
                                          email: AppLocalizations.of(context)!.youAreNotLoggedIn);
                                    }
                                  }
                                )
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1.5),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(10.0),
                                      bottomRight: Radius.circular(10.0),
                                    ),
                                    color: Colors.transparent,
                                  ),
                                  height: MediaQuery.of(context).size.height / 7.2),
                            ],
                          ),
                          StreamBuilder<User?>(
                            stream: _auth.authStateChanges(),
                            builder: (context, snapshot) {
                              if(snapshot.hasData || isLogined){
                                return ListTile(
                                  leading: Icon(Icons.logout, size: 30,
                                      color: Theme.of(context).primaryColorDark),
                                  title: Text(
                                    AppLocalizations.of(context)!.logout,
                                    style: AppLocalizations.of(context)!.localeName == 'ko'
                                        ? ko24.copyWith(color: Theme.of(context).primaryColorDark)
                                        : en24.copyWith(color: Theme.of(context).primaryColorDark),
                                  ),
                                  onTap: () {
                                    googleSignIn.disconnect();
                                    // It makes the pop up to choose between Google accounts always come out.
                                    _auth.signOut();
                                    isLogined = false;
                                    Get.back();
                                  },
                                );
                              } else {
                                return ListTile(
                                    leading: Icon(Icons.login, size: 30,
                                        color: Theme.of(context).primaryColorDark),
                                    title: Text(
                                      AppLocalizations.of(context)!.login,
                                      style: AppLocalizations.of(context)!.localeName == 'ko'
                                          ? ko24.copyWith(color: Theme.of(context).primaryColorDark)
                                          : en24.copyWith(color: Theme.of(context).primaryColorDark),
                                    ),
                                    onTap: () {
                                      loginDialog(context);
                                    },
                                  );
                              }
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.library_books_outlined,
                              size: 30,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            title: Text(
                              AppLocalizations.of(context)!.guide,
                                style: AppLocalizations.of(context)!.localeName == 'ko'
                                    ? ko24.copyWith(color: Theme.of(context).primaryColorDark)
                                    : en24.copyWith(color: Theme.of(context).primaryColorDark),
                            ),
                            onTap: () {
                              guideDialog(context);
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.delete_forever_outlined,
                              size: 30,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            title: Text(
                                AppLocalizations.of(context)!.deleteTheEntireSchedule,
                                style: AppLocalizations.of(context)!.localeName == 'ko'
                                    ? ko20.copyWith(color: Theme.of(context).primaryColorDark)
                                    : en20.copyWith(color: Theme.of(context).primaryColorDark),
                            ),
                            onTap: () {
                              deleteDialog(context);
                            },
                          ),
                          StreamBuilder<User?>(
                            stream: _auth.authStateChanges(),
                            builder: (context, snapshot) {
                              if(snapshot.hasData || isLogined){
                                return ListTile(
                                  leading: Icon(
                                    Icons.upload,
                                    size: 30,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  title: Text(
                                    AppLocalizations.of(context)!.saveToDrive,
                                    style: AppLocalizations.of(context)!.localeName == 'ko'
                                        ? ko20.copyWith(color: Theme.of(context).primaryColorDark)
                                        : en20.copyWith(color: Theme.of(context).primaryColorDark),
                                  ),
                                  onTap: () {
                                    driveDialog(context, true);
                                  },
                                );
                              } else {
                                return const SizedBox(height: 0,);
                              }
                            },
                          ),
                          StreamBuilder<User?>(
                            stream: _auth.authStateChanges(),
                            builder: (context, snapshot) {
                              print(status);
                              if(snapshot.hasData || isLogined){
                                return ListTile(
                                  leading: Icon(
                                    Icons.download,
                                    size: 30,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  title: Text(
                                    AppLocalizations.of(context)!.loadFromDrive,
                                    style: AppLocalizations.of(context)!.localeName == 'ko'
                                        ? ko20.copyWith(color: Theme.of(context).primaryColorDark)
                                        : en20.copyWith(color: Theme.of(context).primaryColorDark),
                                  ),
                                  onTap: () {
                                    driveDialog(context, false);
                                  },
                                );
                              } else {
                                return const SizedBox(height: 0,);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: (!Get.isDarkMode)
                          ? const Icon(Icons.dark_mode, size: 30, color: Colors.black)
                          : const Icon(Icons.light_mode, size: 30, color: Colors.white),
                      title: (!Get.isDarkMode)
                          ? Text(
                              AppLocalizations.of(context)!.darkTheme,
                              style: AppLocalizations.of(context)!.localeName == 'ko'
                                  ? ko24.copyWith(color: Theme.of(context).primaryColorDark)
                                  : en22.copyWith(color: Theme.of(context).primaryColorDark),
                            )
                          : Text(
                              AppLocalizations.of(context)!.lightTheme,
                              style: AppLocalizations.of(context)!.localeName == 'ko'
                                  ? ko24.copyWith(color: Theme.of(context).primaryColorDark)
                                  : en22.copyWith(color: Theme.of(context).primaryColorDark),
                            ),
                      onTap: () {
                        if (Get.isDarkMode) {
                          _saveThemeStatus(1);
                        } else {
                          _saveThemeStatus(0);
                        }
                        Get.changeThemeMode(
                          Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                        );
                        callInterstitialAd();
                        loadInterstitialAd();
                        Get.back();
                      },
                    ),
                    if(status == ConsentStatus.required)
                      ListTile(
                        leading: Icon(
                          Icons.ads_click,
                          size: 30,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        title: Text(
                          "Consent for personalized ads",
                          style: en18.copyWith(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        onTap: () {
                          consentPersonalizedAds();
                        },
                      ),
                    if(status == ConsentStatus.obtained)
                      ListTile(
                        leading: Icon(
                          Icons.ads_click,
                          size: 30,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        title: Text(
                          "Cancle Consent for personalized ads",
                          style: en18.copyWith(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        onTap: () {
                          cancelConsentPersonalizedAds();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Cancel complete',
                                style: en20.copyWith(color: Theme.of(context).primaryColorDark),
                                textAlign: TextAlign.center,
                              ),
                              duration: const Duration(seconds: 3),
                              backgroundColor: Theme.of(context).primaryColorLight,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
        body: const SafeArea(
          child: Calendar(),
        ),
      );
    });
  }

  UserAccountsDrawerHeader userAccountsDrawerHeader({
    required String displayName,
    required String email,
  }){
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
          color: (!Get.isDarkMode)
              ? colorList[colorController.numberOfColor]
              : const Color(0xFF3D4146)),
      margin: const EdgeInsets.only(bottom: 0.0),
      accountName: Text(
        displayName,
        style: (AppLocalizations.of(context)!.localeName == 'ko')
            ? GoogleFonts.poorStory(
            fontSize: 27,
            color: Theme.of(context).primaryColorDark,
            fontWeight: FontWeight.w500)
            : en24.copyWith(color: Theme.of(context).primaryColorDark),
      ),
      accountEmail: Text(
        email,
        style: (AppLocalizations.of(context)!.localeName == 'ko')
            ? GoogleFonts.poorStory(
            fontSize: 20,
            color: Theme.of(context).primaryColorDark,
            fontWeight: FontWeight.w500)
            : en20.copyWith(color: Theme.of(context).primaryColorDark),
      ),
    );
  }

  GestureDetector colorButton({
    required Color color,
    required int number,
  }) {
    return GestureDetector(
      onTap: () {
        callInterstitialAd();
        loadInterstitialAd();
        if (number == 0) {
          colorController.changeToZero();
        } else if (number == 1) {
          colorController.changeToOne();
        } else if (number == 2) {
          colorController.changeToTwo();
        } else if (number == 3) {
          colorController.changeToThree();
        } else if (number == 4) {
          colorController.changeToFour();
        }
        _saveColorStatus(colorController.numberOfColor);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: CircleAvatar(
          radius: 19,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 17,
            backgroundColor: color,
            child: (colorController.numberOfColor == number)
                ? const Icon(Icons.check, size: 24.0, color: Colors.white)
                : null,
          ),
        ),
      ),
    );
  }
}
