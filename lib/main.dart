import 'package:flutter/material.dart';
import 'package:ngocapp/pages/choose_location.dart';
import 'package:ngocapp/pages/home.dart';
import 'package:ngocapp/pages/loading.dart';

void main() => runApp(MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => Loading(),
    '/home': (context) => Home(),
    '/location': (context) => ChooseLocation(),
  }
));



