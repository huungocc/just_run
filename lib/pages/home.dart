import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:just_run/routes.dart';
import 'package:just_run/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _authService = AuthService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser;
    });
  }

  Future<void> _signOut() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: SpinKitThreeBounce(
            color: Colors.redAccent,
            size: 50.0,
          ),
        );
      },
    );
    await _authService.signOut(context);
    Navigator.pushReplacementNamed(context, Routes.login);
  }

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
                  Navigator.pushNamed(context, Routes.running);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  backgroundColor: Colors.grey[850],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.freeButton,
                  style: TextStyle(fontSize: 20.0, color: Colors.white, fontFamily: 'Blinker', fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      String limit = '';
                      FocusNode focusNode = FocusNode();

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        FocusScope.of(context).requestFocus(focusNode);
                      });

                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        title: Text(
                          AppLocalizations.of(context)!.enterLimitTitle,
                          style: TextStyle(fontSize: 20.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold),
                        ),
                        content: TextField(
                          focusNode: focusNode,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            limit = value;
                          },
                          decoration: InputDecoration(),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              AppLocalizations.of(context)!.cancelButton,
                              style: TextStyle(fontSize: 20.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, Routes.running);
                            },
                            child: Text(
                              AppLocalizations.of(context)!.okButton,
                              style: TextStyle(fontSize: 18.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold),
                            ),
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
                child: Text(
                  AppLocalizations.of(context)!.limitButton,
                  style: TextStyle(fontSize: 20.0, color: Colors.black, fontFamily: 'Blinker', fontWeight: FontWeight.bold),
                ),
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
                foregroundImage: NetworkImage(_currentUser!.photoURL!),
                radius: 18,
              ),
            ],
          ),
          title: Text(
            _currentUser?.displayName ?? AppLocalizations.of(context)!.offlineModeTitle,
            style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'Kanit', fontWeight: FontWeight.bold),
          ),
          actions: [
            Row(
              children: [
                IconButton(
                  onPressed: _signOut,
                  icon: Icon(Icons.logout_outlined, color: Colors.black),
                ),
                SizedBox(width: 12),
              ],
            ),
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
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                children: [
                  _buildNetworkCard(AppLocalizations.of(context)!.networkCardTitle, Icons.wifi),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  _buildInformationCard(AppLocalizations.of(context)!.ageTitle, '20', _changeInformation),
                  _buildInformationCard(AppLocalizations.of(context)!.heightTitle, '160', _changeInformation),
                  _buildInformationCard(AppLocalizations.of(context)!.weightTitle, '57', _changeInformation),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  _buildHistoryCard(AppLocalizations.of(context)!.historyCardTitle, _navigateToHistory),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 80.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                child: FloatingActionButton(
                  onPressed: () {
                    _showOptions(context);
                  },
                  child: Icon(Icons.directions_run_rounded, color: Colors.redAccent, size: 30.0),
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

  Widget _buildInformationCard(String title, String description, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        width: double.infinity,
        height: 50.0,
        margin: EdgeInsets.symmetric(vertical: 2.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 20.0, fontFamily: 'Blinker', fontWeight: FontWeight.bold,),
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

  Widget _buildHistoryCard(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        width: double.infinity,
        height: 80.0,
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Card(
          color: Colors.redAccent,
          elevation: 5.0,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 20.0, fontFamily: 'Blinker', fontWeight: FontWeight.bold,),
                ),
                Icon(Icons.play_arrow),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkCard(String title, IconData iconData) {
    return GestureDetector(
      child: Container(
        width: double.infinity,
        height: 50.0,
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Card(
          color: Colors.grey[850],
          elevation: 5.0,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 20.0, color: Colors.white, fontFamily: 'Blinker', fontWeight: FontWeight.bold,),
                ),
                Icon(iconData, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToHistory() {
    Navigator.pushNamed(context, Routes.history);
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
          title: Text(
            AppLocalizations.of(context)!.changeInformationTitle,
            style: TextStyle(fontSize: 20.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold,),
          ),
          content: TextField(
            onChanged: (value) {
              infor = value;
            },
            decoration: InputDecoration(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context)!.cancelButton,
                style: TextStyle(fontSize: 20.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold,),
              ),
            ),
            TextButton(
              onPressed: () {
                // Perform update information logic here
              },
              child: Text(
                AppLocalizations.of(context)!.okButton,
                style: TextStyle(fontSize: 18.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
