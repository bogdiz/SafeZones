import 'package:firebase_auth/firebase_auth.dart';
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
  final response = await http.get(Uri.parse('$baseURL/users/$userId'));
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to fetch username');
  }
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
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final username = snapshot.data;
            return ListView(
              // Remove padding
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Row(
                    children: [
                      Text('Salut,'),
                      SizedBox(width: 20),
                      Text(username ?? 'NAME'),
                    ],
                  ),
                  accountEmail: null,
                  currentAccountPicture: CircleAvatar(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/passat.png',
                        fit: BoxFit.cover,
                        width: 90,
                        height: 90,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(
                        'https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg',
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.star),
                  title: Text('Levels'),
                  onTap: () => null,
                ),
                ListTile(
                  leading: Icon(Icons.monetization_on),
                  title: Text('Reward points: 0/999'),
                  onTap: () => null,
                ),
                Divider(),
                ListTile(
                  title: Text('Dark Mode'),
                  trailing: Switch(
                    value: false,
                    onChanged: null,
                  ),
                  onTap: () => null,
                ),
                Divider(),
                ListTile(
                  title: Text('Exit'),
                  leading: Icon(Icons.exit_to_app),
                  onTap: () => signMeOut(context),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
