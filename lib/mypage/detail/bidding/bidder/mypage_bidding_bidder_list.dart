import 'dart:convert';

import 'package:any_rent/mypage/mypage_server.dart';
import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'package:flutter/material.dart';

import 'mypage_bidding_bidder_item.dart';

class MyPageBidderList extends StatefulWidget {
  @override
  _MyPageBidderListState createState() => _MyPageBidderListState();
}

class _MyPageBidderListState extends State<MyPageBidderList> {
  List<dynamic> bidderItems = [];
  bool isDisposed = false;
  String token, jobId, jobTtl, bidDlDtm, jobSts;
  int jobAmt, count;

  @override
  void initState() {
    super.initState();
    getBidder();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  getBidder() async { //토큰 불러와서 준일 리스트 불러오기
    token =await customSharedPreferences.getString('token');
    if(!isDisposed) setState(() => token);
    try{
      if(token != null){
        String result = await myPageServer.getBidderList(token);
        // print('result ================== $result');
        if(!isDisposed){setState(() => bidderItems = jsonDecode(result)['result'] );}
        print('bidderItems ================ $bidderItems');
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
          title: Text('입찰 선택 목록'),
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
          itemCount: bidderItems.length,
          itemBuilder: (context, index) {
            jobId = bidderItems[index]['jobId'];
            jobTtl = bidderItems[index]['jobTtl'];
            bidDlDtm = bidderItems[index]['bidDlDtm'];
            jobAmt = bidderItems[index]['jobAmt'];
            count = bidderItems[index]['count'];
            jobSts = bidderItems[index]['jobSts'];
            return MyPageBidderItem(index, jobId, jobTtl, bidDlDtm, jobAmt, count, jobSts);
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