import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartrecord_app/src/components/play/event_banner.dart';
import 'package:smartrecord_app/src/components/utils/customButton.dart';
import 'package:smartrecord_app/src/controller/play_controller.dart';

import '../components/play/play_list.dart';

class Play extends StatelessWidget {
  const Play({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PlayerController controller = Get.put(PlayerController());

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              //color: Colors.white,
              padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      radiusVal: 20,
                      text:'게임생성', color: Theme.of(context).primaryColor,
                      onPressed: (){},
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    child: CustomButton(
                      radiusVal: 20,
                      text:'게임찾기', color: Theme.of(context).primaryColor,
                      onPressed: (){},
                    ),
                  ),
                ],
              ),
              height: 54,
              width: double.infinity,
            ),
            EnventBanner(),
            Expanded(
              child: PlayList()
            )
          ],
        ),
      ),
    );
  }
}