import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:just_run/manager/routes.dart';

class Loading extends StatelessWidget {
  void _checkLoginStatus(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.pushReplacementNamed(context, Routes.login);
      } else {
        Navigator.pushReplacementNamed(context, Routes.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus(context);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SpinKitThreeBounce(
          color: Colors.black,
          size: 30,
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Loading(),
  ));
}
