import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home: Home(),
));

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FIRST APP',
          style: TextStyle(
            fontFamily: 'Caveat Variable',
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red[400],
      ),
      body: Center(
        child:
          ////TextButton(
          // ElevatedButton(
          //   onPressed: () {
          //     print('clicked');
          //   },
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.red[400],
          //   ),
          //   child: Text(
          //     'Please Click!',
          //     style: TextStyle(
          //       fontFamily: 'Caveat Variable',
          //       fontSize: 20,
          //       color: Colors.black,
          //     ),
          //   ),
          // ),

          // ElevatedButton.icon(
          //   onPressed: () {},
          //   icon: Icon(Icons.cabin),
          //   label: Text('cabin', style: TextStyle(color: Colors.white)),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.red[400],
          //     iconColor: Colors.white
          //   ),
          // ),

        IconButton(
          onPressed: () {
            print('Cabin');
          },
          icon: Icon(Icons.cabin),
          color: Colors.red[400],
        )
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        child: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}


