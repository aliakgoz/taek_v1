import 'dart:async';
import 'dart:typed_data';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_basics_quiz_app/AnaSayfa2.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:battery_indicator/battery_indicator.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';

import './DiscoveryPage.dart';
import './SelectBondedDevicePage.dart';
import './ChatPage.dart';
import './BackgroundCollectingTask.dart';
import './BackgroundCollectedPage.dart';
import './MainPage.dart';
import './anaSayfa.dart';
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
}

String receivedData = '';
String ham_count = '';
String ham_temp = '';
String ham_bat = '';

var _styleIndex = 0;

var _colorful = true;

var _showPercentSlide = true;
var _showPercentNum = false;

var _size = 18.0;

var _ratio = 3.0;

var battery_level=0;

Color _color = Colors.blue;

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
      ham_temp = receivedData.split(',')[1];
      ham_bat = receivedData.split(',')[2]; 
      battery_level = ((double.parse(ham_bat)%1024)/1024*100).round();
      FlutterBeep.beep();
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _collectingTask?.dispose();
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
                Icons.bluetooth,
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
            child: Column(
              children: <Widget>[
                Text("\n Radyasyon ve Hızlandırıcı Teknolojileri Dairesi",
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                    textAlign: TextAlign.center),
                Text("\n Radyasyon Ölçüm Cihazı \n Bağlantı ve Analiz Programı",
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                    textAlign: TextAlign.center),
                Text("\n Dedektör 1 bağlandı. \n",
                    style: TextStyle(
                        color: Colors.blueGrey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                    textAlign: TextAlign.center),
                RaisedButton(
                  onPressed: () async {
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
                            Colors.blueGrey,
                            Colors.redAccent
                          ], //Colors.blueGrey, Colors.redAccent
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(30.0)),
                    child: Container(
                      constraints:
                          BoxConstraints(maxWidth: 250.0, minHeight: 50.0),
                      alignment: Alignment.center,
                      child: const Text(
                        "Cihaza Bağlan",
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
                  glowColor: Colors.green,
                  endRadius: 120.0,
                  duration: Duration(milliseconds: 1000),
                  repeat: true,
                  showTwoGlows: true,
                  repeatPauseDuration: Duration(milliseconds: 100),
                  child: Material(
                    elevation: 8.0,
                    shape: CircleBorder(),
                    child: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(ham_count, style: TextStyle(fontSize: 45,color: Colors.white70), ),
                      radius: 60.0,
                      //shape: BoxShape.circle
                    ),
                  ),
                  shape: BoxShape.circle,
                  animate: true,
                  curve: Curves.fastOutSlowIn,
                ),
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
              ],
            )),
      ),
    );
  }

  BluetoothConnection connection;
  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  void _startChat(BuildContext context, BluetoothDevice server) {
    String receivedData = '';
    String _messageBuffer = '';

    final TextEditingController textEditingController =
        new TextEditingController();
    final ScrollController listScrollController = new ScrollController();

    StreamController<Uint8List> streamController =
        new StreamController.broadcast();

    BluetoothConnection.toAddress(server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
      streamController.addStream(connection.input);

      streamController.stream.listen(_onDataReceived).onDone(() {
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
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }
}

// class _MyAppState extends State<MyApp> {
//   final _questions = const [
//     {
//       'questionText': 'What\'s your favorite color?',
//       'answers': [
//         {'text': 'Black', 'score': 10},
//         {'text': 'Red', 'score': 6},
//         {'text': 'Green', 'score': 3},
//         {'text': 'White', 'score': 1}
//       ]
//     },
//     {
//       'questionText': 'What\'s your favorite animal?',
//       'answers': [
//         {'text': 'Rabbit', 'score': 7},
//         {'text': 'Snake', 'score': 10},
//         {'text': 'Elephant', 'score': 3},
//         {'text': 'Lion', 'score': 1}
//       ]
//     },
//     {
//       'questionText': 'What\'s your favorite instructor?',
//       'answers': [
//         {'text': 'Max', 'score': 1},
//         {'text': 'Max', 'score': 1},
//         {'text': 'Max', 'score': 1},
//         {'text': 'Max', 'score': 1}
//       ]
//     },
//   ];

//   var _questionIndex = 0;
//   var _totalScore = 0;

//   void _resetQuiz() {
//     setState(() {
//       _questionIndex = 0;
//       _totalScore = 0;
//     });
//   }

//   void _answerQuestion(int score) {
//     _totalScore += score;

//     setState(() {
//       _questionIndex = _questionIndex + 1;
//     });
//     print(_questionIndex);
//     if (_questionIndex < _questions.length) {
//       print('We have more questions!');
//     } else {
//       print('no more questions!');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('My First App'),
//         ),
//         body: _questionIndex < _questions.length
//             ? Quiz(
//                 answerQuestion: _answerQuestion,
//                 questionIndex: _questionIndex,
//                 questions: _questions,
//               )
//             : Result(_totalScore, _resetQuiz),
//       ),
//     );
//   }
// }
