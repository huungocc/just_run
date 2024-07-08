import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationWithTime {
  final LatLng location;
  final DateTime time;

  LocationWithTime(this.location, this.time);
}
