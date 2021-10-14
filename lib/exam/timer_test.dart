import 'dart:async';

import 'package:flutter/material.dart';
import 'package:any_rent/main_home.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner: false,
      title: 'AnyRent',
      theme: ThemeData( primarySwatch: Colors.purple, ), // 앱에 매인 테마 색을 정한다.
      // home: MyHomePage(index: 0),
      home :Chat(),
    );
  }
}

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  int day = 0;
  int hour = 0;
  int min = 0;
  int sec = 0;
  String timeToDisplay = '';
  int timeForTimer = 0;

  String dateFormatString = 'yyyy-MM-dd HH:mm:ss';
  @override
  void initState() {
    super.initState();
    start();
  }

  start() {


    Timer.periodic(Duration(
      seconds: 1,
    ), (Timer t) {

      DateFormat dateFormat = DateFormat(dateFormatString); //날짜 방식 정하기
      DateTime nowDateTime = dateFormat.parse(DateFormat(dateFormatString).format(DateTime.now())); // 날짜 방식에 맞춰 현재 날짜 가져오기 String
      DateTime originDateTime = new DateFormat(dateFormatString).parse("2021-03-01 16:36:00 "); // 남은 입찰 날짜 넣어야됨
      // print('Home originDateTime =============== $originDateTime');
      // print('Home nowDateTime =============== $nowDateTime');
      final differenceSeconds = originDateTime.difference(nowDateTime).inSeconds; // 두날짜의 차이를 초단위로 가져온다  앞이 입찰시간 뒤 가 현재 시간으로 해야되나?
      // final differenceHours = originDateTime.difference(nowDateTime).inHours;
      final differenceDays = originDateTime.difference(nowDateTime).inDays;

      print('Home differenceSeconds =============== $differenceSeconds');
      // print('Home differenceHours =============== $differenceHours');
      print('Home differenceDays =============== $differenceDays');
      timeForTimer = differenceSeconds;

      setState(() {
        if (timeForTimer < 1) {
          t.cancel();
          if (timeForTimer == 0) {}
          // Navigator.pushReplacement(context, MaterialPageRoute(
          //   builder: (context) => Homepage(),
          // ));
          timeToDisplay = "입찰 시간 종료";
        }
        else if(differenceDays > 0){
          timeForTimer = timeForTimer - (differenceDays * 86400);
          int h = timeForTimer ~/ 3600;
          int t = timeForTimer - (3600 * h);
          int m = t ~/ 60;
          int s = t - (60 * m);
          // if()
          timeToDisplay =
              "$differenceDays 일"+  h.toString() + ":" + m.toString() + ":" + s.toString();
          timeForTimer = timeForTimer - 1;
        }
        else if (timeForTimer < 60) {
          timeToDisplay = timeForTimer.toString();
          timeForTimer = timeForTimer - 1;
        } else if (timeForTimer < 3600) {
          int m = timeForTimer ~/ 60;
          int s = timeForTimer - (60 * m);
          timeToDisplay = m.toString() + ":" + s.toString();
          timeForTimer = timeForTimer - 1;
        } else {
          int h = timeForTimer ~/ 3600;
          int t = timeForTimer - (3600 * h);
          int m = t ~/ 60;
          int s = t - (60 * m);
          // if()
          timeToDisplay =
              h.toString() + ":" + m.toString() + ":" + s.toString();
          timeForTimer = timeForTimer - 1;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // height = MediaQuery.of(context).size.height;
    // width = MediaQuery.of(context).size.width;
    print('Widget timeToDisplay ================== $timeToDisplay');
    return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                timeToDisplay,
                style: TextStyle(
                  fontSize: 35.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Center(child: Text('asd'))
          ],

        )
    );
  }
}