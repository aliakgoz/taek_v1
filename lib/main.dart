import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_basics_quiz_app/AnaSayfa2.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:battery_indicator/battery_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

import './DiscoveryPage.dart';
import './SelectBondedDevicePage.dart';
import './ChatPage.dart';
import './BackgroundCollectingTask.dart';
import './BackgroundCollectedPage.dart';
import './MainPage.dart';
import './anaSayfa.dart';
import 'helpers/LineChart.dart';
import 'helpers/PaintStyle.dart';
//import './example2.dart';
//import './bluetoothpage.dart';
//import './quiz.dart';
//import './result.dart';
// import 'bl_example.dart';
// import 'blt_basic_deneme.dart';
// import 'blt_basic_example.dart';
// import 'example.dart';

// void main() {
//   runApp(MyApp());
// }
// same with the line below
void main() {
  runApp(MaterialApp(
    home: MyApp(), // becomes the route named '/'
    // routes: <String, WidgetBuilder>{
    //   '/blue': (BuildContext context) => BluetoothPage(),
    //   // '/b': (BuildContext context) => MyPage(title: 'page B'),
    //   // '/c': (BuildContext context) => MyPage(title: 'page C'),
    // },
  ));
}

// Navigator.pushNamed(context, '/b');
// extends uses another (prebuilt) class blueprint and if you want you can add properties to it.
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyAppState();
  }

  get isConnected => connection != null && connection.isConnected;
}

GlobalKey _myapp_key = GlobalKey();

BluetoothConnection connection;
bool isConnecting;
bool isConnected;
String receivedData = '';
String ham_count = '';
String ham_temp = '';
String ham_bat = '';
String orta_dugme = 'Cihaza Bağlan';
String status_text = '';

var my_duration = Duration(milliseconds: 2500);

var _styleIndex = 0;

var _colorful = true;
var sound_enabled = true;
var _showPercentSlide = true;
var _showPercentNum = true;
var connected_device = '';
var avaratar_glow_on = false;
double device_info_icons_on = 0;
var title_font = GoogleFonts.jomhuria(
  textStyle: TextStyle(color: Colors.indigo, letterSpacing: .5, fontSize: 90),
);

var my_bl_state = BluetoothBondState.fromUnderlyingValue(10);

var my_server_adress;
var _size = 18.0;

var _ratio = 3.0;

List<double> cpm_received = List<double>();

// List<tim> cpm_received_time;

var battery_level = 0;
var temp_level = 0;

var bl_icon_ilk = Icons.bluetooth;

var completer = Completer();

Color _color = Colors.blue;

var my_conn_notifier;

var batteryIndicator = new BatteryIndicator(
  style: BatteryIndicatorStyle.values[_styleIndex],
  colorful: _colorful,
  showPercentNum: _showPercentNum,
  mainColor: _color,
  size: _size,
  ratio: _ratio,
  showPercentSlide: _showPercentSlide,
  batteryLv: battery_level,
);

