import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import './Mytextpadpage.dart';
import './Myplotpage.dart';

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
        body: ListView(
          children: widget.logarchivelist.map<Widget>((w) {
            var bfile =
                File(w.toString().replaceAll("File: ", "").replaceAll("'", ""));
            var filesize = (bfile.lengthSync() / 1024).toStringAsFixed(0);
            return ExpansionTile(
              title: Row(children: <Widget>[
                IconButton(
                    icon: Icon(Icons.assignment),
                    color: Colors.blueAccent,
                    onPressed: () => {}),
                Flexible(
                  child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                          w.toString().replaceAll("'", "").split("/").last)),
                ),
              ]),
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(filesize + " KB"),
                      // Text(w
                      //     .toString()
                      //     .replaceAll("File: ", "")
                      //     .replaceAll("'", "")),
                      IconButton(
                          icon: Icon(Icons.share),
                          onPressed: () async {
                            final Email email = Email(
                              body: 'TAEK01 adlı cihazın log kaydı ektedir.',
                              subject: 'TAEK01 LOG KAYDI',
                              recipients: [],
                              attachmentPaths: [
                                w
                                    .toString()
                                    .replaceAll("File: ", "")
                                    .replaceAll("'", "")
                              ],
                              isHTML: false,
                            );

                            String platformResponse;

                            try {
                              await FlutterEmailSender.send(email);
                              platformResponse = 'success';
                            } catch (error) {
                              platformResponse = error.toString();
                            }

                            if (!mounted) return;
                          }),
                      IconButton(
                          icon: Icon(Icons.table_chart),
                          onPressed: () {
                            final file = File(w
                                .toString()
                                .replaceAll("File: ", "")
                                .replaceAll("'", ""));
                            // file.readAsLines().then((value) => )
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Mytextpadpage(file)));
                          }),
                      IconButton(
                          icon: Icon(Icons.show_chart),
                          onPressed: () {
                            final file = File(w
                                .toString()
                                .replaceAll("File: ", "")
                                .replaceAll("'", ""));
                            // file.readAsLines().then((value) => )
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Myplotpage(file)));
                          }),
                      IconButton(
                          icon: Icon(Icons.delete_forever), onPressed: null),
                    ]),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
