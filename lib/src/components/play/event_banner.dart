import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../controller/play_controller.dart';

class EnventBanner extends StatelessWidget {
  EnventBanner({Key? key}) : super(key: key);
  int _current = 0;
  final CarouselController _controller = CarouselController();
  final PlayerController controller = PlayerController.to;

  Widget poisionInfo(Color color) {
    return Container(
      decoration: BoxDecoration(
        // border: Border.all( 
        //   width: 1,
        //   color: const Color(0xffcccccc), 
        // ),
        color: color,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.white,
      padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      height: 174,
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 135,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
            ),
            items: [
              poisionInfo(Colors.red),
              poisionInfo(Colors.purple),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [0,1].map((entry) {
              return GestureDetector(
                onTap: () => _controller.animateToPage(entry),
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(_current == entry ? 0.9 : 0.4)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}