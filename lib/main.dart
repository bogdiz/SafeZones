import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/pages/auth_page.dart';
import 'package:flutter_demo/pages/sign_in.dart';
import 'package:flutter_demo/pages/map_page.dart';
import 'package:flutter_demo/pages/sign_up.dart';
import 'package:flutter_demo/pages/splash_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() async {
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
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
        '/loginPage' : (context) => LoginPage(),
        '/mapsPage' : (context) => MapPage(),
        '/authPage' : (context) => AuthPage(),
        '/signInPage' : (context) => SignInPage()
      },
    );
  }
}

