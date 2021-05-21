import 'package:areanator/models/map_point.dart';
import 'package:hive/hive.dart';

part 'measure_save.g.dart';

@HiveType(typeId: 0)
class MeasuredArea extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  double area;
  @HiveField(2)
  String image;
  @HiveField(3)
  List<MapPoint> polygon;

  MeasuredArea({this.name, this.area, this.polygon});
}