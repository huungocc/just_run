import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:just_run/routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Running extends StatefulWidget {
  @override
  State<Running> createState() => _RunningState();
}

class _RunningState extends State<Running> with TickerProviderStateMixin {
  late AnimationController controller;
  bool isStarting = false;

  bool isLockOn = false;

  Location location = Location();
  LatLng? currentLocation;
  late GoogleMapController mapController;

  static const LatLng defaultCenter = LatLng(21.0278, 105.8342);

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
      setState(() {});
    });
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        _handleNoLocationService();
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        _handleNoLocationPermission();
        return;
      }
    }

    LocationData _locationData = await location.getLocation();
    setState(() {
      currentLocation = LatLng(_locationData.latitude!, _locationData.longitude!);
    });
  }

  void _handleNoLocationService() {
    // Xử lý khi không có dịch vụ định vị
    setState(() {
      currentLocation = defaultCenter;
    });
  }

  void _handleNoLocationPermission() {
    // Xử lý khi không có quyền truy cập định vị
    setState(() {
      currentLocation = defaultCenter;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _toggleAnimation() {
    setState(() {
      if (isStarting) {
        controller.stop();
      } else {
        controller.repeat();
      }
      isStarting = !isStarting;
    });
  }

  Future <bool> _onBackPressed() {
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

  Future <void> _onStopPressed() {
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
              Navigator.pushReplacementNamed(context, Routes.result);
            },
            child: Text(AppLocalizations.of(context)!.stopButton, style: TextStyle(fontSize: 20.0, color: Colors.redAccent, fontFamily: 'Blinker', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
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
            Container(
              height: 300,
              child: Visibility(
                visible: !isLockOn,
                maintainState: true,
                child: GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  initialCameraPosition: currentLocation != null
                      ? CameraPosition(target: currentLocation!, zoom: 15)
                      : CameraPosition(target: defaultCenter, zoom: 15),
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                    if (currentLocation != null) {
                      mapController.animateCamera(CameraUpdate.newCameraPosition(
                        CameraPosition(target: currentLocation!, zoom: 15),
                      ));
                    }
                  },
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
                      Expanded(child: _buildInformationCard('4.12', AppLocalizations.of(context)!.distanceTitle)),
                      SizedBox(width: 16),
                      Expanded(child: _buildInformationCard('00:20:00', AppLocalizations.of(context)!.totalTimeTitle)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildInformationCard('15', AppLocalizations.of(context)!.speedTitle)),
                      SizedBox(width: 16),
                      Expanded(child: _buildInformationCard('200', AppLocalizations.of(context)!.stepsTitle)),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 12),
                    width: double.infinity,
                    height: 20,
                    padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                    child: Visibility(
                      visible: !isLockOn,
                      maintainState: true,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(7)),
                        child: LinearProgressIndicator(
                          value: controller.value,
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
                        icon: Icon(Icons.stop_circle_outlined, size: 34.0, color: Colors.black),
                        onPressed: () {
                          isLockOn ? null : _onStopPressed();
                        },
                      ),
                      Container(
                        height: 80.0,
                        width: 80,
                        decoration: BoxDecoration(
                          color: isLockOn ? Colors.black : Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Visibility(
                          visible: !isLockOn,
                          maintainState: true,
                          child: IconButton(
                            icon: Icon(
                              isStarting ? Icons.pause : Icons.play_arrow,
                              size: 50.0,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _toggleAnimation();
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isLockOn ? Icons.lock_outline_rounded : Icons.lock_open_rounded, size: 30.0,
                          color: isLockOn ? Colors.white : Colors.black
                        ),
                        onPressed: () {
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
