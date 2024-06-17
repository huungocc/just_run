import 'package:flutter/material.dart';

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
    return Scaffold(
      body:
        SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/location');
                    },
                    icon: Icon(Icons.edit_location),
                    label: Text('Location'),
                  ),
                  SizedBox(height: 20),
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
                  SizedBox(height: 200),
                ],
              ),
            ],
          )
        )
    );
  }
}
