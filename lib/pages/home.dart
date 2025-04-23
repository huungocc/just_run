import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:just_run/manager/background_title.dart';
import 'package:just_run/services/background_service.dart';
import 'package:just_run/services/database_helper.dart';
import 'package:page_view_indicators/page_view_indicators.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_run/manager/fonts.dart';

import 'package:just_run/manager/routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:just_run/services/data_service.dart';
import 'package:just_run/services/user_arguments.dart';
import 'package:just_run/services/network_service.dart';
import 'package:pedometer/pedometer.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:permission_handler/permission_handler.dart' as permission_pack;
import 'package:flutter_background_service/flutter_background_service.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DataService _dataService = DataService();
  User? _currentUser;
  Map<String, dynamic>? _currentUserData;
  Map<String, dynamic>? _currentLimitData;
  String currentUserWeight = '', currentUserHeight = '';

  final NetworkService _networkService = NetworkService();

  final _currentPageNotifier = ValueNotifier<int>(0);

  late StreamSubscription<StepCount> dailyStepsCountStream;

  bool isStarting = false;
  bool isForeground = false;
  int _startSteps = 0, _todaySteps = 0;
  double _todayCalories = 0;
  String currentLimitSteps = '0', currentLimitCalories = '0';

  late Timer _timer;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<String> last7Days = [];

  @override
  void initState() {
    super.initState();
    _loadChart();
    _requestPermission();
    initializeStepService();
    _loadCurrentUser();
    _startTimer();
  }

  void initializeStepService() async {
    await _checkDate();
    _loadLimitDataFromDatabase();
    if(_networkService.connectionStatus && currentLimitSteps == 0 && currentLimitCalories == 0){
      _loadLimitDataFromFirestore();
    }
    _onPressedCount();
  }

  @override
  void dispose() {
    _networkService.dispose();
    _timer.cancel();
    stopPedometer();
    //save _todaySteps, _todayCalories
    _saveDailyDataToDatabase();
    _saveDailyDataToFirestore();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(minutes: 30), (timer) async {
      await _checkDate();
    });
  }

  Future<void> _saveDailyDataToDatabase() async {
    String today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    await _dbHelper.saveData(today, _todaySteps, _startSteps, _todayCalories);
  }

  Future<void> _saveDailyDataToFirestore() async {
    String today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    if(_networkService.connectionStatus) {
      if (_currentUser != null) {
        await _dataService.saveDailyData(
            context,
            _currentUser!.uid,
            today,
            _todaySteps,
            _startSteps,
            _todayCalories
        );
      }
    }
  }

  Future<void> _checkDate() async {
    String today = DateFormat('dd-MM-yyyy').format(DateTime.now());

    String? _lastestDateFromDatabase = await _dbHelper.loadLatestDate();
    int? _startStepsFromDatabase = await _dbHelper.loadStartSteps(today);

    if (today != _lastestDateFromDatabase){
      setState(() {
        _startSteps = 0;
      });
    } else {
      setState(() {
        _startSteps = _startStepsFromDatabase!;
      });
    }

    if(_networkService.connectionStatus && _lastestDateFromDatabase == null && _startStepsFromDatabase == null){
      String? _loadDateKey = await _dataService.loadLatestDate(context, _currentUser!.uid);
      int? _loadStartSteps = await _dataService.loadStartSteps(context, _currentUser!.uid, today);
      if (today != _loadDateKey){
        setState(() {
          _startSteps = 0;
        });
      } else {
        setState(() {
          _startSteps = _loadStartSteps!;
        });
      }
    }
  }

  Future<void> _requestPermission() async {
    final activityRecognitionStatus = await permission_pack.Permission.activityRecognition.status;
    final locationStatus = await permission_pack.Permission.location.status;
    final notificationStatus = await permission_pack.Permission.notification.status;
    final batteryStatus = await permission_pack.Permission.ignoreBatteryOptimizations.status;
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
    //Notification Permission
    if (!notificationStatus.isGranted) {
      final notificationRequest = await permission_pack.Permission.notification.request();
      if (notificationRequest.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.notificationDenied),
          ),
        );
      }
    }
    //Ignore Battery Optimizations
    if (!batteryStatus.isGranted) {
      final batteryRequest = await permission_pack.Permission.ignoreBatteryOptimizations.request();
      if (batteryRequest.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.batteryDenied),
          ),
        );
      }
    }
  }

  Future<void> _startBackgroundService() async {
    initializeBackgroundService();
    FlutterBackgroundService().invoke(BackgroundTitle.foregroundService);
    isForeground = true;
  }

  Future<void> _stopBackgroundService() async {
    FlutterBackgroundService().invoke(BackgroundTitle.stopService);
    isForeground = false;
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
        currentUserWeight = userData?['weight']?.toString() ?? '0';
        currentUserHeight = userData?['height']?.toString() ?? '0';
      });
    }
  }

  Future<void> _saveLimitDataToDatabase(String limitStepsValue, String limitCaloriesValue) async {
    await _dbHelper.saveLimit(limitStepsValue, limitCaloriesValue);
  }

  Future<void> _saveLimitDataToFirestore(String limitStepsValue, String limitCaloriesValue) async {
    if(_currentUser != null) {
      await _dataService.saveLimitData(
          context, _currentUser!.uid,
          int.tryParse(limitStepsValue) ?? 0,
          double.tryParse(limitCaloriesValue) ?? 0.0
      );
    }
  }

  Future<void> _loadLimitDataFromDatabase() async {
    Map<String, String>? limits = await _dbHelper.loadLimit();
    currentLimitSteps = limits?['currentLimitSteps'] ?? '0';
    currentLimitCalories = limits?['currentLimitCalories'] ?? '0';
  }

  Future<void> _loadLimitDataFromFirestore() async {
    if (_currentUser != null) {
      var limitData = await _dataService.loadLimitData(
          context, _currentUser!.uid);
      setState(() {
        _currentLimitData = limitData;
        currentLimitSteps = limitData?['limitSteps']?.toString() ?? '0';
        currentLimitCalories = limitData?['limitCalories']?.toString() ?? '0';
      });
    }
  }

  // Future<void> _loadDailyDataFromFirestore() async {
  //   if (_currentUser != null) {
  //     var dailyData = await _dataService.loadDailyData(
  //         context, _currentUser!.uid);
  //     setState(() {
  //       _startSteps = dailyData?['startSteps'] ?? 0;
  //     });
  //   }
  // }

  double dailyStepsProgress () {
    if(int.parse(currentLimitSteps) >= _todaySteps && int.parse(currentLimitSteps) > 0) {
      return _todaySteps / int.parse(currentLimitSteps);
    } else if (_todaySteps == 0 || int.parse(currentLimitSteps) == 0) {
      return 0;
    } else {
      return 1;
    }
  }

  double dailyCaloriesProgress () {
    if(double.parse(currentLimitCalories) >= _todayCalories && double.parse(currentLimitCalories) > 0) {
      return _todayCalories / double.parse(currentLimitCalories);
    } else if (_todayCalories == 0 || double.parse(currentLimitCalories) == 0) {
      return 0;
    } else {
      return 1;
    }
  }

  void startPedometer() {
    dailyStepsCountStream = Pedometer.stepCountStream.listen((StepCount event) {
      if(_startSteps >= event.steps){
        _startSteps = 0;
      }
      if(_startSteps == 0) {
        _startSteps = event.steps;
        //save _startSteps
        _saveDailyDataToDatabase();
        _saveDailyDataToFirestore();
      }
      setState(() {
        _todaySteps = event.steps - _startSteps;
        _todayCalories = _calculateDailyCalories();
      });
    });
  }

  void stopPedometer() {
    dailyStepsCountStream.cancel();
  }

  void _onPressedCount() {
    if (isStarting) {
      stopPedometer();
      //save _todaySteps, _todayCalories
      _saveDailyDataToDatabase();
      _saveDailyDataToFirestore();
      //stop background
      _stopBackgroundService();
    }
    else {
      startPedometer();
      _startBackgroundService();
    }
    setState(() {
      isStarting = !isStarting;
    });
  }

  double _calculateDailyCalories() {
    double weight = double.parse(currentUserWeight);
    double stepLength = (double.parse(currentUserHeight) * 0.415) / 100;
    return _todaySteps * (weight / stepLength) * 0.57;
  }

  void _loadChart() {
    final DateFormat dateFormat = DateFormat('dd-MM');
    DateTime today = DateTime.now();
    for (int i = 1; i <= 7; i++) {
      setState(() {
        DateTime date = today.subtract(Duration(days: i));
        last7Days.add(dateFormat.format(date));
      });
    }
  }

  Future<void> _onRefresh() async{
    //
  }

  void _showOptions(BuildContext context) {
    String limit = '0';
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (isForeground == true){
                      stopPedometer();
                      _stopBackgroundService();
                      setState(() {
                        isStarting = !isStarting;
                      });
                    }
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
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.freeButton,
                    style: TextStyle(fontSize: 20.0, color: Colors.white, fontFamily: Fonts.display_font, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                width: MediaQuery.of(context).size.width * 0.44,
                child: ElevatedButton(
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
                            borderRadius: BorderRadius.circular(30.0),
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
                                stopPedometer();
                                _stopBackgroundService();
                                setState(() {
                                  isStarting = !isStarting;
                                });
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
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.limitButton,
                    style: TextStyle(fontSize: 20.0, color: Colors.grey[850], fontFamily: Fonts.display_font, fontWeight: FontWeight.bold),
                  ),
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
          backgroundColor: Colors.white70,
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
            style: TextStyle(fontSize: 18, color: Colors.grey[800], fontFamily: Fonts.display_font, fontWeight: FontWeight.bold),
          ),
          actions: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    _stopBackgroundService();
                    SystemNavigator.pop();
                  },
                  icon: Icon(Icons.power_settings_new_rounded, color: Colors.grey[800]),
                ),
                SizedBox(width: 12),
              ],
            ),
          ],
          centerTitle: true,
          elevation: 0,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        color: Colors.white70,
        child: RefreshIndicator(
          color: Colors.black,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          _buildDailyCard(AppLocalizations.of(context)!.stepsTitle, _todaySteps.toString(), isStarting ? Icons.pause : Icons.play_arrow, Colors.greenAccent, dailyStepsProgress(), _onPressedCount),
                          SizedBox(height: 5),
                          _buildDailyCard(AppLocalizations.of(context)!.caloriesTitle, _todayCalories.round().toString(), Icons.local_fire_department_rounded, Colors.redAccent, dailyCaloriesProgress(), null),
                        ],
                      ),
                      _buildProgressCard(),
                    ],
                  ),
                  SizedBox(height: 5),
                  _buildHistoryChartCard(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: Colors.white70,
        child: Container(
          height: 80.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  _navigateToReport();
                },
                icon: Icon(Icons.bar_chart_rounded, color: Colors.grey[800], size: 30),
              ),
              FloatingActionButton(
                onPressed: () {
                  _showOptions(context);
                },
                child: Icon(Icons.directions_run_rounded, color: Colors.redAccent, size: 30),
                backgroundColor: Colors.grey[800],
                shape: CircleBorder(),
                elevation: 0,
              ),
              IconButton(
                onPressed: () {
                },
                icon: Icon(Icons.group_outlined, color: Colors.grey[800], size: 30),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: null,
    );
  }

  Widget _buildProgressCard(/*String title, VoidCallback onTap*/) {
    return GestureDetector(
      // onTap: () {
      //   onTap();
      // },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45,
        height: 265,
        child: Card(
          color: Colors.redAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            //
          ),
        ),
      ),
    );
  }

  void _navigateToReport() {
    _networkService.connectionStatus ? Navigator.pushNamed(context, Routes.report) : _showInternetStatus(context);
  }

  _onDailyCardPressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? limitStepsValue = currentLimitSteps;
        String? limitCaloriesValue = currentLimitCalories;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          title: Text(
            AppLocalizations.of(context)!.enterDailyLimitTitle,
            style: TextStyle(fontSize: 20.0, color: Colors.grey[850], fontFamily: Fonts.display_font, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: limitStepsValue),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  limitStepsValue = value;
                },
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.stepsTitle, labelStyle: TextStyle(fontFamily: Fonts.display_font)),
              ),
              TextField(
                controller: TextEditingController(text: limitCaloriesValue),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  limitCaloriesValue = value;
                },
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.caloriesTitle, labelStyle: TextStyle(fontFamily: Fonts.display_font)),
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
                style: TextStyle(fontSize: 20.0, color: Colors.grey[850], fontFamily: Fonts.display_font),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Update limit data
                if (_currentUser != null) {
                  _saveLimitDataToDatabase(limitStepsValue!, limitCaloriesValue!);
                  _loadLimitDataFromDatabase();
                  if(_networkService.connectionStatus) {
                    _saveLimitDataToFirestore(limitStepsValue!, limitCaloriesValue!);
                    _loadLimitDataFromFirestore();
                  }
                }
                Navigator.pop(context);
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
  }

  Widget _buildDailyCard(String title, String dailySteps, IconData iconData, Color colorData, double dailyProgress, VoidCallback? onTap) {
    return GestureDetector(
      onTap: _onDailyCardPressed,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45,
        height: 130,
        child: Card(
          color: Colors.grey[850],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 13.0, color: Colors.white70, fontFamily: Fonts.display_font),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dailySteps,
                      style: TextStyle(fontSize: 28.0, color: Colors.white, fontFamily: Fonts.display_font, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: onTap,
                      child: CircularPercentIndicator(
                        radius: 20,
                        lineWidth: 5,
                        animation: false,
                        percent: dailyProgress,
                        center: Icon(iconData, color: colorData, size: 15),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: colorData,
                        backgroundColor: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryChartCard() {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      height: 317,
      child: Card(
        color: Colors.grey[850],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: PageController(viewportFraction: 1),
                onPageChanged: (int index) {
                  _currentPageNotifier.value = index;
                },
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(height: 14),
                      Text(
                        AppLocalizations.of(context)!.stepsChart,
                        style: TextStyle(fontSize: 16.0, color: Colors.white, fontFamily: Fonts.display_font, fontWeight: FontWeight.bold),
                      ),
                      AspectRatio(
                        aspectRatio: 1.70,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(30, 15, 40, 15),
                          child: BarChart(barMainData()),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(height: 14),
                      Text(
                        AppLocalizations.of(context)!.caloChart,
                        style: TextStyle(fontSize: 16.0, color: Colors.white, fontFamily: Fonts.display_font, fontWeight: FontWeight.bold),
                      ),
                      AspectRatio(
                        aspectRatio: 1.70,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(30, 15, 40, 5),
                          child: LineChart(lineMainData()),
                        ),
                      ),
                    ],
                  ),
                ]
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: CirclePageIndicator(
                currentPageNotifier: _currentPageNotifier,
                itemCount: 2,
                size: 6,
                selectedSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget lineBottomTitle(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10.0, color: Colors.white, fontFamily: Fonts.display_font, fontWeight: FontWeight.bold);
    String text;
    switch (value.toInt()) {
      case 0:
        text = last7Days[6];
        break;
      case 1:
        text = last7Days[5];
        break;
      case 2:
        text = last7Days[4];
        break;
      case 3:
        text = last7Days[3];
        break;
      case 4:
        text = last7Days[2];
        break;
      case 5:
        text = last7Days[1];
        break;
      case 6:
        text = last7Days[0];
        break;
      default:
        text = 'no data';
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget lineLeftTitle(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10, color: Colors.white, fontFamily: Fonts.display_font, fontWeight: FontWeight.bold);
    String text;
    switch (value.toInt()) {
      case 2:
        text = '2K';
        break;
      case 4:
        text = '4k';
        break;
      case 6:
        text = '6k';
        break;
      case 8:
        text = '8k';
        break;
      case 10:
        text = '10k';
        break;
      case 12:
        text = '12k';
        break;
      case 14:
        text = '14k';
        break;
      case 16:
        text = '16k';
        break;
      case 18:
        text = '18k';
        break;
      case 20:
        text = '20k';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData lineMainData() {
    return LineChartData(
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: lineBottomTitle,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: lineLeftTitle,
            reservedSize: 25,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 9,
      lineBarsData: [
        LineChartBarData(
          color: Colors.redAccent,
          spots: const [
            FlSpot(0, 3),
            FlSpot(1, 2),
            FlSpot(2, 5),
            FlSpot(3, 3),
            FlSpot(4, 4),
            FlSpot(5, 3),
            FlSpot(6, 4),
          ],
          isCurved: true,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 0,
                ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.redAccent.withOpacity(0.5),
                Colors.redAccent.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipRoundedRadius: 30,
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.y}',
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  BarChartData barMainData() {
    BarChartGroupData generateGroupData(
        int x,
        double dailySteps,
        double runSteps,
        ) {
      return BarChartGroupData(
        x: x,
        groupVertically: true,
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: dailySteps,
            color: Colors.orangeAccent,
            width: 12,
          ),
          BarChartRodData(
            fromY: dailySteps + 0.2,
            toY: dailySteps + 0.2 + runSteps,
            color: Colors.redAccent,
            width: 12,
          ),
        ],
      );
    }

    return BarChartData(
      alignment: BarChartAlignment.spaceBetween,
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: barLeftTitle,
            reservedSize: 25,
          ),
        ),
        rightTitles: const AxisTitles(),
        topTitles: const AxisTitles(),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: barBottomTitles,
            reservedSize: 20,
          ),
        ),
      ),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipRoundedRadius: 30,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String value;
            if (rodIndex == 0) {
              value = rod.toY.toString();
            } else {
              value = (rod.toY - group.barRods[0].toY - 0.2).toStringAsFixed(0);
            }
            return BarTooltipItem(
              value,
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: false),
      barGroups: [
        generateGroupData(0, 2, 3),
        generateGroupData(1, 2, 2),
        generateGroupData(2, 1.3, 3.1),
        generateGroupData(3, 3.1, 4),
        generateGroupData(4, 0.8, 3.3),
        generateGroupData(5, 2, 1),
        generateGroupData(6, 1.3, 3.2),
      ],
    );
  }

  Widget barBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10.0, color: Colors.white, fontFamily: Fonts.display_font, fontWeight: FontWeight.bold);
    String text;
    switch (value.toInt()) {
      case 0:
        text = last7Days[6];
        break;
      case 1:
        text = last7Days[5];
        break;
      case 2:
        text = last7Days[4];
        break;
      case 3:
        text = last7Days[3];
        break;
      case 4:
        text = last7Days[2];
        break;
      case 5:
        text = last7Days[1];
        break;
      case 6:
        text = last7Days[0];
        break;
      default:
        text = 'no data';
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget barLeftTitle(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10, color: Colors.white, fontFamily: Fonts.display_font, fontWeight: FontWeight.bold);
    String text;
    switch (value.toInt()) {
      case 2:
        text = '2K';
        break;
      case 4:
        text = '4k';
        break;
      case 6:
        text = '6k';
        break;
      case 8:
        text = '8k';
        break;
      case 10:
        text = '10k';
        break;
      case 12:
        text = '12k';
        break;
      case 14:
        text = '14k';
        break;
      case 16:
        text = '16k';
        break;
      case 18:
        text = '18k';
        break;
      case 20:
        text = '20k';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }
}
