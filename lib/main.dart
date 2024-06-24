import 'package:flutter/material.dart';
import 'package:just_run/pages/history.dart';
import 'package:just_run/pages/login.dart';
import 'package:just_run/pages/home.dart';
import 'package:just_run/pages/running.dart';

void main() => runApp(MaterialApp(
    initialRoute: '/login',
    routes: {
      '/login': (context) => Login(),
      '/home': (context) => Home(),
      '/running': (context) => Running(),
      '/history': (context) => History(),
    }
));