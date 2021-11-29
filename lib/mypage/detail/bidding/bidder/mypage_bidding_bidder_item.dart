import 'dart:async';

import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';
import 'package:intl/intl.dart';

import 'mypag_bidding_bidder_detail.dart';


class MyPageBidderItem extends StatefulWidget {

  String jobId, jobTtl, bidDlDtm, jobSts;
  int index, jobAmt, count;
  MyPageBidderItem( this.index, this.jobId, this.jobTtl, this.bidDlDtm, this.jobAmt, this.count, this.jobSts);

  @override
  _MyPageBidderItemState createState() => _MyPageBidderItemState();
}

class _MyPageBidderItemState extends State<MyPageBidderItem> {
  final formatter = new NumberFormat("###,###,###,###,###");
  String  formJobAmt = '0';
  String jobIts, jobSts;
  String timeToDisplay = '';
  String dateFormatString = 'yyyy-MM-dd HH:mm:ss';
  int timeForTimer = 0;
  bool isDisposed = false;
  Timer _timer;
  Duration _duration = Duration( seconds: 1);

  @override
  void initState() {
    formJobAmt =  formatter.format(widget.jobAmt);
    time();
    print('===============================================');
    print(widget.jobId);
    print(widget.jobSts);
    print('===============================================');
    super.initState();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  time(){
    _timer = Timer.periodic(_duration, (timer) {
      DateFormat dateFormat = DateFormat(dateFormatString); //날짜 방식 정하기
      DateTime nowDateTime = dateFormat.parse(
          DateFormat(dateFormatString).format(
              DateTime.now())); // 날짜 방식에 맞춰 현재 날짜 가져오기 String
      DateTime originDateTime = new DateFormat(dateFormatString).parse(
          widget.bidDlDtm); // 남은 입찰 날짜 넣어야됨
      // print('bidDlDtm ============================== ${widget.bidDlDtm}');
      // print('nowDateTime ============================== $nowDateTime');
      // print('originDateTime =========================== $originDateTime');
      final differenceSeconds = originDateTime
          .difference(nowDateTime)
          .inSeconds; // 두날짜의 차이를 초단위로 가져온다  앞이 입찰시간 뒤 가 현재 시간으로 해야되나?
      final differenceDays = originDateTime
          .difference(nowDateTime)
          .inDays;
      // print('Home differenceSeconds =============== $differenceSeconds');
      // print('Home differenceDays =============== $differenceDays');
      timeForTimer = differenceSeconds;
      if (widget.jobSts == "1") {
        if (!isDisposed) {
          setState(() {
            if (timeForTimer < 1) {
              timeToDisplay = "입찰 시간 종료";
              print('timeToDisplay ======================= $timeToDisplay');
              _timer.cancel();
            } else if (differenceDays > 0) {
              timeForTimer = timeForTimer - (differenceDays * 86400);
              int h = timeForTimer ~/ 3600;
              int t = timeForTimer - (3600 * h);
              int m = t ~/ 60;
              int s = t - (60 * m);
              // if()
              timeToDisplay =
                  "$differenceDays일 " + h.toString() + ":" + m.toString() +
                      ":" + s.toString();
              timeForTimer = timeForTimer - 1;
            } else if (timeForTimer < 60) {
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
              timeToDisplay =
                  h.toString() + ":" + m.toString() + ":" + s.toString();
              timeForTimer = timeForTimer - 1;
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return GestureDetector(
      onTap: (){
        // print('입찰 대기 상세 이동 ${widget.jobSts}');

        Navigator.push(context, MaterialPageRoute(builder: (context) => MypageBidderDetail(widget.jobId, widget.count, widget.bidDlDtm, widget.jobAmt, widget.jobTtl, widget.jobSts)));
      },
      child: Card(
        elevation: widget.index == 0 ? 8 : 4,
        shape: widget.index != 0  ? RoundedRectangleBorder( borderRadius: BorderRadius.circular(4),  side: BorderSide( color: Colors.grey[400], )) : null,
        margin: EdgeInsets.only(bottom: 10, left: 1, right: 1),
        child: Padding(
          padding: EdgeInsets.all(defaultSize * 1.6),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    // decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                    width: defaultSize * 34,
                    height: defaultSize * 5,
                    child: Text( widget.jobTtl, style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.7,fontWeight: FontWeight.bold ),),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    child: Text( '남은 입찰시간 :  $timeToDisplay', style: TextStyle(color: Colors.pinkAccent, fontSize: defaultSize * 1.7 ), ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: defaultSize * 1.6,top: defaultSize * 1),
                    padding: EdgeInsets.only(bottom: defaultSize * 2),
                    child: Row(
                      children: [
                        Container(
                          child: Container(
                            child: Text( '입찰 인원 ${widget.count}명', style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.7 ),),
                            // decoration: BoxDecoration( color: Colors.orange[50],  borderRadius: BorderRadius.circular(2), ),
                          ),
                        ),
                        Container(
                          // decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                          margin: EdgeInsets.only(left: defaultSize * 5),
                          width: defaultSize * 20,
                          child: Container(
                            child: Text( '희망 금액 $formJobAmt 원', style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.7 ),
                            textAlign: TextAlign.right,),
                            // decoration: BoxDecoration( color: Colors.orange[50],  borderRadius: BorderRadius.circular(2), ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}