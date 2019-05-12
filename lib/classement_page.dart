import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';

import 'jungle_list.dart';

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

          return Container(
            child: ListView(
              children: <Widget>[
                FightRow(
                  isFirst: true,
                  leftImage: DecorationImage(
                      image: new ExactAssetImage("assets/none.png"),
                      fit: BoxFit.cover),
                  rightImage: DecorationImage(
                      image: new ExactAssetImage("assets/none.png"),
                      fit: BoxFit.cover),
                  marginSize: 5.0,
                ),
                FightRow(
                  leftImage: DecorationImage(
                      image: new ExactAssetImage("assets/none.png"),
                      fit: BoxFit.cover),
                  rightImage: DecorationImage(
                      image: new ExactAssetImage("assets/none.png"),
                      fit: BoxFit.cover),
                  marginSize: 5.0,
                ),
                FightRow(
                  leftImage: DecorationImage(
                      image: new ExactAssetImage("assets/none.png"),
                      fit: BoxFit.cover),
                  rightImage: DecorationImage(
                      image: new ExactAssetImage("assets/none.png"),
                      fit: BoxFit.cover),
                  marginSize: 5.0,
                ),
                FightRow(
                  leftImage: DecorationImage(
                      image: new ExactAssetImage("assets/none.png"),
                      fit: BoxFit.cover),
                  rightImage: DecorationImage(
                      image: new ExactAssetImage("assets/none.png"),
                      fit: BoxFit.cover),
                  marginSize: 5.0,
                ),
                FightRow(
                  leftImage: DecorationImage(
                      image: new ExactAssetImage("assets/none.png"),
                      fit: BoxFit.cover),
                  rightImage: DecorationImage(
                      image: new ExactAssetImage("assets/none.png"),
                      fit: BoxFit.cover),
                  marginSize: 5.0,
                ),
                FightRow(
                  leftImage: DecorationImage(
                      image: new ExactAssetImage("assets/none.png"),
                      fit: BoxFit.cover),
                  rightImage: DecorationImage(
                      image: new ExactAssetImage("assets/none.png"),
                      fit: BoxFit.cover),
                  marginSize: 5.0,
                ),
                FightRow(
                  leftImage: DecorationImage(
                      image: new ExactAssetImage("assets/none.png"),
                      fit: BoxFit.cover),
                  rightImage: DecorationImage(
                      image: new ExactAssetImage("assets/none.png"),
                      fit: BoxFit.cover),
                  marginSize: 5.0,
                ),
                FightRow(
                  leftImage: DecorationImage(
                      image: new ExactAssetImage("assets/none.png"),
                      fit: BoxFit.cover),
                  rightImage: DecorationImage(
                      image: new ExactAssetImage("assets/none.png"),
                      fit: BoxFit.cover),
                  marginSize: 5.0,
                  isLast: true,
                ),
              ],
            ),
          );
        });
  }
}