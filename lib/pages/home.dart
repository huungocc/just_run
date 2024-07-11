import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_run/manager/fonts.dart';

import 'package:just_run/manager/routes.dart';
import 'package:just_run/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:just_run/services/data_service.dart';
import 'package:just_run/services/user_arguments.dart';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:permission_handler/permission_handler.dart' as permission_pack;

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
    _requestPermission();
    _internetCheck();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _internetConnection?.cancel();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    final activityRecognitionStatus = await permission_pack.Permission.activityRecognition.status;
    final locationStatus = await permission_pack.Permission.location.status;
    //Activity Recognition Permission
    if (!activityRecognitionStatus.isGranted) {
      final activityRecognitionRequest = await permission_pack.Permission.activityRecognition.request();
      if (activityRecognitionRequest.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.activityRecognitionDenied),
          ),
        );
      }
    }
    //Location Permission
    if (!locationStatus.isGranted) {
      final locationRequest = await permission_pack.Permission.location.request();
      if (locationRequest.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.locationDenied),
          ),
        );
      }
    }
  }

  void _loadCurrentUser() {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser;
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    if (_currentUser != null) {
      var userData = await _dataService.loadUserData(context, _currentUser!.uid);
      setState(() {
        _currentUserData = userData;
        currentUserWeight = userData?['weight']?.toString() ?? 'no data';
      });
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
    String limit = '0';
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
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    Routes.running,
                    arguments: RunningArguments(_currentUserData?['weight'] ?? 0, limit),
                  );
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
                  style: TextStyle(fontSize: 20.0, color: Colors.white, fontFamily: Fonts.display_font, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
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
                          style: TextStyle(fontSize: 20.0, color: Colors.grey[850], fontFamily: Fonts.display_font, fontWeight: FontWeight.bold),
                        ),
                        content: TextField(
                          cursorColor: Colors.black,
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
                              style: TextStyle(fontSize: 20.0, color: Colors.grey[850], fontFamily: Fonts.display_font, fontWeight: FontWeight.bold),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                context,
                                Routes.running,
                                arguments: RunningArguments(_currentUserData?['weight'] ?? 0, limit),
                              );
                            },
                            child: Text(
                              AppLocalizations.of(context)!.okButton,
                              style: TextStyle(fontSize: 18.0, color: Colors.grey[850], fontFamily: Fonts.display_font, fontWeight: FontWeight.bold),
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
                  style: TextStyle(fontSize: 20.0, color: Colors.black, fontFamily: Fonts.display_font, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInternetStatus(BuildContext context){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.internetStatus),
      ),
    );
  }

  void _settingScreen() {
    Navigator.pushNamed(context, Routes.setting);
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
              GestureDetector(
                onTap: _settingScreen,
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/default.png'),
                  foregroundImage: NetworkImage(_currentUser!.photoURL!),
                  radius: 18,
                ),
              ),
            ],
          ),
          title: Text(
            _currentUser?.displayName ?? AppLocalizations.of(context)!.offlineModeTitle,
            style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: Fonts.display_font, fontWeight: FontWeight.bold),
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
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background_black.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: RefreshIndicator(
          color: Colors.black,
          onRefresh: _loadUserData,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
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
                  style: TextStyle(fontSize: 20.0, fontFamily: Fonts.display_font, fontWeight: FontWeight.bold,),
                ),
                Icon(Icons.play_arrow),
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

}
