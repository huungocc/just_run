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
    //lay data thanh map
    data = data.isNotEmpty ? data : ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    //print(data);

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
                      style: TextStyle(fontFamily: 'Anton', fontSize: 35, color: Colors.blueGrey[900]),
                    ),
                    Text(
                      data['time'],
                      style: TextStyle(fontFamily: 'Anton', fontSize: 75, color: Colors.blueGrey[900]),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        dynamic result = await Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ChooseLocation(bgColor: bgColor),
                          ),
                        );
                        if(result != null){
                          setState(() {
                            data = {
                              'location': result['location'],
                              'time': result['time'],
                              'isDayTime': result['isDayTime']
                            };
                          });
                        }
                      },
                      icon: Icon(Icons.edit_location, color: Colors.redAccent),
                      label: Text('Location', style: TextStyle(fontFamily: 'Anton', color: Colors.redAccent)),
                      style: TextButton.styleFrom(backgroundColor: Colors.transparent),
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
