import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:any_rent/mypage/mypage_server.dart';
import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'mypage_list_han_item.dart';

class MyPageHanWorkList extends StatefulWidget {
  @override
  _MyPageHanWorkListState createState() => _MyPageHanWorkListState();
}

class _MyPageHanWorkListState extends State<MyPageHanWorkList> {

  String token, townCd1, townCd2, townNm1, townNm2, auctionTimeString, twnCd;
  String jobId, jobTtl, aucMtd, jobStDtm, bidDlDtm, payMtd, jobIts, jobSts, junId;
  int jobAmt, bidAmt,prfSeq;
  bool isDisposed = false;
  Map <String, dynamic> hanWorkResult;
  List<dynamic> hanWorkItems = [];

  @override
  void initState() {
    super.initState();
    getHanWorkList();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  getHanWorkList() async { //토큰 불러와서 준일 리스트 불러오기
    token =await customSharedPreferences.getString('token');
    if(!isDisposed) setState(() => token);
    try{
      if(token != null){
        String result = await myPageServer.getHanWorkList(token);
        print('result ================== $result');
        if(!isDisposed){setState(() => hanWorkItems = jsonDecode(result)['result'] );}
        print('hanWorkItems ================ $hanWorkItems');
      }
    } catch(e){
      Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        AppBar(
          centerTitle: true,
          title: Text('한일 목록'),
          leading: IconButton( icon: Icon(Icons.arrow_back), onPressed: ()=>  Navigator.pop(context) ),
          // actions: [
          //   IconButton( icon: Icon(Icons.tune),  onPressed: (){ print('필터링'); },
          //   ),
          // ],
        ),
        Expanded( child:
        (hanWorkItems.length == 0 ) ?
        Center(child:  roadJunWorkList(hanWorkItems)) :
        ListView.builder(
          itemCount: hanWorkItems.length,
          itemBuilder: (context, index) {
            // jobId, jobTtl, aucMtd, jobStDtm, bidDlDtm, jobAmt
            jobId = hanWorkItems[hanWorkItems.length - index -1]['jobId'];
            jobTtl = hanWorkItems[hanWorkItems.length - index -1]['jobTtl'];
            aucMtd = hanWorkItems[hanWorkItems.length - index -1]['aucMtd'];
            jobStDtm = hanWorkItems[hanWorkItems.length - index -1]['jobStDtm'];
            bidDlDtm = hanWorkItems[hanWorkItems.length - index -1]['bidDlDtm'];
            jobAmt = hanWorkItems[hanWorkItems.length - index -1]['jobAmt'];
            payMtd = hanWorkItems[hanWorkItems.length - index -1]['payMtd'];
            jobIts = hanWorkItems[hanWorkItems.length - index -1]['jobIts'];
            jobSts = hanWorkItems[hanWorkItems.length - index -1]['jobSts'];
            prfSeq = hanWorkItems[hanWorkItems.length - index -1]['prfSeq'];
            // return Center(child: Text('준일 내역이 없습니다. \n1 \n2 \n3 \n4'));
            return  MyPageListHanWorkItem(token, jobId, jobTtl, aucMtd, jobStDtm, bidDlDtm, jobAmt, index, payMtd, jobIts, jobSts, prfSeq);
          },
        ))
      ],
    );
  }

  Widget roadJunWorkList (List<dynamic> junWorkItems){
    if(junWorkItems.length == 0){
      return Text('현재 준일 내역이 없습니다.');
    } else {
      Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
      return CircularProgressIndicator();
    }
  }
}