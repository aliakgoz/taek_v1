import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';

//import './question.dart';
//import './answer.dart';
import './anasayfa.dart';
import './example2.dart';
//import './bluetoothpage.dart';
import './quiz.dart';
import './result.dart';

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

class _MyAppState extends State<MyApp> {
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => FlutterBlueApp()));
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
          child: Anasayfa(),
        ),
      ),
    );
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
