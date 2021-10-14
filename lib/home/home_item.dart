import 'dart:async';

import 'package:any_rent/home/home_detail.dart';
import 'package:any_rent/home/home_server.dart';
import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';
import 'package:intl/intl.dart';

class HomeItem extends StatefulWidget {
  
  String token, jobId, jobTtl, aucMtd, jobStDtm, bidDlDtm, payMtd, jobIts, twnNm;
  int index, jobAmt;
  HomeItem(this.token, this.jobId, this.jobTtl, this.aucMtd, this.jobStDtm, this.bidDlDtm, this.jobAmt, this.index, this.payMtd, this.jobIts, this.twnNm);
  @override
  _HomeItemState createState() => _HomeItemState();
}

class _HomeItemState  extends State<HomeItem> with RouteAware, WidgetsBindingObserver{
  final formatter = new NumberFormat("###,###,###,###,###");
  String jobIts;
  String timeToDisplay = '';
  String dateFormatString = 'yyyy-MM-dd HH:mm:ss';
  int timeForTimer = 0;
  bool isDisposed = false;
  Timer _timer;
  Duration _duration = Duration( seconds: 1);

  @override
  void initState() {
    jobIts = widget.jobIts;
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

        // print('Home differenceSeconds =============== $differenceSeconds');
        // print('Home differenceDays =============== $differenceDays');
        timeForTimer = differenceSeconds;
        if(!isDisposed) {
          setState(() {
            if (timeForTimer < 1) {
              timeToDisplay = "입찰 시간 종료";
              print('timeToDisplay ======================= $timeToDisplay');
              _timer.cancel();
            }  else if(differenceDays > 0){
              timeForTimer = timeForTimer - (differenceDays * 86400);
              int h = timeForTimer ~/ 3600;
              int t = timeForTimer - (3600 * h);
              int m = t ~/ 60;
              int s = t - (60 * m);
              // if()
              timeToDisplay =
                  "$differenceDays일 "+  h.toString() + ":" + m.toString() + ":" + s.toString();
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
              timeToDisplay = h.toString() + ":" + m.toString() + ":" + s.toString();
              timeForTimer = timeForTimer - 1;
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
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomeDetail(jobId:widget.jobId)));
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
                    Text(
                      // '남은 입찰시간 : DD일 HH시 mm분 ',
                      (widget.aucMtd == "1") ? '' : '남은 입찰시간 : '+timeToDisplay, //남은시간 카운트 해야됨
                      style: TextStyle(color: Colors.deepOrange, fontSize: defaultSize * 1.2),
                    )
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    child: (widget.aucMtd == "1") ? Text(
                      '금액 : '+formatter.format(widget.jobAmt) +'원'
                      // style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                    ) :
                    Text(
                      '희망 금액 : '+formatter.format(widget.jobAmt)+'원',
                      // style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox( width: defaultSize ),
                  Container(
                    child: Text(
                      widget.twnNm,
                      style: TextStyle(color: Colors.black, fontSize: defaultSize *1.2, fontWeight: FontWeight.bold),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    // decoration: BoxDecoration( color: Colors.lightBlue[50],  borderRadius: BorderRadius.circular(2), ),
                  ),
                  SizedBox( width: defaultSize ),
                  Container(
                    child: Text(
                      (widget.aucMtd == "1") ? '선착순' : '입찰식',
                      style: TextStyle(color: Colors.lightBlue, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    // decoration: BoxDecoration( color: Colors.lightBlue[50],  borderRadius: BorderRadius.circular(2), ),
                  ),
                  SizedBox( width: defaultSize ),
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
                        child: Text(
                          "시작 시간 : ${widget.jobStDtm}",
                          style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        // decoration: BoxDecoration( color: Colors.orange[50],  borderRadius: BorderRadius.circular(2), ),
                      ),
                    ),
                    Expanded(
                      child:
                      (widget.token == null) ? Container() :
                          (jobIts == widget.jobId) ? IconButton(icon: Icon(Icons.favorite), iconSize: defaultSize * 2, onPressed: () => sendAttentionDelete(context) ) :
                        IconButton(icon: Icon(Icons.favorite_border_outlined), iconSize: defaultSize * 2, onPressed: () => sendAttention(context) ),
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

  sendAttention(BuildContext context) async{
    print('관심 등록');
    try{
      String result = await homeServer.sendAttention(widget.token, widget.jobId);
      print("sendAttention====================================================$result");
      setState(() =>jobIts = widget.jobId);
    } catch(e){
      Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
    }
  }

  sendAttentionDelete(BuildContext context) async{
    print('관심 취소');
    try{
      String result = await homeServer.sendAttentionDelete(widget.token, widget.jobId);
      print("sendAttention====================================================$result");
      setState(() =>jobIts = "0");
    } catch(e){
      Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
    }
  }
}