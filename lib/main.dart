import 'dart:async';
import 'dart:convert';
// import 'dart:html';
import 'dart:io';
import 'dart:typed_data';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:flutter_basics_quiz_app/infopage.dart';
import 'package:flutter_basics_quiz_app/archivepage.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:battery_indicator/battery_indicator.dart';
// import 'package:charts_flutter/flutter.dart' as charts;
// import 'package:flutter_audio_player/flutter_audio_player.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import './SelectBondedDevicePage.dart';
import './BackgroundCollectingTask.dart';
import './MainPage.dart';

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
String dataString = '';
double double_count = 0;

var my_duration = Duration(milliseconds: 2500);

var _styleIndex = 0;

// List<TimeSeriesSales> chart_data_list = new List();

var my_device_connected = false;
var _colorful = true;
var sound_enabled = true;
var _showPercentSlide = true;
var _showPercentNum = true;
var connected_device = '';
var avaratar_glow_on = false;
double device_info_icons_on = 1;
// var title_font = GoogleFonts.jomhuria(
//   textStyle: TextStyle(color: Colors.indigo, letterSpacing: .5, fontSize: 90),
// );

var my_bl_state = BluetoothBondState.fromUnderlyingValue(10);

var my_server_adress;
var _size = 18.0;

var _ratio = 3.0;

// var soundId;

// List<double> cpm_received = List<double>();

// List<tim> cpm_received_time;

var battery_level = 0;
var temp_level = 0;

var bl_icon_ilk = Icons.bluetooth;

var completer = Completer();

Color _color = Colors.blue;

