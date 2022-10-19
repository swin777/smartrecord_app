import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:pausable_timer/pausable_timer.dart';
import 'package:smartrecord_app/src/mapEngine/drawRoute.dart';
import 'package:smartrecord_app/src/model/playInfo.dart';
import 'package:smartrecord_app/src/model/route/route_info.dart';
import 'package:smartrecord_app/src/model/route/tbt_info.dart';
import 'package:smartrecord_app/src/repository/routeRepository.dart';
import 'package:wakelock/wakelock.dart';
import 'dart:async';

class PlayerController extends GetxController {
  static PlayerController get to => Get.find();

  RxInt cnt = 12.obs;
  Rx<DateTime> dt = DateTime.now().obs;
  RxBool playMode = false.obs;
  RxBool simulationMode = false.obs;
  RxBool driverMode = false.obs;
  PausableTimer? timer;
  RouteInfo? routeInfo;
  RxString roadName = "".obs;
  RxString tbtUrl = "".obs;
  RxString farTbtUrl = "".obs;
  RxString tbtName = "".obs;
  RxBool routeComplate = false.obs;
  //Rx<PlayData>? playData = PlayData().obs;
  Rx<PlayData>? playData = Rx<PlayData>(PlayData());

  //late List<CustomPoint> smoothRoute; //smooth된 utmk
  late DrawRoute drawRoute;

  ScrollController scrollController = ScrollController();
  late MaplibreMapController maplibreMapController;

  StreamSubscription<Position>? streamSubscription;
  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 100,
  );

  @override
  void onInit() {
    _playListLoad();
    _event();
    super.onInit(); 
  }

  @override
  void onClose() {
    super.onClose();
  }

  void _event() {
    scrollController.addListener(() {
      if(scrollController.position.pixels == scrollController.position.maxScrollExtent){
        _playListLoad();
      }
    });
  } 

  void _playListLoad() async{}

  void routeExecute() async {
    RouteInfo routeInfo = await getRoute();
    drawRoute = DrawRoute(maplibreMapController: maplibreMapController, routeInfo: routeInfo);
    routeComplate.value = true;
  }

  Future<RouteInfo> getRoute() async{
    routeInfo = await RouteResitory.to.getRoute(playData!.value.startLat!, playData!.value.startLng!, playData!.value.endLat!, playData!.value.endLng!);
    return Future.value(routeInfo);
  }

  void playAndStop() {
    if(driverMode.value){
      driver();
    }else{
      if (playMode.value) {
        timer!.pause();
      }else{
        if (timer == null) {
          timer = PausableTimer(const Duration(milliseconds: 100), () async {
            int number = timer!.tick;
            if (number == drawRoute.smoothRoute.length - 1) {
              timer!.cancel();
            }
            if(drawRoute.smoothRoute[number].roadName!=null && drawRoute.smoothRoute[number].roadName!=roadName.value){
              roadName.value = drawRoute.smoothRoute[number].roadName!;
            }
            if(drawRoute.smoothRoute[number].tbt!=null && drawRoute.smoothRoute[number].tbt!.type!=998){
              tbtUrl('https://map.gis.kt.com/images/tbt-images/${tbtIcon['type_${drawRoute.smoothRoute[number].tbt!.type}']}.png');
              tbtName(drawRoute.smoothRoute[number].tbt!.tbtName);
            }
            if(drawRoute.smoothRoute[number].farTbt!=null && drawRoute.smoothRoute[number].farTbt!.type!=998){
              farTbtUrl('https://map.gis.kt.com/images/tbt-images/${tbtIcon['type_${drawRoute.smoothRoute[number].farTbt!.type}']}.png');
            }

            drawRoute.drawBySeq(number);
          
            timer!.reset();
            timer!.start();
          })..start();
        } else {
          timer!.start();
        }
      }
    }
    playMode.value = !playMode.value;
  }

  void driver(){
    _determinePosition().then((value) {
      Wakelock.enable();
      streamSubscription = Geolocator.getPositionStream(locationSettings:locationSettings).listen((Position event) async{
        if(event.speed > 0 && playMode.value){
          Get.snackbar('GPS', '${event.latitude} : ${event.longitude}', snackPosition: SnackPosition.TOP);
          drawRoute.drawByGPS(LatLng(event.latitude, event.longitude));
        }
      });
    }).onError((error, stackTrace) {});
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    return await Geolocator.getCurrentPosition();
  }
}