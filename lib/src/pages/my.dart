import 'package:flutter/material.dart';

class My extends StatelessWidget {
  const My({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'My',
              style: TextStyle(fontSize: 48),
            ),
          ],
        ),
      ),
    );
  }
}