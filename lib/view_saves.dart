import 'package:areanator/models/measure_save.dart';
import 'package:areanator/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'components/area_dialog.dart';

class ViewSaves extends StatefulWidget {
  const ViewSaves({Key key}) : super(key: key);

  @override
  _ViewSavesState createState() => _ViewSavesState();
}

class _ViewSavesState extends State<ViewSaves> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All saves"),
      ),
      body: ValueListenableBuilder(
          valueListenable: Hive.box<MeasuredArea>(Utils.MBOXNAME).listenable(),
          builder: (context, Box<MeasuredArea> box, _) {
            if (box.values.isEmpty) {
              return Center(child: Text("No Saved Areas"));
            }
            return Container(
              padding: EdgeInsets.all(8),
              child: ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    MeasuredArea area = box.getAt(index);
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) {
                                  return AreaDialog(
                                    measureNew: null,
                                    createNew: false,
                                    measuredArea: area,
                                  );
                                }));
                      },
                      child: Card(
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Text(area.name),
                              Text(area.area.toString())
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            );
          }),
    );
  }
}
