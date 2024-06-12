import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_demo/components/theme_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_demo/pages/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void signMeOut(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) {
      return Center(child: CircularProgressIndicator());
    },
  );

  await FirebaseAuth.instance.signOut();

  Navigator.of(context).pop(); // Ascunde dialogul de progres
  Navigator.pushNamed(context, '/loginPage');
}

Future<String> fetchUsername(String userId) async {
  if (userId != null) {
    final response = await http.get(Uri.parse('$baseURL/users/$userId'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to fetch username');
    }
  }
  return "";
}

Future<int> fetchUserLevel(String userId) async {
  if (userId.isNotEmpty) {
    final response = await http.get(Uri.parse('$baseURL/users/level/$userId'),
        headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      return int.parse(response.body); // Parse the integer from response body
    } else {
      throw Exception('Failed to fetch user level');
    }
  }
  return 1; // Default to level 1 if not fetched
}

// Method to fetch user points from the server
Future<int> fetchUserPoints(String userId) async {
  if (userId.isNotEmpty) {
    final response = await http.get(Uri.parse('$baseURL/users/points/$userId'),
        headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      return int.parse(response.body); // Parse the integer from response body
    } else {
      throw Exception('Failed to fetch user points');
    }
  }
  return 0; // Default to 0 points if not fetched
}

Future<String> x() async {
  return "";
}

class NavBar extends StatelessWidget {
  final Function(bool) toggleTheme;
  NavBar({required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Drawer(
        child: ListTile(
          leading: Icon(Icons.error),
          title: Text('Not Logged In'),
        ),
      );
    }
    var userId = user.uid;
    Color textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Drawer(
      child: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          fetchUsername(userId),
          fetchUserLevel(userId),
          fetchUserPoints(userId)
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(color: textColor)));
          } else {
            final username = snapshot.data?[0];
            final userLevel = snapshot.data?[1];
            final userPoints = snapshot.data?[2];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Row(
                    children: [
                      Text('Hello, ', style: TextStyle(color: textColor)),
                      SizedBox(width: 5),
                      Text(username ?? 'NAME',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: textColor)),
                    ],
                  ),
                  accountEmail: null,
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/eu.jpeg'),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade100, Colors.blue.shade600],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.star, color: Colors.yellow),
                  title: Text('Level $userLevel',
                      style: TextStyle(
                          color: textColor, fontWeight: FontWeight.bold)),
                  onTap: () => null,
                ),
                ListTile(
                  leading: Icon(Icons.filter_center_focus_rounded,
                      color: Colors.green),
                  title: Text(
                      'Reward points: $userPoints${userLevel == 5 ? "" : "/${userLevel * 10}"}',
                      style: TextStyle(
                          color: textColor, fontWeight: FontWeight.bold)),
                  onTap: () => null,
                ),
                Divider(),
                ListTile(
                  title: Text('Dark Mode',
                      style: TextStyle(
                          color: textColor, fontWeight: FontWeight.bold)),
                  trailing: Switch(
                    value: Provider.of<ThemeProvider>(context)
                            .getTheme()
                            .brightness ==
                        Brightness.dark,
                    onChanged: (bool value) {
                      toggleTheme(value);
                    },
                  ),
                  onTap: () => null,
                ),
                Divider(),
                Spacer(),
                SafeArea(
                  child: ListTile(
                    title: Text('Exit',
                        style: TextStyle(
                            color: textColor, fontWeight: FontWeight.bold)),
                    leading: Icon(Icons.exit_to_app, color: Colors.red),
                    onTap: () => signMeOut(context),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
