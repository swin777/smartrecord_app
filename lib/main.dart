import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'src/app.dart';
import 'src/binding/init_binding.dart';

void main() {
  runApp(const MyApp());
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    Widget splashScreenView = SplashScreenView(
      navigateRoute: const App(),
      duration: 3000,
      imageSize: 150,
      imageSrc: "assets/images/logo.png",
      text: "Smart Record",
      textType: TextType.ColorizeAnimationText,
      textStyle: const TextStyle(
        fontSize: 40.0,
      ),
      //colors: const [Colors.purple, Colors.blue, Colors.yellow,Colors.red],
      colors: const [Colors.black, Color(0xff60acff), Color(0xffcccccc), Color(0xff2a3f85)],
      backgroundColor: const Color(0xffffffff),
    );
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: createMaterialColor(const Color(0xff2a3f85)), 
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: AppBarTheme(backgroundColor: Colors.grey[200],),
        textTheme: const TextTheme(
          bodyText1: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18
          ),
          headline3: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17
          ),
          bodyText2: TextStyle(
            color: Color(0xff606060), fontWeight: FontWeight.bold, fontSize: 16
          ),
          caption: TextStyle(
            color: Color(0xff606060), fontWeight: FontWeight.bold, fontSize: 14,
          ),
          headline6: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16
          ),
          headline5: TextStyle(
            color: Color(0xff2a3f85), fontWeight: FontWeight.bold, fontSize: 14,
          ),
        )
      ),
      home: splashScreenView,
      initialBinding: InitBinding(),
    );
  }
}