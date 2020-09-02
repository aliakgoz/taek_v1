import 'package:flutter/material.dart';

class Myinfopage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Bilgilendirme'),
        ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                "\nGenel Bilgiler",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              Divider(),
              Text(
                "\nİletişim Bilgileri",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
