import 'dart:async';

import 'package:areanator/components/tile.dart';
import 'package:areanator/models/map_point.dart';
import 'package:areanator/models/measure_save.dart';
import 'package:areanator/utils/util.dart';
import 'package:areanator/view_saves.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

import 'map.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(MapPointAdapter());
  Hive.registerAdapter(MeasuredAreaAdapter());
  await Hive.openBox<MeasuredArea>(Utils.MBOXNAME);
  runApp(MyApp());
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class _HomeState extends State<Home> {
  Position _locationData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AreaNator"),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MainTile(
              title: "Add Area",
              onClick: () {
                if (_locationData != null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Mapper(
                                position: _locationData,
                              )));
                }
              },
            ),
            SizedBox(height: 10,),
            MainTile(
              title: "View Saved",
              onClick: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewSaves()));
              },
            )
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //
      //   },
      //   child: Icon(Icons.add),
      // ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  void _checkPermission() async {
    try {
      _locationData = await _determinePosition();
    } catch (e) {
      print(e);
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
