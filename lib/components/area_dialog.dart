import 'dart:io';
import 'dart:typed_data';

import 'package:areanator/models/measure_save.dart';
import 'package:areanator/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:units_converter/Area.dart';

class AreaDialog extends StatefulWidget {
  AreaDialog(
      {Key key,
      @required this.measureNew,
      @required this.createNew,
      this.measuredArea})
      : super(key: key);

  final MeasureNew measureNew;
  final bool createNew;
  final MeasuredArea measuredArea;

  @override
  _AreaDialogState createState() => _AreaDialogState();
}

class _AreaDialogState extends State<AreaDialog> {
  Area area;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    double value =
        widget.createNew ? widget.measureNew.value : widget.measuredArea.area;
    area = Area();
    area.convert(AREA.square_meters, value);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.createNew ? "Area" : widget.measuredArea.name),
        actions: [
          IconButton(icon: Icon(Icons.share), onPressed: () {
            var points = widget.createNew ?  Utils.toMapPoints(widget.measureNew.polygons) : widget.measuredArea.polygon;
            final geoJSON = Utils.createGeoJson(points);
            print(geoJSON);
            Share.share(geoJSON, subject: "Shared Map GeoJSON");
          }),
          widget.createNew
              ? IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (innerContext) {
                          return AreaNameDialog(
                            formKey: _formKey,
                            submit: (String name, Function close) async {
                              Box<MeasuredArea> measureBox =
                                  Hive.box<MeasuredArea>(Utils.MBOXNAME);
                              var measured = MeasuredArea(
                                  area: widget.measureNew.value,
                                  name: name,
                                  polygon: Utils.toMapPoints(
                                      widget.measureNew.polygons));

                              try {
                                var file = await saveImageFile(
                                    widget.measureNew.imageBytes, name);
                                measured.image = file.path;
                                print(file);
                                measureBox.add(measured);
                              } catch (e) {
                                print(e);
                              }

                              close();
                              Navigator.pop(context);
                            },
                          );
                        });
                  })
              : IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          return AlertDialog(
                            content: Text(
                              "Do you want to delete ${widget.measuredArea.name}?",
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text("No"),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              TextButton(
                                child: Text("Yes"),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  try {
                                    await File(widget.measuredArea.image)
                                        .delete(recursive: true);
                                  } catch (e) {
                                    print(e);
                                  }

                                  widget.measuredArea.delete();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        });
                  }),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: widget.createNew
                      ? (widget.measureNew.imageBytes != null
                          ? Image.memory(widget.measureNew.imageBytes)
                          : null)
                      : Image.file(File(widget.measuredArea.image))),
            ),
            SizedBox(
              height: 20,
            ),
            Card(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Measurement(
                        title: "Metres²",
                        measurement:
                            Utils.formatUnit(area.square_meters.value)),
                    Measurement(
                        title: "Acres",
                        measurement: Utils.formatUnit(area.acres.value)),
                    Measurement(
                        title: "Hectares",
                        measurement: Utils.formatUnit(area.hectares.value)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> saveImageFile(Uint8List image, String name) async {
    final path = await _localPath;
    return File('$path/$name.jpg').writeAsBytes(image);
  }
}

class AreaNameDialog extends StatelessWidget {
  AreaNameDialog({
    Key key,
    @required GlobalKey<FormState> formKey,
    @required this.submit,
  })  : _formKey = formKey,
        super(key: key);

  final GlobalKey<FormState> _formKey;
  final Function submit;
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AlertDialog(
        title: Text("Area Name"),
        content: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter Area name",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please provide a name";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("CANCEL")),
          TextButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  submit(nameController.text, () {
                    Navigator.pop(context);
                  });
                }
              },
              child: Text("SAVE")),
        ],
      ),
    );
  }
}

class Measurement extends StatelessWidget {
  final String title;
  final String measurement;

  const Measurement({Key key, this.title, this.measurement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headline6,
        ),
        Text(
          measurement,
          style: Theme.of(context).textTheme.subtitle1,
        ),
      ],
    );
  }
}

class MeasureNew {
  final num value;
  final Uint8List imageBytes;
  final List<LatLng> polygons;

  MeasureNew({this.value, this.imageBytes, this.polygons});
}
