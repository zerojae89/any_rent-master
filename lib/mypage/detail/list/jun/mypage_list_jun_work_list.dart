import 'dart:convert';

import 'package:any_rent/mypage/mypage_server.dart';
import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../../../main_home.dart';
import 'mypage_list_jun_item.dart';

class MyPageJunWorkList extends StatefulWidget {
  @override
  _MyPageJunWorkListState createState() => _MyPageJunWorkListState();
}

class _MyPageJunWorkListState extends State<MyPageJunWorkList> {
  String token, townCd1, townCd2, townNm1, townNm2, auctionTimeString, twnCd;
  String jobId, jobTtl, aucMtd, jobStDtm, bidDlDtm, payMtd, jobIts, jobSts;
  int jobAmt, bidAmt, prfSeq;
  bool isDisposed = false;
  Map <String, dynamic> junWorkResult;
  List<dynamic> junWorkItems = [];

  @override
  void initState() {
    super.initState();
    getJunWorkList();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  getJunWorkList() async { //토큰 불러와서 준일 리스트 불러오기
    token =await customSharedPreferences.getString('token');
    if(!isDisposed) setState(() => token);
    try{
      if(token != null){
        String result = await myPageServer.getjunWorkList(token);
        print('result ================== $result');
        if(!isDisposed){setState(() => junWorkItems = jsonDecode(result)['result'] );}
        print('junWorkItems ================ $junWorkItems');
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
          title: Text('준일 목록'),
          leading: IconButton( icon: Icon(Icons.arrow_back), onPressed: ()=>  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MyHomePage(index: 3,)), (route) => true) ),
          // actions: [
          //   IconButton( icon: Icon(Icons.tune),  onPressed: (){ print('필터링'); },
          //   ),
          // ],
        ),
        Expanded( child:
        (junWorkItems.length == 0 ) ?
        Center(child:  roadJunWorkList(junWorkItems)) :
        ListView.builder(
          itemCount: junWorkItems.length,
          itemBuilder: (context, index) {
            jobId = junWorkItems[index]['jobId'];
            jobTtl = junWorkItems[index]['jobTtl'];
            aucMtd = junWorkItems[index]['aucMtd'];
            jobStDtm = junWorkItems[index]['jobStDtm'];
            bidDlDtm = junWorkItems[index]['bidDlDtm'];
            jobAmt = junWorkItems[index]['jobAmt'];
            payMtd = junWorkItems[index]['payMtd'];
            jobIts = junWorkItems[index]['jobIts'];
            jobSts = junWorkItems[index]['jobSts'];
            prfSeq = junWorkItems[index]['prfSeq'];
            // return Center(child: Text('준일 내역이 없습니다. \n1 \n2 \n3 \n4'));
            return  MyPageListJunWorkItem(token, jobId, jobTtl, aucMtd, jobStDtm, bidDlDtm, jobAmt, index, payMtd, jobIts, jobSts, prfSeq);
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