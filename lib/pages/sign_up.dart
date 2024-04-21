import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_demo/components/button_sign_in.dart';
import 'package:flutter_demo/components/button_sign_up.dart';
import 'package:flutter_demo/components/square_logo.dart';
import 'package:flutter_demo/components/text_field.dart';
import 'package:google_sign_in/google_sign_in.dart';


class SignInPage extends StatelessWidget {
  SignInPage({super.key});
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

 Future<void> signMeUp(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) {
      return Center(child: CircularProgressIndicator());
    },
  );
  
  try {
    final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    if (userCredential != null && userCredential.user != null) {
      // Trimiteți e-mailul de verificare
      await userCredential.user!.sendEmailVerification();

      Navigator.of(context).pop();
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Please verify your email, then Sign In!'),
              content: Text('An email verification link has been sent to your email address. Please verify your email before proceeding.'),
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
      await Future.delayed(Duration(seconds: 5));
      Navigator.pushNamed(context, '/loginPage');
    }else {
      // Dacă userCredential sau userCredential.user este null, afișați o alertă pentru a indica o eroare neașteptată
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An unexpected error occurred while creating the account.'),
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
  } on FirebaseAuthException catch (e) {
    Navigator.of(context).pop(); // Ascunde dialogul de progres
    String errorMessage;
    if (e.code == 'weak-password') {
      errorMessage = 'The password provided is too weak.';
    } else if (e.code == 'email-already-in-use') {
      errorMessage = 'The account already exists for that email.';
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


  void signUpWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    final GoogleSignInAuthentication? googleSignInAuthentication = await googleSignInAccount?.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(idToken: googleSignInAuthentication?.idToken, accessToken: googleSignInAuthentication?.accessToken);

    UserCredential result = await firebaseAuth.signInWithCredential(credential);

    User? user = result.user;
    if(result != null) {
      Navigator.pushNamed(context, '/mapsPage');
    }
  }


  @override
  Widget build(BuildContext context) {
    // Timer(Duration(seconds: 3), () {
    //   Navigator.pushNamed(context, '/mapsPage');
    // });
    
    return Scaffold(
      appBar: AppBar(
        // Adăugarea unui buton de tip 'back' în stânga sus
        backgroundColor: Colors.grey[300],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigarea înapoi
          },
        ),
      ),
      backgroundColor: Colors.grey[300],
      body: 
      SafeArea(
        child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                // ceva logo eventual
                SizedBox(height: 100),
                // mesaj
                Text(
                  'Welcome back, SafeZoner!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
              
                // mail
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
              
                // username
                MyTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
              
                // Password
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                
                
                const SizedBox(height: 25),
              
                Container(
                padding: const EdgeInsets.all(25),
                margin: const EdgeInsets.symmetric(horizontal: 25),
                child: ButtonSignUp(
                    onTap: () => signMeUp(context),
                  ),
              ),
              
                const SizedBox(height: 40),
              
                // login with google / meta
              
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:25.0 ),
                  child: Row(children: [
                    Expanded(child: Divider(
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
                    Expanded(child: Divider(
                      thickness: 0.5,
                      color: Colors.grey[400],
                    ),
                    ),
                  ],),
                ),
                // google & meta logo buttons
              
                const SizedBox(height: 40,),
                
                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 SquareLogo(
                  onTap: () => signUpWithGoogle(context),
                  imagePath: 'assets/images/google_logo.png'),
              ],
              ),
              
              ],),
            ),
        ),
      )
    );
}
}