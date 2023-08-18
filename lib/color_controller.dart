import 'package:get/get.dart';

class ColorController extends GetxController {
  int _numberOfColor = 0;

  get numberOfColor => _numberOfColor;
  set numberOfColor(value) => _numberOfColor = value;

  void changeToZero() {
    _numberOfColor = 0;
    update();
  }

  void changeToOne() {
    _numberOfColor = 1;
    update();
  }

  void changeToTwo() {
    _numberOfColor = 2;
    update();
  }

  void changeToThree() {
    _numberOfColor = 3;
    update();
  }

  void changeToFour() {
    _numberOfColor = 4;
    update();
  }
}
