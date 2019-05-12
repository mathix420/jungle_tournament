import 'dart:ui';
import 'package:flutter/material.dart';

enum TimeIndexes { passed, current, future }

class FightRow extends StatelessWidget {
  FightRow({
    @required this.marginSize,
    this.height = 80,
    this.leftImage,
    this.rightImage,
    this.isFirst = false,
    this.isLast = false,
    this.votes,
    this.centerChild,
    this.timeIndex = TimeIndexes.passed,
  });

  final double marginSize;
  final double height;
  bool isFirst;
  bool isLast;
  final TimeIndexes timeIndex;
  final Widget centerChild;
  final List<String> votes;
  final DecorationImage leftImage;
  final DecorationImage rightImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        color: timeIndex == TimeIndexes.current ? Colors.black38 : null,
      ),
      child: Row(children: <Widget>[
        FighterCard(
          marginSize: marginSize,
          height: height,
          fighterImage: leftImage,
          timeIndex: timeIndex,
          votes: votes != null && votes.length >= 2 ? votes[0] : null,
        ),
        CenterSeparator(
          marginSize: marginSize,
          isFirst: isFirst,
          isLast: isLast,
          child: centerChild,
          color: timeIndex == TimeIndexes.current ? Colors.blue : null,
        ),
        FighterCard(
          marginSize: marginSize,
          height: height,
          fighterImage: rightImage,
          timeIndex: timeIndex,
          votes: votes != null && votes.length >= 2 ? votes[1] : null,
        ),
      ]),
    );
  }
}

class CenterSeparator extends StatelessWidget {
  CenterSeparator({
    this.height = 80,
    this.marginSize,
    this.isFirst = false,
    this.isLast = false,
    this.child,
    this.color,
  });

  final double height;
  final double marginSize;
  final bool isFirst;
  final bool isLast;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height + marginSize * 2,
      width: (MediaQuery.of(context).size.width - marginSize * 4) * 0.16,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              constraints: BoxConstraints(maxWidth: 1),
              color: !isFirst ? Colors.yellow[700] : null,
            ),
          ),
          SizedBox(height: 5),
          CircleAvatar(
            backgroundColor: color != null ? color : Colors.yellow[700],
            foregroundColor: Color(0xFF2e3131),
            // backgroundColor: Colors.transparent,
            // foregroundColor: Colors.white,
            child: child,
          ),
          SizedBox(height: 5),
          Expanded(
            child: Container(
              constraints: BoxConstraints(maxWidth: 1),
              color: !isLast ? Colors.yellow[700] : null,
            ),
          ),
        ],
      ),
    );
  }
}

class FighterCard extends StatelessWidget {
  FighterCard({
    @required this.marginSize,
    @required this.height,
    this.fighterImage,
    this.timeIndex = TimeIndexes.passed,
    this.votes,
  });

  final double marginSize;
  final double height;
  final String votes;
  final TimeIndexes timeIndex;
  final DecorationImage fighterImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        image: fighterImage,
      ),
      margin: EdgeInsets.all(marginSize),
      height: height,
      width: (MediaQuery.of(context).size.width - marginSize * 4) * 0.42,
      child: TimeRelativeCard(
        time: timeIndex,
        votes: votes,
      ),
    );
  }
}

class TimeRelativeCard extends StatelessWidget {
  TimeRelativeCard({
    this.time = TimeIndexes.passed,
    this.votes,
  });

  final TimeIndexes time;
  final String votes;

  @override
  Widget build(BuildContext context) {
    switch (time) {
      case TimeIndexes.future:
        return Container();
        break;
      case TimeIndexes.current:
        return Container();
        break;
      default:
        return ClipRRect(
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
                padding: EdgeInsets.all(10.0),
                child: Center(
                  child: Text(
                    "$votes votes",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Komikaze',
                        fontSize: 15),
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }
}
