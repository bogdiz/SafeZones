import 'package:flutter/material.dart';
import 'package:flutter_demo/pages/map_page.dart';
import 'package:flutter_demo/splash_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
      routes: {
        '/loginPage' : (context) => MapPage(),
      },
    );
  }
}

