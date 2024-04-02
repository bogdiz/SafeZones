import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_demo/login.dart';


class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Așteaptă 3 secunde înainte de a trece la următoarea pagină
    Timer(Duration(seconds: 3), () {
      Navigator.pushNamed(context, '/loginPage');
    });

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 26, 24, 24),
      body: Align(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Animatie pentru city_map
            Positioned(
              child: Container(
                child: FadeIn(
                  duration: Duration(milliseconds: 1500),
                  child: SlideInUp(
                    from: 100,
                    child: Image.asset(
                      'assets/images/city_map.png',
                      width: 400,
                      height: 240,
                    ),
                  ),
                ),
              ),
            ),
            // Animatie pentru logo
            Positioned(
              top: 0,
              child: Container(
                child: BounceInDown(
                  from: 200,
                  delay: Duration(milliseconds: 1000),
                  child: RotationTransition(
                    turns: AlwaysStoppedAnimation(1),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}