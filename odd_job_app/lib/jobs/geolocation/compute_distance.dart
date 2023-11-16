import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';

class ComputeDistance {
  late double distanceInMiles = 0;
  FlutterMapMath f = FlutterMapMath();
  double compute(GeoPoint myLocation, GeoPoint theJob) {
    distanceInMiles = f.distanceBetween(myLocation.latitude,
        myLocation.longitude, theJob.latitude, theJob.longitude, "miles");

    return distanceInMiles;
  }
}
