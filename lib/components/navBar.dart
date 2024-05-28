import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_demo/pages/constants.dart';
import 'package:flutter/material.dart';

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

Future<String> x() async {
  return "";
}

class NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Drawer(
      child: FutureBuilder<String>(
        future: fetchUsername(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final username = snapshot.data;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Row(
                    children: [
                      Text('Hello, '),
                      SizedBox(width: 5),
                      Text(username ?? 'NAME', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  title: Text('Level 1', style: TextStyle(color: Color.fromARGB(255, 27, 28, 29), fontWeight: FontWeight.bold )),
                  onTap: () => null,
                ),
                ListTile(
                  leading: Icon(Icons.filter_center_focus_rounded, color: Colors.green),
                  title: Text('Reward points: 0/10', style: TextStyle(color: Color.fromARGB(255, 27, 28, 29), fontWeight: FontWeight.bold )),
                  onTap: () => null,
                ),
                Divider(),
                ListTile(
                  title: Text('Dark Mode', style: TextStyle(color: Color.fromARGB(255, 27, 28, 29), fontWeight: FontWeight.bold )),
                  trailing: Switch(
                    value: false,
                    onChanged: null,
                  ),
                  onTap: () => null,
                ),
                Divider(),
                Spacer(),
                SafeArea(
                  child: ListTile(
                    title: Text('Exit', style: TextStyle(color: Color.fromARGB(255, 27, 28, 29), fontWeight: FontWeight.bold )),
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
