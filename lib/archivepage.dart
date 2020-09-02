import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Myarchivepage extends StatefulWidget {
  var logarchivelist;

  Myarchivepage(this.logarchivelist) {
    logarchivelist = this.logarchivelist;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyarchivepageState();
  }
}

class _MyarchivepageState extends State<Myarchivepage> {
  // @override
  // void initState() {
  //   super.initState();

  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Log Arşivi'),
        ),
        body: RefreshIndicator(
          onRefresh: () {
            return;
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.logarchivelist.map<Widget>((w) {
                  return RaisedButton(
                    child: Text(w.toString().split("/").last),
                    onPressed: () => {},
                  );
                }).toList(),
              ),
              Divider(),
              // Text(
              //   "\nİletişim Bilgileri",
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //       fontSize: 25,
              //       fontWeight: FontWeight.normal,
              //       color: Colors.black),
              // ),
              // Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
