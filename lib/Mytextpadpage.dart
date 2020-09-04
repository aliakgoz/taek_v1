import 'package:flutter/material.dart';

class Mytextpadpage extends StatefulWidget {
  var file;

  Mytextpadpage(this.file) {
    file = this.file;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MytextpadpageState();
  }
}

class _MytextpadpageState extends State<Mytextpadpage> {
  var myfile;

  Future<String> get _readFile async {
    myfile = await widget.file.readAsLines();
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
                    children:
                        snapshot.data.split("\n").asMap().entries.map((entry) {
                      int idx = entry.key;
                      String val = entry.value;

                      return Text(idx.toString() + " : " + val);
                    }).toList(),
                  );
            }
          },
        ),
      ),
    );
  }
}
