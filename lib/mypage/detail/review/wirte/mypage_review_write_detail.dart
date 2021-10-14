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
import '../mypage_review.dart';


enum WhyFarther { report, hiding }

// const url = 'http://211.253.20.112'; //개발서버
// const url = "http://192.168.1.3:4001"; //재승 내부 ip
const url = UrlConfig.url;

class MyPageReviewWriteDetail extends StatefulWidget {
  final String jobId, junHan, myId, opId, myNicNm, opNicNm, revCtn;
  final int totMbrGrd, mbrGrd;
  MyPageReviewWriteDetail({ Key key, @required this.jobId, this.junHan, this.myId, this.myNicNm, this.opId, this.opNicNm, this.revCtn, this.totMbrGrd, this.mbrGrd}) : super(key: key);
  @override
  _MyPageReviewWriteDetailState createState() => _MyPageReviewWriteDetailState();
}

class _MyPageReviewWriteDetailState extends State<MyPageReviewWriteDetail> {
  final globalKey = GlobalKey<ScaffoldState>();
  bool isDisposed = false;
  String token, result, jobId, junId, jobTtl,jobCtn, payMtd, aucMtd, jobStDtm, tp1Nm, tp2Nm, twnNm, junNic, bidDlDtm, jobIts, hanGnd, hanGndName, jobSts, mbrId, junHan, myId, opId, myNicNm, opNicNm, revCtn;
  String message = '';
  int  jobAmt, bidAmt, junPrfSeq, mbrGrd, opGrd;
  int picCnt = 0;
  int totMbrGrd, giveGrd;
  Map <String, dynamic> homeDetailResultList, profile;
  final formatter = new NumberFormat("###,###,###,###,###");
  int grd = 0;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController contentController = TextEditingController();
  double defaultSize = SizeConfig.defaultSize;
  var refreshKey = GlobalKey<RefreshIndicatorState>();

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
    contentController.dispose();
    super.dispose();
  }

  loadToken() async {
    if(opGrd == null){
      if(widget.mbrGrd == 9){
        if(!isDisposed) setState(() { revCtn = "터치하여 평점과 후기내용을 작성해 주세요."; opGrd = widget.mbrGrd;});
      } else {
        if(!isDisposed) setState(() { revCtn = widget.revCtn; });
      }
    }
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
        totMbrGrd = widget.totMbrGrd;
        giveGrd = widget.mbrGrd;
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

  Future<Null> refreshList() async {
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
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: onBackPressed,
      child: Scaffold(
        key: globalKey,
        appBar: AppBar(
          centerTitle: true,
          title: Text('후기 & 평점 작성'),
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
        body: RefreshIndicator(
          key: refreshKey,
          onRefresh: refreshList,
          child: SingleChildScrollView(
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
                        Expanded(flex: 2, child: Text(hanGndName ?? '', style: TextStyle(color: Colors.black, fontSize:  defaultSize * 1.4),)),
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
                  (picCnt == 0) ?  Container() : SizedBox(height: defaultSize * 40, child: buildGridView(jobId, picCnt)),
                  SizedBox( height: defaultSize * 17,  child:  Container( child: Padding( padding: EdgeInsets.all(10),  child: Text(jobCtn ?? '', style:  TextStyle(fontSize:  defaultSize * 1.5),), ), ), ),
                  Divider(height: defaultSize * 4,),
                  Container( height: defaultSize * 16,  width: double.infinity,
                    child: Column(
                      children: [
                        opNicView(defaultSize, widget.opNicNm),
                        opGrdView(defaultSize, widget.opNicNm, widget.myNicNm, giveGrd),
                        InkWell(
                          onLongPress: ()=> (opGrd != 9) ? deleteQuestionsBox(context) : null,
                          onTap: ()=> (opGrd == 9) ? confirmBox(context, setState) : updateQuestionsBox(context),
                          child: Container(
                            height: defaultSize * 10, width:  double.infinity,
                            padding: EdgeInsets.only(top: defaultSize * 4),
                            child: Center(
                              child:  Text( (opGrd != 9) ? revCtn ?? "터치하여 평점과 후기내용을 작성해 주세요." : '터치하여 평점과 후기내용을 작성해 주세요.',
                                style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.2 ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height:  defaultSize * 5, ),
                ],
              ),
          ),
        ),
        // bottomNavigationBar:messageBottomNavigationBar(message, jobSts, size, defaultSize),
      ),
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

  Widget opGrdView(defaultSize, opNicNm, myNicNm, giveGrd){
    return Container(
      margin: EdgeInsets.only(right: defaultSize * 7),
      child: Text( (giveGrd == 9) ? '' : '$myNicNm 님이  $opNicNm에게 준 평점은 $giveGrd 점 입니다.',
        style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.3, fontWeight: FontWeight.bold), ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration( borderRadius: BorderRadius.circular(2), ),
    );
  }

  Widget opNicView(defaultSize, opNicNm){
    return Container(
      margin: EdgeInsets.only(right: defaultSize * 7),
      child: Text( '$opNicNm 님에 대한 후기와 평점을 남겨 주세요',
        style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.5, fontWeight: FontWeight.bold),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        // color: Colors.orange[50],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  sendReview(String kind) async{
    Navigator.pop(context, true);

    final form = formKey.currentState;
    if(form.validate()) { form.save(); }
    print('kind ================== $kind');


    print('grd ================== $grd');
    print('totMbrGrd ================== $totMbrGrd');
    // print('opGrd ================== $opGrd');
    // print('jobId ================== $jobId');
    // print('opId ================== ${widget.opId}');
    // print('junHan ================== ${widget.junHan}');
    try{
      await myPageServer.sendReview(token, widget.opId, widget.jobId, widget.junHan, revCtn, grd.toString(), kind);
      if(!isDisposed) setState(() { opGrd = grd; giveGrd = grd;});
      completeBox(context, kind);
      refreshList();
    } catch(e){
      globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
    }
  }

  void confirmBox(context, setState) {
    setState(() { grd = 0; });
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return Container(
              color: Colors.transparent,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: defaultSize * 38,
                        decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(15), ),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: defaultSize * 1.4),
                              child: Center(child: Text("후기 & 평점", style: TextStyle(fontSize: defaultSize * 2))),
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(icon: Icon(Icons.remove_circle_outline, color: Colors.purple,size: defaultSize * 4,), onPressed:()=> removeGrd(setState)),
                                // Text('$_grd', style: TextStyle(fontSize: defaultSize * 3),),
                                Text(
                                  '$grd',
                                  style: TextStyle(color: Colors.black, fontSize: defaultSize * 3.5),
                                ),
                                IconButton(icon: Icon(Icons.add_circle_outline, color: Colors.purple,size: defaultSize * 4), onPressed:()=> addGrd(setState))
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.all(defaultSize * 1.3),
                              child: Form(
                                key: formKey,
                                child: TextFormField(
                                  decoration: InputDecoration(labelText: '후기', hintText: '후기내용'),
                                  maxLines: 3,
                                  autofocus: true,
                                  validator: (value){ if(value.isEmpty){ return '후기를 작성 해주세요.'; } else{ return null; } }, //null check
                                  onSaved: (value){ revCtn = value; },
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FlatButton(
                                  child: Text("취소", style: TextStyle(color: Colors.purple, fontSize: defaultSize * 1.5),),
                                  onPressed: () => Navigator.pop(context, false),
                                ),
                                FlatButton(
                                  child: Text("작성", style: TextStyle(color: Colors.purple, fontSize: defaultSize * 1.5),),
                                  onPressed: ()=> sendReview("I"),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  //평점 부분 직접결제일 경우 주니 +_ 1 점 하니 +_3 점 가능
  //안전결제일 경우 주니 +_3점 하니 +_1점가능
  void removeGrd(setState){
    print('removeGrd ====================');
    // print('payMtd ======================= ${widget.payMtd}');
    if(grd > -3){ if(!isDisposed) { setState(() { grd--; }); } }
  }

  void addGrd(setState){
    print('addGrd ====================');
    // print('payMtd ==================== ${widget.payMtd}');
    if(grd < 3){ if(!isDisposed) { setState(() { grd++; }); } }
  }

  void completeBox(context, kind) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return Container(
              color: Colors.transparent,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(
                  child: Container(
                    width: defaultSize * 20,
                    height: defaultSize * 20,
                    decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(15), ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(child: Text("후기 ${kind == "I" ? '등록' : kind == "U" ? '수정' : '삭제'} 완료!", style: TextStyle(fontSize: defaultSize * 2))),
                        Padding(padding: EdgeInsets.only(top: defaultSize *3)),
                        FlatButton(color: Colors.purple,child: Text('확인', style: TextStyle(color: Colors.amber),),
                            onPressed: () {
                          if(kind == "D"){
                            revCtn = "터치하여 평점과 후기내용을 작성해 주세요.";
                          }
                          Navigator.pop(context, true);
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  void updateQuestionsBox(context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return Container(
              color: Colors.transparent,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(
                  child: Container(
                    width: defaultSize * 25,
                    height: defaultSize * 25,
                    decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(15), ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(child: Text("후기를 수정 하시겠습니까?", style: TextStyle(fontSize: defaultSize * 1.6))),
                        Padding(padding: EdgeInsets.only(top: defaultSize *5)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FlatButton(color: Colors.purple,child: Text('예', style: TextStyle(color: Colors.amber),),
                                onPressed: (){
                              Navigator.pop(context, true);
                              updateBox(context, setState);
                            }),
                            FlatButton(onPressed: ()=> Navigator.pop(context, true), color: Colors.purple,child: Text('아니오', style: TextStyle(color: Colors.amber),)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  void updateBox(context, setState) {
    setState(() { grd = 0; });
    contentController = TextEditingController(text: (revCtn == null ) ? contentController.text : revCtn );
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return Container(
              color: Colors.transparent,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: defaultSize * 38,
                        decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(15), ),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: defaultSize * 1.4),
                              child: Center(child: Text("후기 & 평점 수정", style: TextStyle(fontSize: defaultSize * 2))),
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(icon: Icon(Icons.remove_circle_outline, color: Colors.purple,size: defaultSize * 4,), onPressed:()=> removeGrd(setState)),
                                // Text('$_grd', style: TextStyle(fontSize: defaultSize * 3),),
                                Text(
                                  '$grd',
                                  style: TextStyle(color: Colors.black, fontSize: defaultSize * 3.5),
                                ),
                                IconButton(icon: Icon(Icons.add_circle_outline, color: Colors.purple,size: defaultSize * 4), onPressed:()=> addGrd(setState))
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.all(defaultSize * 1.3),
                              child: Form(
                                key: formKey,
                                child: TextFormField(
                                  controller: contentController,
                                  decoration: InputDecoration(labelText: '후기', hintText: '후기내용'),
                                  maxLines: 3,
                                  autofocus: true,
                                  validator: (value){ if(value.isEmpty){ return '후기를 작성 해주세요.'; } else{ return null; } }, //null check
                                  onSaved: (value){ revCtn = value; },
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FlatButton(
                                  child: Text("취소", style: TextStyle(color: Colors.purple, fontSize: defaultSize * 1.5),),
                                  onPressed: () => Navigator.pop(context, false),
                                ),
                                FlatButton(
                                  child: Text("작성", style: TextStyle(color: Colors.purple, fontSize: defaultSize * 1.5),),
                                  onPressed: ()=> sendReview("U"),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }


  void deleteQuestionsBox(context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return Container(
              color: Colors.transparent,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(
                  child: Container(
                    width: defaultSize * 25,
                    height: defaultSize * 25,
                    decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(15), ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(child: Text("후기를 삭제 하시겠습니까?", style: TextStyle(fontSize: defaultSize * 1.6))),
                        Padding(padding: EdgeInsets.only(top: defaultSize *5)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FlatButton(color: Colors.purple,child: Text('예', style: TextStyle(color: Colors.amber),),
                                onPressed: () => deleteReview()),
                            FlatButton(onPressed: ()=> Navigator.pop(context, true), color: Colors.purple,child: Text('아니오', style: TextStyle(color: Colors.amber),)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  deleteReview() async{
    Navigator.pop(context, true);
    print('opGrd ======================= $opGrd');
    try{
      await myPageServer.deleteReview(token, widget.jobId);
      completeBox(context,"D");
      setState(()=> opGrd = 9);
      print('opGrd ======================= $opGrd');
    } catch(e){
      globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
    }
  }

  Future<bool> onBackPressed() => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MyPageReview(index: 0,)), (route) => false);
}