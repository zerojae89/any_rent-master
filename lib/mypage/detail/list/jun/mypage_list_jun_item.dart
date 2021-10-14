import 'dart:async';

import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';
import 'package:intl/intl.dart';

import 'jun_detail.dart';

class MyPageListJunWorkItem extends StatefulWidget {

  String token, jobId, jobTtl, aucMtd, jobStDtm, bidDlDtm, payMtd, jobIts, jobSts;
  int index, jobAmt;
  MyPageListJunWorkItem(this.token, this.jobId, this.jobTtl, this.aucMtd, this.jobStDtm, this.bidDlDtm, this.jobAmt, this.index, this.payMtd, this.jobIts, this.jobSts);

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
  Duration _duration = Duration( seconds: 1);

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

  time(){
    if(widget.aucMtd == '2'){
      _timer = Timer.periodic(_duration, (timer) {
        DateFormat dateFormat = DateFormat(dateFormatString); //날짜 방식 정하기
        DateTime nowDateTime = dateFormat.parse(DateFormat(dateFormatString).format(DateTime.now())); // 날짜 방식에 맞춰 현재 날짜 가져오기 String
        DateTime originDateTime = new DateFormat(dateFormatString).parse(widget.bidDlDtm); // 남은 입찰 날짜 넣어야됨

        // print('bidDlDtm ============================== ${widget.bidDlDtm}');
        // print('nowDateTime ============================== $nowDateTime');
        // print('originDateTime =========================== $originDateTime');

        final differenceSeconds = originDateTime.difference(nowDateTime).inSeconds; // 두날짜의 차이를 초단위로 가져온다  앞이 입찰시간 뒤 가 현재 시간으로 해야되나?
        final differenceDays = originDateTime.difference(nowDateTime).inDays;

        // print('MyPageListJunWorkItem differenceSeconds =============== $differenceSeconds');
        // print('MyPageListJunWorkItem differenceDays =============== $differenceDays');
        timeForTimer = differenceSeconds;
        if(!isDisposed) {
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

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return GestureDetector(
      onTap: (){
        print('jobSts ============================= $jobSts');
        print('jobId===================================${widget.jobId}');
        Navigator.push(context, MaterialPageRoute(builder: (context) => MyPageJunDetail(jobId:widget.jobId)));
      },
      child: Card(
        elevation: widget.index == 0 ? 8 : 4,
        shape: widget.index != 0  ? RoundedRectangleBorder( borderRadius: BorderRadius.circular(4),  side: BorderSide( color: Colors.grey[400], )) : null,
        margin: EdgeInsets.only(bottom: 10, left: 1, right: 1),
        child: Padding(
          padding: EdgeInsets.all(defaultSize * 1.3),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: defaultSize),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.jobTtl ?? '일거리'),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    child: (widget.aucMtd == "1") ? Text(
                        '금액 : '+formatter.format(widget.jobAmt) +'원',
                      style: TextStyle(fontSize: defaultSize * 1.4 ),
                    ) :
                    Text(
                      '희망 금액 : '+formatter.format(widget.jobAmt)+'원',
                      style: TextStyle(fontSize: defaultSize * 1.4 ),
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Container(
                    child: Text(
                      (widget.aucMtd == "1") ? '선착순' : '입찰식',
                      style: TextStyle(color: Colors.lightBlue, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    // decoration: BoxDecoration( color: Colors.lightBlue[50],  borderRadius: BorderRadius.circular(2), ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Container(
                    child: Text(
                      (widget.payMtd == "1") ? '직접결제' : '안전결제',
                      style: TextStyle(color: Colors.pink, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    // decoration: BoxDecoration( color: Colors.pink[50],  borderRadius: BorderRadius.circular(2), ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: jobStsText(jobSts, defaultSize),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        // decoration: BoxDecoration( color: Colors.orange[50],  borderRadius: BorderRadius.circular(2), ),
                      ),
                    ),
                    // Expanded(
                    //   child:
                    //   // (jobIts == "0") ? IconButton(icon: Icon(Icons.favorite_border_outlined), iconSize: defaultSize * 2, onPressed: () => sendAttention(context) ) :
                    //   IconButton(icon: Icon(Icons.favorite), iconSize: defaultSize * 2, onPressed: () => print('관심수?') ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget jobStsText(String jobSts, double defaultSize){
    if(jobSts  == "1"){ return Text('입찰중 ',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),); }
    if(jobSts  == "2"){ return Text('진행중 ',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),); }
    if(jobSts  == "3"){ return Text('완료   ',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),); }
    if(jobSts  == "5"){ return Text('주니 완료 대기중  ',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),); }
    if(jobSts  == "8"){ return Text('시간초과',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),); }
    if(jobSts  == "9"){ return Text('취소   ',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),); }
  }
}