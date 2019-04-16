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
  JungleChoice({Key key, this.pos, this.color, this.url}) : super(key: key);

  final String pos;
  final String url;
  final Color color;

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
          child: new FadeInImage(
            image: (url != null && url.length > 0)
                ? new NetworkImage(url)
                : new AssetImage("assets/none.png"),
            fit: BoxFit.cover,
            placeholder: new AssetImage("assets/none.png"),
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
        stream: Firestore.instance.collection('fights').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return JungleHome(documents: snapshot.data.documents);
        },
      ),
    );
  }
}

class JungleHome extends StatelessWidget {
  final List<DocumentSnapshot> documents;

  JungleHome({this.documents});

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
                  url:
                      "https://thefivebeasts.files.wordpress.com/2015/01/picture-grey-wolf.jpg",
                ),
                JungleChoice(
                  pos: "right",
                  url:
                      "http://fantasticlass.weebly.com/uploads/4/6/1/7/4617850/948548969_orig.jpg",
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
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                label: Text("Loup", style: TextStyle(fontSize: 18)),
                icon: Text("🐺", style: TextStyle(fontSize: 30)),
                onPressed: () {},
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: FloatingActionButton.extended(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                label: Text(documents[0].data['name'].toString(), style: TextStyle(fontSize: 18)),
                icon: Text("🐯", style: TextStyle(fontSize: 30)),
                onPressed: () {},
              ),
            ),
          ],
        ),
        Padding(
          child: Text(
            "Qualifications",
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
