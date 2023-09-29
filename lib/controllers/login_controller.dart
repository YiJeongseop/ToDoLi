import 'package:get/get.dart';

class LoginController extends GetxController{
  bool _isLogined = false;
  get isLogined => _isLogined;

  void login() {
    _isLogined = true;
    update();
  }

  void logout() {
    _isLogined = false;
    update();
  }
}