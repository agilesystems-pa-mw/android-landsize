import 'package:areanator/models/map_point.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class Utils {
  static String formatUnit(num value) {
    final formatter = NumberFormat("###.0##");
    return formatter.format(value);
  }

  static const String MBOXNAME = "measured";

  static List<MapPoint> toMapPoints(List<LatLng> polys) {
    List<MapPoint> points = List.empty(growable: true);
    for(LatLng poly in polys) {
      points.add(MapPoint(latitude: poly.latitude, longitude: poly.longitude));
    }
    return points;
  }
}