import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

class Loading extends StatefulWidget {
  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  void getTime() async{
    Response response = await get(Uri.parse('http://worldtimeapi.org/api/timezone/Asia/Bangkok'));
    Map data = jsonDecode(response.body);
    //print(data);

    String datetime = data['datetime'];
    String offset = data['utc_offset'].substring(1,3);
    print(datetime);
    print(offset);

    //create a datetime object
    DateTime now = DateTime.parse(datetime);
    print(now);
  }

  @override
  void initState() {
    super.initState();
    getTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('loading screen')
    );
  }
}
