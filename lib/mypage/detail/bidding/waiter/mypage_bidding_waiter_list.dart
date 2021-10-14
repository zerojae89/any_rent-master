import 'dart:convert';

import 'package:any_rent/mypage/mypage_server.dart';
import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'package:flutter/material.dart';

import 'mypage_bidding_waiter_item.dart';

class MyPageWaiterList extends StatefulWidget {
  @override
  _MyPageWaiterListState createState() => _MyPageWaiterListState();
}

class _MyPageWaiterListState extends State<MyPageWaiterList> {
  // String token, townCd1, townCd2, townNm1, townNm2, auctionTimeString, twnCd;
  // String jobId, jobTtl, aucMtd, jobStDtm, bidDlDtm, payMtd, jobIts, jobSts;
  // int jobAmt, bidAmt;
  bool isDisposed = false;
  // Map <String, dynamic> junWorkResult;
  // List<dynamic> junWorkItems = [];

  @override
  void initState() {
    super.initState();
    // getJunWorkList();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  // getJunWorkList() async { //토큰 불러와서 준일 리스트 불러오기
  //   token =await customSharedPreferences.getString('token');
  //   if(!isDisposed) setState(() => token);
  //   try{
  //     if(token != null){
  //       String result = await myPageServer.getjunWorkList(token);
  //       // print('result ================== $result');
  //       if(!isDisposed){setState(() => junWorkItems = jsonDecode(result)['junWorkList'] );}
  //       // print('junWorkItems ================ $junWorkItems');
  //     }
  //   } catch(e){
  //     Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        AppBar(
          centerTitle: true,
          title: Text('입찰 확인 목록'),
          leading: IconButton( icon: Icon(Icons.arrow_back), onPressed: ()=>  Navigator.pop(context) ),
          // actions: [
          //   IconButton( icon: Icon(Icons.tune),  onPressed: (){ print('필터링'); },
          //   ),
          // ],
        ),

        Expanded( child:
        // (junWorkItems.length == 0 ) ?
        // Center(child:  roadJunWorkList(junWorkItems)) :
        ListView.builder(
          // itemCount: junWorkItems.length,
          itemCount: 5,
          itemBuilder: (context, index) {
            // jobId = junWorkItems[index]['jobId'];
            // jobTtl = junWorkItems[index]['jobTtl'];
            // aucMtd = junWorkItems[index]['aucMtd'];
            // jobStDtm = junWorkItems[index]['jobStDtm'];
            // bidDlDtm = junWorkItems[index]['bidDlDtm'];
            // jobAmt = junWorkItems[index]['jobAmt'];
            // payMtd = junWorkItems[index]['payMtd'];
            // jobIts = junWorkItems[index]['jobIts'];
            // jobSts = junWorkItems[index]['jobSts'];
            // return Center(child: Text('준일 내역이 없습니다. \n1 \n2 \n3 \n4'));
            // return  MyPageListJunWorkItem(token, jobId, jobTtl, aucMtd, jobStDtm, bidDlDtm, jobAmt, index, payMtd, jobIts, jobSts);
            return MyPageWaiterItem(index);
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