import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_demo/components/button_sign_in.dart';
import 'package:flutter_demo/components/square_logo.dart';
import 'package:flutter_demo/components/text_field.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // text fields controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // sign-in method
  Future<void> logMeIn(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await userCredential.user!.reload();
      if (userCredential.user!.emailVerified) {
        Navigator.of(context).pop(); // Ascunde dialogul de progres
        Navigator.pushNamed(context, '/mapsPage');
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop(); // Ascunde dialogul de progres
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else {
        errorMessage = 'An error occurred: ${e.message}';
      }
      // Afișați alerta cu mesajul de eroare
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Afișați alerta pentru alte erori neașteptate
      Navigator.of(context).pop(); // Ascunde dialogul de progres
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An unexpected error occurred: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void signWithGoogle(BuildContext context) async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    showDialog(
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // ------------------ retine in baza de date -----------------------------
    final response = await http.get(
      Uri.parse('http://192.168.1.16:9191/users/${userCredential.user!.uid}'),
    );

    if (response.statusCode == 200) {
      // User already exists, don't add to the database again
      print('User already exists in the database');
    } else {
      print('User does not exist in the database');
      String? email = userCredential.user!.email;
      int atIndex = email!.indexOf('@'); // Find the index of '@' character
      String? username = email.substring(0, atIndex);
      // User does not exist, add to the database
      final response = await http.post(
        Uri.parse('http://192.168.1.16:9191/users/add'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded', // Use form data
        },
        body: {
          'name': username,
          'email': email,
          'id': userCredential.user!.uid,
        },
      );
      if (response.statusCode == 200) {
        print('User added successfully');
      } else {
        print('Failed to add user');
      }
    }
    // -----------------------------------------------------------------------

    Navigator.of(context).pop();
    Navigator.pushNamed(context, '/mapsPage');
  }

  void resetPassowrd(BuildContext context) async {
    if (emailController.text == "") {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Type your email!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Check your mail to reset password!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Timer(Duration(seconds: 3), () {
    //   Navigator.pushNamed(context, '/mapsPage');
    // });

    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ceva logo eventual
                  SizedBox(height: 200),
                  // mesaj
                  Text(
                    'Welcome back, SafeZoner!',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Username
                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                  ),
                  const SizedBox(height: 10),

                  // Password
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => resetPassowrd(context),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      ],
                    ),
                  ),

                  //const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(25),
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    child: ButtonSignIn(
                      onTap: () => logMeIn(context),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // login with google / meta

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // google & meta logo buttons

                  const SizedBox(
                    height: 40,
                  ),

                  InkWell(
                    onTap: () {
                      // Adăugați aici acțiunea dorită pentru atunci când utilizatorul apasă pe logo
                      signWithGoogle(context);
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[200],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/google_logo.png',
                          height: 50,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signInPage');
                        },
                        child: const Text(
                          'Register now',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
