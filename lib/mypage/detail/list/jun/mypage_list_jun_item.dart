import 'dart:async';
import 'dart:convert';

import 'package:any_rent/mypage/mypage_server.dart';
import 'package:any_rent/settings/url.dart';
import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';
import 'package:intl/intl.dart';
import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'jun_detail.dart';

const url = UrlConfig.url;

class MyPageListJunWorkItem extends StatefulWidget {
  String token,
      jobId,
      jobTtl,
      aucMtd,
      jobStDtm,
      bidDlDtm,
      payMtd,
      jobIts,
      jobSts;
  int index, jobAmt;

  MyPageListJunWorkItem(
      this.token,
      this.jobId,
      this.jobTtl,
      this.aucMtd,
      this.jobStDtm,
      this.bidDlDtm,
      this.jobAmt,
      this.index,
      this.payMtd,
      this.jobIts,
      this.jobSts);

  @override
  _MyPageListJunWorkItemState createState() => _MyPageListJunWorkItemState();
}

class _MyPageListJunWorkItemState extends State<MyPageListJunWorkItem> {
  final formatter = new NumberFormat("###,###,###,###,###");
  String jobIts, jobSts;
  String timeToDisplay = '';
  String dateFormatString = 'yyyy-MM-dd HH:mm:ss';
  int timeForTimer = 0;
  bool isDisposed = false;
  Timer _timer;
  Duration _duration = Duration(seconds: 1);
  String token;
  int prfSeq;
  bool state;


