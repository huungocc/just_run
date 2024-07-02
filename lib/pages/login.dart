import 'package:flutter/material.dart';
import 'package:sign_button/sign_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:just_run/routes.dart';
import 'package:just_run/services/auth_service.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService _authService = AuthService();

  Future<void> _signInWithGoogle() async {
    try {
      User? user = await _authService.signInWithGoogle(context);
      if (user != null) {
        Navigator.pushReplacementNamed(context, Routes.home);
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in with Google: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 200, 20, 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome to', style: TextStyle(fontFamily: 'BlinkerBlack', fontSize: 25, color: Colors.grey[850], height: 1),
              ),
              Text(
                'JustRun',
                style: TextStyle(fontFamily: 'BlinkerBlack', fontSize: 70, color: Colors.grey[850], height: 1),
              ),
              SizedBox(height: 40),
              Text('Continue with', style: TextStyle(fontFamily: 'Blinker', color: Colors.grey[850], fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SignInButton(
                buttonType: ButtonType.google,
                btnTextColor: Colors.white70,
                btnColor: Colors.grey[850],
                btnText: 'Google',
                width: 95,
                onPressed: _signInWithGoogle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}