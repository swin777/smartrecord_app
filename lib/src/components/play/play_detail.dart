import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartrecord_app/src/components/play/play_detail_info.dart';
import 'package:smartrecord_app/src/components/play/play_map.dart';

class PlayDetail extends StatelessWidget {
  String playId;
  PlayDetail({Key? key, required this.playId}) : super(key: key);

  void close(){
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.all(0),
      backgroundColor: Colors.transparent,
      //child:FreightDetailInfo(close: close, parentContext:context)
      child: SizedBox(
        //margin: const EdgeInsets.only(top: 20),
        height: MediaQuery.of(context).size.height,
        child : Navigator(
          key: Get.nestedKey(1), 
          initialRoute:'detail/info',
          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {
              case 'detail/info':
                return GetPageRoute(
                  page: () {return PlayDetailInfo(close: close, playId: playId,); },
                  transition: Transition.rightToLeft,
                );
              case 'map':
                return GetPageRoute(
                  settings: settings,
                  page: () {return PlayMap(arg: settings.arguments); },
                  transition: Transition.leftToRight,
                );
            }
          }
        )
      ),
    );
  }
}