import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  bool _isLogined = false;
  get isLogined => _isLogined;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  LoginController(){
    _getLoginStatus();
  }

  _getLoginStatus() async {
    var loginStatus = _prefs.then((SharedPreferences prefs) {
      return prefs.getBool('LoginStatus') ?? false;
    });
    _isLogined = await loginStatus;
  }

  _saveLoginStatus(bool value) async {
    SharedPreferences pref = await _prefs;
    pref.setBool('LoginStatus', value);
  }

  void login() {
    _isLogined = true;
    _saveLoginStatus(true);
    update();
  }

  void logout() {
    _isLogined = false;
    _saveLoginStatus(false);
    update();
  }
}
