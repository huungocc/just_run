import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home: Home()
));

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FIRST APP',
          style: TextStyle(
            fontFamily: 'Caveat Variable',
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red[400],
      ),
      body: Center(
        child: Text(
          'hello, my name is Ngoc',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.red[400],
            fontFamily: 'Caveat Variable',
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Text(
          'click',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: () {},
        backgroundColor: Colors.red,
      ),
    );
  }
}
