import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:just_run/services/data_service.dart';
import 'package:location/location.dart' as location_pack;
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:just_run/routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pedometer/pedometer.dart';
import 'package:just_run/services/location_list.dart';

import '../services/user_arguments.dart';
import 'package:just_run/services/result_arguments.dart';

class Running extends StatefulWidget {
  @override
  State<Running> createState() => _RunningState();
}

class _RunningState extends State<Running> with TickerProviderStateMixin {
  User? _currentUser;

  late AnimationController controller;

  bool isStarting = false;
  bool isLockOn = false;

  location_pack.Location location = location_pack.Location();
  LatLng? currentLocation;
  late GoogleMapController mapController;
  static const LatLng defaultLocation = LatLng(21.0278, 105.8342);
  StreamSubscription<location_pack.LocationData>? locationSubscription;

  Duration _totalTime = Duration.zero;
  late Timer _timer;

  int _currentSteps = 0;
  int _lastSteps = 0;
  late StreamSubscription<StepCount> _subscription;

  List<LocationWithTime> locationList = [];
  double _totalDistance = 0.0;
  double _currentSpeed = 0.0;

  Completer<GoogleMapController> _controller = Completer();
  Set<Polyline> _polylines = {};

  late double _currentUserWeight;
  double _currentCalories = 0.0;

  late double limit;

