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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              child:
                Image.asset('assets/map-1.jpg', fit: BoxFit.cover)
            ),
          ),
          Container(
            child:
              ElevatedButton(
                onPressed: (){},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
                child: Text('This is a World Map', style: TextStyle(color: Colors.white)),
              )
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blueAccent[100],
              height: 100,
            ),
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


