import 'dart:convert';

import 'package:any_rent/mypage/mypage_server.dart';
import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../../../main_home.dart';
import 'mypage_list_tag_itme.dart';

class MyPageTagWorkList extends StatefulWidget {
  @override
  _MyPageTagWorkListState createState() => _MyPageTagWorkListState();
}

class _MyPageTagWorkListState extends State<MyPageTagWorkList> {
  String token, townCd1, townCd2, townNm1, townNm2, auctionTimeString, twnCd;
  String jobId, jobTtl, aucMtd, jobStDtm, bidDlDtm, payMtd, jobIts, jobSts, twnNm;
  int jobAmt, bidAmt, prfSeq;
  bool isDisposed = false;
  Map <String, dynamic> TagResult;
  List<dynamic> TagItems = [];


  @override
  void initState() {
    super.initState();
    TagList();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  TagList() async {
    token =await customSharedPreferences.getString('token');
    if(!isDisposed) setState(() => token);
    try{
      if(token != null){
        String result = await myPageServer.getAttentionList(token);
        print('TagList result ================== $result');
        if(!isDisposed){setState(() => TagItems = jsonDecode(result)['result'] );}
        print('TagItems ================ $TagItems');
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
          title: Text('키워드 목록'),
          leading: IconButton( icon: Icon(Icons.arrow_back), onPressed: ()=>  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MyHomePage(index: 3,)), (route) => true) ),
          // actions: [
          //   IconButton( icon: Icon(Icons.tune),  onPressed: (){ print('필터링'); },
          //   ),
          // ],
        ),
        Expanded( child:
          (TagItems.length == 0 ) ?
        Center(child:  roadTagList(TagItems)) :
        ListView.builder(
          itemCount: TagItems.length,
          itemBuilder: (context, index) {
            // jobId, jobTtl, aucMtd, jobStDtm, bidDlDtm, jobAmt
            jobId = TagItems[TagItems.length - index -1]['jobId'];
            jobTtl = TagItems[TagItems.length - index -1]['jobTtl'];
            aucMtd = TagItems[TagItems.length - index -1]['aucMtd'];
            jobStDtm = TagItems[TagItems.length - index -1]['jobStDtm'];
            bidDlDtm = TagItems[TagItems.length - index -1]['bidDlDtm'];
            jobAmt = TagItems[TagItems.length - index -1]['jobAmt'];
            payMtd = TagItems[TagItems.length - index -1]['payMtd'];
            jobIts = TagItems[TagItems.length - index -1]['jobIts'];
            jobSts = TagItems[TagItems.length - index -1]['jobSts'];
            prfSeq = TagItems[TagItems.length - index -1]['prfSeq'];
            // return Center(child: Text('준일 내역이 없습니다. \n1 \n2 \n3 \n4'));
            return  MyPageTagItme(token, jobId, jobTtl, aucMtd, jobStDtm, bidDlDtm, jobAmt, index, payMtd, jobIts, jobSts,prfSeq);
          },
        ))
      ],
    );
  }

  Widget roadTagList (List<dynamic> junWorkItems){
    if(junWorkItems.length == 0){
      return Text('현재 관심 내역이 없습니다.');
    } else {
      Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
      return CircularProgressIndicator();
    }
  }
}