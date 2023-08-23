import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoli/screens/calendar.dart';
import 'package:todoli/controllers/color_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:todoli/services/interstitial_ad_widget.dart';
import 'package:todoli/fonts.dart';
import 'package:todoli/widgets/move_url.dart';

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ColorController controller = Get.put(ColorController());
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final List<Color> colorList = [
    const Color(0xFF97D7E1),
    const Color(0xFFE5C1F5),
    const Color(0xFFECB7B2),
    const Color(0xFFECDD83),
    const Color(0xFF8BD39A)
  ];

  User? _user;
  String? _displayName;
  String? _email;

  _saveThemeStatus(int value) async {
    SharedPreferences pref = await _prefs;
    pref.setInt('colorNumber', value);
  }

  @override
  void initState() {
    super.initState();
    loadInterstitialAd();
  }

  Future<String?> _getCurrentUser() async {
    _user = _auth.currentUser;
    _displayName = _user!.displayName;
    _email = _user!.email;
    return _email;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ColorController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          appBar: AppBar(
            iconTheme: const IconThemeData(
              size: 35,
              color: Color(0xFFFFFFFF),
            ),
            backgroundColor: colorList[controller.numberOfColor],
            actions: [
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
          drawer: FutureBuilder(
            future: _getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.hasData == false) {
                return const CircularProgressIndicator();
              } else {
                return Container(
                  width: MediaQuery.of(context).size.width / 1.75,
                  child: Drawer(
                    backgroundColor: const Color(0xFFFFFFFF),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height / 7.2 - 15,
                                    child: UserAccountsDrawerHeader(
                                      decoration: BoxDecoration(color: colorList[controller.numberOfColor]),
                                      margin: const EdgeInsets.only(bottom: 0.0),
                                      accountName: Text(
                                        _displayName!,
                                        style: en22
                                      ),
                                      accountEmail: Text(
                                        _email!,
                                        style: en20,
                                      ),
                                    ),
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
                                      height: MediaQuery.of(context).size.height / 7.2
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                child: ListTile(
                                  leading: const Icon(Icons.logout,
                                      size: 30, color: Colors.black),
                                  title: Text(
                                      AppLocalizations.of(context)!.logout,
                                    style: AppLocalizations.of(context)!.localeName == 'ko' ? ko26 : en28
                                  ),
                                  onTap: () {
                                    googleSignIn.disconnect();
                                    // It makes the pop up to choose between Google accounts always come out.
                                    FirebaseAuth.instance.signOut();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const MoveUrl()
                      ],
                    ),
                  ),
                );
              }
            },
          ),
          body: const SafeArea(
            child: Calendar(),
          ),
        );
      },
    );
  }

  GestureDetector colorButton({
    required Color color,
    required int number,
}){
    return GestureDetector(
      onTap: () {
        callInterstitialAd();
        loadInterstitialAd();
        if(number == 0){
          controller.changeToZero();
        } else if(number == 1) {
          controller.changeToOne();
        } else if(number == 2) {
          controller.changeToTwo();
        } else if(number == 3) {
          controller.changeToThree();
        } else if(number == 4) {
          controller.changeToFour();
        }
        _saveThemeStatus(controller.numberOfColor);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: CircleAvatar(
          radius: 19,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 17,
            backgroundColor: color,
            child: (controller.numberOfColor == number)
                ? const Icon(
              Icons.check,
              size: 24.0,
              color: Colors.white,
            )
                : null,
          ),
        ),
      ),
    );
  }
}
