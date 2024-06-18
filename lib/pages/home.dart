import 'package:flutter/material.dart';
import 'choose_location.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map data = {};

  Timer? _timer;
  DateFormat _dateFormat = DateFormat('HH:mm:ss');
  DateTime? currentTime;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (currentTime != null) {
          currentTime = currentTime!.add(Duration(seconds: 1));
        }
      });
    });
  }

  void updateTimeFromData(String time) {
    currentTime = DateFormat('HH:mm:ss').parse(time);
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    if (data.isNotEmpty && currentTime == null) {
      updateTimeFromData(data['time']);
    }

    String bgImage = data['isDayTime'] ? 'day.png' : 'night.png';
    Color? bgColor = data['isDayTime'] ? Colors.blue[200] : Colors.red[300];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/$bgImage'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data['location'],
                    style: TextStyle(fontFamily: 'Anton', fontSize: 35, color: Colors.blueGrey[900]),
                  ),
                  Text(
                    currentTime != null ? _dateFormat.format(currentTime!) : '',
                    style: TextStyle(fontFamily: 'Anton', fontSize: 75, color: Colors.blueGrey[900]),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      dynamic result = await Navigator.push(context, MaterialPageRoute(
                        builder: (context) => ChooseLocation(bgColor: bgColor),
                      ));
                      if (result != null) {
                        setState(() {
                          data = {
                            'location': result['location'],
                            'time': result['time'],
                            'isDayTime': result['isDayTime']
                          };
                          updateTimeFromData(result['time']);
                        });
                      }
                    },
                    icon: Icon(Icons.edit_location, color: Colors.teal),
                    label: Text('Location', style: TextStyle(fontFamily: 'Anton', color: Colors.teal)),
                    style: TextButton.styleFrom(backgroundColor: Colors.white70),
                  ),
                  SizedBox(height: 200),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
