import 'package:flutter/material.dart';

class NoCurrentFights extends StatelessWidget {
  NoCurrentFights();

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
              child: Text(
                "🙅",
                style: TextStyle(
                  color: Colors.yellow[700],
                  fontSize: 80,
                ),
              ),
            ),
            Center(
              child: Text(
                "Aucun combat en cours, revenez plus tard !",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
