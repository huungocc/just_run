import 'package:flutter/material.dart';
import 'package:ngocapp/services/world_time.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  String time = 'Loading';

  Future <void> setupWorldTime() async {
    WorldTime instance = WorldTime(location: 'Berlin',url: 'Europe/Berlin');
    await instance.getTime();
    Navigator.pushReplacementNamed(context, '/home', arguments: {
      'location': instance.location,
      'time': instance.time,
      'isDayTime': instance.isDayTime
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
      backgroundColor: Colors.white,
      body: Center(
        child: SpinKitThreeBounce(
          color: Colors.black,
          size: 30,
        )
      )
    );
  }
}
