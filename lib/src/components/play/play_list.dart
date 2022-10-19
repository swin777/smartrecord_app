import 'package:flutter/material.dart';
import 'package:smartrecord_app/src/components/play/play_detail.dart';
import '../../controller/play_controller.dart';

class PlayList extends StatelessWidget {
  PlayList({Key? key}) : super(key: key);
  final PlayerController controller = PlayerController.to;

  Future goPlayDetail(BuildContext context, String? playId){
    return showDialog<String>(
      barrierColor: const Color(0xffedf0f5),
      context: context,
      builder: (context) => PlayDetail(playId:playId!)
    );
  }

  Widget PlayItem(BuildContext context){
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Image.asset(
            'assets/images/sample.png',
            height: 100,
            width: 120,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: _playInfo(context)
          )
        ],
      ),
    );
  }

  Widget _playInfo(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff60acff),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: const Text('출발', style: TextStyle(color: Colors.white, fontSize: 14),),
                ),
                const SizedBox(height: 4,),
                Text('서울특별시 동대문구 망우로 1', style: TextStyle(color: Colors.black, fontSize: 14), overflow:TextOverflow.ellipsis),
              ],
            )
          ),
          Container(
            width: 34,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset('assets/images/two_arrow.png', width: 22, height: 22)
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff2a3f85),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: const Text('도착', style: TextStyle(color: Colors.white, fontSize: 14),),
                ),
                const SizedBox(height: 4,),
                Text('경기도 의정부시 체육로 90', style: TextStyle(color: Colors.black, fontSize: 14), overflow:TextOverflow.ellipsis),
              ],
            )
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: controller.cnt.value,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          color: const Color(0xffdddddd),
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.grey, width: 0.3)
          ),
          child: GestureDetector(
            onTap: () async{
              await goPlayDetail(context, index.toString());
            },
            child: PlayItem(context)
          )
        );
      },
      //shrinkWrap: true,
    );
  }
}