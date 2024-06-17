import 'package:flutter/material.dart';
import 'package:ngocapp/services/world_time.dart';

class Loading extends StatefulWidget {
  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  String time = 'Loading';

  Future <void> setupWorldTime() async {
    WorldTime instance = WorldTime(location: 'Berlin',flag: 'berlin.png',url: 'Europe/Berlin');
    await instance.getTime();
    print(instance.time);
    setState(() {
      time = instance.time ?? 'Loading';
    });
  }

  @override
  void initState() {
    super.initState();
    setupWorldTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(50),
        child: Text(time),
      )
    );
  }
}
