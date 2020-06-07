import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';


class Anasayfa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text("\n \n \n Radyasyon ve Hızlandırıcı Teknolojileri Dairesi",
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
                Text("\n Dedektör 1 bağlandı. \n \n \n",
                    style: TextStyle(
                        color: Colors.blueGrey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                    textAlign: TextAlign.center),
                RaisedButton(
                  onPressed: () {},
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
                      child: Text(
                        "Sayıma Başla",
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
                  endRadius: 90.0,
                  duration: Duration(milliseconds: 2000),
                  repeat: true,
                  showTwoGlows: false,
                  repeatPauseDuration: Duration(milliseconds: 100),
                  child: Material(
                    elevation: 8.0,
                    shape: CircleBorder(),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[100],
                      child: Text(
                        '0',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      radius: 40.0,
                      //shape: BoxShape.circle
                    ),
                  ),
                  shape: BoxShape.circle,
                  animate: true,
                  curve: Curves.fastOutSlowIn,
                )
              ],
            ),
          );
  }
}