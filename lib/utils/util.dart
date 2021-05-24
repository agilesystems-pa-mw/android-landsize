import 'package:areanator/models/map_point.dart';
import 'package:geojson_vi/geojson_vi.dart';
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

  static String createGeoJson(List<MapPoint> points) {
    final finalFeatureCollection = GeoJSONFeatureCollection([]);
    final List<List<double>> polygon = [];
    points.add(points.first);
    for(MapPoint point in points) {
      polygon.add([point.longitude, point.latitude]);
    }
    final feature = GeoJSONFeature(GeoJSONPolygon([polygon]), properties: {

    });

    finalFeatureCollection.features.add(feature);

    return finalFeatureCollection.toJSON();
  }

}