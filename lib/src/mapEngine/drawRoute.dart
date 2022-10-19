import 'dart:math';
import 'package:flutter/material.dart';
import 'package:proj4dart/proj4dart.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:smartrecord_app/src/model/route/custom_point.dart';
import 'package:smartrecord_app/src/model/route/route_info.dart';
import 'package:smartrecord_app/src/utils/projection.dart';

class DrawRoute{
  MaplibreMapController maplibreMapController;
  RouteInfo routeInfo;
  late List<CustomPoint> smoothRoute; //smooth된 utmk
  late List<CustomPoint> latLngsmoothRoute; //smooth된 utmk에서 위경도로 변경
  late List<CustomPoint> latLngRoute; //utmk에서 위경도로 변경
  late List<List<double>> latalngList;
  Map<String, Object> line = lineTemplate();

  int driverProgress = 0;

  DrawRoute({
    required this.maplibreMapController,
    required this.routeInfo
  }){
    List<CustomPoint> utmkRoute = routeInfo.routePoints!.map((e) {
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
    init();
  }

  void init() async {
    (line['features'] as List)[0]['geometry']['coordinates'] = latalngList;
    await maplibreMapController.addGeoJsonSource("routeOutLine", line);
    await maplibreMapController.addLineLayer(
      "routeOutLine", "routeOutLineLayer",
      LineLayerProperties(
        lineColor: const Color(0xffffffff).toHexStringRGB(),
        lineWidth: 16,
      ),
    );

    await maplibreMapController.addGeoJsonSource("route", line);
    await maplibreMapController.addLineLayer(
      "route", "routeLineLayer",
      LineLayerProperties(
        lineColor: const Color(0xff2a3f85).toHexStringRGB(),
        lineWidth: 10,
      ),
    );
    
    // await maplibreMapController.addGeoJsonSource("routeArrow", _line);
    // await maplibreMapController.addSymbolLayer(
    //   "routeArrow", "routeArrowLayer",
    //   const SymbolLayerProperties(
    //     symbolPlacement: "line",
    //     symbolSpacing: 250,
    //     iconImage: "ico_015",
    //     iconSize: 0.6,
    //     //iconOpacity: 0.8,
    //     iconIgnorePlacement:true
    //   ),
    // );
    maplibreMapController.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(northeast: routeInfo.northeast!,southwest: routeInfo.southwest!))); 
  }

  void drawByGPS(LatLng latLng){
    bool inYn = false;
    int minIndex = driverProgress+1;
    double minLength = 99;
    Point utmk = latlngToUtmk(latLng.latitude, latLng.longitude);
    //smoothRoute.sublist(driverProgress+1, 100).asMap().forEach((index, element) {
    smoothRoute.sublist(driverProgress+1, smoothRoute.length).asMap().forEach((index, element) {
      double length = twoPointLength(utmk.x, utmk.y, element.x, element.y);
      if(inYn && length>50) {
        driverProgress = minIndex;
        drawBySeq(driverProgress);
        return;
      }
      if(length < minLength && length<50){
        inYn = true;
        minLength = length;
        minIndex = minIndex + index;
      }
    });
  }

  void drawBySeq(int number) async{
    List<List<double>> sub = latalngList.sublist(latLngsmoothRoute[number].orgNumber!, latLngsmoothRoute[number].orgNumber!+80);
    sub[0] = [latLngsmoothRoute[number].x, latLngsmoothRoute[number].y];
    (line['features'] as List)[0]['geometry']['coordinates'] = sub; 
    await maplibreMapController.setGeoJsonSource("route", line);
    await maplibreMapController.setGeoJsonSource("routeOutLine", line);
    
    double bearing = atan2(smoothRoute[number + 1].x - smoothRoute[number].x,smoothRoute[number + 1].y - smoothRoute[number].y) * (180 / pi);
    maplibreMapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: bearing<0 ? 360+bearing : bearing,
        target: LatLng(latLngsmoothRoute[number].y, latLngsmoothRoute[number].x), tilt: 60, zoom: 17
      ),
    ));
  }

  void drawByPostion() async{
    try{
      LatLngBounds bounds = await maplibreMapController.getVisibleRegion();
      debugPrint(bounds.northeast.latitude.toString() + ", " + bounds.northeast.longitude.toString() 
      + " : " +  bounds.southwest.latitude.toString() + ", " + bounds.southwest.longitude.toString());
    }catch(e){
      debugPrint(e.toString());
    }
  }

  List<CustomPoint> smooth(List<CustomPoint> utmkRouteList) {
    List<CustomPoint> partPath = [];
    utmkRouteList.asMap().entries.forEach((element) {
      if (utmkRouteList.length > element.key + 1) {
        CustomPoint point = element.value;
        point.orgNumber = element.key;
        CustomPoint netxPoint = utmkRouteList[element.key + 1];
        netxPoint.orgNumber = element.key;
        double length = twoCustomPointLength(point, netxPoint);
        towPointSpint(point, netxPoint, length, partPath, element.key);
      }
    });
    return partPath;
  }

  double twoCustomPointLength(CustomPoint p1, CustomPoint p2) {
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

  double twoPointLength(double startX, double startY, double endX, double endY) {
    return sqrt(pow((startX - endX).abs(), 2) + pow((startY - endY).abs(), 2)); //* 20000;
  }
}