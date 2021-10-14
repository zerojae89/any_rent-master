import 'dart:convert';

import 'package:any_rent/chat/chat_page.dart';
import 'package:any_rent/home/home_detail_dialog.dart';
import 'package:any_rent/home/home_server.dart';
import 'package:any_rent/login/login.dart';
import 'package:any_rent/mypage/mypage_server.dart';
import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'package:any_rent/settings/url.dart';
import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';
import 'package:intl/intl.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import '../mypage_list.dart';

// const url = 'http://211.253.20.112'; //개발서버
// const url = "http://192.168.1.3:4001"; //재승 내부 ip
const url = UrlConfig.url;

class MyPageHanDetail extends StatefulWidget {
  final String jobId, junId;
  MyPageHanDetail({ Key key, @required this.jobId, this.junId}) : super(key: key);

  @override
  _MyPageHanDetailState createState() => _MyPageHanDetailState();
}

class _MyPageHanDetailState extends State<MyPageHanDetail> {

  final globalKey = GlobalKey<ScaffoldState>();
  bool isDisposed = false;
  String token, result, jobId, junId, jobTtl,jobCtn, payMtd, aucMtd, jobStDtm, tp1Nm, tp2Nm, twnNm, junNic, bidDlDtm, jobIts, hanGnd, hanGndName, jobSts, mbrId;
  String message = '';
  int  jobAmt, bidAmt, junPrfSeq, mbrGrd;
  int picCnt = 0;
  Map <String, dynamic> hanDetailResultList;
  final formatter = new NumberFormat("###,###,###,###,###");



  @override
  void initState() {
    super.initState();
    loadToken();
    imageCache.clear();
    jobId = widget.jobId;
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }


