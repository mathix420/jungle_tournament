import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'is_blurred.dart';

class JungleChoice extends StatefulWidget {
  JungleChoice({
    Key key,
    this.pos,
    this.color, //UTILE ???????
    this.fighter,
    this.onTap,
  });

  final String pos;
  final Color color;
  final Function onTap;
  final DocumentSnapshot fighter;

  @override
  _JungleChoiceState createState() => _JungleChoiceState();
}

class _JungleChoiceState extends State<JungleChoice> {
  NetworkImage fighterImage;

  @override
  Widget build(BuildContext context) {
    final String url =
        widget.fighter != null ? widget.fighter.data['image'].toString() : null;

    if (url != null && url.length > 0) {
      fighterImage = new NetworkImage(url);
    }
    if (!IsBlurred.of(context).isBlurred) {
      return ClassicChoice(
        key: widget.key,
        pos: widget.pos,
        color: widget.color,
        url: url,
        onTap: widget.onTap,
        fighterImage: fighterImage,
      );
    } else {
      // TODO: put stream builder only for text
      return StreamBuilder(
          stream: widget.fighter != null
              ? Firestore.instance
                  .collection('fights')
                  .document(widget.fighter.documentID)
                  .snapshots()
              : Firestore.instance
                  .collection('fights')
                  .document('0')
                  .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData)
              return ClassicChoice(
                key: widget.key,
                pos: widget.pos,
                color: widget.color,
                url: url,
                onTap: () {},
                fighterImage: fighterImage,
              );
            return AlreadyVotedChoice(
              fighter: snapshot.data,
              onTap: widget.onTap,
              pos: widget.pos,
              key: widget.key,
              color: widget.color,
              fighterImage: fighterImage,
            );
          });
    }
  }
}

class ClassicChoice extends StatelessWidget {
  ClassicChoice({
    Key key,
    this.pos,
    this.color, //UTILE ???????
    this.url,
    this.onTap,
    this.fighterImage,
  });

  final String pos;
  final String url;
  final Color color;
  final Function onTap;
  final NetworkImage fighterImage;

  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: color,
        margin: (pos == "left")
            ? new EdgeInsets.fromLTRB(4, 8, 2, 4)
            : new EdgeInsets.fromLTRB(2, 8, 4, 4),
        height: 400,
        child: ClipRRect(
          borderRadius: new BorderRadius.all(new Radius.circular(8.0)),
          child: new GestureDetector(
            onTap: () => onTap(),
            child: new FadeInImage(
              image: (url != null && url.length > 0)
                  ? fighterImage
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

class AlreadyVotedChoice extends StatelessWidget {
  AlreadyVotedChoice({
    Key key,
    this.pos,
    this.color,
    this.fighter,
    this.onTap,
    this.fighterImage,
  });

  final String pos;
  final Color color;
  final Function onTap;
  final DocumentSnapshot fighter;
  final NetworkImage fighterImage;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: color,
        margin: (pos == "left")
            ? new EdgeInsets.fromLTRB(4, 8, 2, 4)
            : new EdgeInsets.fromLTRB(2, 8, 4, 4),
        height: 400,
        decoration: new ShapeDecoration(
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.all(new Radius.circular(8.0)),
          ),
          image: new DecorationImage(
            image: fighterImage != null
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
                  borderRadius: new BorderRadius.all(new Radius.circular(8.0)),
                ),
                child: Center(
                  child: Text(
                    (fighter != null && fighter.data != null
                            ? fighter.data['votes'].toString()
                            : '') +
                        " votes",
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
