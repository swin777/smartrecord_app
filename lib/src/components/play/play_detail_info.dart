import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartrecord_app/src/model/playInfo.dart';

import '../utils/customButton.dart';

class PlayDetailInfo extends StatelessWidget {
  String playId;
  VoidCallback close;
  late Size size;

  PlayDetailInfo({Key? key,  required this.close, required this.playId}) : super(key: key);

  Widget _bookMark() {
    return SizedBox(
      width: 22,
      child: MaterialButton(
        //shape: const CircleBorder(),
        elevation: 0,
        color: Colors.white,
        padding: const EdgeInsets.all(0),
        child: const Icon(Icons.bookmark_border, size: 20),
        onPressed: () {},
      ),
    );
  }

  Widget playContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CustomButton(
            radiusVal: 20,
            text:'게임시작', color: Theme.of(context).primaryColor,
            onPressed: (){
              Get.toNamed(
                'map', id:1, 
                // arguments: {
                //   'playData':new PlayData(
                //     startLat:37.496737255470975, startLng:127.02699715248741, 
                //     endLat:37.64624749976607, endLng:127.68093079147333
                //   )
                // }
                arguments: {
                  'playData':new PlayData(
                    startLat:37.56518108201183, startLng:126.98711753980724,
                    endLat:37.64692916498099, endLng:126.8948034516846  //{lat: 37.64692916498099, lng: 126.8948034516846} 37.65137367285187, endLng:127.07074110388983
                  )
                }
              ); 
            },
          )
        ],
      )
    );
  }

  Widget dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
            top: -5,
            //right: 8.0,
            child: Container(
              margin: const EdgeInsets.only(left: 12, right: 12, top: 20),
              width: size.width - 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('게임상세정보', style: TextStyle(color: Colors.black, fontSize: 24)),
                  GestureDetector(
                    onTap: () {
                      close();
                    },
                    child: const Align(
                      alignment: Alignment.topRight,
                      child: CircleAvatar(
                        radius: 20.0,
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 40,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )),
        Container(
          margin: const EdgeInsets.only(
            top: 70.0,
            left: 12,
            right: 12,
          ),
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 0.0,
                  offset: Offset(0.0, 0.0),
                ),
              ]),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                playContent(context),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
        Positioned(top: 70, right: 16, child: _bookMark()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return dialogContent(context);
  }
}