import 'dart:async';

import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';
import 'package:intl/intl.dart';
import 'package:any_rent/mypage/mypage_server.dart';

import 'mypag_bidding_bidder_detail.dart';


class MyPageBidderDetailItem extends StatefulWidget {

  String jobId, hanId, nicNm, jobSts;
  int index, bidAmt, jobAmt;
  MyPageBidderDetailItem( this.index, this.jobId, this.hanId, this.nicNm, this.bidAmt, this.jobAmt, this.jobSts );

  @override
  _MyPageBidderDetailItemState createState() => _MyPageBidderDetailItemState();
}

class _MyPageBidderDetailItemState extends State<MyPageBidderDetailItem> {

  String jobSts, token;
  bool isDisposed = false;
  final formatter = new NumberFormat("###,###,###,###,###");
  String  formBidAmt = '0';
  String  formJobAmt = '0';

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    loadToken();
    formBidAmt =  formatter.format(widget.bidAmt);
    formJobAmt =  formatter.format(widget.jobAmt);
    jobSts = widget.jobSts;
    print('jobSts ==================== $jobSts');
    super.initState();
  }



  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  loadToken() async{
    token = await customSharedPreferences.getString('token');
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Card(
      elevation: widget.index == 0 ? 8 : 4,
      shape: widget.index != 0  ? RoundedRectangleBorder( borderRadius: BorderRadius.circular(4),  side: BorderSide( color: Colors.grey[400], )) : null,
      margin: EdgeInsets.only(bottom: 10, left: 1, right: 1),
      child: Padding(
        padding: EdgeInsets.all(defaultSize * 3),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(flex: 4,  child: Container(
                  child: Text('하니 : ${widget.nicNm}', style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.7 ),),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ) ),
                Expanded(flex: 5,  child: Container(
                  child: Text('입찰 금액 $formBidAmt 원', style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.7 ),),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ) ),
              ],
            ),
            bidderButton(defaultSize, jobSts),
          ],
        ),
      ),
    );
  }

  bidderButton(defaultSize, jobSts){
    return Container( width: double.infinity,
      child: FlatButton( color: Colors.white,
        onPressed: () => reservationAucMtdDialog(jobSts),
        child: jobStsText(jobSts, defaultSize),
      ),
    );
  }

  Widget jobStsText(String jobSts, double defaultSize){
    if(jobSts  == "1"){ return Text('낙찰하기 ',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),); }
    if(jobSts  == "2"){ return Text('진행중 ',style: TextStyle(color: Colors.lightGreen, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),); }
    if(jobSts  == "3"){ return Text('완료   ',style: TextStyle(color: Colors.blue[900], fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),); }
    if(jobSts  == "5"){ return Text('완료 대기중  ',style: TextStyle(color: Colors.lightBlue, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),); }
    if(jobSts  == "8"){ return Text('시간초과',style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),); }
    if(jobSts  == "9"){ return Text('취소   ',style: TextStyle(color: Colors.red, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),); }
  }


  void reservationAucMtdDialog(jobSts){
    if(jobSts  == "1" || jobSts == "4"){
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context){
            return AlertDialog(
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),),
              title: Center(child: Text('입찰하기'),),
              content: Builder(
                builder: (BuildContext context){
                  return Text(
                      '입찰을 진행 하시겠습니까? \n입찰을 하면 변경이 불가능합니다.'
                          '\n\n희망 금액 $formJobAmt'
                          '\n\n입찰 금액 $formBidAmt'
                  );
                },
              ),
              actions: <Widget>[
                FlatButton(onPressed: () {Navigator.pop(context);},
                    child: Text('취소', style: TextStyle(color: Colors.lightGreen[800]),)),
                FlatButton(onPressed: sendReservationAucMtd,
                    child: Text('낙찰', style: TextStyle(color: Colors.lightGreen[800]),),
                ),
                // FlatButton(onPressed: validateAndSave , child: Text('변경', style: TextStyle(color: Colors.purple),)),
              ],
            );
          }
      );
    } else {
      return null;
    }
  }

  void sendReservationAucMtd() async{
    // final form = formKey.currentState;
    // if(form.validate()) {
    //   form.save();
    //   String result = await myPageServer.bidderSuccess(token,
    //       jobId,hanId,bidAmt
    //   );
    //   print('=======33333333===$result');
    // }
  }

//   sendReservationAucMtd () async{
//     Navigator.pop(context);
//
//   }
}