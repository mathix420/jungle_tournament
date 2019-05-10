import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(MyApp());

List<JungleChoice> cards = [null, null];

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

class JungleChoice extends StatefulWidget {
  JungleChoice(
      {Key key, this.pos, this.color, this.url, this.votes, this.onTap});

  final String pos;
  final String url;
  final Color color;
  final String votes;
  final Function onTap;

  @override
  _JungleChoiceState createState() => _JungleChoiceState();
}

class IsBlurred extends InheritedWidget {
  static of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(IsBlurred);

  final bool isBlurred;

  IsBlurred({Key key, @required Widget child, @required this.isBlurred})
      : assert(isBlurred != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(IsBlurred oldWidget) {
    return this.isBlurred != oldWidget.isBlurred;
  }
}

class _JungleChoiceState extends State<JungleChoice> {
  NetworkImage fighterImage;

  @override
  Widget build(BuildContext context) {
    if (widget.url != null && widget.url.length > 0) {
      fighterImage = new NetworkImage(widget.url);
    }
    if (!IsBlurred.of(context).isBlurred) {
      return Expanded(
        child: Container(
          color: widget.color,
          margin: (widget.pos == "left")
              ? new EdgeInsets.fromLTRB(4, 8, 2, 4)
              : new EdgeInsets.fromLTRB(2, 8, 4, 4),
          height: 400,
          child: ClipRRect(
            borderRadius: new BorderRadius.all(new Radius.circular(8.0)),
            child: new GestureDetector(
              onTap: () => widget.onTap(),
              child: new FadeInImage(
                image: (widget.url != null && widget.url.length > 0)
                    ? fighterImage
                    : new AssetImage("assets/none.png"),
                fit: BoxFit.cover,
                placeholder: new AssetImage("assets/none.png"),
              ),
            ),
          ),
        ),
      );
    } else {
      return Expanded(
        child: Container(
          color: widget.color,
          margin: (widget.pos == "left")
              ? new EdgeInsets.fromLTRB(4, 8, 2, 4)
              : new EdgeInsets.fromLTRB(2, 8, 4, 4),
          height: 400,
          decoration: new ShapeDecoration(
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.all(new Radius.circular(8.0)),
            ),
            image: new DecorationImage(
              image: (widget.url != null && widget.url.length > 0)
                  ? fighterImage
                  : new AssetImage("assets/none.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: ClipRRect(
            borderRadius: new BorderRadius.all(new Radius.circular(8.0)),
            child: new BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: new GestureDetector(
                onTap: () {},
                child: new Container(
                  decoration: new BoxDecoration(
                    color: Colors.white.withOpacity(0.0),
                    borderRadius:
                        new BorderRadius.all(new Radius.circular(8.0)),
                  ),
                  child: Center(
                    child: Text(
                      widget.votes.toString() + " votes",
                      style: TextStyle(fontSize: 30, fontFamily: 'Komikaze'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
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
          stream: FirebaseAuth.instance.signInAnonymously().asStream(),
          builder: (
            BuildContext context1,
            AsyncSnapshot<FirebaseUser> snapshot1,
          ) {
            if (!snapshot1.hasData)
              return CircularProgressIndicator(); // need to put an error

            return StreamBuilder(
                stream: Firestore.instance
                    .collection('votes')
                    .document('map')
                    .snapshots(),
                builder: (
                  BuildContext context2,
                  AsyncSnapshot<DocumentSnapshot> snapshot2,
                ) {
                  if (!snapshot2.hasData) return CircularProgressIndicator();

                  if (snapshot2.data.data['users'].keys != null &&
                      !snapshot2.data.data['users'].keys
                          .contains(snapshot1.data.uid.toString())) {
                    Firestore.instance.runTransaction((transaction) async {
                      Map newData = snapshot2.data['users'];
                      newData[snapshot1.data.uid.toString()] = [];
                      await transaction
                          .update(snapshot2.data.reference, {'users': newData});
                    });
                  }
                  List<dynamic> listOfVotes = snapshot2.data.data['users']
                      [snapshot1.data.uid.toString()];

                  return StreamBuilder(
                      stream:
                          Firestore.instance.collection('matchs').snapshots(),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot,
                      ) {
                        if (!snapshot.hasData)
                          return CircularProgressIndicator();
                        DocumentSnapshot doc;
                        snapshot.data.documents.forEach((document) {
                          if (document.data['started'] &&
                              !document.data['finished']) {
                            doc = document;
                          }
                        });
                        if (doc == null || doc.data['opponents'] == null) {
                          return CircularProgressIndicator();
                        }
                        return JungleHomeStateful(
                          fightersList: doc.data['opponents'],
                          title: doc.data['title'].toString(),
                          loggedInUser: snapshot1.data,
                          isBlurred: listOfVotes != null &&
                              listOfVotes.contains(doc.documentID.toString()),
                          votesDatabase: snapshot2.data,
                          fightId: doc.documentID.toString(),
                        );
                      });
                });
          }),
    );
  }
}

class JungleHomeStateful extends StatefulWidget {
  final List<dynamic> fightersList;
  final String title;
  final FirebaseUser loggedInUser;
  final bool isBlurred;
  final String fightId;
  final DocumentSnapshot votesDatabase;

  JungleHomeStateful(
      {this.fightersList,
      this.title,
      this.loggedInUser,
      this.isBlurred,
      this.votesDatabase,
      this.fightId});

  @override
  _JungleHomeStatefulState createState() {
    return new _JungleHomeStatefulState(
        futureFightersList: fightersList,
        title: title,
        isBlurred: isBlurred,
        votesDatabase: votesDatabase,
        loggedInUser: loggedInUser,
        fightId: fightId);
  }
}

class _JungleHomeStatefulState extends State<JungleHomeStateful> {
  final List<dynamic> futureFightersList;
  final String title;
  final FirebaseUser loggedInUser;
  final String fightId;
  final DocumentSnapshot votesDatabase;
  bool isBlurred = false;

  List<DocumentSnapshot> _fightersList = new List<DocumentSnapshot>();

  _JungleHomeStatefulState(
      {this.futureFightersList,
      this.title,
      this.loggedInUser,
      this.isBlurred,
      this.fightId,
      this.votesDatabase}) {
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
    if (!isBlurred) {
      setState(() {
        isBlurred = true;
      });
      Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshSnap =
            await transaction.get(_fightersList[index].reference);
        await transaction
            .update(freshSnap.reference, {'votes': freshSnap['votes'] + 1});
      });
      Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshSnap =
            await transaction.get(votesDatabase.reference);
        Map newData = freshSnap.data['users'];
        newData[loggedInUser.uid.toString()] += [fightId];
        await transaction.update(freshSnap.reference, {'users': newData});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    cards[0] = new JungleChoice(
      pos: "left",
      url: _fightersList.length == 2
          ? _fightersList[0].data['image'].toString()
          : null,
      onTap: () => vote(0),
      votes: _fightersList.length == 2
          ? _fightersList[0].data['votes'].toString()
          : null,
    );
    cards[1] = new JungleChoice(
      pos: "right",
      url: _fightersList.length == 2
          ? _fightersList[1].data['image'].toString()
          : null,
      onTap: () => vote(1),
      votes: _fightersList.length == 2
          ? _fightersList[1].data['votes'].toString()
          : null,
    );
    return Column(
      children: <Widget>[
        Stack(
          alignment: const Alignment(-0.05, 1.8),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                IsBlurred(isBlurred: isBlurred, child: cards[0]),
                IsBlurred(isBlurred: isBlurred, child: cards[1]),
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
                      color: Color.fromARGB(255, 0, 0, 0)),
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
