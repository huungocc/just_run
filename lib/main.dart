import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: NgocCard(),
  ));
}

class NgocCard extends StatefulWidget {

  @override
  State<NgocCard> createState() => _NgocCardState();
}

class _NgocCardState extends State<NgocCard> {
  int level = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title:
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.credit_card, size: 38, color: Colors.grey[200]),
            SizedBox(width: 10),
            Text('ID Card', style: TextStyle(color: Colors.grey[200], fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/ngoc_avt.png'),
                radius: 70,
              ),
            ),
            Divider(
              height: 60,
              color: Colors.grey[700],
            ),
            Text('NAME  ', style: TextStyle(color: Colors.grey[400], fontSize: 15)),
            Text('NGUYEN HUU NGOC', style: TextStyle(color: Colors.amberAccent, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('D.O.B', style: TextStyle(color: Colors.grey[400], fontSize: 15)),
            Text('03/10/2003', style: TextStyle(color: Colors.amberAccent, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('LEVEL', style: TextStyle(color: Colors.grey[400], fontSize: 15)),
            Text('$level', style: TextStyle(color: Colors.amberAccent, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          setState((){
            level ++;
          });
        },
        backgroundColor: Colors.blueGrey[700],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}



