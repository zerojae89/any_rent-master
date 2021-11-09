import 'dart:convert';

import 'package:any_rent/home/home_detail_dialog.dart';
import 'package:any_rent/home/home_server.dart';
import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'package:any_rent/settings/url.dart';
import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';
import 'package:intl/intl.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../../../mypage_server.dart';
import 'attention_dottom.dart';

enum WhyFarther { report, hiding }

// const url = 'http://211.253.20.112'; //개발서버
// const url = "http://192.168.1.3:4001"; //재승 내부 ip
const url = UrlConfig.url;

class MyPageAttentionDetail extends StatefulWidget {
  final String jobId;
  MyPageAttentionDetail({ Key key, @required this.jobId}) : super(key: key);
  @override
  _MyPageAttentionDetailState createState() => _MyPageAttentionDetailState();
}

class _MyPageAttentionDetailState extends State<MyPageAttentionDetail> {
  final globalKey = GlobalKey<ScaffoldState>();
  bool isDisposed = false;
  String token, result, jobId, junId, jobTtl,jobCtn, payMtd, aucMtd, jobStDtm, tp1Nm, tp2Nm, twnNm, junNic, bidDlDtm, jobIts, hanGnd, hanGndName, jobSts, mbrId;
  String message = '';
  int  jobAmt, bidAmt, junPrfSeq, mbrGrd;
  int picCnt = 0;
  Map <String, dynamic> homeDetailResultList, profile;
  final formatter = new NumberFormat("###,###,###,###,###");

