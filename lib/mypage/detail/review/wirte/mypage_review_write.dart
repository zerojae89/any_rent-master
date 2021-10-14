import 'dart:convert';

import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'package:flutter/material.dart';

import '../../../mypage_server.dart';
import '../../mypage_detail_appbar.dart';
import 'mypage_review_wirte_item.dart';

class MyPageReviewWrite extends StatefulWidget {
  @override
  _MyPageDetailReviewState createState() => _MyPageDetailReviewState();
}

class _MyPageDetailReviewState extends State<MyPageReviewWrite> {

  String token, mbrId, jobId, jobTtl, junHan, myId, opId, myNicNm, opNicNm, revCtn;
  int jobAmt, bidAmt,    totMbrGrd, mbrGrd, currentIndex;
  bool isDisposed = false;
  List<dynamic> reviewWriteItems = [];

  @override
  void initState() {
    getJunWorkList();
    super.initState();

  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }


  getJunWorkList() async { //토큰 불러와서 후기 리스트 불러오기
    token =await customSharedPreferences.getString('token');
    if(!isDisposed) setState(() => token);
    try{
      if(token != null){
        String idResult = await myPageServer.getProfile(token);
        Map<String, dynamic> profile = jsonDecode(idResult);
        debugPrint('MyPageDetailReview responeJson == $profile');
        String reviewResult = await myPageServer.getReviewWiretList(token);
        // print('reviewResult ================== $reviewResult');
        if(!isDisposed){setState((){
          mbrId = profile['mbrId'];
          myNicNm = profile['nicNm'];
          reviewWriteItems = jsonDecode(reviewResult);
        } );}

        // print('MyPageDetailReview mbrId =============================== $mbrId');
        // print('reviewWriteItems ================ reviewWriteItems');
      }
    } catch(e){
      Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyPageDetailAppbar( title: '후기작성',),
        Expanded( child:
        (reviewWriteItems.length == 0 ) ?
        Center(child:  roadJunWorkList(reviewWriteItems)) :
        ListView.builder(
          itemCount: reviewWriteItems.length,
          itemBuilder: (context, index) {
            jobTtl = reviewWriteItems[reviewWriteItems.length - index -1]['JOB_TTL'];
            jobId = reviewWriteItems[reviewWriteItems.length - index -1]['JOBID'];
            junHan = reviewWriteItems[reviewWriteItems.length - index -1]['JUN_HAN'];
            myId = reviewWriteItems[reviewWriteItems.length - index -1]['MY_ID'];
            opId = reviewWriteItems[reviewWriteItems.length - index -1]['OP_ID'];
            opNicNm = reviewWriteItems[reviewWriteItems.length - index -1]['NIC_NM'];
            totMbrGrd = reviewWriteItems[reviewWriteItems.length - index -1]['TOT_MBR_GRD'];
            mbrGrd = reviewWriteItems[reviewWriteItems.length - index -1]['MBR_GRD'];
            revCtn = reviewWriteItems[reviewWriteItems.length - index -1]['REV_CTN'];
            return  MyPageReviewWirteItem(token, index, mbrId, jobId, jobTtl, junHan, myId, opId, myNicNm, opNicNm, revCtn, totMbrGrd, mbrGrd);
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