var my_conn_notifier;
DateTime now = DateTime.now();
var filename = '';
var logarchivelist;

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
  String _messageBuffer = '';
  String my_log = "";
  // var sink = new File('file.txt').openWrite();

  Timer _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  BackgroundCollectingTask _collectingTask;

  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    super.initState();

    filename =
        'TAEK_v1_log_${now.year.toString()}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';

    // soundId = await rootBundle.load("sounds/bip_geiger1.wav").then((ByteData soundData) {
    //           return pool.load(soundData);
    //         });
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

  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();
    // final directory = await getApplicationDocumentsDirectory();
    logarchivelist = [];
    directory.list().forEach((element) {
      logarchivelist.add(element.toString());
    });
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;

    print('$path');

    final file = File('$path/$filename.txt');

    final doesExist = await file.exists();

    if (!doesExist) await file.create();

    return file;
  }

  Future<File> writeCounts(String cpm_log) async {
    final file = await _localFile;

    // Write the file.
    return file.writeAsString('$cpm_log', mode: FileMode.append);
  }

  // /data/user/0/com.example.flutter_basics_quiz_app/app_flutter

  Future<void> send() async {
    final path = await _localPath;
    final Email email = Email(
      body:
          'TAEK01 adlı cihazın ${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} tarihli log kaydı ektedir.',
      subject: 'TAEK01 LOG KAYDI',
      recipients: [],
      attachmentPaths: ['$path/$filename.txt'],
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
  }

  void _onDataReceived(Uint8List data) {
    print('Data:');
    print(data);
    // Allocate buffer for parsed data

    Uint8List buffer = Uint8List(data.length);

    // Create message if there is new line character
    dataString = String.fromCharCodes(data);
    print(dataString);
    //int index = dataString.indexOf('x');
    int index = data.indexOf(120);
    print(index);
    if (~index != 0) {
      setState(() {
        String myString = _messageBuffer + dataString.substring(0, index);
        _messageBuffer = dataString.substring(index);
        print(_messageBuffer);
        receivedData = myString.replaceAll('x', '');
        ham_count = receivedData.split(',')[0];
        double_count = double.parse(ham_count);

        print(receivedData.split(','));
        print(ham_count);
        //cpm_received.add(double.parse(ham_count));
        // cpm_received_time.add(TimeOfDay.now());

        // chart_data_list
        //     .add(TimeSeriesSales(DateTime.now(), int.parse(ham_count)));
        ham_temp = receivedData.split(',')[1];
        ham_bat = receivedData.split(',')[2];
        print(ham_temp);
        print(ham_bat);
        battery_level = ((double.parse(ham_bat) % 1024) / 1024 * 100).round();
        temp_level =
            ((double.parse(ham_temp) % 1024) / 1024 * 100).round(); //<>
        my_log = my_log +
            '${new DateTime.now()} : CPM: ' +
            double_count.toStringAsFixed(3) +
            ' BATTERY LEVEL: ' +
            battery_level.toString() +
            ' TEMP: ' +
            temp_level.toString() +
            '\n';
        writeCounts('${new DateTime.now()} : CPM: ' +
            double_count.toStringAsFixed(3) +
            ' BATTERY LEVEL: ' +
            battery_level.toString() +
            ' TEMP: ' +
            temp_level.toString() +
            '\n');
        sink.write('  ${new DateTime.now()} : ' +
            double_count.toStringAsFixed(3) +
            ' ' +
            battery_level.toString() +
            ' ' +
            temp_level.toString() +
            '<br>\n');

        sound_enabled
            ? double_count < 100.0
                ? FlutterBeep.beep()
                : double_count < 1000.0
                    ? {
                        FlutterBeep.beep()
                            .then((value) => FlutterBeep.beep())
                            .then((value) => FlutterBeep.beep()),
                      }
                    : double_count < 2000.0
                        ? {
                            FlutterBeep.beep()
                                .then((value) => FlutterBeep.beep())
                                .then((value) => FlutterBeep.beep())
                                .then((value) => FlutterBeep.beep())
                                .then((value) => FlutterBeep.beep())
                                .then((value) => FlutterBeep.beep()),
                          }
                        : double_count < 10000.0
                            ? {
                                FlutterBeep.beep()
                                    .then((value) => FlutterBeep.beep())
                                    .then((value) => FlutterBeep.beep())
                                    .then((value) => FlutterBeep.beep())
                                    .then((value) => FlutterBeep.beep())
                                    .then((value) => FlutterBeep.beep())
                                    .then((value) => FlutterBeep.beep())
                                    .then((value) => FlutterBeep.beep())
                                    .then((value) => FlutterBeep.beep())
                                    .then((value) => FlutterBeep.beep())
                                    .then((value) => FlutterBeep.beep())
                                    .then((value) => FlutterBeep.beep()),
                              }
                            : {
                                FlutterBeep.playSysSound(30),
                              }
            : {};

        avaratar_glow_on = true;
        device_info_icons_on = 1;
        // Scaffold.of(_myapp_key.currentContext).showSnackBar(snackBar);
      });
    } else {
      _messageBuffer = _messageBuffer + dataString;
    }
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
    if (connection != null) {
      await waitWhile(() => connection.isConnected).then((value) => {
            setState(() {
              my_device_connected = false;
              sink.close();
              showDialog(
                context: context,
                child: new AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80.0)),
                  // title: new Text("My Super title"),
                  content: new Text(
                    connected_device + ' bağlantısı koptu'
                    // + TimeOfDay.now().toString()
                    ,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
              // await Scaffold.of(context).showSnackBar(snackBar);
            }),
          });
    }
  }

  // void my_chart() async {
  //   var series = ChartSeries([
  //     'Jan',
  //     'Feb',
  //     'Mar'
  //   ], {
  //     'A': [10, 20, 5],
  //     'B': [15, 25, 55],
  //     'C': [100, 130, 140]
  //   });

  //   series.title = 'Chart Example';
  //   series.xTitle = 'Months';
  //   series.yTitle = 'Count';
  //   series.options.fillLines = true;
  //   series.options.straightLines = true;

  //   //var charEngine = ChartEngineChartJS() ;
  //   var charEngine = ChartEngineApexCharts();
  //   await charEngine.load();
  //   charEngine.renderLineChart(querySelector('#output'), series);
  // }
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
            IconButton(
              icon: Icon(
                Icons.archive,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Myarchivepage(logarchivelist)));
              },
            ),
            IconButton(
              icon: Icon(
                Icons.info_outline,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Myinfopage()));
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
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.bottomCenter,
                    // constraints: BoxConstraints(minHeight: 100, maxHeight: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text("\n\nNükleer Enerji Araştırma Enstitüsü",
                            style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo),
                            textAlign: TextAlign.center),
                        Text("Sintilatörlü Dozimetre Cihazı\n",
                            style:
                                TextStyle(fontSize: 30, color: Colors.indigo),
                            textAlign: TextAlign.center),
                      ],
                    ),
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
                    glowColor: double_count < 1000.0
                        ? Colors.green
                        : double_count < 1000000.0 ? Colors.yellow : Colors.red,
                    endRadius: 120.0,
                    duration: Duration(milliseconds: 1000),
                    repeat: true,
                    showTwoGlows: true,
                    repeatPauseDuration: Duration(milliseconds: 100),
                    child: Material(
                      elevation: 8.0,
                      shape: CircleBorder(),
                      child: CircleAvatar(
                        backgroundColor: my_device_connected
                            ? double_count < 10.0
                                ? Colors.green
                                : double_count < 10000.0
                                    ? Colors.yellow[800]
                                    : double_count < 1000000.0
                                        ? Colors.orange[800]
                                        : Colors.red
                            : Colors.grey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              double_count < 1000.0
                                  ? '\u00B5Sv/saat'
                                  : double_count < 1000000.0
                                      ? 'mSv/saat'
                                      : 'Sv/saat',
                              style:
                                  TextStyle(fontSize: 25, color: Colors.white),
                            ),
                            Text(
                              double_count < 1000.0
                                  ? double_count.toStringAsFixed(3)
                                  : double_count < 1000000.0
                                      ? (double_count / 1000.0)
                                          .toStringAsFixed(3)
                                      : (double_count / 1000000.0)
                                          .toStringAsFixed(3),
                              style: TextStyle(
                                  fontSize:
                                      double_count.toStringAsFixed(3).length < 6
                                          ? 43
                                          : 33,
                                  color: Colors.white),
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
                            color: connection == null
                                ? Colors.grey
                                : connection.isConnected
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
                            Icons.volume_down,
                            color: sound_enabled ? Colors.blue : Colors.grey,
                          ),
                          onPressed: () => {
                            sound_enabled
                                ? sound_enabled = false
                                : sound_enabled = true,
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.save),
                          onPressed: send,
                        ),
                        // onPressed: connection != null
                        //     ? connection.isConnected
                        //         ? () => _sendMessage('deneme')
                        //         : null
                        //     : null),
                        Text(temp_level.toString() + " \u2103"),
                        IconButton(
                            icon: Icon(Icons.do_not_disturb_on),
                            color: connection != null
                                ? connection.isConnected
                                    ? Colors.red
                                    : Colors.grey
                                : Colors.red,
                            onPressed: connection != null
                                ? () => {
                                      connection.close(),
                                    }
                                : null),
                      ],
                    ),
                  ),

                  // my_chart,
                ],
              ),
            )),
      ),
    );
  }

  bool isDisconnecting = false;

  void _sendMessage(String text) async {
    text = text.trim();

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\n"));
        await connection.output.allSent;
        print(utf8.encode(text + "\r\n"));
        setState(() {});
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }

  var file;
  var sink;

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
        my_device_connected = true;
        file = new File('logs/file.txt');
        sink = file.openWrite();
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
          print('Bağlantı koptu!');
        } else {
          print('Bağlantı uzaktan kapatıldı!');
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

// class my_chart extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return new charts.TimeSeriesChart(
//       [
//         new charts.Series<TimeSeriesSales, DateTime>(
//           id: 'Sales',
//           colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
//           domainFn: (TimeSeriesSales sales, _) => sales.time,
//           measureFn: (TimeSeriesSales sales, _) => sales.sales,
//           data: chart_data_list != null
//               ? chart_data_list
//               : [
//                   new TimeSeriesSales(new DateTime(2017, 9, 1), 5),
//                   new TimeSeriesSales(new DateTime(2017, 9, 2), 10),
//                 ],
//         )
//       ],
//       animate: false,
//       // Set the default renderer to a bar renderer.
//       // This can also be one of the custom renderers of the time series chart.
//       defaultRenderer: new charts.BarRendererConfig<DateTime>(),
//       // It is recommended that default interactions be turned off if using bar
//       // renderer, because the line point highlighter is the default for time
//       // series chart.
//       defaultInteractions: false,
//       // If default interactions were removed, optionally add select nearest
//       // and the domain highlighter that are typical for bar charts.
//       behaviors: [new charts.SelectNearest(), new charts.DomainHighlighter()],
//     );
//   }
// }
