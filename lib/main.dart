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
            fontFamily: 'Caveat Variable',
            color: Colors.white,
          ),
        ),
        //centerTitle: true,
        backgroundColor: Colors.red[400],
      ),
      body: Container(
        color: Colors.grey[400],
        child: Text('hello'),
        margin: EdgeInsets.fromLTRB(20, 30, 40, 30),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        child: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}


