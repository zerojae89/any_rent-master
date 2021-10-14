import 'dart:convert';
import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../../mypage_server.dart';
import '../../mypage_detail_appbar.dart';
import 'mypage_review_read_item.dart';

class MyPageReviewRead extends StatefulWidget {
  @override
  _MyPageDetailReviewState createState() => _MyPageDetailReviewState();
}

class _MyPageDetailReviewState extends State<MyPageReviewRead> {

  String token, mbrId, jobId, jobTtl, junHan, myId, opId, myNicNm, opNicNm, revCtn;
  int jobAmt, bidAmt,    totMbrGrd, mbrGrd, currentIndex;
  bool isDisposed = false;
  List<dynamic> reviewReadItems = [];

  @override
  void initState() {
    getReviewReadList();
    super.initState();

  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }


  getReviewReadList() async { //토큰 불러와서 후기 리스트 불러오기
    token =await customSharedPreferences.getString('token');
    if(!isDisposed) setState(() => token);
    try{
      if(token != null){
        String idResult = await myPageServer.getProfile(token);
        Map<String, dynamic> profile = jsonDecode(idResult);
        String reviewResult = await myPageServer.getReviewReadList(token);
        // print('getReviewReadList reviewResult ================== $reviewResult');
        if(!isDisposed){setState((){
          mbrId = profile['mbrId'];
          myNicNm = profile['nicNm'];
          reviewReadItems = jsonDecode(reviewResult);
        } );}
        print('reviewReadItems ================ $reviewReadItems');
      }
    } catch(e){
      Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyPageDetailAppbar( title: '후기확인',),
        Expanded( child:
        (reviewReadItems.length == 0 ) ?
        Center(child:  roadJunWorkList(reviewReadItems)) :
        ListView.builder(
          itemCount: reviewReadItems.length,
          itemBuilder: (context, index) {
            jobTtl = reviewReadItems[reviewReadItems.length - index -1]['JOB_TTL'];
            jobId = reviewReadItems[reviewReadItems.length - index -1]['JOBID'];
            junHan = reviewReadItems[reviewReadItems.length - index -1]['JUN_HAN'];
            myId = reviewReadItems[reviewReadItems.length - index -1]['MY_ID'];
            opId = reviewReadItems[reviewReadItems.length - index -1]['OP_ID'];
            opNicNm = reviewReadItems[reviewReadItems.length - index -1]['NIC_NM'];
            totMbrGrd = reviewReadItems[reviewReadItems.length - index -1]['TOT_MBR_GRD'];
            mbrGrd = reviewReadItems[reviewReadItems.length - index -1]['MBR_GRD'];
            revCtn = reviewReadItems[reviewReadItems.length - index -1]['REV_CTN'];
            return  MyPageReviewReadItem(token, index, mbrId, jobId, jobTtl, junHan, myId, opId, myNicNm, opNicNm, revCtn, totMbrGrd, mbrGrd);
          },
        ))
      ],
    );
  }

  Widget roadJunWorkList (List<dynamic> reviewItems){
    if(reviewItems.length == 0){
      return Text('후기 내역이 없습니다.');
    } else {
      Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
      return CircularProgressIndicator();
    }
  }

}