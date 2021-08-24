import 'package:flutter/material.dart';
import 'package:future_exercise/apis/sunsettimeapi.dart';
import 'package:future_exercise/init.dart';
import 'package:future_exercise/apis/naverapi.dart';
import 'package:future_exercise/splash.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future _initFuture = Init.initialize();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FutureBuilder(
          future: _initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              String long = snapshot.data.toString().split(",")[0].substring(1);
              String lati =
                  snapshot.data.toString().split(",")[1].substring(0, 10);
              return Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        Color(0xff7faeff),
                        Color(0xffe0bfff),
                        Color(0xffffa67f),
                        Color(0xffff6a7a),
                      ])),
                  child: MyHomePage(
                    title: lati,
                    lon: long,
                    lat: lati,
                  ));
            } else {
              return SplashScreen();
            }
          },
        ));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage(
      {Key? key, required this.title, required this.lon, required this.lat})
      : super(key: key);

  final String title;
  final String lon;
  final String lat;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final Future _naver = NaverApi.getNaverData(widget.lon, widget.lat);
    final Future _sunset =
        SunsetTimeApi.getSunsetTimeData(widget.lon, widget.lat);

    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(
              future: _naver,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  int lastindex =
                      snapshot.data.toString().split(",")[1].indexOf(']');
                  String shi =
                      snapshot.data.toString().split(",")[0].substring(1);
                  String gu = snapshot.data
                      .toString()
                      .split(",")[1]
                      .substring(1, lastindex);
                  return Container(
                    child: Column(
                      children: [
                        Material(
                          color: Colors.red.withOpacity(0),
                          child: Text(
                            shi,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                textBaseline: TextBaseline.alphabetic),
                          ),
                        ),
                        Text(gu)
                      ],
                    ),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            FutureBuilder(
              future: _sunset,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  String aa = snapshot.data.toString().substring(1, 5);
                  String fs = aa.substring(0, 2);
                  String bs = aa.substring(2);
                  String fd = DateFormat('yyyy-MM-dd').format(DateTime.now());
                  var leftSstTimeStr = fd + ' ' + fs + ':' + bs;
                  DateTime leftSstTime =
                      new DateFormat('yyyy-MM-dd HH:mm').parse(leftSstTimeStr);
                  Duration diff = leftSstTime.difference(DateTime.now());
                  int leftMin = diff.inMinutes.toInt() + 1;
                  String getLeftTimeStr(int value) {
                    final int hour = value ~/ 60;
                    final int minutes = value % 60;
                    return '노을까지 ${hour.toString().padLeft(2, "0")}시간 ${minutes.toString().padLeft(2, "0")}분 남았습니다.';
                  }

                  String finalTime = getLeftTimeStr(leftMin);

                  return Column(
                    children: [
                      Text(aa),
                      Text(finalTime),
                    ],
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
