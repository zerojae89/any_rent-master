import 'dart:async';
import 'dart:convert';

import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';
import 'package:intl/intl.dart';

import '../../../mypage_server.dart';
import 'mypage_bidding_bidder_detail_item.dart';


class MypageBidderDetail extends StatefulWidget {

  String jobId, bidDlDtm, jobTtl, jobSts;
  int count, jobAmt;
  MypageBidderDetail(this.jobId, this.count, this.bidDlDtm, this.jobAmt, this.jobTtl, this.jobSts);
  @override
  _MypageBidderDetailState createState() => _MypageBidderDetailState();
}

class _MypageBidderDetailState extends State<MypageBidderDetail> {
  bool isDisposed = false;
  List<dynamic> bidderItems = [];
  final formatter = new NumberFormat("###,###,###,###,###");
  String  formJobAmt = '0';
  Timer _timer;
  Duration _duration = Duration( seconds: 1);
  String timeToDisplay = '';
  String dateFormatString = 'yyyy-MM-dd HH:mm:ss';
  int timeForTimer = 0;
  String jobId, hanId, nicNm;
  int bidAmt;
  final globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    print('widget.jobSts ============================ ${widget.jobSts}');
    formJobAmt =  formatter.format(widget.jobAmt);
    loadToken();
    time();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  loadToken() async {
    try{
      if(widget.jobId != null){
        String result = await myPageServer.getBidderDetail(widget.jobId);
        if(!isDisposed){setState(() => bidderItems = jsonDecode(result)['result'] );}
        print(bidderItems.length);
      }
    } catch(e){
      Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
    }
  }

  time(){
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

      if(widget.jobSts == "1"){
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
      } else {
        if(!isDisposed) {
          setState(() {
            timeToDisplay = "입찰 종료";
            _timer.cancel();
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double defaultSize = SizeConfig.defaultSize;
    return WillPopScope(
      onWillPop: (){
        Navigator.pop(context, _timer.cancel());
        return;
      },
      child: Scaffold(
        key: globalKey,
        appBar: AppBar(
          centerTitle: true,
          title: Text('입찰자 명단'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _timer.cancel()),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(left: defaultSize * 3 , top: defaultSize * 1.6,right: defaultSize * 3),
              child: Column(
                children: [
                  Container(),
                  Container(
                    width: defaultSize * 35,
                    height: defaultSize * 5,
                    // decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: Text( widget.jobTtl, style: TextStyle(color: Colors.black, fontSize: defaultSize * 2 ,fontWeight: FontWeight.bold),), ),
                  Container(child: Text('남은 입찰시간 :  $timeToDisplay', style: TextStyle(color: Colors.pink, fontSize:  defaultSize * 1.5),)),
                ],
              ),
            ),
            Divider(height: 10,),
            Padding(
              padding: EdgeInsets.only(left: defaultSize * 3 , top: defaultSize * 1.6,bottom: defaultSize * 0.8,right: defaultSize * 3),
              child: Row(
                children: [
                  Container(child: Text( '입찰인원  ${widget.count} 명', style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.7 ),), ),
                  SizedBox(width: defaultSize * 8.5,),
                  Container(
                      // decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                      width: defaultSize * 16,
                      child: Text('희망금액 $formJobAmt원', style: TextStyle(color: Colors.black, fontSize:  defaultSize * 1.7),textAlign: TextAlign.right,)),
                ],
              ),
            ),
            Divider(height: 30,),
            Expanded( child:
            (bidderItems.length == 0 ) ?
            Center(child:  bidderWorkList()) :
            ListView.builder(
              itemCount: bidderItems.length,
              itemBuilder: (context, index) {
                jobId = bidderItems[index]['jobId'];
                hanId = bidderItems[index]['hanId'];
                bidAmt = bidderItems[index]['bidAmt'];
                nicNm = bidderItems[index]['nicNm'];
                return MyPageBidderDetailItem(index, jobId, hanId, nicNm, bidAmt, widget.jobAmt, widget.jobSts);
              },
            ))
          ],
        ),
      ),
    );
  }

  Widget bidderWorkList (){
    if(bidderItems.length == 0){
      return Text('현재 입찰자가 없습니다.');
    } else {
      Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
      return CircularProgressIndicator();
    }
  }

}