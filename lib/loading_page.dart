import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  LoadingPage();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.lightGreen,
      home: Container(
        color: Colors.yellow[700],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Icon(
                  Icons.cloud_download,
                  color: Colors.grey[850],
                  size: 100,
                ),
              ),
              Center(
                child: Text(
                  "Jungle tournament",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[850],
                    fontFamily: 'Komikaze',
                    fontSize: 30,
                    decoration: TextDecoration.none,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
