import 'dart:async';
import 'dart:convert';

import 'package:any_rent/chat/chat_page.dart';
import 'package:any_rent/home/home_server.dart';
import 'package:any_rent/login/login.dart';
import 'package:any_rent/mypage/mypage_server.dart';
import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'package:any_rent/settings/url.dart';
import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';
import 'package:intl/intl.dart';
import 'home_detail_dialog.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

enum WhyFarther { report, hiding }

// const url = 'http://211.253.20.112'; //개발서버
// const url = "http://192.168.1.3:4001"; //재승 내부 ip
const url = UrlConfig.url;

class HomeDetail extends StatefulWidget {
  final String jobId;
  HomeDetail({ Key key, @required this.jobId}) : super(key: key);

  @override
  _HomeDetailState createState() => _HomeDetailState();
}

class _HomeDetailState extends State<HomeDetail> {

  final globalKey = GlobalKey<ScaffoldState>();
  bool isDisposed = false;
  String token, result, jobId, junId, jobTtl,jobCtn, payMtd, jobStDtm, tp1Nm, tp2Nm, twnNm, junNic, bidDlDtm, jobIts, hanGnd, hanGndName, jobSts, mbrId, hanResult;
  String message = '';
  String aucMtd = '1';
  int  jobAmt, bidAmt, junPrfSeq, mbrGrd;
  int picCnt = 0;
  Map <String, dynamic> homeDetailResultList;
  final formatter = new NumberFormat("###,###,###,###,###");
  String  formJobAmt = '0';
  Timer _timer;
  Duration _duration = Duration( seconds: 1);
  String timeToDisplay = '';
  String dateFormatString = 'yyyy-MM-dd HH:mm:ss';
  int timeForTimer = 0;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  static const _locale = 'ko';
  String _formatNumber(String s) => NumberFormat.decimalPattern(_locale).format(int.parse(s));
  String get _currency => NumberFormat.compactSimpleCurrency(locale: _locale).currencySymbol;

  @override
  void initState() {
    super.initState();
    loadToken();
    imageCache.clear();
    jobId = widget.jobId;
    _controller.addListener(() {
      // using Ashok's answer to format the text
      final reg_ex = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      final matchFunc = (Match match) => '${match[1]},';
      final text = _controller.text;

      _controller.value = _controller.value.copyWith(
        // we need to remove all the ',' from the values before reformatting
        // if you use other formatting values, remember to remove them here
        text: text.replaceAll(',', '').replaceAllMapped(reg_ex, matchFunc),
        // this will keep the cursor on the right as you type in values
        selection: TextSelection(
          baseOffset: text.length,
          extentOffset: text.length,
        ),
      );
    });
  }

  @override
  void dispose() {
    isDisposed = true;
    _controller.dispose();
    super.dispose();
  }


