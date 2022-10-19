import 'package:flutter/material.dart';

Widget CustomButton({
    Color color = const Color(0xff2a3f85), 
    TextStyle textStyle = const TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Color(0xffffffff)),
    String text = "",
    VoidCallback? onPressed, 
    double radiusVal = 0.0
  }){
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusVal)),
        //side: BorderSide(color: Color(0xff2a3f85))
      ),
      primary: color
    ),
    onPressed: onPressed,
    child: Text(text, style: textStyle),
  );
}