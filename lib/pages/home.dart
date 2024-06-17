import 'package:flutter/material.dart';

import 'choose_location.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map data = {};

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    print(data);
    String bgImage = data['isDayTime'] ? 'day.png' : 'night.png';
    Color? bgColor = data['isDayTime'] ? Colors.blue[200] : Colors.deepOrangeAccent;

    return Scaffold(
      body:
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/$bgImage'),
              fit: BoxFit.cover
            )
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
                      style: TextStyle(
                        fontSize: 35,
                      ),
                    ),
                    Text(
                      data['time'],
                      style: TextStyle(
                      fontSize: 65,
                    ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ChooseLocation(bgColor: bgColor),
                          ),
                        );
                      },
                      icon: Icon(Icons.edit_location, color: Colors.black),
                      label: Text('Location', style: TextStyle(color: Colors.black)),
                      style: TextButton.styleFrom(backgroundColor: Colors.transparent,),
                    ),

                    SizedBox(height: 200),
                  ],
                ),
              ],
            )
          ),
        )
    );
  }
}
