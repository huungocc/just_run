import 'package:flutter/material.dart';
import 'package:just_run/manager/fonts.dart';
import 'package:sign_button/sign_button.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:just_run/manager/routes.dart';
import 'package:just_run/services/auth_service.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService _authService = AuthService();

  Future<void> _signInWithGoogle() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: SpinKitThreeBounce(
            color: Colors.white,
            size: 30.0,
          ),
        );
      },
    );

    User? user = await _authService.signInWithGoogle(context);
    Navigator.pop(context);
    if (user != null) {
      Navigator.pushReplacementNamed(context, Routes.home);
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
              Text(' Welcome to', style: TextStyle(fontFamily: Fonts.display_font, fontSize: 25, color: Colors.grey[850], height: 1, fontWeight: FontWeight.bold),
              ),
              Text(
                'JustRun',
                style: TextStyle(fontFamily: Fonts.display_font, fontSize: 70, color: Colors.grey[850], height: 1, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              Text(' Continue with', style: TextStyle(fontFamily: Fonts.display_font, color: Colors.grey[850], fontWeight: FontWeight.bold, fontSize: 15),
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