import 'package:get/get.dart';

enum RouteName {MY, PLAY, TEAM, ETC}

class AppController extends GetxController {
  static AppController get to => Get.find();
  RxInt currentIndex = 1.obs;

  void changePageIndex(int index) {
    currentIndex(index);
  }
} 