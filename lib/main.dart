import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
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
