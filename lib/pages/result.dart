import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:intl/intl.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Result extends StatefulWidget {
  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  final ScreenshotController screenshotController = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.asset('assets/map_1.jpg'),
                  ),
                ),
                Column(
                  children: [
                    _buildInformationCard(AppLocalizations.of(context)!.dateTitle, '20/06/2024'),
                    _buildInformationCard(AppLocalizations.of(context)!.distanceTitle, '4.12'),
                    _buildInformationCard(AppLocalizations.of(context)!.totalTimeTitle, '00:20:00'),
                    _buildInformationCard(AppLocalizations.of(context)!.stepsTitle, '200'),
                    _buildInformationCard(AppLocalizations.of(context)!.caloriesTitle, '100'),
                  ],
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
        height: 75.0,
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
