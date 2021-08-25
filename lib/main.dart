import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:future_exercise/apis/sunsettimeapi.dart';
import 'package:future_exercise/colors.dart';
import 'package:future_exercise/init.dart';
import 'package:future_exercise/apis/naverapi.dart';
import 'package:future_exercise/splash.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as az;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future _initFuture = Init.initialize();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'noeul',
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
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    var androidSetting = AndroidInitializationSettings("@mipmap/ic_launcher");

    var iosSetting = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});
    var initializationSettings =
        InitializationSettings(android: androidSetting, iOS: iosSetting);

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    _showNotificationAtTime();
    print("알림 작동");
  }

  void _showNotificationAtTime() async {
    var type = 'yyyy-MM-dd (E) a HH:mm:ss';
    var sunsetAlarmDate = DateFormat(type).format(DateTime.now());
    print(sunsetAlarmDate);
    var android = AndroidNotificationDetails(
        'channelId', 'channelName', 'channelDescription',
        importance: Importance.max, priority: Priority.high);
    var ios = IOSNotificationDetails();
    var detail = NotificationDetails(android: android, iOS: ios);
    await _flutterLocalNotificationsPlugin.zonedSchedule(
        0, '제목', '내용', _setNotiTime(), detail,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  Future<void> onSelectNotification(String? payload) async {
    debugPrint('$payload');
    showDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text('sdsdsdsd'),
              content: Text('Payload: $payload'),
            ));
  }

  tz.TZDateTime _setNotiTime() {
    az.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 11, 47);

    return scheduledDate;
  }

  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var width = screenSize.width;
    var height = screenSize.height;
    final Future _naver = NaverApi.getNaverData(widget.lon, widget.lat);
    final Future _sunset =
        SunsetTimeApi.getSunsetTimeData(widget.lon, widget.lat);

    return Container(
      child: FutureBuilder(
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
            // int leftMin = diff.inMinutes.toInt() + 1;
            int leftMin = -30;
            print(leftMin);
            String getLeftTimeStr(int value) {
              final int hour = value ~/ 60;
              final int minutes = value % 60;
              return '노을까지 ${hour.toString().padLeft(2, "0")}시간 ${minutes.toString().padLeft(2, "0")}분 남았습니다.';
            }

            String finalTime = getLeftTimeStr(leftMin);
            String gong = "a";

            String setBackground(int lm) {
              int index = 1;

              if (lm > 200) {
                index = 1;
              } else if (lm <= 200 && lm > 70) {
                index = 2;
              } else if (lm <= 70 && lm > 40) {
                index = 3;
              } else if (lm <= 40 && lm > 10) {
                index = 4;
              } else if (lm <= 10 && lm > -20) {
                index = 5;
              } else if (lm <= -20) {
                index = 6;
              }

              return 'images/city${index}.png';
            }

            return Scaffold(
              body: Container(
                  height: height,
                  width: width,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        if (leftMin > 200) ...[
                          bgColors[0][0],
                          bgColors[0][1],
                        ] else if (leftMin <= 200 && leftMin > 70) ...[
                          bgColors[1][0],
                          bgColors[1][1],
                          bgColors[1][2],
                          bgColors[1][3],
                        ] else if (leftMin <= 70 && leftMin > 40) ...[
                          bgColors[2][0],
                          bgColors[2][1],
                          bgColors[2][2],
                          bgColors[2][3],
                        ] else if (leftMin <= 40 && leftMin > 10) ...[
                          bgColors[3][0],
                          bgColors[3][1],
                          bgColors[3][2],
                          bgColors[3][3],
                        ] else if (leftMin <= 10 && leftMin > -20) ...[
                          bgColors[4][0],
                          bgColors[4][1],
                          bgColors[4][2],
                          bgColors[4][3],
                        ] else if (leftMin <= -20) ...[
                          bgColors[5][0],
                          bgColors[5][1],
                        ]
                      ]
                          // colors: leftMin > 30 ? bgColors[0] : bgColors[1]
                          )),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SafeArea(
                        child: Column(
                          children: [
                            Text(
                              finalTime,
                              style: TextStyle(color: Colors.white),
                            ),
                            FutureBuilder(
                              future: _naver,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  int lastindex = snapshot.data
                                      .toString()
                                      .split(",")[1]
                                      .indexOf(']');
                                  String shi = snapshot.data
                                      .toString()
                                      .split(",")[0]
                                      .substring(1);
                                  String gu = snapshot.data
                                      .toString()
                                      .split(",")[1]
                                      .substring(1, lastindex);
                                  return Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          shi,
                                          style: TextStyle(
                                              fontSize: 30,
                                              fontFamily: 'GowunDodum',
                                              color: Colors.white),
                                        ),
                                        Text(
                                          " ",
                                          style: TextStyle(
                                              fontSize: 30,
                                              fontFamily: 'GowunDodum'),
                                        ),
                                        Text(
                                          gu,
                                          style: TextStyle(
                                              fontSize: 30,
                                              fontFamily: 'GowunDodum',
                                              color: Colors.white),
                                        )
                                      ],
                                    ),
                                  );
                                } else {
                                  return Text("loading");
                                }
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  aa.substring(0, 2),
                                  style: TextStyle(
                                      fontSize: 40,
                                      fontFamily: 'GowunDodum',
                                      color: Colors.white),
                                ),
                                Text(
                                  ":",
                                  style: TextStyle(
                                      fontSize: 40, color: Colors.white),
                                ),
                                Text(
                                  aa.substring(2),
                                  style: TextStyle(
                                      fontSize: 40,
                                      fontFamily: 'GowunDodum',
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 50,
                        child: Padding(
                          padding: const EdgeInsets.all(150),
                          child: Image.asset(
                            'images/sun1.png',
                          ),
                        ),
                      ),
                      Image.asset(
                        setBackground(leftMin),
                        alignment: Alignment.bottomCenter,
                      )
                    ],
                  )),
            );
          } else {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
        },
      ),
    );
  }
}
