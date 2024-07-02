import 'package:flutter/material.dart';

import 'package:just_run/routes.dart';

class History extends StatefulWidget {
  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Chiều cao của AppBar
        child: AppBar(
          backgroundColor: Colors.white,
          title: Text('History', style: TextStyle(color: Colors.black, fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/background_black.jpg'),
              fit: BoxFit.cover
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            children: [
              _buildHistoryCard('26/06/2024', _onHistoryPressed),
              _buildHistoryCard('25/06/2024', _onHistoryPressed),
              _buildHistoryCard('24/06/2024', _onHistoryPressed),
            ],
          ),
        ),
      ),
    );;
  }

  Widget _buildHistoryCard(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        width: double.infinity,
        height: 80.0,
        margin: EdgeInsets.symmetric(vertical: 4.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 20.0, fontFamily: 'Blinker', fontWeight: FontWeight.bold),
                ),
                Icon(Icons.play_arrow)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onHistoryPressed(){
    Navigator.pushNamed(context, Routes.result);
  }

}
