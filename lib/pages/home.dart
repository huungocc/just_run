import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:just_run/routes.dart';
import 'package:just_run/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:just_run/services/data_service.dart';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _authService = AuthService();
  final DataService _dataService = DataService();
  User? _currentUser;
  Map<String, dynamic>? _currentUserData;
  String currentUserAge = '', currentUserHeight = '', currentUserWeight = '';

  bool isConnected = false;
  StreamSubscription ? _internetConnection;

  @override
  void initState() {
    super.initState();
    _internetCheck();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _internetConnection?.cancel();
    super.dispose();
  }

  void _loadCurrentUser() {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser;
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    try {
      if (_currentUser != null) {
        var userData = await _dataService.loadUserData(context, _currentUser!.uid);
        setState(() {
          _currentUserData = userData;
        });
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load user data: $e'),
        ),
      );
    }
  }


  Future<void> _signOut() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: SpinKitThreeBounce(
            color: Colors.black,
            size: 30.0,
          ),
        );
      },
    );

    await _authService.signOut(context);
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, Routes.login);
  }


  void _internetCheck() {
    _internetConnection = InternetConnection().onStatusChange.listen((event) {
      switch (event) {
        case InternetStatus.connected:
          setState(() {
            isConnected = true;
          });
          break;
        case InternetStatus.disconnected:
          setState(() {
            isConnected = false;
          });
          break;
        default:
          setState(() {
            isConnected = false;
          });
          break;
      }
    });
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

  void _showInternetStatus(BuildContext context){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Text(AppLocalizations.of(context)!.internetStatus, style: TextStyle(fontSize: 22.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.okButton, style: TextStyle(fontSize: 20.0, color: Colors.redAccent, fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
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
                  onPressed: () {
                    if (isConnected) {
                      _signOut();
                    } else {
                      _showInternetStatus(context);
                    }
                  },
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
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
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
                      _buildNetworkCard(AppLocalizations.of(context)!.networkCardTitle, isConnected ? Icons.wifi : Icons.wifi_off),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      _buildInformationCard(AppLocalizations.of(context)!.ageTitle, () {
                        _changeInformation(currentUserAge);
                      }),
                      _buildInformationCard(AppLocalizations.of(context)!.heightTitle, () {
                        _changeInformation(currentUserHeight);
                      }),
                      _buildInformationCard(AppLocalizations.of(context)!.weightTitle, () {
                        _changeInformation(currentUserWeight);
                      }),
          
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

  Widget _buildInformationCard(String title, VoidCallback onTap) {
    String currentValue = '';
    if (_currentUserData != null) {
      if (title == AppLocalizations.of(context)!.ageTitle) {
        currentValue = _currentUserData!['age']?.toString() ?? 'no data';
      } else if (title == AppLocalizations.of(context)!.heightTitle) {
        currentValue = _currentUserData!['height']?.toString() ?? 'no data';
      } else if (title == AppLocalizations.of(context)!.weightTitle) {
        currentValue = _currentUserData!['weight']?.toString() ?? 'no data';
      }
    }
    return GestureDetector(
      onTap: onTap,
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
                  style: TextStyle(fontSize: 20.0, fontFamily: 'Blinker', fontWeight: FontWeight.bold),
                ),
                Text(
                  currentValue,
                  style: TextStyle(fontFamily: 'Blinker', fontSize: 20, fontWeight: FontWeight.bold),
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
                Icon(iconData, color: isConnected ? Colors.greenAccent : Colors.redAccent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToHistory() {
    isConnected ? Navigator.pushNamed(context, Routes.history) : _showInternetStatus(context);
  }

  void _changeInformation(String field) {
    isConnected ? showDialog(
      context: context,
      builder: (BuildContext context) {
        String? ageValue = _currentUserData?['age']?.toString() ?? '';
        String? heightValue = _currentUserData?['height']?.toString() ?? '';
        String? weightValue = _currentUserData?['weight']?.toString() ?? '';

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(
            AppLocalizations.of(context)!.changeInformationTitle,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.grey[850],
              fontFamily: 'Blinker',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: ageValue),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  ageValue = value;
                },
                decoration: InputDecoration(labelText: 'Age', labelStyle: TextStyle(fontFamily: 'Blinker')),
              ),
              TextField(
                controller: TextEditingController(text: heightValue),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  heightValue = value;
                },
                decoration: InputDecoration(labelText: 'Height (cm)', labelStyle: TextStyle(fontFamily: 'Blinker')),
              ),
              TextField(
                controller: TextEditingController(text: weightValue),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  weightValue = value;
                },
                decoration: InputDecoration(labelText: 'Weight (kg)', labelStyle: TextStyle(fontFamily: 'Blinker')),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context)!.cancelButton,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.grey[850],
                  fontFamily: 'Blinker',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Update user data
                if (_currentUser != null) {
                  await _dataService.saveUserData(
                    context, _currentUser!.uid,
                    int.tryParse(ageValue ?? '0') ?? 0,
                    double.tryParse(heightValue ?? '0.0') ?? 0.0,
                    double.tryParse(weightValue ?? '0.0') ?? 0.0,
                  );
                  _loadUserData();
                }
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context)!.okButton,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.grey[850],
                  fontFamily: 'Blinker',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    ) : _showInternetStatus(context);
  }
}
