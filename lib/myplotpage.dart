import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_plot/flutter_plot.dart';

class Myplotpage extends StatefulWidget {
  var file;

  Myplotpage(this.file) {
    file = this.file;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyplotpageState();
  }
}

class _MyplotpageState extends State<Myplotpage> {
  var myfile;
  final List<Point> data = [];

  Future<String> get _readFile async {
    myfile = await widget.file.readAsLines();

    for (var i = 0; i < myfile.length; i++) {
      try {
        print(myfile[i]);
        data.add(Point(
          double.parse(myfile[i].split(' ')[6]),
          DateTime.parse(
                  myfile[i].split(' ')[2] + ' ' + myfile[i].split(' ')[3])
              .difference(DateTime.parse(
                  myfile[0].split(' ')[2] + ' ' + myfile[0].split(' ')[3]))
              .inSeconds,
        ));
        print(data[i]);
        print(double.parse(myfile[i].split(' ')[7]));
      } finally {
        continue;
      }
    }

    myfile = myfile.join("\n").toString();
    return myfile;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(widget.file.path.toString().split("/").last),
        ),
        body: FutureBuilder<String>(
          future: _readFile, // async work
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Text('Yükleniyor....');
              default:
                if (snapshot.hasError)
                  return Text('Hata: ${snapshot.error}');
                else
                  return ListView(
                    children: <Widget>[
                      Card(
                        child: new Column(
                          children: <Widget>[
                            new Container(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: new Text(''),
                            ),
                            new Container(
                              child: new Plot(
                                height:
                                    double.parse((data.length * 5).toString()),
                                data: data,
                                gridSize: new Offset(2.0, 2.0),
                                style: new PlotStyle(
                                  // pointRadius: 3.0,
                                  outlineRadius: 1.0,
                                  primary: Colors.white,
                                  secondary: Colors.red,
                                  trace: true,
                                  showCoordinates: false,
                                  textStyle: new TextStyle(
                                    fontSize: 8.0,
                                    color: Colors.blueGrey,
                                  ),
                                  axis: Colors.blueGrey[600],
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                    20.0, 12.0, 12.0, 20.0),
                                yTitle: 'Zaman (s)',
                                xTitle: 'CPM',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
            }
          },
        ),
      ),
    );
  }
}
