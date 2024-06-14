import 'package:flutter/material.dart';

class ChooseLocation extends StatefulWidget {
  @override
  State<ChooseLocation> createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Choose a location'),
        centerTitle: true,
      ),
      body:
        TextButton(
          onPressed: (){
            setState(() {
              counter ++;
            });
          },
          child: Text('counter is $counter'),
        )
    );
  }
}
