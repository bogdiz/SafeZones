import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("TEst")),
      appBar: AppBar(
        title: Text("Hello"),
      ),
      drawer: Drawer(backgroundColor: Colors.green,),
    );
}
}