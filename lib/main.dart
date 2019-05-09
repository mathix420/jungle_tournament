import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jungle tournament',
      debugShowCheckedModeBanner: false, // banner
      theme: ThemeData(
        primaryColor: Colors.yellow[700],
        brightness: Brightness.dark,
      ),
      home: MyHomePage(title: 'Jungle tournament'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class JungleChoice extends Container {
  JungleChoice({Key key, this.pos, this.color, this.url, this.onClick})
      : super(key: key);

  final String pos;
  final String url;
  final Color color;
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: color,
        margin: (this.pos == "left")
            ? new EdgeInsets.fromLTRB(4, 8, 2, 4)
            : new EdgeInsets.fromLTRB(2, 8, 4, 4),
        height: 400,
        child: ClipRRect(
          borderRadius: new BorderRadius.all(new Radius.circular(8.0)),
          child: new GestureDetector(
            onTap: () => this.onClick(),
            child: new FadeInImage(
              image: (url != null && url.length > 0)
                  ? new NetworkImage(url)
                  : new AssetImage("assets/none.png"),
              fit: BoxFit.cover,
              placeholder: new AssetImage("assets/none.png"),
            ),
          ),
        ),
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 4.0,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.brightness_6),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('matchs').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          DocumentSnapshot doc;
          snapshot.data.documents.forEach((document) {
            if (document.data['started'] && !document.data['finished']) {
              doc = document;
            }
          });
          if (doc == null || doc.data['opponents'] == null) {
            return CircularProgressIndicator();
          }
          return JungleHomeStateful(
              fightersList: doc.data['opponents'],
              title: doc.data['title'].toString());
        },
      ),
    );
  }
}

class ScoreView extends StatelessWidget {
  final List<dynamic> fightersList;
  final String title;

  ScoreView({this.fightersList, this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(child: Text("Tu as voté")),
    );
  }
}

class JungleHomeStateful extends StatefulWidget {
  final List<dynamic> fightersList;
  final String title;

  JungleHomeStateful({this.fightersList, this.title});

  @override
  _JungleHomeStatefulState createState() {
    return new _JungleHomeStatefulState(
        futureFightersList: fightersList, title: title);
  }
}

class _JungleHomeStatefulState extends State<JungleHomeStateful> {
  final List<dynamic> futureFightersList;
  final String title;
  List<DocumentSnapshot> _fightersList = new List<DocumentSnapshot>();

  _JungleHomeStatefulState({this.futureFightersList, this.title}) {
    getOpponentsList(this.futureFightersList).then((val) => setState(() {
          _fightersList = val;
        }));
  }

  Future<List<DocumentSnapshot>> getOpponentsList(
      List<dynamic> fightersList) async {
    return [
      await fightersList[0].get(),
      await fightersList[1].get(),
    ];
  }

  void vote(int index) {
    print("IN");
    Firestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap =
          await transaction.get(_fightersList[index].reference);
      await transaction
          .update(freshSnap.reference, {'votes': freshSnap['votes'] + 1});
    });
    Route route = MaterialPageRoute(builder: (context) => ScoreView());
    Navigator.pushReplacement(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Stack(
          alignment: const Alignment(-0.05, 1.8),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                JungleChoice(
                  pos: "left",
                  url: _fightersList.length == 2
                      ? _fightersList[0].data['image'].toString()
                      : null,
                  onClick: () => vote(0),
                ),
                JungleChoice(
                  pos: "right",
                  url: _fightersList.length == 2
                      ? _fightersList[1].data['image'].toString()
                      : null,
                  onClick: () => vote(1),
                ),
              ],
            ),
            new Text(
              "VS",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 100,
                fontWeight: FontWeight.bold,
                fontFamily: 'Martyric',
                color: Colors.yellow[700],
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(10.0, 10.0),
                    blurRadius: 5.0,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: FloatingActionButton.extended(
                heroTag: "img1",
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                label: Text(
                  _fightersList.length == 2
                      ? _fightersList[0].data['name'].toString()
                      : 'null',
                  style: TextStyle(fontSize: 18),
                ),
                icon: Text(
                  _fightersList.length == 2
                      ? _fightersList[0].data['emoji'].toString()
                      : '',
                  style: TextStyle(fontSize: 30),
                ),
                onPressed: () => vote(0),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: FloatingActionButton.extended(
                heroTag: "img2",
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                label: Text(
                  _fightersList.length == 2
                      ? _fightersList[1].data['name'].toString()
                      : 'null',
                  style: TextStyle(fontSize: 18),
                ),
                icon: Text(
                  _fightersList.length == 2
                      ? _fightersList[1].data['emoji'].toString()
                      : '',
                  style: TextStyle(fontSize: 30),
                ),
                onPressed: () => vote(1),
              ),
            ),
          ],
        ),
        Padding(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 30,
              fontFamily: "Komikaze",
            ),
          ),
          padding: EdgeInsets.fromLTRB(0, 60, 0, 0),
        ),
      ],
    );
  }
}
