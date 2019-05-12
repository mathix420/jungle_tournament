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
        stream: Firestore.instance.collection('matchs').snapshots(),
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          return StreamBuilder(
              stream: Firestore.instance.collection('fights').snapshots(),
              builder: (
                BuildContext context2,
                AsyncSnapshot<QuerySnapshot> snapshot2,
              ) {
                if (!snapshot2.hasData) return CircularProgressIndicator();

                List<FightRow> itemList = [];
                List<DocumentSnapshot> matchsList = snapshot.data.documents;
                List<DocumentSnapshot> fightersList = snapshot2.data.documents;

                matchsList.sort((a, b) =>
                    int.parse(a.documentID).compareTo(int.parse(b.documentID)));

                matchsList.forEach((document) {
                  TimeIndexes time = TimeIndexes.future;
                  String tip = document.data['tip'].toString();
                  DocumentSnapshot opponent1, opponent2;
                  String vote1, vote2;
                  double tipSize = double.parse(
                    document.data['tip_size'].toString(),
                  );

                  if (document.data['opponents'] != null) {
                    if (document.data['opponents'].length >= 1) {
                      opponent1 = fightersList.singleWhere((doc) =>
                          doc.documentID ==
                          document.data['opponents'][0].documentID);
                      vote1 = opponent1.data['votes'].toString();
                    }
                    if (document.data['opponents'].length >= 2) {
                      opponent2 = fightersList.singleWhere((doc) =>
                          doc.documentID ==
                          document.data['opponents'][1].documentID);
                      vote2 = opponent2.data['votes'].toString();
                    }
                  }

                  if (document.data['started'] && document.data['finished']) {
                    time = TimeIndexes.passed;
                  } else if (document.data['started'] &&
                      !document.data['finished']) {
                    time = TimeIndexes.current;
                    tip = '⚔️';
                    tipSize = 20;
                  }

                  itemList.add(new FightRow(
                    leftImage: DecorationImage(
                        image: opponent1 != null
                            ? new NetworkImage(
                                opponent1.data['image'].toString())
                            : new ExactAssetImage("assets/none.png"),
                        fit: BoxFit.cover),
                    rightImage: DecorationImage(
                        image: opponent2 != null
                            ? new NetworkImage(
                                opponent2.data['image'].toString())
                            : new ExactAssetImage("assets/none.png"),
                        fit: BoxFit.cover),
                    centerChild: Text(tip, style: TextStyle(fontSize: tipSize)),
                    votes: [vote1, vote2],
                    timeIndex: time,
                    marginSize: 5.0,
                  ));
                });

                itemList.first.isFirst = true;
                itemList.last.isLast = true;

                return Container(
                  child: ListView(children: itemList),
                );
              });
        });
  }
}