  loadToken() async {
    token = await customSharedPreferences.getString('token'); //토큰으로 회원 비회원 판단
    debugPrint('HomeDetail token ================= $token');
    var homeDetail;
    try{ //한일은 비로그인 또는 비회원 처럼 디테일 가져온다
      homeDetail = { "jobId" : jobId };
      // homeDetail = { "recieveToken": token ,"jobId" : widget.junId };
      result  = await homeServer.getHomeDetail(homeDetail);
      // debugPrint('result ============= $result');
      hanDetailResultList = jsonDecode(result);
      debugPrint('hanDetailResultList ==================== $hanDetailResultList');
    } catch(e){
      globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
    }
    if(!isDisposed)  {

      setState(() {
        message = hanDetailResultList['message'];
        picCnt = hanDetailResultList['picCnt'];
        junId = hanDetailResultList['homeDetailSub']['junId']; //주니 아이디
        jobTtl = hanDetailResultList['homeDetailSub']['jobTtl']; // 일제목
        jobCtn = hanDetailResultList['homeDetailSub']['jobCtn']; //일 내용
        payMtd = hanDetailResultList['homeDetailSub']['payMtd']; //결제 방식 1. 직접결제  2. 안전결제
        aucMtd = hanDetailResultList['homeDetailSub']['aucMtd']; //입찰 방식 1. 선착순  2. 입찰식
        jobAmt = hanDetailResultList['homeDetailSub']['jobAmt']; // 선착순 금액
        bidAmt = hanDetailResultList['homeDetailSub']['bidAmt']; // 입찰식 금액
        jobStDtm = hanDetailResultList['homeDetailSub']['jobStDtm']; //소일 시작시간 ,
        tp1Nm = hanDetailResultList['homeDetailSub']['tp1Nm']; // 1차분류
        tp2Nm = hanDetailResultList['homeDetailSub']['tp2Nm']; // 2차분류
        twnNm = hanDetailResultList['homeDetailSub']['twnNm']; // 동네명
        junNic = hanDetailResultList['homeDetailSub']['junNic']; //주니 닉네임
        junPrfSeq = hanDetailResultList['homeDetailSub']['junPrfSeq']; // 주니 프로필 이미지 시퀀스
        mbrGrd = hanDetailResultList['homeDetailSub']['mbrGrd']; //주니 평점 일단 숫자로 해놈
        bidDlDtm = hanDetailResultList['homeDetailSub']['bidDlDtm']; // 입찰 마감일시
        jobIts = hanDetailResultList['homeDetailSub']['jobIts']; // 소일 관심 상태
        jobSts = hanDetailResultList['homeDetailSub']['jobSts']; // 소일 상태
        hanGnd = hanDetailResultList['homeDetailSub']['hanGnd'];//하니 희망 성별
        (hanGnd == "0") ? hanGndName = '무관' : (hanGnd == "M") ?  hanGndName = '남성' : hanGndName = '여성';
      });

      debugPrint('jobSts ========= $jobSts');
      // debugPrint('hanGnd ========= $hanGnd');
      // debugPrint('message ========= $message');
      // debugPrint('picCnt ========= $picCnt');
      // debugPrint('junId ========= $junId');
      // debugPrint('jobTtl ========= $jobTtl');
      // debugPrint('jobCtn ========= $jobCtn');
      // debugPrint('payMtd ========= $payMtd');
      // debugPrint('aucMtd ========= $aucMtd');
      // debugPrint('jobAmt ========= $jobAmt');
      // debugPrint('bidAmt ========= $bidAmt');
      // debugPrint('tp1Nm ========= $tp1Nm');
      // debugPrint('tp2Nm ========= $tp2Nm');
      // debugPrint('twnNm ========= $twnNm');
      // debugPrint('junNic ========= $junNic');
      // debugPrint('junPrfSeq ========= $junPrfSeq');
      // debugPrint('mbrGrd ========= $mbrGrd');
      // debugPrint('bidDlDtm ========= $bidDlDtm');
      // debugPrint('HomeDetail jobIts ========= $jobIts');
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double defaultSize = SizeConfig.defaultSize;
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('한일 상세내용'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: defaultSize * 1.6 , top: defaultSize * 1.6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 7,
                      child: Text( jobTtl ?? '',  style: TextStyle(color: Colors.black, fontSize:  defaultSize * 1.8, fontWeight: FontWeight.bold), ),
                    ),
                    Expanded(flex: 3, child: Text('희망 성별 :', style: TextStyle(color: Colors.black, fontSize:  defaultSize * 1.5),)),
                    Expanded(flex: 1, child: Text(hanGndName ?? '', style: TextStyle(color: Colors.black, fontSize:  defaultSize * 1.4),)),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          // panorama shop raid  lens  label  favorite
                          (jobIts == widget.jobId) ? IconButton(icon: Icon(Icons.favorite), iconSize: defaultSize * 2, onPressed: () => sendAttentionDelete(context) ) :
                          IconButton(icon: Icon(Icons.favorite_border_outlined), iconSize: defaultSize * 2, onPressed: () => sendAttention(context) ),

                          // (bidDlDtm == "null") ? null : Text(
                          //   "job id 대신 입찰 식일시 남은 시간 넣자",
                          //   style: TextStyle(color: Colors.black, fontSize:  defaultSize * 1.4,),
                          // ),
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
                        Expanded(
                          flex: 3,
                          child: (junPrfSeq == null) ? Icon(Icons.account_box_rounded, size: 40,) : Image.network('$url/api/mypage/images?recieveToken=$junPrfSeq')
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                junNic ?? '',
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize:  defaultSize * 1.4),
                              ),
                              Text(
                                twnNm ?? '',
                                style: TextStyle(color: Colors.black, fontSize:  defaultSize * 1.2),
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
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: defaultSize * 1.2),
                              ),
                              Text( '$mbrGrd',
                                style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.1),
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
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Container(
                          child: Text(
                            '$tp1Nm / $tp2Nm',
                            style: TextStyle(color: Colors.lightBlue, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Expanded(flex:1,child: SizedBox()),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container( child: Text( jobStDtm ?? '',  style: TextStyle(color: Colors.orange, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold), ), ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Text(
                          (aucMtd == "1") ? '금액 : '+formatter.format(jobAmt) +'원': '금액 : 0 원',
                          style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold,),
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
                          style: TextStyle(color: Colors.pink, fontSize:  defaultSize * 1.2 , fontWeight: FontWeight.bold,),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Text(
                          (aucMtd == null) ? '' : (aucMtd == '1') ? '선착순' : (aucMtd == '2')? '입찰식' : '',
                          style: TextStyle(color: Colors.brown, fontSize:  defaultSize * 1.2, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: defaultSize * 3,),
              (picCnt == 0) ?  Container() : SizedBox(height: defaultSize * 45, child: buildGridView(jobId, picCnt)),
              SizedBox( height: defaultSize * 17,  child:  Container( child: Padding( padding: EdgeInsets.all(10),  child: Text(jobCtn ?? '', style:  TextStyle(fontSize:  defaultSize * 1.5),), ), ), ),
              Divider(height: defaultSize * 4,),
            ],
          ),
      ),
      bottomNavigationBar:messageBottomNavigationBar(jobSts, size, defaultSize),
    );
  }

