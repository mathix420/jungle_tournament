import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';

class ClassementScreen extends StatelessWidget {
  ClassementScreen();

  List<Widget> getElements(List<DocumentSnapshot> list) {
    List<Widget> output = [];
    list.forEach((doc) {
      output.add(Container(
        color: Colors.indigoAccent,
        height: 35,
        width: 35,
      ));
    });
    return output;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance.collection('fights').snapshots(),
        builder: (
          BuildContext context2,
          AsyncSnapshot<QuerySnapshot> snapshot2,
        ) {
          if (!snapshot2.hasData) return CircularProgressIndicator();
          List<TimelineModel> items = [
            TimelineModel(Container(color: Colors.lightGreen, height: 100),
                position: TimelineItemPosition.right,
                iconBackground: Colors.redAccent,
                icon: Icon(Icons.blur_circular)),
            TimelineModel(Container(color: Colors.lightBlue, height: 100),
                position: TimelineItemPosition.left,
                iconBackground: Colors.redAccent,
                icon: Icon(Icons.blur_circular)),
                TimelineModel(Container(color: Colors.lightGreen, height: 100),
                position: TimelineItemPosition.right,
                iconBackground: Colors.redAccent,
                icon: Icon(Icons.blur_circular)),
            TimelineModel(Container(color: Colors.lightBlue, height: 100),
                position: TimelineItemPosition.left,
                iconBackground: Colors.redAccent,
                icon: Icon(Icons.blur_circular)),
                TimelineModel(Container(color: Colors.lightGreen, height: 100),
                position: TimelineItemPosition.right,
                iconBackground: Colors.redAccent,
                icon: Icon(Icons.blur_circular)),
            TimelineModel(Container(color: Colors.lightBlue, height: 100),
                position: TimelineItemPosition.left,
                iconBackground: Colors.redAccent,
                icon: Icon(Icons.blur_circular)),
                TimelineModel(Container(color: Colors.lightGreen, height: 100),
                position: TimelineItemPosition.right,
                iconBackground: Colors.redAccent,
                icon: Icon(Icons.blur_circular)),
            TimelineModel(Container(color: Colors.lightBlue, height: 100),
                position: TimelineItemPosition.left,
                iconBackground: Colors.redAccent,
                icon: Icon(Icons.blur_circular)),
                TimelineModel(Container(color: Colors.lightGreen, height: 100),
                position: TimelineItemPosition.right,
                iconBackground: Colors.redAccent,
                icon: Icon(Icons.blur_circular)),
            TimelineModel(Container(color: Colors.lightBlue, height: 100),
                position: TimelineItemPosition.left,
                iconBackground: Colors.redAccent,
                icon: Icon(Icons.blur_circular)),
          ];
          return Timeline(children: items, position: TimelinePosition.Center, lineColor: Colors.redAccent,);
        });
  }
}
