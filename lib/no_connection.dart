import 'package:flutter/material.dart';

class NoConnectionScreen extends StatelessWidget {
  NoConnectionScreen();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black12,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: Icon(
                Icons.cloud_off,
                color: Colors.yellow[700],
                size: 100,
              ),
            ),
            Center(
              child: Text(
                "Veuillez vous connecter à internet !",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.yellow[700],
                  fontSize: 18,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
