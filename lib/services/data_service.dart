import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
          content: Text('Failed to save data: $e'),
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
        print('No user data found for $userId');
        return null;
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load data: $e'),
        ),
      );
      return null;
    }
  }
}
