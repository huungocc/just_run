import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:intl/intl.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:just_run/services/result_arguments.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Result extends StatefulWidget {
  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  final ScreenshotController screenshotController = ScreenshotController();
  late ResultArguments result;
  late GoogleMapController mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        result = ModalRoute.of(context)!.settings.arguments as ResultArguments;
      });
    });
  }

  String _formatDuration(Duration duration) {
    DateTime time = DateTime(0).add(duration);
    return DateFormat('HH:mm:ss').format(time);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (result?.polylines.isNotEmpty ?? false) {
      final bounds = _getBounds(result!.polylines);
      mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  LatLngBounds _getBounds(Set<Polyline> polylines) {
    double? x0, x1, y0, y1;
    for (Polyline polyline in polylines) {
      for (LatLng point in polyline.points) {
        if (x0 == null) {
          x0 = x1 = point.latitude;
          y0 = y1 = point.longitude;
        } else {
          if (point.latitude > x1!) x1 = point.latitude;
          if (point.latitude < x0) x0 = point.latitude;
          if (point.longitude > y1!) y1 = point.longitude;
          if (point.longitude < y0!) y0 = point.longitude;
        }
      }
    }
    return LatLngBounds(
      southwest: LatLng(x0!, y0!),
      northeast: LatLng(x1!, y1!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70.0),
          child: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              AppLocalizations.of(context)!.resultCardTitle,
              style: TextStyle(color: Colors.black, fontFamily: 'Blinker', fontWeight: FontWeight.bold),
            ),
            actions: [
              Row(
                children: [
                  IconButton(
                    onPressed: _captureScreenshot,
                    icon: Icon(Icons.camera_alt_outlined, color: Colors.black),
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Container(
                      height: 255,
                      child: GoogleMap(
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(21.0278, 105.8342),
                          zoom: 15.0,
                        ),
                        polylines: Set<Polyline>.from(
                          result?.polylines.map((polyline) => Polyline(
                            polylineId: PolylineId('polyline_id'),
                            points: polyline.points,
                            color: Colors.redAccent,
                            width: 3,
                          )) ?? {},
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildInformationCard(AppLocalizations.of(context)!.dateTitle, result.dateTime),
                      _buildInformationCard(AppLocalizations.of(context)!.distanceTitle, result.totalDistance.toStringAsFixed(1)),
                      _buildInformationCard(AppLocalizations.of(context)!.totalTimeTitle, _formatDuration(result.totalTime)),
                      _buildInformationCard(AppLocalizations.of(context)!.stepsTitle, result.totalSteps.toString()),
                      _buildInformationCard(AppLocalizations.of(context)!.caloriesTitle, result.totalCalories.toStringAsFixed(0)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );;
  }

  Widget _buildInformationCard(String title, String description) {
    return GestureDetector(
      child: Container(
        width: double.infinity,
        height: 74.0,
        margin: EdgeInsets.symmetric(vertical: 5.0),
        child: Card(
          color: Colors.grey[300],
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

  Future<void> _captureScreenshot() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    final directory = Directory('/storage/emulated/0/DCIM/JustRun');
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }

    String fileName = 'result_${DateFormat('ddMMyyyy_HHmm').format(DateTime.now())}.png';
    String filePath = '${directory.path}/$fileName';

    Uint8List? image = await screenshotController.capture();
    if (image != null) {
      File imgFile = File(filePath);
      await imgFile.writeAsBytes(image);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Screenshot saved!', style: TextStyle(fontSize: 15.0, fontFamily: 'Blinker'))));
    }
  }
}