  Widget buildGridView(String jobId, int picCnt) {
    if (picCnt != 0)
      return Container(
        height: 150,
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

  messageBottomNavigationBar(String jobSts, Size size, double defaultSize) {
    print('MessageBottomNavigationBar jobSts ============================= $jobSts');
    if(jobSts =="1"){
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size.width / 2,
              height: defaultSize * 6,
              child: FlatButton(
                color: Colors.purple,
                onPressed: () => homeDetailDialog.onUpdatePressed(context, jobId),
                child: Text( "수정하기",  style: TextStyle( color: Colors.amber,  fontSize: defaultSize * 1.3,), ),
              ),
            ),
            Expanded(
              child: FlatButton(
                onPressed: () => onDeletePressed(context, jobId, token),
                child: Text("삭제하기"),
              ),
            ),
          ],
        ),
      );
    }else if (jobSts == "2"){
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size.width / 2,
              height: defaultSize * 6,
              child: FlatButton(
                color: Colors.purple,
                onPressed: () => onComplComplete(context, jobId, token),
                child: Text( "소일 완료하기",  style: TextStyle( color: Colors.amber,  fontSize: defaultSize * 1.3,), ),
              ),
            ),
            Expanded(
              child: FlatButton(
                onPressed: () => sendMessage(),
                child: Text("메세지 보내기"),
              ),
            ),
          ],
        ),
      );
    } else if (jobSts == "3"){
      return Container(
        child: SizedBox(
          width: double.infinity,
          height: defaultSize * 6,
          child: FlatButton(
            color: Colors.purple,
            onPressed: () => null,
            child: Text( "작업 완료",  style: TextStyle( color: Colors.amber,  fontSize: defaultSize * 1.3,), ),
          ),
        ),
      );
    } else if (jobSts == "5"){
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size.width / 2,
              height: defaultSize * 6,
              child: FlatButton(
                color: Colors.purple,
                onPressed: () => null,
                child: Text( "주니 완료 대기중",  style: TextStyle( color: Colors.amber,  fontSize: defaultSize * 1.3,), ),
              ),
            ),
            Expanded(
              child: FlatButton(
                onPressed: () => sendMessage(),
                child: Text("메세지 보내기"),
              ),
            ),
          ],
        ),
      );
    } else if (jobSts == "9"){
      return Container(
        child: SizedBox(
          width: double.infinity,
          height: defaultSize * 6,
          child: FlatButton(
            color: Colors.purple,
            onPressed: () => null,
            child: Text( "취소",  style: TextStyle( color: Colors.amber,  fontSize: defaultSize * 1.3,), ),
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.purple,
        child: SizedBox(
          width: double.infinity,
          height: defaultSize * 6,
          child: Center(child: Text( "상태없음",  style: TextStyle( color: Colors.amber,  fontSize: defaultSize * 1.3,), )),
        ),
      );
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

  onDeletePressed(context, jobId, token){ //삭제하기
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text("게시물을 삭제 하시겠습니까?"),
          actions: <Widget>[
            FlatButton(
              child: Text("아니오"),
              onPressed: () => Navigator.pop(context, false),
            ),
            FlatButton(
              child: Text("예"),
              onPressed: (){
                try{
                  homeServer.deleteService(token, jobId);
                } catch(e){
                  globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
                }
                return Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MyPageDetailList()), (route) => true);
              },
            )
          ],
        )
    );
  }

  onComplComplete(context, jobId, token){ //소일 완료 하기
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text("소일을 완료 하시겠습니까?"),
          actions: <Widget>[
            FlatButton(
              child: Text("아니오"),
              onPressed: () => Navigator.pop(context, false),
            ),
            FlatButton(
              child: Text("예"),
              onPressed: (){
                try{
                  myPageServer.sendServiceComplete(token, jobId);
                } catch(e){
                  globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
                }
                return Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MyPageDetailList(index: 1,)), (route) => false);
              },
            )
          ],
        )
    );
  }

  sendMessage() async{
    try{
      String idResult = await myPageServer.getProfile(token);
      Map<String, dynamic> profile = jsonDecode(idResult);
      debugPrint('Chat1 responeJson == $profile');
      if(!isDisposed) { setState(() => mbrId = profile['mbrId']); }
      print('sendMessage mbrId =============================== $mbrId');
    } catch(e){
      globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(mbrId: mbrId, jobId: jobId, junId: junId, hanId: mbrId,)));
  }

}

