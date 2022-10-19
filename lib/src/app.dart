import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:smartrecord_app/src/pages/my.dart';
import 'package:smartrecord_app/src/pages/play.dart';
import 'package:smartrecord_app/src/pages/team.dart';
import 'package:smartrecord_app/src/pages/etc.dart';

import 'controller/app_controller.dart';

class App extends GetView<AppController> {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        switch (RouteName.values[controller.currentIndex.value]) {
          case RouteName.MY:
            return const My();
          case RouteName.PLAY:
            return const Play();
          case RouteName.TEAM:
            return const Team();
          case RouteName.ETC:
            return const Etc();
        }
      }),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.currentIndex.value,
          showSelectedLabels: true,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          backgroundColor: Theme.of(context).primaryColor,
          onTap: (index) {
            controller.changePageIndex(index);
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(TablerIcons.man),
              label: 'My',
            ),
            BottomNavigationBarItem(
              icon: Icon(TablerIcons.player_play),
              label: "Play",
            ),
            BottomNavigationBarItem(
              icon: Icon(TablerIcons.social),
              label: "Team",
            ),
            BottomNavigationBarItem(
              icon: Icon(TablerIcons.info_circle),
              label: "...",
            ),
          ],
        ),
      ),
    );
  }
}