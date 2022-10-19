import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:pausable_timer/pausable_timer.dart';
import 'package:proj4dart/proj4dart.dart';
import 'package:smartrecord_app/src/model/playInfo.dart';
import 'package:smartrecord_app/src/model/route/custom_point.dart';
import 'package:smartrecord_app/src/model/route/route_info.dart';
import 'package:smartrecord_app/src/model/route/tbt_info.dart';
import 'package:smartrecord_app/src/repository/routeRepository.dart';
import 'package:smartrecord_app/src/utils/projection.dart';

class PlayerController extends GetxController {
  static PlayerController get to => Get.find();

  RxInt cnt = 12.obs;
  Rx<DateTime> dt = DateTime.now().obs;
  RxBool playMode = false.obs;
  RxBool simulationMode = false.obs;
  PausableTimer? timer;
  RouteInfo? routeInfo;
  RxString roadName = "".obs;
  RxString tbtUrl = "".obs;
  RxString farTbtUrl = "".obs;
  RxString tbtName = "".obs;
  RxBool routeComplate = false.obs;
  Rx<PlayData>? playData = PlayData().obs;

  late List<CustomPoint> smoothRoute; //smooth된 utmk
  late List<CustomPoint> latLngsmoothRoute; //smooth된 utmk에서 위경도로 변경
  late List<CustomPoint> latLngRoute; //utmk에서 위경도로 변경
  late List<List<double>> latalngList;
  final _line = {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": []
        }
      }
    ]
  };
  final _lineArrow = {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": []
        }
      }
    ]
  };
  final _line2 = {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": []
        }
      }
    ]
  };

  ScrollController scrollController = ScrollController();
  late MaplibreMapController maplibreMapController;

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

  void drawRoute() async {
    RouteInfo routeInfo = await getRoute();
    routeComplate.value = true;

    (_line['features'] as List)[0]['geometry']['coordinates'] = latalngList;
    (_lineArrow['features'] as List)[0]['geometry']['coordinates'] = latalngList;
    
    await maplibreMapController.addGeoJsonSource("routeOutLine", _line);
    await maplibreMapController.addLineLayer(
      "routeOutLine", "routeOutLineLayer",
      LineLayerProperties(
        lineColor: const Color(0xffffffff).toHexStringRGB(),
        lineWidth: 16,
      ),
      // LineLayerProperties.fromJson(
      //   {
      //     // 'line-gradient': [
      //     //   'interpolate',
      //     //   ['linear'],
      //     //   ['line-progress'],
      //     //   0,'rgba(0, 0, 0, 0.4)',
      //     //   0.01999,'rgba(0, 0, 0, 0.4)',
      //     //   0.019991,'rgba(255, 0, 0, 1)',
          
      //     //   0.1,'rgba(255, 0, 0, 1)'
      //     // ],
      //     "line-width" : 10,
      //     "line-dasharray":[0.5,1.5],
      //   }
      // ),
    );

    await maplibreMapController.addGeoJsonSource("route", _line);
    await maplibreMapController.addLineLayer(
      "route", "routeLineLayer",
      LineLayerProperties(
        lineColor: const Color(0xff2a3f85).toHexStringRGB(),
        lineWidth: 10,
      ),
      // LineLayerProperties.fromJson({
      //   "line-width" : 10,
      //   "line-color" : 'red',
      //   "line-dasharray": [3, 3],
      // })
      // LineLayerProperties.fromJson(
      //   {
      //     // 'line-gradient': [
      //     //   'interpolate',
      //     //   ['linear'],
      //     //   ['line-progress'],
      //     //   0,'rgba(0, 0, 0, 0.4)',
      //     //   0.01999,'rgba(0, 0, 0, 0.4)',
      //     //   0.019991,'rgba(255, 0, 0, 1)',
          
      //     //   0.1,'rgba(255, 0, 0, 1)'
      //     // ],
      //     "line-width" : 10,
      //     "line-dasharray":[0.5,1.5],
      //     "line-pattern": "ico_001"
      //   }
      // ),
    );
    
    await maplibreMapController.addGeoJsonSource("routeArrow", _line);
    await maplibreMapController.addSymbolLayer(
      "routeArrow", "routeArrowLayer",
      const SymbolLayerProperties(
        symbolPlacement: "line",
        symbolSpacing: 250,
        iconImage: "ico_015",
        iconSize: 0.6,
        //iconOpacity: 0.8,
        iconIgnorePlacement:true
      ),
    );

    // //(_line2['features'] as List)[0]['geometry']['coordinates'] = [[]];
    // await maplibreMapController.addGeoJsonSource("routePast", _line2);
    // await maplibreMapController.addLineLayer(
    //   "routePast", "routeLinePastLayer",
    //   LineLayerProperties(
    //     lineColor: const Color(0xffeeeeee ).toHexStringRGB(),
    //     lineWidth: 14,
    //   ),
    // );

    maplibreMapController.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(northeast: routeInfo.northeast!,southwest: routeInfo.southwest!))); 
  }

  Future<RouteInfo> getRoute() async{
    routeInfo = await RouteResitory.to.getRoute(playData!.value.startLat!, playData!.value.startLng!, playData!.value.endLat!, playData!.value.endLng!);

    List<CustomPoint> utmkRoute = routeInfo!.routePoints!.map((e) {
      Point p = latlngToUtmk(e.lat, e.lng);
      return CustomPoint(x:p.x, y:p.y, roadName:e.roadName, tbt:e.tbt, farTbt:e.farTbt);
    }).toList();

    latLngRoute = utmkRoute.map((CustomPoint e) {
      Point p = utmkTolatlng(e.x, e.y);
      return CustomPoint(x:p.x, y:p.y);
    }).toList();
    latalngList = latLngRoute.map((CustomPoint e) => [e.x, e.y]).toList();

    smoothRoute = smooth(utmkRoute);
    latLngsmoothRoute = smoothRoute.map((CustomPoint e) {
      Point p = utmkTolatlng(e.x, e.y);
      return CustomPoint(x:p.x, y:p.y, orgNumber: e.orgNumber);
    }).toList();

    return Future.value(routeInfo);
  }

  void playAndStop() {
    if (playMode.value) {
      timer!.pause();
    } else {
      if (timer == null) {
        timer = PausableTimer(const Duration(milliseconds: 100), () async {
          int number = timer!.tick;
          if (number == latLngsmoothRoute.length - 1) {
            timer!.cancel();
          }
          if(smoothRoute[number].roadName!=null && smoothRoute[number].roadName!=roadName.value){
            roadName.value = smoothRoute[number].roadName!;
          }
          if(smoothRoute[number].tbt!=null && smoothRoute[number].tbt!.type!=998){
            tbtUrl('https://map.gis.kt.com/images/tbt-images/${tbtIcon['type_${smoothRoute[number].tbt!.type}']}.png');
            tbtName(smoothRoute[number].tbt!.tbtName);
          }
          if(smoothRoute[number].farTbt!=null && smoothRoute[number].farTbt!.type!=998){
            farTbtUrl('https://map.gis.kt.com/images/tbt-images/${tbtIcon['type_${smoothRoute[number].farTbt!.type}']}.png');
          }

          List<List<double>> sub = latalngList.sublist(latLngsmoothRoute[number].orgNumber!, latLngsmoothRoute[number].orgNumber!+80);
          sub[0] = [latLngsmoothRoute[number].x, latLngsmoothRoute[number].y];
          (_line['features'] as List)[0]['geometry']['coordinates'] = sub; 
          await maplibreMapController.setGeoJsonSource("route", _line);
          await maplibreMapController.setGeoJsonSource("routeOutLine", _line);
          //await maplibreMapController.setGeoJsonSource("routeArrow", _line);

          //List<List<double>> subArrow = latalngList.sublist(latLngsmoothRoute[number].orgNumber!, latLngsmoothRoute[number].orgNumber!+80);
          //(_lineArrow['features'] as List)[0]['geometry']['coordinates'] = subArrow; 
          //await maplibreMapController.setGeoJsonSource("routeArrow", _lineArrow);

          // if(latLngsmoothRoute[number].orgNumber!>40){
          //   List<List<double>> sub = latalngList.sublist(latLngsmoothRoute[number].orgNumber!-39, latLngsmoothRoute[number].orgNumber!+1);
          //   sub[sub.length-1] = [latLngsmoothRoute[number].x, latLngsmoothRoute[number].y];
          //   (_line2['features'] as List)[0]['geometry']['coordinates'] = sub; 
          // }else{
          //   List<List<double>> sub = latalngList.sublist(0, latLngsmoothRoute[number].orgNumber!+1);
          //   sub[sub.length-1] = [latLngsmoothRoute[number].x, latLngsmoothRoute[number].y];
          //   (_line2['features'] as List)[0]['geometry']['coordinates'] = sub; 
          // }
          // await maplibreMapController.setGeoJsonSource("routePast", _line2);
          
          // try{
          //   LatLngBounds bounds = await maplibreMapController.getVisibleRegion();
          //   debugPrint(bounds.northeast.latitude.toString() + ", " + bounds.northeast.longitude.toString() 
          //   + " : " +  bounds.southwest.latitude.toString() + ", " + bounds.southwest.longitude.toString());
          // }catch(e){
          //   debugPrint(e.toString());
          // }
          
          double bearing = atan2(smoothRoute[number + 1].x - smoothRoute[number].x,smoothRoute[number + 1].y - smoothRoute[number].y) * (180 / pi);
          maplibreMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              bearing: bearing,
              target: LatLng(latLngsmoothRoute[number].y, latLngsmoothRoute[number].x), tilt: 60, zoom: 17.5
            ),
          ));
        
          timer!.reset();
          timer!.start();
        })
              ..start();
      } else {
        timer!.start();
      }
    }
    playMode.value = !playMode.value;
  }


  List<CustomPoint> smooth(List<CustomPoint> utmkRouteList) {
    List<CustomPoint> partPath = [];
    utmkRouteList.asMap().entries.forEach((element) {
      if (utmkRouteList.length > element.key + 1) {
        CustomPoint point = element.value;
        point.orgNumber = element.key;
        CustomPoint netxPoint = utmkRouteList[element.key + 1];
        netxPoint.orgNumber = element.key;
        double length = twoPointLength(point, netxPoint);
        towPointSpint(point, netxPoint, length, partPath, element.key);
      }
    });
    return partPath;
  }

  double twoPointLength(CustomPoint p1, CustomPoint p2) {
    return sqrt(pow((p1.x - p2.x).abs(), 2) + pow((p1.y - p2.y).abs(), 2)); //* 20000;
  }

  void towPointSpint(CustomPoint p1, CustomPoint p2, double length, List<CustomPoint> result, int idx) {
    int max = (length / 1).round();
    for (int i = 0; i < max - 1; i++) {
      if(i%10==0){
        result.add(CustomPoint(
          x: (p2.x * (i) / max) + (p1.x * (max - i) / max), y: (p2.y * (i) / max) + (p1.y * (max - i) / max), 
          roadName: p1.roadName, tbt:p1.tbt, farTbt:p1.farTbt, orgNumber:idx
        ));
      }
    }
  }
}