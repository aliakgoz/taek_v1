// import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';

// class BluetoothPage extends StatefulWidget {
//   @override
//   State createState() => new BtListe();
// }

// FlutterBlue flutterBlue = FlutterBlue.instance;

// class BtListe extends State<BluetoothPage> {
//   List<String> litems = [];
//   final TextEditingController eCtrl = new TextEditingController();
//   @override
//   Widget build(BuildContext ctxt) {
//     return new Scaffold(
//         appBar: new AppBar(
//           title: new Text("Dynamic Demo"),
//         ),
//         body: new Column(
//           children: <Widget>[
//             RaisedButton(
//               onPressed: () {
//                 // Start scanning

//                 flutterBlue.startScan(timeout: Duration(seconds: 4));

//                 // Listen to scan results
//                 var subscription = flutterBlue.scanResults.listen((results) {
//                   // do something with scan results
//                   List<String> my_bl_list = [];
//                   for (ScanResult r in results) {
//                     my_bl_list.add(
//                         '${r.device.name} bulundu. '); //(${r.advertisementData})
//                   }
//                   litems = my_bl_list;
//                   setState(() {});
//                 });
//               },
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(80.0)),
//               padding: EdgeInsets.all(0.0),
//               child: Ink(
//                 decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Color(0xff374ABE), Color(0xff64B6FF)],
//                       begin: Alignment.centerLeft,
//                       end: Alignment.centerRight,
//                     ),
//                     borderRadius: BorderRadius.circular(10.0)),
//                 child: Container(
//                   constraints: BoxConstraints(maxWidth: 150.0, minHeight: 40.0),
//                   alignment: Alignment.center,
//                   child: Text(
//                     "Cihazları Ara",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             new Expanded(
//                 child: new ListView.builder(
//                     itemCount: litems.length,
//                     itemBuilder: (BuildContext ctxt, int index) {
//                       return new RaisedButton(
//                         child: Text(
//                           litems[index],
//                           style: TextStyle(
//                             fontSize: 24,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         //width: double.infinity,
//                         padding: const EdgeInsets.all(10.0),
//                         // decoration: BoxDecoration(
//                         //     border: Border.all(
//                         //   color: Colors.grey,
//                         //   width: 1,
//                         // )),
//                         onPressed: () async => {
//                           //await device.connect(),
//                           Navigator.pop(context),
//                         },
//                       );
//                     }))
//           ],
//         ));
//   }
// }
