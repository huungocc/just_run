import 'package:flutter/material.dart';
import 'package:ngocapp/services/world_time.dart';

class ChooseLocation extends StatefulWidget {
  final Color? bgColor;

  ChooseLocation({Key? key, this.bgColor}) : super(key: key);

  @override
  State<ChooseLocation> createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {
  List<WorldTime> locations = [
    WorldTime(url: 'Europe/London', location: 'London'),
    WorldTime(url: 'Europe/Berlin', location: 'Athens'),
    WorldTime(url: 'Africa/Cairo', location: 'Cairo'),
    WorldTime(url: 'Africa/Nairobi', location: 'Nairobi'),
    WorldTime(url: 'America/Chicago', location: 'Chicago'),
    WorldTime(url: 'America/New_York', location: 'New York'),
    WorldTime(url: 'Asia/Seoul', location: 'Seoul'),
    WorldTime(url: 'Asia/Jakarta', location: 'Jakarta'),
  ];

  void updateTime(index) async {
    WorldTime instance = locations[index];
    await instance.getTime();
    Navigator.pop(context, {
      'location': instance.location,
      'time': instance.time,
      'isDayTime': instance.isDayTime
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.bgColor,
      appBar: AppBar(
        backgroundColor: widget.bgColor,
        title: Text('Choose a location', style: TextStyle(fontFamily: 'Anton')),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, index){
          return Padding(
            padding: const EdgeInsets.all(3.0),
            child: Card(
              child: ListTile(
                onTap: () {
                  updateTime(index);
                },
                title: Text(locations[index].location, style: TextStyle(fontFamily: 'Anton')),
              ),
            ),
          );
        },
      ),
    );
  }
}
