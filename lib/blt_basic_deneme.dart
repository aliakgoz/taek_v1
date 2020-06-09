// import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';

// class Blt_deneme extends StatefulWidget {
//   @override
//   _Blt_denemeState createState() => _Blt_denemeState();
// }

// class _Blt_denemeState extends State<Blt_deneme> {
//   FlutterBlue flutterBlue = FlutterBlue.instance;
//   BluetoothDevice _device;
//   var devices = [
//     'abc',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text("Bluetooth Tarayıcı"),
//         ),
//         body: Column(
//           children: <Widget>[
//             RaisedButton(
//                 onPressed: () {
//                   devices = [
//                     '2abc',
//                   ];
//                   // Start scanning
//                   flutterBlue.startScan(timeout: Duration(seconds: 4));
//                   var subscription = flutterBlue.scanResults.listen((results) {
//                     // do something with scan results
//                     for (ScanResult r in results) {
//                       print('${r.advertisementData} found! rssi: ${r.rssi}');
//                       devices.add('${r.advertisementData} found! rssi: ${r.rssi}');
//                     }
//                   });

//                   /// Stop scanning
//                   flutterBlue.stopScan();

//                   setState(() {});
//                 },
//                 child: Text("Tara")),
//             ListView.builder(
//               scrollDirection: Axis.vertical,
//               shrinkWrap: true,
//               itemCount: devices.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text('${devices[index]}'),
//                 );
//               },
//             ),
//           ],
//         ));
//   }
// }