  loadToken() async {
    token = await customSharedPreferences.getString('token'); //토큰으로 회원 비회원 판단
    debugPrint('HomeDetail token ================= $token');
    debugPrint('HomeDetail jobId ================= $jobId');
    var homeDetail;
    try{
      if(token == null ){ //비회원 또는 비로그인 상세 보기
        homeDetail = { "jobId" : jobId };
        result  = await homeServer.getHomeDetail(homeDetail);
        debugPrint('result ============= $result');
        homeDetailResultList = jsonDecode(result);
        // debugPrint('NULL TOKEN homeDetailResultList ==================== $homeDetailResultList');
      }else {
        homeDetail = { "recieveToken": token ,"jobId" : jobId };
        result  = await homeServer.getHomeDetail(homeDetail);
        debugPrint('result ============= $result');
        // debugPrint('homeDetailResultList result ============= $result');
        homeDetailResultList = jsonDecode(result);
        // debugPrint('homeDetailResultList ==================== $homeDetailResultList');
      }
    } catch(e){
      globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
    }
    if(!isDisposed)  {
      setState(() {
        message = homeDetailResultList['message'];
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
        bidDlDtm = homeDetailResultList['homeDetailSub']['bidDlDtm']; // 입찰 금액
        jobIts = homeDetailResultList['homeDetailSub']['jobIts']; // 일 관심 여부
        jobSts = homeDetailResultList['homeDetailSub']['jobSts']; // 일 상태
        hanGnd = homeDetailResultList['homeDetailSub']['hanGnd']; // 하니 희망 성별
        (hanGnd == "0") ? hanGndName = '무관' : (hanGnd == "M") ?  hanGndName = '남성' : hanGndName = '여성';
        formJobAmt = formatter.format(jobAmt);
        hanResult = homeDetailResultList['homeDetailSub']['result']; // 하니 입찰식 예약 여부
      });

      // debugPrint('HomeDetail jobId ========= ${widget.jobId}');
      print('aucMtd ====================== $aucMtd');
      if(aucMtd == '2'){
        _timer = Timer.periodic(_duration, (timer) {
          DateFormat dateFormat = DateFormat(dateFormatString); //날짜 방식 정하기
          DateTime nowDateTime = dateFormat.parse(DateFormat(dateFormatString).format(DateTime.now())); // 날짜 방식에 맞춰 현재 날짜 가져오기 String
          DateTime originDateTime = new DateFormat(dateFormatString).parse(bidDlDtm); // 남은 입찰 날짜 넣어야됨

          // print('bidDlDtm ============================== ${widget.bidDlDtm}');
          // print('nowDateTime ============================== $nowDateTime');
          // print('originDateTime =========================== $originDateTime');

          final differenceSeconds = originDateTime.difference(nowDateTime).inSeconds; // 두날짜의 차이를 초단위로 가져온다  앞이 입찰시간 뒤 가 현재 시간으로 해야되나?
          final differenceDays = originDateTime.difference(nowDateTime).inDays;

          // print('Home differenceSeconds =============== $differenceSeconds');
          // print('Home differenceDays =============== $differenceDays');
          timeForTimer = differenceSeconds;
          if(!isDisposed) {
            setState(() {
              if (timeForTimer < 1) {
                timeToDisplay = "입찰 시간 종료";
                print('timeToDisplay ======================= $timeToDisplay');
                jobSts = "8";
                _timer.cancel();
              }  else if(differenceDays > 0){
                timeForTimer = timeForTimer - (differenceDays * 86400);
                int h = timeForTimer ~/ 3600;
                int t = timeForTimer - (3600 * h);
                int m = t ~/ 60;
                int s = t - (60 * m);
                // if()
                timeToDisplay =
                    "$differenceDays일 "+  h.toString() + ":" + m.toString() + ":" + s.toString();
                timeForTimer = timeForTimer - 1;
              } else if (timeForTimer < 60) {
                timeToDisplay = timeForTimer.toString();
                timeForTimer = timeForTimer - 1;
              } else if (timeForTimer < 3600) {
                int m = timeForTimer ~/ 60;
                int s = timeForTimer - (60 * m);
                timeToDisplay = m.toString() + ":" + s.toString();
                timeForTimer = timeForTimer - 1;
              } else {
                int h = timeForTimer ~/ 3600;
                int t = timeForTimer - (3600 * h);
                int m = t ~/ 60;
                int s = t - (60 * m);
                timeToDisplay = h.toString() + ":" + m.toString() + ":" + s.toString();
                timeForTimer = timeForTimer - 1;
              }
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double defaultSize = SizeConfig.defaultSize;
    return WillPopScope(
      onWillPop: (){
        if(aucMtd == '2'){ _timer.cancel(); }
        Navigator.pop(context);
        return;
      },
      child: Scaffold(
        key: globalKey,
        appBar: AppBar(
          centerTitle: true,
          title: Text('상세내용'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              if(aucMtd == '2') { _timer.cancel(); }
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
                  child: Column(
                    children: [
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
                      (aucMtd == "1") ? Container() : Text(
                        '남은 입찰시간 : '+timeToDisplay,
                        style: TextStyle(color: Colors.black, fontSize:  defaultSize * 1.4,),
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
                            (aucMtd == "1") ? '금액 : '+ formJobAmt +'원': '희망 금액 : '+formJobAmt+'원',
                            // (jobAmt != null) ? '금액 : '+formatter.format(jobAmt) +'원': '금액 : 0 원',
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
                          margin: EdgeInsets.only(right: 35),
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
                // Divider(height: defaultSize * 3,),
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
        bottomNavigationBar:messageBottomNavigationBar(message, size, defaultSize, jobSts, hanResult),
      ),
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
                return Image.network('$url/api/service/homeImage?jobId=$jobId&picIndex=${index+1}',);
              }
          ),
        ),
      );
    else
      return null;
  }

  messageBottomNavigationBar(String message, Size size, double defaultSize, String jobSts, String hanResult) {
    print('MessageBottomNavigationBar message ============================= $hanResult');
    if(jobSts == "8"){
      return Container(
        color: Colors.grey[700],
        child: SizedBox(
          width: double.infinity,
          height: defaultSize * 6,
          child: FlatButton(
            color: Colors.grey[700],
            onPressed: null,
            child: Text( "시간초과",  style: TextStyle( color: Colors.white,  fontSize: defaultSize * 1.3,), ),
          ),
        ),
      );
    }
    if(message == "User"){
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size.width / 2,
              height: defaultSize * 6,
              child: FlatButton(
                color: Colors.purple,
                onPressed: () {
                  if(jobSts != "1") return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('예약 할수 없습니다.')));
                  print('aucMtd ===================================== $aucMtd');
                  if( aucMtd == "1"){
                    homeDetailDialog.showDialogFunc(context, defaultSize, jobTtl, jobCtn, jobStDtm, token, widget.jobId);
                  } else {
                    if(hanResult == "N"){
                      print('입찰식 예약하기!!!!!!!!!!!!!!!!!!!');
                      reservationAucMtdDialog();
                    }else {
                      print('입찰중 으로 대기알림 !!!!!!!!!!!!!!!');
                    }
                  }
                },
                child: Text( hanResult,  style: TextStyle( color: Colors.amber,  fontSize: defaultSize * 1.3,), ),
              ),
            ),
            Expanded(
              child: FlatButton(
                onPressed: () => sendMessage(),
                child: Text("메세지"),
              ),
            ),
          ],
        ),
      );
    } else if(message =="SMAE"){
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size.width / 2,
              height: defaultSize * 6,
              child: FlatButton(
                color: Colors.lightGreen,
                onPressed: () => homeDetailDialog.onUpdatePressed(context, jobId),
                child: Text( "수정하기",  style: TextStyle( color: Colors.white,  fontSize: defaultSize * 2,), ),
              ),
            ),
            Expanded(flex: 2,
              child: Expanded(
                child: FlatButton(
                  onPressed: () => homeDetailDialog.onDeletePressed(context, jobId, token),
                  child: Text("삭제하기",style: TextStyle(fontSize: defaultSize*2),),
                ),
              ),
            ),
          ],
        ),
      );
    }else {
      return Container(
        child: SizedBox(
          width: double.infinity,
          height: defaultSize * 6,
          child: FlatButton(
            color: Colors.purple,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
            },
            child: Text( "로그인",  style: TextStyle( color: Colors.amber,  fontSize: defaultSize * 1.3,), ),
          ),
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
  sendMessage() async{
    try{
      String idResult = await myPageServer.getProfile(token);
      Map<String, dynamic> profile = jsonDecode(idResult);
      debugPrint('Chat1 responeJson == $profile');
      if(!isDisposed) { setState(() => mbrId = profile['mbrId']); }
      print('sendMessage mbrId =============================== $mbrId');
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(mbrId: mbrId, jobId: jobId, junId: junId, hanId: mbrId,)));
    } catch(e){
    Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
    }
  }

