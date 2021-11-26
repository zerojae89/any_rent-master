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
                  Container(
                    padding: EdgeInsets.only(left: defaultSize * 1.6 , top: defaultSize * 1.6),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: defaultSize * 2,),
                              padding: EdgeInsets.only(top: defaultSize * 0.4),
                              // decoration: BoxDecoration(border: Border.all(color:Colors.grey)),
                              width: defaultSize * 36,
                              height: defaultSize * 5,
                              child: Text( jobTtl ?? '',  style: TextStyle(color: Colors.black, fontSize:  defaultSize * 1.8, fontWeight: FontWeight.bold),textAlign: TextAlign.left, ),
                            ),
                          ],
                        ),
                        // Expanded(flex: 3, child: Text('희망 성별:', style: TextStyle(color: Colors.black, fontSize:  defaultSize * 1.5),)),
                        // Expanded(flex: 2, child: Text(hanGndName ?? '', style: TextStyle(color: Colors.black, fontSize:  defaultSize * 1.4),)),
                      ],
                    ),
                  ),
                  Divider(height: 10,),
                  InkWell(
                    onTap: () => homeDetailDialog.showDialogProfile(context, defaultSize, junNic, junPrfSeq, mbrGrd),
                    child: Container(
                      height: defaultSize * 11,
                      child: Container(
                        padding: EdgeInsets.only(left:defaultSize * 4,right: defaultSize * 1.6),
                        child: Row(
                          children: [
                            Container(margin: EdgeInsets.only(right: defaultSize * 2.5),
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
                                        width: defaultSize * 0.3)),
                                width: defaultSize * 9,
                                height: defaultSize * 15
                              // child: (junPrfSeq == null) ? Icon(Icons.account_box_rounded, size: 40,) : Image.network('$url/api/mypage/images?recieveToken=$junPrfSeq')
                            ),
                            Container(
                              width: defaultSize * 12,
                              // decoration: BoxDecoration(
                              //   border: Border.all(
                              //     color: Colors.grey
                              //   )
                              // ),
                              // margin: EdgeInsets.only(right: defaultSize * 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(),
                                  Container(
                                    // decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                                    width: defaultSize * 10.5,
                                    child: Text(
                                      junNic ?? '',
                                      style: TextStyle(color: Colors.lightGreen[700], fontWeight: FontWeight.bold, fontSize:  defaultSize * 1.7),textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: defaultSize * 1.5,),
                                  Container(
                                    width: defaultSize * 10.5,
                                    // decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                                    child: Text(
                                      twnNm ?? '',
                                      style: TextStyle(color: Colors.black, fontSize:  defaultSize * 1.7),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              // decoration: BoxDecoration(
                              //   border: Border.all(
                              //     color: Colors.grey
                              //   )
                              // ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: defaultSize * 1),
                                    child: Text(
                                      "사용자 평점",
                                      style: TextStyle(color: Colors.lightGreen[700], fontWeight: FontWeight.bold, fontSize: defaultSize * 1.7),
                                    ),
                                  ),
                                  SizedBox(height: defaultSize * 1.2,),
                                  Container(
                                    margin: EdgeInsets.only(left: defaultSize * 1),
                                    width: 70,
                                    // decoration: BoxDecoration(
                                    //   border: Border.all(color: Colors.grey)
                                    // ),
                                    child: Text( '$mbrGrd',
                                      style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.7),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider(height: 15,),
                  Container(
                    padding: EdgeInsets.only(top: defaultSize * 1.5),
                    child: Row(
                      children: [
                        // Padding(),
                        Container(
                          margin: EdgeInsets.only(left: defaultSize * 3.5),
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Container(
                              width: defaultSize * 14.7,
                              child: Text(
                                '$tp1Nm / $tp2Nm',
                                style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.7, ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          // margin: EdgeInsets.only(right: defaultSize * 0),
                          // decoration: BoxDecoration(border:Border.all(color:Colors.grey)),
                          width: defaultSize * 17,
                          child: Text( jobStDtm ?? '',  style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.7, ),textAlign: TextAlign.right, ), ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    child: Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: defaultSize * 4.7,top: defaultSize * 0.7),
                          child: Container(
                            width: defaultSize * 15,
                            child: Text(
                              (aucMtd == "1") ? '금액 : '+formatter.format(jobAmt) +'원': '금액 : 0 원',
                              style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.7),
                              textAlign: TextAlign.left,
                            ),
                            decoration: BoxDecoration(
                              // color: Colors.pink[50],
                              borderRadius: BorderRadius.circular(2),
                              // border: Border.all(color:Colors.grey)
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: defaultSize * 0.7),
                          padding: EdgeInsets.only(left: defaultSize * 1),
                          width: defaultSize * 9,
                          // decoration: BoxDecoration(
                          //   border:Border.all(color: Colors.grey)
                          // ),
                          child: Text(
                            '결제방식 :',style: TextStyle(fontSize: defaultSize * 1.7),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: defaultSize * 1.5,top: defaultSize * 0.7),
                          child: Container(
                            child: Text(
                              (payMtd == null) ? '' : (payMtd == '1') ? '직접결제' : (payMtd == '2')? '안전결제' : '',
                              style: TextStyle(color: Colors.black, fontSize:  defaultSize * 1.7 , ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: defaultSize * 2.6,),
                  (picCnt == 0) ?  Container() : SizedBox(height: defaultSize * 40, child: buildGridView(jobId, picCnt)),
                  Container(
                    margin: EdgeInsets.only(left: defaultSize * 1.8,),
                    width: defaultSize * 38,
                    height: defaultSize * 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.lightGreen[400],width: defaultSize * 0.3
                      )
                    ),
                    padding: EdgeInsets.only(left: defaultSize* 3 ),
                    child:  Container( 
                      child: Padding( 
                        padding: EdgeInsets.only(top: defaultSize*2),
                        child: Text(jobCtn ?? '',
                          style:  TextStyle(fontSize:  defaultSize * 1.7),), ), ), ),
                  // Divider(height: defaultSize * 4,),
                  SizedBox(height: defaultSize*2,),
                  Container( height: defaultSize * 16,  width: double.infinity,
                    child: Column(
                      children: [
                        opNicView(defaultSize*1.1, widget.opNicNm),
                        opGrdView(defaultSize, widget.opNicNm, widget.myNicNm, giveGrd) ,
                        InkWell(
                          onLongPress: ()=> (opGrd != 9) ? deleteQuestionsBox(context) : null,
                          onTap: ()=> (opGrd == 9) ? confirmBox(context, setState) : updateQuestionsBox(context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border:Border.all(color: Colors.amber[700],width: defaultSize * 0.3),
                              borderRadius: BorderRadius.circular(15)
                            ),
                            height: defaultSize * 8,
                            width:  defaultSize * 38,
                            child: Center(
                              child:  Text( (opGrd != 5) ? revCtn ?? "터치하여 평점과 후기내용을 작성해 주세요." : '터치하여 평점과 후기내용을 작성해 주세요.',
                                style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.7),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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

  Widget opNicView(defaultSize, opNicNm){
    return Container(
      // margin: EdgeInsets.only(bottom: defaultSiz),
      child: Text( '$opNicNm 님에 대한 후기와 평점을 남겨 주세요',
        style: TextStyle(color: Colors.black, fontSize: defaultSize * 1.5, fontWeight: FontWeight.bold),
      ),
      decoration: BoxDecoration(
        // color: Colors.orange[50],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget opGrdView(defaultSize, opNicNm, myNicNm, giveGrd){
    return Container(
      margin: EdgeInsets.only(right: defaultSize * 0,top: defaultSize*1,bottom: defaultSize * 1),
      child: Text( (giveGrd == 9) ? '' : '$myNicNm 님이  $opNicNm에게 준 평점은 $giveGrd 점 입니다.',
        style: TextStyle(color: Colors.amber[800], fontSize: defaultSize * 2, fontWeight: FontWeight.bold), ),
      decoration: BoxDecoration( borderRadius: BorderRadius.circular(2), ),
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
                                IconButton(icon: Icon(Icons.remove_circle_outline, color: Colors.lightGreen,size: defaultSize * 4,), onPressed:()=> removeGrd(setState)),
                                // Text('$_grd', style: TextStyle(fontSize: defaultSize * 3),),
                                Text(
                                  '$grd',
                                  style: TextStyle(color: Colors.black, fontSize: defaultSize * 3.5),
                                ),
                                IconButton(icon: Icon(Icons.add_circle_outline, color: Colors.lightGreen,size: defaultSize * 4), onPressed:()=> addGrd(setState))
                              ],
                            ),
                            Container(
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
                                  child: Text("취소", style: TextStyle(color: Colors.lightGreen[800], fontSize: defaultSize * 1.5),),
                                  onPressed: () => Navigator.pop(context, false),
                                ),
                                FlatButton(
                                  child: Text("작성", style: TextStyle(color: Colors.lightGreen[800], fontSize: defaultSize * 1.5),),
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
                    height: defaultSize * 13,
                    decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(15), ),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: defaultSize *2.5),
                          padding: EdgeInsets.only(top: defaultSize *0),
                            // decoration:BoxDecoration(border: Border.all(color: Colors.grey)),
                            child: Text("후기 ${kind == "I" ? '등록' : kind == "U" ? '수정' : '삭제'} 완료!", style: TextStyle(fontSize: defaultSize * 2))),
                        Container(
                          margin: EdgeInsets.only(top: defaultSize*2),
                          child: FlatButton(child: Text('확인', style: TextStyle(color: Colors.lightGreen[800],fontWeight: FontWeight.bold),),
                              onPressed: () {
                            if(kind == "D"){
                              revCtn = "터치하여 평점과 후기내용을 작성해 주세요.";
                            }
                            Navigator.pop(context, true);
                          }),
                        ),
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
                    height: defaultSize * 14,
                    decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(15), ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(margin: EdgeInsets.only(top: defaultSize *3),child: Text("후기를 수정 하시겠습니까?", style: TextStyle(fontSize: defaultSize * 1.9))),
                        Padding(padding: EdgeInsets.only(top: defaultSize *2)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FlatButton(child: Text('예', style: TextStyle(color: Colors.lightGreen[800],fontWeight: FontWeight.bold),),
                                onPressed: (){
                              Navigator.pop(context, true);
                              updateBox(context, setState);
                            }),
                            FlatButton(onPressed: ()=> Navigator.pop(context, true),child: Text('아니오', style: TextStyle(color: Colors.lightGreen[800],fontWeight: FontWeight.bold),)),
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
                                IconButton(icon: Icon(Icons.remove_circle_outline, color: Colors.lightGreen,size: defaultSize * 4,), onPressed:()=> removeGrd(setState)),
                                // Text('$_grd', style: TextStyle(fontSize: defaultSize * 3),),
                                Text(
                                  '$grd',
                                  style: TextStyle(color: Colors.black, fontSize: defaultSize * 3.5),
                                ),
                                IconButton(icon: Icon(Icons.add_circle_outline, color: Colors.lightGreen,size: defaultSize * 4), onPressed:()=> addGrd(setState))
                              ],
                            ),
                            Container(
                              // decoration: BoxDecoration(
                              //   border: Border.all(color: Colors.grey)
                              // ),
                              child: Padding(
                                padding: EdgeInsets.only(left :defaultSize*4),
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
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FlatButton(
                                  child: Text("취소", style: TextStyle(color: Colors.lightGreen[800], fontSize: defaultSize * 1.7),),
                                  onPressed: () => Navigator.pop(context, false),
                                ),
                                FlatButton(
                                  child: Text("작성", style: TextStyle(color: Colors.lightGreen[800], fontSize: defaultSize * 1.7),),
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
                    height: defaultSize * 18,
                    decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(15), ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(margin: EdgeInsets.only(top: defaultSize *3),child: Text("후기를 삭제 하시겠습니까?", style: TextStyle(fontSize: defaultSize * 1.9))),
                        Padding(padding: EdgeInsets.only(top: defaultSize *5)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FlatButton(child: Text('예', style: TextStyle(color: Colors.lightGreen[800],fontWeight: FontWeight.bold),),
                                onPressed: () => deleteReview()),
                            FlatButton(onPressed: ()=> Navigator.pop(context, true),child: Text('아니오', style: TextStyle(color: Colors.lightGreen[800],fontWeight: FontWeight.bold),)),
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