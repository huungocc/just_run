import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUserData(BuildContext context, String userId, int age, double height, double weight) async {
    try {
      await _db.collection('users').doc(userId).set({
        'age': age,
        'height': height,
        'weight': weight,
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.saveDataFailed + ': $e'),
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> loadUserData(BuildContext context, String userId) async {
    try {
      var doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      } else {
        print(AppLocalizations.of(context)!.userDataFailed + ' $userId');
        return null;
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.loadDataFailed + ': $e'),
        ),
      );
      return null;
    }
  }

  Future<void> saveRunningData(BuildContext context, String userId, String dateTime, double totalDistance, Duration totalTime, int totalSteps, double totalCalories, Set<Polyline> polylines) async {
    try {
      List<Map<String, dynamic>> polylineList = polylines.map((polyline) {
        return {
          'polylineId': polyline.polylineId.value,
          'points': polyline.points.map((point) => {
            'latitude': point.latitude,
            'longitude': point.longitude
          }).toList(),
        };
      }).toList();

      await _db.collection('users').doc(userId).collection('runs').doc(dateTime).set({
        'dateTime': dateTime,
        'totalDistance': totalDistance,
        'totalTime': totalTime.inSeconds,
        'totalSteps': totalSteps,
        'totalCalories': totalCalories,
        'polylines': polylineList,
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.saveDataFailed + ': $e'),
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>?> loadRunningData(BuildContext context, String userId) async {
    try {
      var querySnapshot = await _db.collection('users').doc(userId).collection('runs').get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.loadDataFailed + ': $e'),
        ),
      );
      return null;
    }
  }
}
