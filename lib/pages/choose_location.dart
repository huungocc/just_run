import 'package:flutter/material.dart';

class ChooseLocation extends StatefulWidget {
  @override
  State<ChooseLocation> createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {
  int counter = 0;

  void getData() async{
    String username = await Future.delayed(Duration(seconds: 3), () { return 'ngoc'; });
    String bio = await Future.delayed(Duration(seconds: 2), () { return 'vietnam'; });

    print('$username - $bio');
  }

  @override
  void initState() {
    super.initState();
    getData();
    print('initState');
  }

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
