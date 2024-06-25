import 'package:flutter/material.dart';

class History extends StatefulWidget {
  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Chiều cao của AppBar
        child: AppBar(
          backgroundColor: Colors.white,
          title: Text('History', style: TextStyle(color: Colors.black, fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/background_black.jpg'),
              fit: BoxFit.cover
          ),
        ),
        //child: ,
      ),
    );;
  }
}
