import 'package:google_maps_flutter/google_maps_flutter.dart';

class ResultArguments {
  final String dateTime;
  final double totalDistance;
  final Duration totalTime;
  final int totalSteps;
  final double totalCalories;
  final Set<Polyline> polylines;

  ResultArguments({
    required this.dateTime,
    required this.totalDistance,
    required this.totalTime,
    required this.totalSteps,
    required this.totalCalories,
    required this.polylines,
  });
}