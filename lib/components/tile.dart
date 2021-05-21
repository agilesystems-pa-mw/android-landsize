import 'package:flutter/material.dart';

class MainTile extends StatelessWidget {
  const MainTile({Key key, this.onClick, this.title}) : super(key: key);
  final Function onClick;
  final String title;

  @override
  Widget build(BuildContext context) {
    return  Card(
        child: InkWell(
          onTap: () {
            onClick();
          },
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Text(title),
                Text(""),
              ],
            ),
          ),
        ),
      );
  }
}