  @override
  void initState() {
    super.initState();
    imageCache.clear();
    loadToken();
    jobId = widget.jobId;
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  loadToken() async {
    token = await customSharedPreferences.getString('token'); //토큰으로 회원 비회원 판단
    var homeDetail;
    try{
        homeDetail = { "recieveToken": token ,"jobId" : jobId };
        result  = await homeServer.getHomeDetail(homeDetail);
        // debugPrint('result ============= $result');
        homeDetailResultList = jsonDecode(result);
        debugPrint('NULL TOKEN homeDetailResultList ==================== $homeDetailResultList');
        String resultID = await myPageServer.getProfile(token); //관심에서 본인이 준일 구분 하기 위한 mbrId 받기위한 호출
        // debugPrint('MyPageAttentionDetail responeJson == $resultID');
        profile = jsonDecode(resultID);
    } catch(e){
      globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
    }
    if(!isDisposed)  {
      setState(() {
        mbrId = profile['mbrId'];
        picCnt = homeDetailResultList['picCnt'];
        junId = homeDetailResultList['homeDetailSub']['junId']; //주니 아이디
        jobTtl = homeDetailResultList['homeDetailSub']['jobTtl']; // 일제목
        jobCtn = homeDetailResultList['homeDetailSub']['jobCtn']; //일 내용
        payMtd = homeDetailResultList['homeDetailSub']['payMtd']; //결제 방식 1. 직접결제  2. 안전결제
        aucMtd = homeDetailResultList['homeDetailSub']['aucMtd']; //입찰 방식 1. 선착순  2. 입찰식
        jobAmt = homeDetailResultList['homeDetailSub']['jobAmt']; // 선착순 금액
        bidAmt = homeDetailResultList['homeDetailSub']['bidAmt']; // 입찰식 금액
        jobStDtm = homeDetailResultList['homeDetailSub']['jobStDtm']; //소일 시작시간 ,
        tp1Nm = homeDetailResultList['homeDetailSub']['tp1Nm']; // 1차분류
        tp2Nm = homeDetailResultList['homeDetailSub']['tp2Nm']; // 2차분류
        twnNm = homeDetailResultList['homeDetailSub']['twnNm']; // 동네명
        junNic = homeDetailResultList['homeDetailSub']['junNic']; //주니 닉네임
        junPrfSeq = homeDetailResultList['homeDetailSub']['junPrfSeq']; // 주니 프로필 이미지 시퀀스
        mbrGrd = homeDetailResultList['homeDetailSub']['mbrGrd']; //주니 평점 일단 숫자로 해놈
        bidDlDtm = homeDetailResultList['homeDetailSub']['bidDlDtm']; //
        jobIts = homeDetailResultList['homeDetailSub']['jobIts'];
        jobSts = homeDetailResultList['homeDetailSub']['jobSts']; //
        hanGnd = homeDetailResultList['homeDetailSub']['hanGnd'];//하니 희망 성별
        (hanGnd == "0") ? hanGndName = '무관' : (hanGnd == "M") ?  hanGndName = '남성' : hanGndName = '여성';
      });
      if(mbrId == junId){
        setState(()=> message = "SMAE");
      } else {
        setState(()=> message = "User");
      }
      debugPrint('MyPageAttentionDetail jobIts ========= $jobIts');
      // debugPrint('MyPageAttentionDetail hanGnd ========= $hanGnd');
      // debugPrint('MyPageAttentionDetail message ========= $message');
    }
  }


  @override
  Widget build(BuildContext context) {
    print('jobIts ==================== $jobIts');
    print('jobId ==================== $jobId');
    Size size = MediaQuery.of(context).size;
    double defaultSize = SizeConfig.defaultSize;
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('관심 상세내용'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        // actions: [
        //   PopupMenuButton<WhyFarther>(
        //     icon: Icon(Icons.more_vert),
        //     itemBuilder: (BuildContext context) => [
        //       PopupMenuItem<WhyFarther>(
        //         value: WhyFarther.report,
        //         child: Text('신고하기'),
        //       ),
        //       PopupMenuItem<WhyFarther>(
        //         value: WhyFarther.hiding,
        //         child: Text('숨김'),
        //       ),
        //     ],
        //     onSelected: (value){
        //       print(value);
        //       // Navigator.push(context, MaterialPageRoute(builder: (context) => HomeDetail()));
        //     },
        //   )
        // ],
      ),
      body: SingleChildScrollView(

        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: defaultSize * 1.6 , top: defaultSize * 1.6),
                child:
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 24,right: 70),
                      child: Text( jobTtl ?? '',  style: TextStyle(color: Colors.black, fontSize:  defaultSize * 1.8, fontWeight: FontWeight.bold), ),
                    ),
                    Container(child: Text('희망 성별 :', style: TextStyle(color: Colors.black, fontSize:  defaultSize * 1.7,fontWeight:FontWeight.bold),)),
                    Container(margin: EdgeInsets.only(left: 10), child: Text(hanGndName ?? '', style: TextStyle(color: Colors.black, fontSize:  defaultSize * 1.7),)),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          (token == null) ? Container() :
                          (jobIts == widget.jobId) ? IconButton(icon: Icon(Icons.favorite), iconSize: defaultSize * 2, onPressed: () => sendAttentionDelete(context) ) :
                          IconButton(icon: Icon(Icons.favorite_border_outlined), iconSize: defaultSize * 2, onPressed: () => sendAttention(context) ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
              Divider(height: 10,),
              InkWell(
                onTap: () => homeDetailDialog.showDialogProfile(context, defaultSize, junNic, junPrfSeq, mbrGrd),
                child: SizedBox(
                  height: defaultSize * 14,
                  child: Container(
                    padding: EdgeInsets.all(defaultSize * 1.6),
                    child: Row(
                      children: [
                        Container(margin: EdgeInsets.only(right: 50),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: (junPrfSeq == null)
                                        ? AssetImage('assets/noimage.jpg')
                                        : NetworkImage(
                                        '$url/api/mypage/images?recieveToken=$junPrfSeq')), //.
                                border: Border.all(
                                    color: Colors.yellow.withOpacity(0.8),
                                    width: 5)),
                            width: defaultSize * 9,
                            height: defaultSize * 15
                          // child: (junPrfSeq == null) ? Icon(Icons.account_box_rounded, size: 40,) : Image.network('$url/api/mypage/images?recieveToken=$junPrfSeq')
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                junNic ?? '',
                                style: TextStyle(color: Colors.lightGreen[700], fontWeight: FontWeight.bold, fontSize:  defaultSize * 2),
                              ),
                              SizedBox(height: 5,),
                              Text(
                                twnNm ?? '',
                                style: TextStyle(color: Colors.black, fontSize:  defaultSize * 1.7),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "User평점",
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: defaultSize * 1.7),
                              ),
                              SizedBox(height: 5,),
                              Text( '$mbrGrd',
                                style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.4),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(height: 30,),
              Container(
                child: Row(
                  children: [
                    // Padding(),
                    Container(
                      margin: EdgeInsets.only(left: 28),
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Container(
                          child: Text(
                            '$tp1Nm / $tp2Nm',
                            style: TextStyle(color: Colors.lightBlue, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Expanded(flex:1,child: SizedBox()),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container( child: Text( jobStDtm ?? '',  style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold), ), ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              Container(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        child: Text(
                          (aucMtd == "1") ? '금액 : '+formatter.format(jobAmt) +'원': '금액 : 0 원',
                          style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold,),
                          textAlign: TextAlign.center,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          // color: Colors.pink[50],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Text(
                          (payMtd == null) ? '' : (payMtd == '1') ? '직접결제' : (payMtd == '2')? '안전결제' : '',
                          style: TextStyle(color: Colors.pink, fontSize:  defaultSize * 1.7 , fontWeight: FontWeight.bold,),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Text(
                          (aucMtd == null) ? '' : (aucMtd == '1') ? '선착순' : (aucMtd == '2')? '입찰식' : '',
                          style: TextStyle(color: Colors.brown, fontSize:  defaultSize * 1.7, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: defaultSize * 3,),
              (picCnt == 0) ?  Container() : SizedBox(height: defaultSize * 45, child: buildGridView(jobId, picCnt)),
              Container(
                margin: EdgeInsets.all(20.0),
                height: defaultSize * 30,
                child:  Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.lightGreen,width: 1),
                      borderRadius: BorderRadius.circular(20.0)
                  ),
                  width: 350,
                  child: Padding( padding: EdgeInsets.all(20),  child: Text(jobCtn ?? '', style:  TextStyle(fontSize:  defaultSize * 1.5),), ), ), ),
              Divider(height: defaultSize * 4,),
            ],
          ),
      ),
      bottomNavigationBar:messageBottomNavigationBar(message, jobSts, size, defaultSize),
    );
  }

  Widget buildGridView(String jobId, int picCnt) {
    if (picCnt != 0)
      return Container(
        height: 100,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Swiper(
              scale: 0.9,
              viewportFraction: 0.8,
              pagination: SwiperPagination(
                alignment: Alignment.bottomRight,
              ),
              itemCount: picCnt,
              itemBuilder: (BuildContext context, int index){
                return Image.network('$url/api/service/homeImage?jobId=$jobId&picIndex=${index+1}');
              }
          ),
        ),
      );
    else
      return null;
  }

  messageBottomNavigationBar(String message, String jobSts, Size size, double defaultSize) {
    print('MessageBottomNavigationBar message ============================= $message');
    switch(message){
      case "User" :{
        return Container(
          child: attentionBottom.userState(jobSts, size, defaultSize, context, jobTtl, jobCtn, jobStDtm, token, widget.jobId, junId)
        );
      }
      break;
      case "SMAE": {
        return Container(
          child: attentionBottom.sameState(jobSts, size, defaultSize, context, jobTtl, jobCtn, jobStDtm, token, jobId, junId),
        );
      }
      break;
      default :{
        return Container(
          color: Colors.lightGreen,
          child: SizedBox(
            width: double.infinity,
            height: defaultSize * 6,
            child: Center(child: Text( "상태없음",  style: TextStyle( color: Colors.white,  fontSize: defaultSize * 1.3,), )),
          ),
        );
      }
    }
  }

  sendAttention(BuildContext context) async{
    print('관심 등록');
    try{
      String result = await homeServer.sendAttention(token, widget.jobId);
      print("sendAttention====================================================$result");
      setState(() =>jobIts = widget.jobId);
    } catch(e){
      Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
    }
  }

  sendAttentionDelete(BuildContext context) async{
    print('관심 취소');
    try{
      String result = await homeServer.sendAttentionDelete(token, widget.jobId);
      print("sendAttention====================================================$result");
      setState(() =>jobIts = "0");
    } catch(e){
      Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
    }
  }
}