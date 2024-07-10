import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:just_run/routes.dart';
import 'package:just_run/services/data_service.dart';
import 'package:just_run/services/result_arguments.dart';

import 'package:vibration/vibration.dart';

class History extends StatefulWidget {
  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  User? _currentUser;
  List<String> historyDates = [];
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadHistoryDates();
  }

  void _loadCurrentUser() {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser;
    });
  }

  Future<void> _loadHistoryDates() async {
    setState(() {
      _isLoading = true;
    });

    var runningData = await DataService().loadRunningData(context, _currentUser!.uid);

    if (runningData != null) {
      setState(() {
        historyDates = runningData.map<String>((data) => data['dateTime']).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            AppLocalizations.of(context)!.historyCardTitle,
            style: TextStyle(color: Colors.black, fontFamily: 'Blinker', fontWeight: FontWeight.bold),
          ),
          actions: historyDates.isEmpty
            ? []
            : [ Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _onDeleteAllPressed(context);
                    },
                    icon: Icon(Icons.delete_outline_rounded, color: Colors.black),
                  ),
                  SizedBox(width: 8)
                ],
              )
            ],
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
        child:  _isLoading
            ? Center(child: SpinKitThreeBounce(color: Colors.white, size: 30.0))
            : historyDates.isEmpty
            ? Center(
              child: Text(
                AppLocalizations.of(context)!.noHistoryFound,
                style: TextStyle(color: Colors.white, fontSize: 20.0, fontFamily: 'Blinker', fontWeight: FontWeight.bold),
              ),
            )
            : Scrollbar(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: RefreshIndicator(
                  onRefresh: _loadHistoryDates,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: _buildHistoryCards(),
                    ),
                  ),
                ),
              ),
        ),
      ),
    );;
  }

  List<Widget> _buildHistoryCards() {
    return historyDates.map((date) {
      return _buildHistoryCard(date, () {
        _onHistoryPressed(context, date);
      }, () {
        _onHistoryLongPressed(context, date);
      });
    }).toList();
  }

  Widget _buildHistoryCard(String title, VoidCallback onTap, VoidCallback onLongPress) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
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

  void _onHistoryPressed(BuildContext context, String dateTime) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: SpinKitThreeBounce(color: Colors.white, size: 30.0),
        );
      },
    );

    List<Map<String, dynamic>>? runningData = await DataService().loadRunningData(context, _currentUser!.uid);
    if (runningData != null) {
      var selectedData = runningData.firstWhere((data) => data['dateTime'] == dateTime);
      if (selectedData != null) {
        Navigator.pop(context);
        Navigator.pushNamed(context, Routes.result, arguments: ResultArguments(
          dateTime: selectedData['dateTime'],
          totalDistance: selectedData['totalDistance'],
          totalTime: Duration(seconds: selectedData['totalTime']),
          totalSteps: selectedData['totalSteps'],
          totalCalories: selectedData['totalCalories'],
          polylines: selectedData['polylines'],
        ));
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.loadDataFailed + ': $dateTime')),
        );
      }
    }
  }

  Future<void> _onHistoryLongPressed(BuildContext context, String dateTime) async {
    Vibration.vibrate(duration: 100, amplitude: 64);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Text(AppLocalizations.of(context)!.deleteEachTitle, style: TextStyle(fontSize: 22.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text(AppLocalizations.of(context)!.cancelButton, style: TextStyle(fontSize: 20.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () async {
              await DataService().deleteEachRunningData(context, _currentUser!.uid, dateTime);
              Navigator.pop(context, true);
              _loadHistoryDates();
            },
            child: Text(AppLocalizations.of(context)!.deleteButton, style: TextStyle(fontSize: 20.0, color: Colors.redAccent, fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  Future<void> _onDeleteAllPressed(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Text(AppLocalizations.of(context)!.deleteAllTitle, style: TextStyle(fontSize: 22.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text(AppLocalizations.of(context)!.cancelButton, style: TextStyle(fontSize: 20.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () async {
              await DataService().deleteAllRunningData(context, _currentUser!.uid);
              Navigator.pop(context, true);
              _loadHistoryDates();
            },
            child: Text(AppLocalizations.of(context)!.deleteButton, style: TextStyle(fontSize: 20.0, color: Colors.redAccent, fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }
}
