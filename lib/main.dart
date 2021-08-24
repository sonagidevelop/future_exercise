import 'package:flutter/material.dart';
import 'package:future_exercise/apis/sunsettimeapi.dart';
import 'package:future_exercise/init.dart';
import 'package:future_exercise/apis/naverapi.dart';
import 'package:future_exercise/splash.dart';
import 'package:geolocator/geolocator.dart';

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
              return MyHomePage(
                title: lati,
                lon: long,
                lat: lati,
              );
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(widget.lat),
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
                  return Column(
                    children: [Text(shi), Text(gu)],
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
                  return Column(
                    children: [Text(aa)],
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