  @override
  void initState() {
    jobIts = widget.jobIts;
    jobSts = widget.jobSts;
    time();
    super.initState();
  }



  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  time() {
    if (widget.aucMtd == '2') {
      _timer = Timer.periodic(_duration, (timer) {
        DateFormat dateFormat = DateFormat(dateFormatString); //날짜 방식 정하기
        DateTime nowDateTime = dateFormat.parse(DateFormat(dateFormatString)
            .format(DateTime.now())); // 날짜 방식에 맞춰 현재 날짜 가져오기 String
        DateTime originDateTime = new DateFormat(dateFormatString)
            .parse(widget.bidDlDtm); // 남은 입찰 날짜 넣어야됨

        // print('bidDlDtm ============================== ${widget.bidDlDtm}');
        // print('nowDateTime ============================== $nowDateTime');
        // print('originDateTime =========================== $originDateTime');

        final differenceSeconds = originDateTime
            .difference(nowDateTime)
            .inSeconds; // 두날짜의 차이를 초단위로 가져온다  앞이 입찰시간 뒤 가 현재 시간으로 해야되나?
        final differenceDays = originDateTime.difference(nowDateTime).inDays;

        // print('MyPageListJunWorkItem differenceSeconds =============== $differenceSeconds');
        // print('MyPageListJunWorkItem differenceDays =============== $differenceDays');
        timeForTimer = differenceSeconds;
        if (!isDisposed) {
          setState(() {
            if (timeForTimer < 1) {
              timeToDisplay = "입찰 시간 종료";
              print('timeToDisplay ======================= $timeToDisplay');
              jobSts = "8";
              _timer.cancel();
            }
          });
        }
      });
    }
  }
  // loadToken() async{
  //   token = await customSharedPreferences.getString('token');
  //   state = await customSharedPreferences.getBool('state');
  //   try{
  //     prfSeq = widget.junItems['prfSeq'];
  //   } catch(e){
  //     Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요."),duration: Duration(seconds: 3),));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return GestureDetector(
      onTap: () {
        print('jobSts ============================= $jobSts');
        print('jobId===================================${widget.jobId}');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MyPageJunDetail(jobId: widget.jobId)));
      },
      child: Card(
        elevation: widget.index == 0 ? 8 : 4,
        shape: widget.index != 0 ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: Colors.grey[400],)) : null,
        margin: EdgeInsets.only(bottom: 7, left: 1, right: 1),
        child: Padding(
          padding: EdgeInsets.only(top: defaultSize * 1, left: defaultSize * 3),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: defaultSize),

              ),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: defaultSize * 3),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        // border: Border.all(color: Colors.black),
                        shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: (prfSeq == null)
                        ? AssetImage('assets/noimage.jpg')
                          : NetworkImage('$url/api/mypage/images?recieveToken=$prfSeq')
                    )
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        // decoration: BoxDecoration(
                        //     border: Border.all(color: Colors.grey)),
                        margin: EdgeInsets.only(left: defaultSize * 3),
                        padding: EdgeInsets.only(left: 5, top: 5),
                        height: 40,
                        width: defaultSize * 25,
                        child: Text(widget.jobTtl ?? '일거리',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: defaultSize * 3,bottom: defaultSize * 1,right: defaultSize * 6.7),
                        width: defaultSize * 17,
                        // decoration: BoxDecoration(
                        //     border: Border.all(color: Colors.grey)),
                        child: (widget.aucMtd == "1")
                            ? Text(
                                '금액 : ' + formatter.format(widget.jobAmt) + '원',
                                style: TextStyle(
                                    fontSize: defaultSize * 1.7,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                              )
                            : Text(
                                '희망 금액 : ' +
                                    formatter.format(widget.jobAmt) +
                                    '원',
                                style: TextStyle(
                                    fontSize: defaultSize * 1.7,
                                    color: Colors.black,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                              ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding:EdgeInsets.only(bottom: defaultSize * 1),
                            // decoration: BoxDecoration(
                            //     border: Border.all(color: Colors.grey)),
                            child: Text(
                              (widget.aucMtd == "1") ? '선착순' : '입찰식',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: defaultSize * 1.7,
                                  fontWeight: FontWeight.bold),
                            ),

                            // decoration: BoxDecoration( color: Colors.lightBlue[50],  borderRadius: BorderRadius.circular(2), ),
                          ),
                          Container(
                            padding:EdgeInsets.only(bottom: defaultSize * 1),
                            margin: EdgeInsets.only(left: defaultSize * 3,right: defaultSize * 6.7),
                            // decoration: BoxDecoration(
                            //     border: Border.all(color: Colors.grey)),
                            child: Text(
                              (widget.payMtd == "1") ? '직접결제' : '안전결제',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: defaultSize * 1.7,
                                  fontWeight: FontWeight.bold),
                            ),

                            // decoration: BoxDecoration( color: Colors.pink[50],  borderRadius: BorderRadius.circular(2), ),
                          ),
                        ],
                      ),

                      Container(
                        margin: EdgeInsets.only(right: defaultSize * 12.5),
                        width: defaultSize * 10,
                        // decoration: BoxDecoration(
                        //     border: Border.all(color: Colors.grey)),
                        child: jobStsText( jobSts, defaultSize),
                        padding:
                            EdgeInsets.only(left: defaultSize * 1),
                        // decoration: BoxDecoration( color: Colors.orange[50],  borderRadius: BorderRadius.circular(2), ),
                      ),
                      SizedBox(height: defaultSize * 2,)
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget jobStsText(String jobSts, double defaultSize) {
    if (jobSts == "1") {
      return Text(
        '입찰중 ',
        style: TextStyle(
            color: Colors.lightGreen,
            fontSize: defaultSize * 1.7,
            fontWeight: FontWeight.bold),
        textAlign: TextAlign.left,
      );
    }
    if (jobSts == "2") {
      return Text(
        '진행중 ',
        style: TextStyle(
            color: Colors.orange,
            fontSize: defaultSize * 1.7,
            fontWeight: FontWeight.bold),
        textAlign: TextAlign.left,
      );
    }
    if (jobSts == "3") {
      return Text(
        '완료   ',
        style: TextStyle(
            color: Colors.blue[900],
            fontSize: defaultSize * 1.7,
            fontWeight: FontWeight.bold),
        textAlign: TextAlign.left,
      );
    }
    if (jobSts == "5") {
      return Text(
        '주니 완료 대기중  ',
        style: TextStyle(
            color: Colors.blue,
            fontSize: defaultSize * 1.2,
            fontWeight: FontWeight.bold),
        textAlign: TextAlign.left,
      );
    }
    if (jobSts == "8") {
      return Text(
        '시간초과',
        style: TextStyle(
            color: Colors.amber[700],
            fontSize: defaultSize * 1.7,
            fontWeight: FontWeight.bold),
        textAlign: TextAlign.left,
      );
    }
    if (jobSts == "9") {
      return Text(
        '취소   ',
        style: TextStyle(
            color: Colors.red,
            fontSize: defaultSize * 1.7,
            fontWeight: FontWeight.bold),
        textAlign: TextAlign.left,
      );
    }
  }
}
