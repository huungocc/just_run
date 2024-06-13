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
          'HUU NGOC',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        //centerTitle: true,
        backgroundColor: Colors.red[400],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 150,
            height: 150,
            child: Image.asset('assets/map-1.jpg', fit: BoxFit.cover),
          ),
          Container(
            child: Text('This is a World Map', style: TextStyle(color: Colors.red[400], fontFamily: 'Caveat Variable')),
          ),
          Container(
            child:
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.map),
                color: Colors.red[400],
              )
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        child: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}


