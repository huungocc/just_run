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
          Column(
            children: [
              Container(
                width: 150,
                height: 150,
                margin: EdgeInsets.fromLTRB(10, 20, 10, 10),
                child: Image.asset('assets/map-1.jpg', fit: BoxFit.cover),
              ),
              Container(
                width: 150,
                height: 150,
                margin: EdgeInsets.all(10),
                child: Image.network('https://cdn.britannica.com/13/134213-159-1DEC3447/World-map-Theatrum-orbis-terrarum-Abraham-Ortelius-1570.jpg', fit: BoxFit.cover),
              ),
            ]
          ),
          Column(
            children: [
              Container(
                width: 150,
                height: 150,
                child: Center(child: Text('This is a World Map', style: TextStyle(color: Colors.red[400], fontFamily: 'Caveat Variable', fontSize: 20)))
              ),
              Container(
                width: 150,
                height: 150,
                child: Center(
                  child:
                    ElevatedButton.icon(
                      onPressed: (){},
                      label: Text('Map', style: TextStyle(color: Colors.white)),
                      icon: Icon(Icons.map, color: Colors.white, weight: 100),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
                    )
                ),
              )
            ]
          )
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


