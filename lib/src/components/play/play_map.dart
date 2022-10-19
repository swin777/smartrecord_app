import 'dart:convert';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:smartrecord_app/src/components/play/simulation/remocon.dart';
import 'package:smartrecord_app/src/controller/play_controller.dart';

import '../../model/playInfo.dart';

class PlayMap extends StatelessWidget {
  PlayMap({Key? key, this.arg}) : super(key: key) {
    playData = (arg as Map)['playData'];
    ctl.playData!.value = playData!;
    ctl.playMode.value = false;
    ctl.simulationMode.value = false;
    ctl.driverMode.value = false;
    ctl.timer = null;
  }

  Object? arg;
  late Size size;
  dynamic styleData;
  List<String> dtBldLine = [];
  List<String> dtBldPoly = [];
  PlayData? playData;
  final PlayerController ctl = PlayerController.to;

  void simulationRedy() async {
    Rect rect = Rect.fromLTRB(0, 0, size.width, size.height);
    await ctl.maplibreMapController.queryRenderedFeaturesInRect(rect, ['routeLineLayer'], null);
    ctl.simulationMode.toggle();
    Future.delayed(const Duration(milliseconds: 500), () {
      ctl.maplibreMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(playData!.startLat!, playData!.startLng!),
          tilt: ctl.simulationMode.value ? 60 : 0,
          zoom: 16.5),
      ));
    });
  }

  void driveRedy() async {
    Rect rect = Rect.fromLTRB(0, 0, size.width, size.height);
    await ctl.maplibreMapController.queryRenderedFeaturesInRect(rect, ['routeLineLayer'], null);
    ctl.driverMode.toggle();
    Future.delayed(const Duration(milliseconds: 500), () {
      ctl.maplibreMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(playData!.startLat!, playData!.startLng!),
          tilt: ctl.driverMode.value ? 60 : 0,
          zoom: 16.5),
      ));
    });
  }

  void _onMapCreated(MaplibreMapController maplibreMapController) async {
    ctl.maplibreMapController = maplibreMapController;
    ctl.routeExecute();
  }

  SymbolOptions _getSymbolOptions(String iconImage) {
    return SymbolOptions(
      geometry: LatLng(playData!.startLat!, playData!.startLng!),
      iconImage: iconImage,
      iconSize: 0.5,
    );
  }

  void _onCameraIdle() {
    extrusionToggle();
  }

  void _onStyleLoadedCallback() async {
    final String tileStyle =
        await rootBundle.loadString('assets/style/tileStyleAll.json');
    styleData = await json.decode(tileStyle);
    List layers = styleData['layers'] as List;

    for (var layer in layers) {
      String layerId = layer['id'] as String;
      if (layerId.contains("dt_bld_poly")) {
        String type = layer['type'] as String;
        if (type == 'line') {
          dtBldLine.add(layerId);
        } else {
          dtBldPoly.add(layerId);
        }
      }
    }
    extrusionToggle();
  }

  void extrusionToggle() {
    if (styleData != null) {
      double? tilt = ctl.maplibreMapController.cameraPosition?.tilt;
      if (tilt != null) {
        if (tilt == 0) {
          for (var layerId in dtBldLine) {
            ctl.maplibreMapController.visiableLayer(layerId);
          }
          for (var layerId in dtBldPoly) {
            ctl.maplibreMapController.noneVisiableLayer(layerId);
          }
        }
        if (tilt > 0) {
          for (var layerId in dtBldLine) {
            ctl.maplibreMapController.noneVisiableLayer(layerId);
          }
          for (var layerId in dtBldPoly) {
            ctl.maplibreMapController.visiableLayer(layerId);
          }
        }
      }
    }
  }

  Widget poisionInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: const Color(0xffcccccc),
        ),
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xff60acff),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(2),
                child: const Text(
                  '출발',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      ' 405km',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Obx(() => Container(
                            height: 30,
                            //alignment: Alignment.centerRight,
                            child: ctl.routeComplate.value ? 
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(4))
                                  ),
                                  textStyle: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                                  primary: Theme.of(context).primaryColor
                                ),
                                onPressed: driveRedy,
                                child: const Text('주행'),
                              )
                              : const SizedBox()
                            )
                          ),
                          SizedBox(width: 4,),
                          Obx(() => Container(
                            height: 30,
                            //alignment: Alignment.centerRight,
                            child: ctl.routeComplate.value ? 
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(4))
                                  ),
                                  textStyle: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                                  primary: Colors.pink,
                                ),
                                onPressed: simulationRedy,
                                child: const Text('모의주행'),
                              )
                              : const SizedBox()
                            )
                          ),
                        ],
                      )
                    )
                  ],
                )
              )
            ],
          )
        ]
      )
    );
  }

  MaplibreMap maplibreMap() {
    CameraPosition cameraPosition = CameraPosition(
        target: LatLng(playData!.startLat!, playData!.startLng!), zoom: 16.5, tilt: 0);
    return MaplibreMap(
        onMapCreated: _onMapCreated,
        onStyleLoadedCallback: _onStyleLoadedCallback,
        onCameraIdle: _onCameraIdle,
        styleString: 'assets/style/tileStyleAll.json',
        trackCameraPosition: true,
        initialCameraPosition: cameraPosition,
        logoViewMargins: const Point(0, -100),
        attributionButtonMargins: const Point(0, -100));
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return LayoutBuilder(
      builder: (context, constraints) => 
      Stack(
        children: <Widget>[
          Obx(() => FractionallySizedBox(
            heightFactor: ctl.simulationMode.value || ctl.driverMode.value? 1.65 : 1.0,
            widthFactor: 1.0,
            alignment: Alignment.topCenter,
            child: maplibreMap(),
          )),

          Obx(() => !ctl.playMode.value ?
            Positioned(
              top: 14,
              left: 14,
              child: GestureDetector(
                onTap: () {
                  Get.back(id: 1);
                  ctl.playMode.value = false;
                  ctl.simulationMode.value = false;
                  ctl.driverMode.value = false;
                  ctl.timer = null;
                },
                child: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.black,
                  size: 40,
                ),
              ),
            )
            : const SizedBox()
          ),

          Positioned(
            bottom: 6,
            child: Obx(() => ctl.simulationMode.value || ctl.driverMode.value
              ? RemodeCon()
              : !ctl.driverMode.value ? 
                SizedBox(
                    width: size.width,
                    height: 184,
                    child: CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: false,
                        aspectRatio: 2.0,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: false,
                        initialPage: 0,
                        viewportFraction: 0.92
                      ),
                    items: [
                      poisionInfo(context),
                      poisionInfo(context),
                    ],
                  ),
                )
                : const SizedBox()
            ),
          ),

          Obx(() => ctl.simulationMode.value || ctl.driverMode.value ? 
            Positioned(
              top: constraints.maxHeight * 1.65 / 2 - 25 ,
              left: constraints.maxWidth / 2 - 25,
              child: Image.asset(
                "assets/images/car.png",
                width: 50,
                height: 50,
              ),
            )
            : const SizedBox()
          ),
        ]
      )
    );
  }
}
