import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home: Scaffold(
    appBar: AppBar(
      title: Text('FIRST APP',),
      centerTitle: true,
    ),
    body: Center(
      child: Text('hello, my name is Ngoc'),
    ),
    floatingActionButton: FloatingActionButton(
      child: Text('click'),
      onPressed: () {},
    ),
  ),
));