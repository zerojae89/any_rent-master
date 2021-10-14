import 'dart:async';

import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';
import 'package:intl/intl.dart';


class MyPageWaiterItem extends StatefulWidget {

  // String token, jobId, jobTtl, aucMtd, jobStDtm, bidDlDtm, payMtd, jobIts, jobSts;
  // int index, jobAmt;
  // MyPageBidderItem(this.token, this.jobId, this.jobTtl, this.aucMtd, this.jobStDtm, this.bidDlDtm, this.jobAmt, this.index, this.payMtd, this.jobIts, this.jobSts);
  int index;
  MyPageWaiterItem( this.index );

  @override
  _MyPageWaiterItemState createState() => _MyPageWaiterItemState();
}

class _MyPageWaiterItemState extends State<MyPageWaiterItem> {
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
    // jobIts = widget.jobIts;
    // jobSts = widget.jobSts;
    // time();
    super.initState();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  // time(){
  //   if(widget.aucMtd == '2'){
  //     _timer = Timer.periodic(_duration, (timer) {
  //       DateFormat dateFormat = DateFormat(dateFormatString); //날짜 방식 정하기
  //       DateTime nowDateTime = dateFormat.parse(DateFormat(dateFormatString).format(DateTime.now())); // 날짜 방식에 맞춰 현재 날짜 가져오기 String
  //       DateTime originDateTime = new DateFormat(dateFormatString).parse(widget.bidDlDtm); // 남은 입찰 날짜 넣어야됨
  //
  //       // print('bidDlDtm ============================== ${widget.bidDlDtm}');
  //       // print('nowDateTime ============================== $nowDateTime');
  //       // print('originDateTime =========================== $originDateTime');
  //
  //       final differenceSeconds = originDateTime.difference(nowDateTime).inSeconds; // 두날짜의 차이를 초단위로 가져온다  앞이 입찰시간 뒤 가 현재 시간으로 해야되나?
  //       final differenceDays = originDateTime.difference(nowDateTime).inDays;
  //
  //       // print('MyPageListJunWorkItem differenceSeconds =============== $differenceSeconds');
  //       // print('MyPageListJunWorkItem differenceDays =============== $differenceDays');
  //       timeForTimer = differenceSeconds;
  //       if(!isDisposed) {
  //         setState(() {
  //           if (timeForTimer < 1) {
  //             timeToDisplay = "입찰 시간 종료";
  //             print('timeToDisplay ======================= $timeToDisplay');
  //             jobSts = "8";
  //             _timer.cancel();
  //           }
  //         });
  //       }
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return GestureDetector(
      onTap: (){
        print('입찰 대기 상세 이동');
        // Navigator.push(context, MaterialPageRoute(builder: (context) => MyPageJunDetail(jobId:widget.jobId)));
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
                    child: Text( '일제목', style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.5 ),),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  SizedBox(
                    width: 24,
                  ),
                  Container(
                    child: Text( '남은 입찰 시간  DD일 HH:MM:SS', style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.5 ), ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        child: Text( '입찰 인원 0명', style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.5 ),),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        // decoration: BoxDecoration( color: Colors.orange[50],  borderRadius: BorderRadius.circular(2), ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Text( '일상태', style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.5 ),),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        // decoration: BoxDecoration( color: Colors.orange[50],  borderRadius: BorderRadius.circular(2), ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Text( '낙찰 유무', style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.5 ),),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        // decoration: BoxDecoration( color: Colors.orange[50],  borderRadius: BorderRadius.circular(2), ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Text( '희망금액 1000000원', style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.5 ),),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        // decoration: BoxDecoration( color: Colors.orange[50],  borderRadius: BorderRadius.circular(2), ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Text( '제시금액 1000000원', style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.5 ),),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        // decoration: BoxDecoration( color: Colors.orange[50],  borderRadius: BorderRadius.circular(2), ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}