  void reservationAucMtdDialog(){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            // shape: RoundedRectangleBorder(
            // borderRadius: BorderRadius.circular(10.0)
            title: Center(child: Text('입찰하기'),),
            content: Builder(
              builder: (BuildContext context){
                return Form(
                  key: formKey,
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(prefixText: _currency, labelText: '입찰액', hintText: '입찰할 금액을 입력하세요.'),
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    validator: (value){
                        if(value.isEmpty){
                        return '입찰금액을 입력해주세요';
                        } else if(value.substring(0,1) == "0"){
                          return '입찰금액은 0원 이상이여야 합니다.';
                        } else {
                        return null;
                      }
                    }, //null check
                  ),
                );
              },
            ),
            actions: <Widget>[
              FlatButton(onPressed: () {
                Navigator.pop(context, false);
                _controller.clear();
              }, child: Text('취소', style: TextStyle(color: Colors.purple),)),
              FlatButton(onPressed: sendReservationAucMtd, child: Text('예약', style: TextStyle(color: Colors.purple),)),
              // FlatButton(onPressed: validateAndSave , child: Text('변경', style: TextStyle(color: Colors.purple),)),
            ],
          );
        }
    );
  }

  sendReservationAucMtd () async{
    final form = formKey.currentState;
    if(form.validate()) {
      print(_controller.text);
      print(jobId);
      print(junId);
      try{
        String result = await homeServer.reservationBidAmt(token, _controller.text, jobId, junId);
        print('result =================================== $result');
      } catch(e){
        globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
      }
      _controller.clear();
      Navigator.pop(context);
    }
  }
}