import 'package:get/get.dart';
import 'package:smartrecord_app/src/controller/app_controller.dart';
import 'package:smartrecord_app/src/repository/routeRepository.dart';


class InitBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AppController());
    Get.put(RouteResitory(), permanent: true);
  }
}

