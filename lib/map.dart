import 'dart:async';
import 'dart:collection';
import 'dart:math' as Math;
import 'dart:typed_data';

import 'package:areanator/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as MapUtil;

import 'components/area_dialog.dart';

class Mapper extends StatefulWidget {
  final Position position;

  Mapper({this.position});

  @override
  _MapperState createState() => _MapperState();
}

class _MapperState extends State<Mapper> {
  Position _positionData;

  Set<Marker> _markers = HashSet<Marker>();
  Set<Polygon> _polygons = HashSet<Polygon>();
  List<LatLng> polygonLatLngs = List<LatLng>();

  // ignore: cancel_subscriptions
  StreamSubscription<Position> positionStream;
  bool isTracking = false;

  num area = 0;

  int _markerIdCounter = 1;

  GoogleMapController _controller;
  Uint8List imageBytes;
  bool loading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: CameraPosition(
                  target:
                      LatLng(_positionData.latitude, _positionData.longitude),
                  zoom: 14.4746),
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
              markers: _markers,
              polygons: _polygons,
              onTap: (point) {
                if (!isTracking)
                  setState(() {
                    _setMarker(point);
                  });
              },
            ),
            Positioned(
              top: 8,
              left: 10.0,
              right: 10.0,
              child: Card(
                elevation: 8.0,
                color: Color.fromARGB(255, 45, 47, 49),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Area",
                        style: TextStyle(color: Colors.white60, fontSize: 30),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(Utils.formatUnit(area) + " m²",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 20)),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(
                        height: 2,
                        thickness: 2,
                        color: Colors.white24,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (area > 0)
                            TextButton(
                                onPressed: () async {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CircularProgressIndicator()
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                  await _controller.animateCamera(
                                      CameraUpdate.newLatLngBounds(
                                          fromList(polygonLatLngs), 100));
                                  await Future.delayed(
                                      Duration(milliseconds: 1000));
                                  var img = await _controller.takeSnapshot();
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          fullscreenDialog: true,
                                          builder: (context) {
                                            return AreaDialog(
                                              measureNew: MeasureNew(
                                                value: area,
                                                imageBytes: img,
                                                polygons: polygonLatLngs
                                              ),
                                              createNew: true,
                                            );
                                          }));
                                },
                                child: Text("More")),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                area = 0;
                                _markers.clear();
                                _polygons.clear();
                                polygonLatLngs.clear();
                              });
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    FloatingActionButton(
                      backgroundColor: Color.fromARGB(255, 45, 47, 49),
                      onPressed: () {
                        setState(() {
                          _setMarker(LatLng(
                              _positionData.latitude, _positionData.longitude));
                        });
                      },
                      child: Icon(Icons.add),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    FloatingActionButton(
                      backgroundColor: isTracking ? Colors.red : Colors.green,
                      onPressed: () {
                        if (!isTracking)
                          startTracking();
                        else
                          stopTracking();
                      },
                      child: Icon(isTracking ? Icons.clear : Icons.play_arrow),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _positionData = widget.position;
  }

  void startTracking() {
    setState(() {
      isTracking = true;
    });
    positionStream =
        Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.high)
            .listen((position) {
      print(position == null
          ? 'Unknown'
          : position.latitude.toString() +
              ', ' +
              position.longitude.toString());
      if (position != null)
        _setMarker(LatLng(position.latitude, position.longitude));
    });
  }

  void stopTracking() {
    setState(() {
      isTracking = false;
    });
    positionStream.cancel();
  }

  void _compute() {
    List<MapUtil.LatLng> points = List();
    polygonLatLngs.forEach((point) {
      points.add(MapUtil.LatLng(point.latitude, point.longitude));
    });
    setState(() {
      area = MapUtil.SphericalUtil.computeArea(points);
    });
    // print(calculatePolygonArea(polygonLatLngs));
    // print(points.length);
  }

  void _setMarker(LatLng point) {
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    final String polygonIdVal = 'polygon_id_$_markerIdCounter';

    _markerIdCounter++;
    print(markerIdVal);
    setState(() {
      polygonLatLngs.add(point);
    });
    setState(() {
      _markers.add(
        Marker(
            markerId: MarkerId(markerIdVal),
            position: point,
            draggable: true,
            onDragEnd: (newPosition) {
              polygonLatLngs.insert(polygonLatLngs.indexOf(point), newPosition);
            }),
      );
    });
    if (polygonLatLngs.length > 2) {
      setState(() {
        _polygons.add(Polygon(
            polygonId: PolygonId(polygonIdVal),
            points: polygonLatLngs,
            strokeWidth: 2,
            strokeColor: Colors.blue,
            fillColor: Colors.grey));
      });
      _compute();
    }
  }

  static double calculatePolygonArea(List coordinates) {
    double area = 0;
    if (coordinates.length > 2) {
      for (var i = 0; i < coordinates.length - 1; i++) {
        var p1 = coordinates[i];
        var p2 = coordinates[i + 1];
        area += convertToRadian(p2.longitude - p1.longitude) *
            (2 +
                Math.sin(convertToRadian(p1.latitude)) +
                Math.sin(convertToRadian(p2.latitude)));
      }
      area = area * 6378137 * 6378137 / 2;
    }

    // return area.abs() * 0.000247105; //sq meters to Acres
    return area.abs();
  }

  static double convertToRadian(double input) {
    return input * Math.pi / 180;
  }

  static LatLngBounds fromList(List coords) {
    double x0, x1, y0, y1;
    for (LatLng coord in coords) {
      if (x0 == null) {
        x0 = x1 = coord.latitude;
        y0 = y1 = coord.longitude;
      } else {
        if (coord.latitude > x1) x1 = coord.latitude;
        if (coord.latitude < x0) x0 = coord.latitude;
        if (coord.longitude > y1) y1 = coord.longitude;
        if (coord.longitude < y0) y0 = coord.longitude;
      }
    }
    return LatLngBounds(
      southwest: LatLng(x0, y0),
      northeast: LatLng(x1, y1),
    );
  }
}
