import 'package:flutter/material.dart';

class Running extends StatefulWidget {
  @override
  State<Running> createState() => _RunningState();
}

class _RunningState extends State<Running> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Chiều cao của AppBar
        child: AppBar(
          backgroundColor: Colors.white,
          title: Text('Running', style: TextStyle(color: Colors.black, fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
      ),
    );
  }
}
