import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/running');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  backgroundColor: Colors.grey[850],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('Free', style: TextStyle(fontSize: 20.0, color: Colors.white, fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      String limit = ''; // Biến để lưu dữ liệu nhập vào
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        title: Text('Enter your limit (km)', style: TextStyle(fontSize: 20.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
                        content: TextField(
                          onChanged: (value) {
                            limit = value;
                          },
                          decoration: InputDecoration(
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel', style: TextStyle(fontSize: 20.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/running');
                            },
                            child: Text('OK', style: TextStyle(fontSize: 18.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  backgroundColor: Colors.redAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('Limit', style: TextStyle(fontSize: 20.0, color: Colors.white, fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Chiều cao của AppBar
        child: AppBar(
          backgroundColor: Colors.white,
          leading: Row(
            children: [
              SizedBox(width: 20),
              CircleAvatar(
                backgroundImage: AssetImage('assets/default.png'),
                radius: 18,
              ),
            ],
          ),
          title: Text(
            'Hi, user_name',
            style: TextStyle(color: Colors.black, fontFamily: 'Blinker', fontWeight: FontWeight.bold),
          ),
          actions: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  icon: Icon(Icons.logout_outlined, color: Colors.black),
                ),
                SizedBox(width: 12)
              ],
            )
          ],
          centerTitle: true,
          elevation: 4,
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  _buildSizedCardIcon('Network', Icons.wifi, _changeNetworkStatus as VoidCallback),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                children: [
                  _buildSizedCardIcon('History', Icons.play_arrow, _navigateToHistory as VoidCallback),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  _buildSizedCardText('Age', '20', _changeInformation as VoidCallback),
                  _buildSizedCardText('Height (cm)', '160', _changeInformation as VoidCallback),
                  _buildSizedCardText('Weight (kg)', '57', _changeInformation as VoidCallback),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 80.0, // Tăng chiều cao của thanh dock để chứa FAB
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                child: FloatingActionButton(
                  onPressed: () {
                    _showOptions(context);
                  },
                  child: Icon(Icons.play_arrow, color: Colors.redAccent, size: 36.0),
                  backgroundColor: Colors.grey[850],
                  shape: CircleBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: null,
    );
  }

  Widget _buildSizedCardText(String title, String description, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        width: double.infinity,
        height: 80.0,
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Card(
          elevation: 5.0,
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
                Text(
                  description,
                  style: TextStyle(fontFamily: 'Blinker', fontSize: 20, fontWeight: FontWeight.bold,),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSizedCardIcon(String title, IconData iconData, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        width: double.infinity,
        height: 80.0,
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Card(
          elevation: 5.0,
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
                Icon(iconData)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToHistory() {
    Navigator.pushNamed(context, '/history');
  }

  void _changeNetworkStatus() {
    //xử lí
  }

  void _changeInformation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String infor = ''; // Biến để lưu dữ liệu nhập vào
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text('Change Information', style: TextStyle(fontSize: 20.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
          content: TextField(
            onChanged: (value) {
              infor = value;
            },
            decoration: InputDecoration(
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(fontSize: 20.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                //
              },
              child: Text('OK', style: TextStyle(fontSize: 18.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