  @override
  void initState() {
    super.initState();

    _loadCurrentUser();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is RunningArguments) {
        setState(() {
          _currentUserWeight = args.weight.toDouble();
          limit = double.tryParse(args.limit) ?? 0.0;
        });
      }
    });

    _timer = Timer(Duration.zero, () {});

    checkLocationServiceEnabled();

  }

  void _loadCurrentUser() {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser;
    });
  }

  Future<void> checkLocationServiceEnabled() async {
    currentLocation = defaultLocation;
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    location_pack.LocationData _locationData = await location!.getLocation();
    setState(() {
      currentLocation = LatLng(_locationData.latitude!, _locationData.longitude!);
      _updateCameraPosition();
    });

    locationSubscription = location!.onLocationChanged.listen((location_pack.LocationData newLocation) {
      setState(() {
        currentLocation = LatLng(newLocation.latitude!, newLocation.longitude!);
        _updateCameraPosition();
      });
    });
  }

  void _updateCameraPosition() {
    if (mapController != null && currentLocation != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
            zoom: 15,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    _timer.cancel();
    stopCountingSteps();
    _polylines.clear();
    super.dispose();
  }

  void _onPressedCount() {
    if (isStarting) {
      stopTimer();
      stopCountingSteps();
      _currentSpeed = 0;
    } else {
      startTimer();
      startCountingSteps();
      startTracking();
    }
    setState(() {
      isStarting = !isStarting;
    });
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _totalTime = _totalTime + Duration(seconds: 1);
      });
    });
  }

  void stopTimer() {
    setState(() {
      _timer.cancel();
    });
  }

  String _formatDuration(Duration duration) {
    DateTime time = DateTime(0).add(duration);
    return DateFormat('HH:mm:ss').format(time);
  }

  void startCountingSteps() {
    _subscription = Pedometer.stepCountStream.listen((StepCount event) {
      if(_lastSteps == 0){
        _lastSteps = event.steps;
        print(event.steps);
      }
      setState(() {
        _currentSteps = event.steps - _lastSteps;
      });
    });
  }

  void stopCountingSteps() {
    _subscription.cancel();
  }

  void startTracking() {
    location.onLocationChanged.listen((location_pack.LocationData locationData) {
      setState(() {
        LatLng currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
        DateTime currentTime = DateTime.now();
        locationList.add(LocationWithTime(currentLocation, currentTime));

        if (locationList.length >= 2) {
          _calculateDistance();
          _calculateSpeed();
          _updatePolyline();
        }
      });
    });
  }

  void _calculateDistance() {
    if (locationList.length >= 2) {
      LocationWithTime lastLocation = locationList[locationList.length - 2];
      LocationWithTime currentLocation = locationList.last;
      double distanceInKm = _calculateDistanceBetween(lastLocation.location, currentLocation.location);

      if (isStarting) {
        _totalDistance += distanceInKm;
        if (_totalDistance >= limit && limit > 0) {
          setState(() {
            limit = 0;
            _onPressedCount();
            _onReachLimit();
          });
        }
      }
    }
  }

  double _calculateDistanceBetween(LatLng start, LatLng end) {
    //su dung cong thuc Haversine
    const EARTH_RADIUS = 6371000.0;
    double lat1 = start.latitude * (pi / 180);
    double lon1 = start.longitude * (pi / 180);
    double lat2 = end.latitude * (pi / 180);
    double lon2 = end.longitude * (pi / 180);
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;
    double a = (sin(dLat / 2) * sin(dLat / 2)) + (cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = EARTH_RADIUS * c;
    // m -> km
    double distanceInKm = distance / 1000.0;
    return distanceInKm;
  }

  void _calculateSpeed() {
    if (locationList.length >= 2) {
      LocationWithTime lastLocation = locationList[locationList.length - 2];
      LocationWithTime currentLocation = locationList.last;
      double distanceInKm = _calculateDistanceBetween(lastLocation.location, currentLocation.location);
      double timeInSeconds = currentLocation.time.difference(lastLocation.time).inSeconds.toDouble();

      if (isStarting && timeInSeconds > 0) {
        double timeInHours = timeInSeconds / 3600.0;
        _currentSpeed = distanceInKm / timeInHours;
      }
    }
  }

  void _updatePolyline() {
    List<LatLng> polylinePoints = locationList.map((loc) => loc.location).toList();
    Polyline polyline = Polyline(
      polylineId: PolylineId('tracking_polyline_${_polylines.length}'),
      color: isStarting ? Colors.redAccent : Colors.blueAccent,
      width: 3,
      points: polylinePoints,
    );

    setState(() {
      _polylines.add(polyline);
    });
  }



  double _getMet(double averageSpeed) {
    if (averageSpeed >= 17.5) {
      return 16.0;
    } else if (averageSpeed >= 16.1) {
      return 14.5;
    } else if (averageSpeed >= 13.8) {
      return 12.8;
    } else if (averageSpeed >= 12.1) {
      return 11.8;
    } else if (averageSpeed >= 11.3) {
      return 11.0;
    } else if (averageSpeed >= 9.7) {
      return 9.8;
    } else {
      return 8.3; // gia tri MET mac dinh
    }
  }

  void _calculateCalories() {
    double averageSpeed = _calculateAverageSpeed();
    double met = _getMet(averageSpeed);
    double durationInHours = _totalTime.inSeconds / 3600.0;
    _currentCalories = met * _currentUserWeight * durationInHours;
    print(_currentCalories);
  }

  double _calculateAverageSpeed() {
    double _totalTimeInHours = _totalTime.inSeconds / 3600.0;
    return _totalDistance / _totalTimeInHours;
  }

  double calculateProgress() {
    if (limit > 0) {
      return _totalDistance > 0 ? (_totalDistance / limit).clamp(0.0, 1.0) : 0.0;
    } else {
      return 0.0;
    }
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Text(AppLocalizations.of(context)!.exitTitle, style: TextStyle(fontSize: 22.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text(AppLocalizations.of(context)!.cancelButton, style: TextStyle(fontSize: 20.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text(AppLocalizations.of(context)!.exitButton, style: TextStyle(fontSize: 20.0, color: Colors.redAccent, fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  Future<void> _onStopPressed() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Text(AppLocalizations.of(context)!.stopTitle, style: TextStyle(fontSize: 22.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.cancelButton, style: TextStyle(fontSize: 20.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, Routes.running);
              _calculateCalories();
              Navigator.pushReplacementNamed(context, Routes.result, arguments: ResultArguments(dateTime: DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()), totalDistance: _totalDistance, totalTime: _totalTime, totalSteps: _currentSteps, totalCalories: _currentCalories, polylines: _polylines));
              DataService().saveRunningData(
                context,
                _currentUser!.uid,
                DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()),
                _totalDistance,
                _totalTime,
                _currentSteps,
                _currentCalories,
                _polylines,
              );
            },
            child: Text(AppLocalizations.of(context)!.stopButton, style: TextStyle(fontSize: 20.0, color: Colors.redAccent, fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  Future<void> _onReachLimit() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Text(AppLocalizations.of(context)!.reachLimitTitle, style: TextStyle(fontSize: 22.0, color: Colors.grey[850], fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.okButton, style: TextStyle(fontSize: 20.0, color: Colors.redAccent, fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = calculateProgress();

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: isLockOn ? Colors.black : Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.0),
          child: AppBar(
            backgroundColor: isLockOn ? Colors.black : Colors.white,
            title: Text(
              AppLocalizations.of(context)!.runningCardTitle,
              style: TextStyle(
                color: isLockOn ? Colors.white : Colors.black,
                fontFamily: 'Blinker',
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
        ),
        body: currentLocation == null
            ? Center(child: SpinKitThreeBounce(color: Colors.black, size: 30.0))
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Container(
                  height: 300,
                  child: Visibility(
                    visible: !isLockOn,
                    maintainState: true,
                    child: GoogleMap(
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                      initialCameraPosition: CameraPosition(target: currentLocation!, zoom: 15),
                      polylines: _polylines,
                      onMapCreated: (GoogleMapController controller) {
                        mapController = controller;
                        mapController.animateCamera(CameraUpdate.newCameraPosition(
                          CameraPosition(target: currentLocation!, zoom: 15),
                        ));
                        _controller.complete(controller);
                      },
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildInformationCard(_totalDistance.toStringAsFixed(1), AppLocalizations.of(context)!.distanceTitle)),
                      SizedBox(width: 16),
                      Expanded(child: _buildInformationCard(_formatDuration(_totalTime), AppLocalizations.of(context)!.totalTimeTitle)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildInformationCard(_currentSpeed.toStringAsFixed(1), AppLocalizations.of(context)!.speedTitle)),
                      SizedBox(width: 16),
                      Expanded(child: _buildInformationCard(_currentSteps.toString(), AppLocalizations.of(context)!.stepsTitle)),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 12),
                    width: double.infinity,
                    height: 20,
                    padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                    child: Visibility(
                      visible: /* limit > 0 && */!isLockOn,
                      maintainState: true,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(7)),
                        child: LinearProgressIndicator(
                          value: progress,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.stop_circle_outlined, size: 34.0, color: isLockOn ? Colors.white : Colors.black87),
                        onPressed: () {
                          isStarting
                            ? ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!.stopStatus),
                                ),
                              )
                            : _onStopPressed();
                        },
                      ),
                      Container(
                        height: 80.0,
                        width: 80,
                        decoration: BoxDecoration(
                          color: isLockOn ? Colors.black : Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isStarting ? Icons.pause : Icons.play_arrow,
                            size: 50.0,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _onPressedCount();
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                            isLockOn ? Icons.lock_outline_rounded : Icons.lock_open_rounded, size: 30.0,
                            color: isLockOn ? Colors.white : Colors.black
                        ),
                        onPressed: () {
                          print(limit);
                          print(_currentUserWeight);
                          setState(() {
                            isLockOn = !isLockOn;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformationCard(String title, String description) {
    return GestureDetector(
      child: Container(
        height: 100.0,
        margin: EdgeInsets.symmetric(vertical: 4.0),
        child: Card(
          color: isLockOn ? Colors.black : Colors.grey[300],
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 30.0, fontFamily: 'Blinker', fontWeight: FontWeight.bold,
                      color: isLockOn ? Colors.white : Colors.black87
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                      fontFamily: 'Blinker', fontSize: 12, fontWeight: FontWeight.bold,
                      color: isLockOn ? Colors.white : Colors.black87
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
