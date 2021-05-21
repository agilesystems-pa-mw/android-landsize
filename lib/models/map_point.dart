import 'package:hive/hive.dart';

part 'map_point.g.dart';

@HiveType(typeId: 1)
class MapPoint extends HiveObject {
  @HiveField(0)
  double latitude;
  @HiveField(1)
  double longitude;

  MapPoint({this.latitude, this.longitude});
}