class _MyAppState extends State<MyApp> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  BackgroundCollectingTask _collectingTask;

  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  void _onDataReceived(Uint8List data) {
    // if (data = null) {
    //   setState(() {
    //     _visible = true;
    //     status_text = 'Bağlantı Koptu';
    //   });
    // }
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);

    setState(() {
      receivedData = dataString;
      ham_count = receivedData.split(',')[0];
      // cpm_received.add(double.parse(ham_count));
      // cpm_received_time.add(TimeOfDay.now());

      ham_temp = receivedData.split(',')[1];
      ham_bat = receivedData.split(',')[2];
      battery_level = ((double.parse(ham_bat) % 1024) / 1024 * 100).round();
      temp_level = ((double.parse(ham_temp) % 1024) / 1024 * 100).round();
      sound_enabled ? FlutterBeep.beep() : {};
      avaratar_glow_on = true;
      device_info_icons_on = 1;
      // Scaffold.of(_myapp_key.currentContext).showSnackBar(snackBar);
    });
  }

  Future waitWhile(bool test(), [Duration pollInterval = Duration.zero]) {
    var completer = new Completer();
    check() {
      if (!test()) {
        completer.complete();
      } else {
        new Timer(pollInterval, check);
      }
    }

    check();
    return completer.future;
  }

  void my_func() async {
    await waitWhile(() => connection.isConnected).then((value) => {
          setState(() {
            showDialog(
              context: context,
              child: new AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80.0)),
                // title: new Text("My Super title"),
                content: new Text(
                  connected_device + ' bağlantısı koptu' + TimeOfDay.now().toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
            // await Scaffold.of(context).showSnackBar(snackBar);
          }),
        });
  }

  // @override
  // void dispose() {
  //   FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
  //   _collectingTask?.dispose();
  //   _discoverableTimeoutTimer?.cancel();
  //   super.dispose();
  // }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _myapp_key,
        resizeToAvoidBottomPadding: false,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          //title: Text('My First App'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(
                bl_icon_ilk,
                color: Colors.blue,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MainPage()));
              },
            ),
            // action button
          ],
        ),
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('imgs/taeklogo.png'),
                colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.2), BlendMode.dstATop),
                fit: BoxFit.contain,
              ),
            ),
            constraints: BoxConstraints.expand(),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    constraints: BoxConstraints(minHeight: 100, maxHeight: 200),
                    child: Text("RHTD",
                        style: title_font, textAlign: TextAlign.center),
                  ),
                  // Text(
                  //     "\n Radyasyon Ölçüm Cihazı \n Bağlantı ve Analiz Programı",
                  //     style: TextStyle(
                  //         color: Colors.grey[800],
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 18),
                  //     textAlign: TextAlign.center),
                  // Text("\n Dedektör 1 bağlandı. \n",
                  //     style: TextStyle(
                  //         color: Colors.blueGrey[800],
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 20),
                  //     textAlign: TextAlign.center),
                  RaisedButton(
                    onPressed: () async {
                      // if (connection == null) {
                      // } else {
                      //   isDisconnecting = true;
                      //   connection.dispose();
                      //   connection = null;
                      // }
                      final BluetoothDevice selectedDevice =
                          await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return SelectBondedDevicePage(
                                checkAvailability: false);
                          },
                        ),
                      );

                      if (selectedDevice != null) {
                        print('Connect -> selected ' + selectedDevice.address);
                        _startChat(context, selectedDevice);
                      } else {
                        print('Connect -> no device selected');
                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80.0)),
                    padding: EdgeInsets.all(0.0),
                    child: Ink(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.indigo,
                              Colors.blueAccent,
                            ], //Colors.blueGrey, Colors.redAccent
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(30.0)),
                      child: Container(
                        constraints:
                            BoxConstraints(maxWidth: 250.0, minHeight: 50.0),
                        alignment: Alignment.center,
                        child: Text(
                          orta_dugme,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  AvatarGlow(
                    startDelay: Duration(milliseconds: 1000),
                    glowColor: Colors.blueGrey,
                    endRadius: 120.0,
                    duration: Duration(milliseconds: 1000),
                    repeat: true,
                    showTwoGlows: true,
                    repeatPauseDuration: Duration(milliseconds: 100),
                    child: Material(
                      elevation: 8.0,
                      shape: CircleBorder(),
                      child: CircleAvatar(
                        backgroundColor: Colors.blueGrey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'cpm',
                              style:
                                  TextStyle(fontSize: 25, color: Colors.white),
                            ),
                            Text(
                              ham_count,
                              style:
                                  TextStyle(fontSize: 45, color: Colors.white),
                            ),
                          ],
                        ),
                        radius: 70.0,
                        //shape: BoxShape.circle
                      ),
                    ),
                    shape: BoxShape.circle,
                    animate: avaratar_glow_on,
                    curve: Curves.fastOutSlowIn, //Curves.fastOutSlowIn,
                  ),
                  Opacity(
                    opacity: device_info_icons_on,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.radio_button_checked,
                            color: connection.isConnected
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        Text(connected_device + ':      '),
                        new BatteryIndicator(
                          style: BatteryIndicatorStyle.values[_styleIndex],
                          colorful: _colorful,
                          showPercentNum: _showPercentNum,
                          mainColor: _color,
                          size: _size,
                          ratio: _ratio,
                          showPercentSlide: _showPercentSlide,
                          batteryLv: battery_level,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.music_note,
                            color: sound_enabled ? Colors.blue : Colors.grey,
                          ),
                          onPressed: () => {
                            sound_enabled
                                ? sound_enabled = false
                                : sound_enabled = true,
                          },
                        ),
                        IconButton(icon: Icon(Icons.save), onPressed: null),
                        Text(ham_temp + " \u2103"),
                      ],
                    ),
                  ),
                  
                ],
              ),
            )),
      ),
    );
  }

  bool isDisconnecting = false;

  void _startChat(BuildContext context, BluetoothDevice server) {
    StreamController<Uint8List> streamController =
        new StreamController.broadcast();

    BluetoothConnection.toAddress(server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
        // my_func();
        connected_device = server.name;
        my_server_adress = server.address;
        showDialog(
            context: context,
            child: new AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(80.0)),
              // title: new Text("My Super title"),
              content: new Text(
                server.name + ' bağlandı',
                textAlign: TextAlign.center,
              ),
            ));
      });

      streamController.addStream(connection.input);
      my_func();

      streamController.stream.listen(_onDataReceived).onDone(() {
        // my_conn_notifier = ValueNotifier(connection.isConnected == true);
        // ValueListenableBuilder(
        //   valueListenable: my_conn_notifier,
        //   builder: (context, value, child) {
        //     print(value);
        //     if (!connection.isConnected) {
        //       setState(() {});
        //     }
        //   },
        // );
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });

      // Future.wait([completer.future, streamController.stream.listen])
      //     .then((value) => {
      //           _visible = true,
      //           status_text = 'Bağlantı Koptu',
      //         });
    }).catchError((error) {
      print(
          'Cannot connect, exception occured***************************************************');
      print(error);
    });
  }
}
