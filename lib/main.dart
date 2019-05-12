import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import 'jungle_choice.dart';
import 'is_blurred.dart';
import 'no_connection.dart';
import 'no_fight.dart';
import 'classement_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return DashboardScreen();
  }
}

class DashboardScreen extends StatefulWidget {
  DashboardScreen({Key key}) : super(key: key);

  @override
  _DashboardScreenState createState() => new _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PageController _pageController = new PageController(initialPage: 0);
  int _pageIndex = 0;

  void onPageChanged(int page) {
    setState(() {
      this._pageIndex = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jungle tournament',
      debugShowCheckedModeBanner: false, // banner
      theme: ThemeData(
        primaryColor: Colors.yellow[700],
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Jungle tournament'),
        ),
        body: new PageView(
          children: [
            MyHomePage(),
            ClassementScreen(),
          ],
          controller: _pageController,
          onPageChanged: onPageChanged,
          physics: BouncingScrollPhysics(),
        ),
        bottomNavigationBar: new BottomNavigationBar(
          items: [
            new BottomNavigationBarItem(
              icon: new Icon(Icons.calendar_today),
              title: new Text("Combat en cours"),
            ),
            new BottomNavigationBarItem(
              icon: new Icon(Icons.format_list_bulleted),
              title: new Text("Liste des combats"),
            ),
          ],
          onTap: (selectedItem) {
            this._pageIndex = selectedItem;
            this._pageController.animateToPage(selectedItem,
                duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
          },
          currentIndex: _pageIndex,
          fixedColor: Colors.yellow[700],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.signInAnonymously().asStream(),
        builder:
            (BuildContext context1, AsyncSnapshot<FirebaseUser> snapshot1) {
          if (!snapshot1.hasData) return NoConnectionScreen();
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
                List<dynamic> listOfVotes =
                    snapshot2.data.data['users'][snapshot1.data.uid.toString()];

                return StreamBuilder(
                    stream: Firestore.instance.collection('matchs').snapshots(),
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot,
                    ) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      DocumentSnapshot doc;
                      snapshot.data.documents.forEach((document) {
                        if (document.data['started'] &&
                            !document.data['finished']) {
                          doc = document;
                        }
                      });
                      if (doc == null || doc.data['opponents'] == null) {
                        return NoCurrentFights();
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
        });
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
    return Column(
      children: <Widget>[
        Stack(
          alignment: const Alignment(-0.05, 1.8),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                IsBlurred(
                  isBlurred: isBlurred,
                  child: new JungleChoice(
                    pos: "left",
                    onTap: () => vote(0),
                    fighter:
                        _fightersList.length == 2 ? _fightersList[0] : null,
                  ),
                ),
                IsBlurred(
                  isBlurred: isBlurred,
                  child: new JungleChoice(
                    pos: "right",
                    onTap: () => vote(1),
                    fighter:
                        _fightersList.length == 2 ? _fightersList[1] : null,
                  ),
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
            VoteButton(
              heroTag: "img1",
              fighterData: _fightersList.length == 2 ? _fightersList[0] : null,
              vote: vote,
            ),
            VoteButton(
              heroTag: "img2",
              fighterData: _fightersList.length == 2 ? _fightersList[1] : null,
              vote: vote,
            ),
          ],
        ),
        Expanded(
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 30,
                fontFamily: "Komikaze",
              ),
            ),
            // padding: EdgeInsets.fromLTRB(0, 60, 0, 0),
          ),
        ),
      ],
    );
  }
}

class VoteButton extends StatelessWidget {
  VoteButton({
    @required this.heroTag,
    @required this.fighterData,
    @required this.vote,
  });

  final Object heroTag;
  final DocumentSnapshot fighterData;
  final Function vote;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: FloatingActionButton.extended(
        heroTag: heroTag,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        label: Text(
          fighterData != null ? fighterData.data['name'].toString() : '     ',
          style: TextStyle(fontSize: 18),
        ),
        icon: Text(
          fighterData != null ? fighterData.data['emoji'].toString() : '',
          style: TextStyle(fontSize: 30),
        ),
        onPressed: () => vote(int.parse(heroTag.toString().substring(3)) - 1),
      ),
    );
  }
}
