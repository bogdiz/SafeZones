import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/theme_provider.dart';
import 'package:flutter_demo/pages/auth_page.dart';
import 'package:flutter_demo/pages/sign_in.dart';
import 'package:flutter_demo/pages/map_page.dart';
import 'package:flutter_demo/pages/sign_up.dart';
import 'package:flutter_demo/pages/splash_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) =>
          ThemeProvider(ThemeData.light()), // Default to light theme
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: themeProvider.getTheme(),
      home: AuthStateSwitcher(),
      routes: {
        '/loginPage': (context) => LoginPage(),
        '/mapsPage': (context) => MapPage(),
        '/authPage': (context) => AuthPage(),
        '/signInPage': (context) => SignInPage()
      },
    );
  }
}

class AuthStateSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashPage();
        } else {
          print('User is logged in');
          return MapPage();
        }
      },
    );
  }
}
