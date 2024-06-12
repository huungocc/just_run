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
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red[400],
      ),
      body: Center(
        child:
        //Image.network('https://i5.walmartimages.com/seo/24x36-United-States-USA-US-Premier-Wall-Map-Paper-Folded_82a3e3b2-6590-4463-8b72-f603f6ec86aa.499cf7bb657e73df5a9d97ffff412cb9.jpeg'),
        Image.asset('assets/map-1.jpg'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        child: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}


