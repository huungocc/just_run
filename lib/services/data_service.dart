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

  Future<void> saveLimitData(BuildContext context, String userId, int limitSteps, double limitCalories) async {
    try {
      await _db.collection('users').doc(userId).collection('limits').doc('limitData').set({
        'limitSteps': limitSteps,
        'limitCalories': limitCalories,
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

  Future<Map<String, dynamic>?> loadLimitData(BuildContext context, String userId) async {
    try {
      var doc = await _db.collection('users').doc(userId).collection('limits').doc('limitData').get();
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

  Future<void> saveDailyData(BuildContext context, String userId, String dateKey, int dailySteps, int startSteps, double dailyCalories) async {
    try {
      await _db.collection('users').doc(userId).collection('daily').doc(dateKey).set({
        'dateKey': dateKey,
        'dailySteps': dailySteps,
        'startSteps': startSteps,
        'dailyCalories': dailyCalories,
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

  Future<Map<String, dynamic>?> loadDailyData(BuildContext context, String userId) async {
    try {
      var doc = await _db.collection('users').doc(userId).collection('daily').doc('dateKey').get();
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

  Future<String?> loadLatestDate(BuildContext context, String userId) async {
    try {
      var snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('daily')
          .orderBy('dateKey', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first;
        return doc['dateKey'] as String?;
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

  Future<int?> loadStartSteps(BuildContext context, String userId, String dateKey) async {
    try {
      var doc = await _db
          .collection('users')
          .doc(userId)
          .collection('daily')
          .doc(dateKey)
          .get();

      if (doc.exists) {
        return doc['startSteps'] as int?;
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
      var querySnapshot = await _db.collection('users').doc(userId).collection('runs').orderBy('dateTime', descending: true).get();

      List<Map<String, dynamic>> runningData = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data()!;

        List<dynamic> polylineList = data['polylines'];
        Set<Polyline> polylines = polylineList.map((polylineData) {
          return Polyline(
            polylineId: PolylineId(polylineData['polylineId']),
            points: (polylineData['points'] as List<dynamic>).map((point) => LatLng(point['latitude'], point['longitude'])).toList(),
          );
        }).toSet();
        data['polylines'] = polylines;

        return data;
      }).toList();

      return runningData;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.loadDataFailed + ': $e'),
        ),
      );
      return null;
    }
  }

  Future<void> deleteEachRunningData(BuildContext context, String userId, String dateTime) async {
    try {
      await _db.collection('users').doc(userId).collection('runs').doc(dateTime).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.deleteDataFailed + ': $e'),
        ),
      );
    }
  }

  Future<void> deleteAllRunningData(BuildContext context, String userId) async {
    try {
      var querySnapshot = await _db.collection('users').doc(userId).collection('runs').get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.deleteDataFailed + ': $e'),
        ),
      );
    }
  }
}
