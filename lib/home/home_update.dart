import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:any_rent/mypage/detail/list/mypage_list.dart';
import 'package:any_rent/register/register_items.dart';
import 'package:any_rent/register/register_server.dart';
import 'package:any_rent/settings/url.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:any_rent/mypage/detail/mytown/mypage_mytown.dart';
import 'package:flutter/material.dart';

// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:any_rent/settings/size_config.dart';
import '../login/login.dart';
import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:date_format/date_format.dart';
import 'home_server.dart';

// const url = 'http://211.253.20.112'; //개발서버
// const url = "http://192.168.1.3:4001"; //재승 내부 ip
const url = UrlConfig.url;

class HomeUpdate extends StatefulWidget {
  HomeUpdate({Key key, this.jobId}) : super(key: key);
  final String jobId;

  @override
  _HomeUpdateState createState() => _HomeUpdateState();
}

class _HomeUpdateState extends State<HomeUpdate> {
  double _width;
  DateTime selectedDate = DateTime.now();
  String token,
      jobTp1,
      jobTp2,
      twnCd,
      twnGc,
      jobStDtm,
      bidDlDtm,
      jobAmt,
      aucMtd,
      payMtd,
      jobTtl,
      jobCtn,
      hanGnd,
      townCd1,
      townCd2,
      townNm1,
      townNm2,
      auctionTimeString,
      twnGcName,
      hanGndName;
  String result,
      jobId,
      junId,
      tp1Nm,
      tp2Nm,
      twnNm,
      junNic,
      jobIts,
      tp1Cd,
      tp2Cd;
  String message = '';
  int bidAmt, junPrfSeq, mbrGrd;
  int picCnt = 0;
  int auctionTime = 600;
  String people = "1";
  bool state = true;
  List<Map> areaItems = [];
  Map<String, dynamic> addressResult;
  List<dynamic> tp1List, tp2List;
  List<Asset> images = List<Asset>();
  String _error;
  bool boolImages = false;
  final globalKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  double defaultSize = SizeConfig.defaultSize;
  DateTime start;
  bool isDisposed = false;
  bool isHttpSend = false;
  bool isNextPage = false;
  Map<String, dynamic> homeUpdateResultList;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController moneyController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay(
    hour: DateTime.now().hour,
    minute: DateTime.now().minute,
  );
  static const _locale = 'ko';

  String _formatNumber(String s) =>
      NumberFormat.decimalPattern(_locale).format(int.parse(s));

  String get _currency =>
      NumberFormat.compactSimpleCurrency(locale: _locale).currencySymbol;

  Future<Null> _selectDate(BuildContext context) async {
    final format = DateFormat("yyyy-MM-dd");
    final DateTime picked = await showDatePicker(
        context: context,
        // locale: Locale('kr'),
        // locale: const Locale("kr", "KR"),
        initialDate: selectedDate,
        // initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2021),
        lastDate: DateTime(2100));
    if (picked != null)
      setState(() {
        selectedDate = picked;
        print("selectedDate ============");
        String formattedDate = format.format(picked);
        print(selectedDate.toString());
        print("selectedDate ============$formattedDate");
        print("selectedDate ============");

        _dateController.text =
            // DateFormat.yMd('ko_KR').format(selectedDate);
            formattedDate;
      });
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      setState(() {
        // jobStDtm = date.toString().substring(0.16); start =date;
        selectedTime = picked;
        print("selectedTime ============");
        print(selectedTime.toString());
        print(selectedTime.format(context));
        print(selectedTime.hourOfPeriod);

        String timeSub = selectedTime.toString().substring(10, 15);
        print(timeSub);
        print("selectedTime ============");

        // _hour = selectedTime.hour.toString();
        // _minute = selectedTime.minute.toString();
        // _time = _hour + ' : ' + _minute;
        // _timeController.text = _time;
        //
        // print("_time =========== $_time");

        jobStDtm = selectedDate.toString().substring(0, 11) + timeSub;
        print("jobStdtm ============ $jobStDtm");

        _timeController.text = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [hh, ':', nn, " ", am]).toString();
      });
  }

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  final _controller = TextEditingController();

  @override
  void dispose() {
    moneyController.dispose();
    titleController.dispose();
    contentController.dispose();
    isDisposed = true;
    super.dispose();
  }

  loadToken() async {
    //동네등록 확인여부 및 동네 리스트 가져오기
    token = await customSharedPreferences.getString('token');
    state = await customSharedPreferences.getBool('state');

    var homeDetail;
    try {
      homeDetail = {"recieveToken": token, "jobId": widget.jobId};
      String result = await homeServer.getHomeDetail(homeDetail);
      // debugPrint('result ============= $result');
      homeUpdateResultList = jsonDecode(result);
      debugPrint(
          'homeUpdateResultList ==================== $homeUpdateResultList');
    } catch (e) {
      globalKey.currentState
          .showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
    }
    setState(() {
      message = homeUpdateResultList['message'];
      picCnt = homeUpdateResultList['picCnt'];
      junId = homeUpdateResultList['homeDetailSub']['junId']; //주니 아이디
      jobTtl = homeUpdateResultList['homeDetailSub']['jobTtl']; // 일제목
      jobCtn = homeUpdateResultList['homeDetailSub']['jobCtn']; //일 내용
      payMtd = homeUpdateResultList['homeDetailSub']
          ['payMtd']; //결제 방식 1. 직접결제  2. 안전결제
      aucMtd = homeUpdateResultList['homeDetailSub']
          ['aucMtd']; //입찰 방식 1. 선착순  2. 입찰식
      jobAmt =
          homeUpdateResultList['homeDetailSub']['jobAmt'].toString(); // 선착순 금액
      bidAmt = homeUpdateResultList['homeDetailSub']['bidAmt']; // 입찰식 금액
      jobStDtm = homeUpdateResultList['homeDetailSub']['jobStDtm']; //소일 시작시간 ,
      tp1Nm = homeUpdateResultList['homeDetailSub']['tp1Nm']; // 1차분류
      tp1Cd = homeUpdateResultList['homeDetailSub']['tp1Cd']; // 1차분류 코드
      tp2Nm = homeUpdateResultList['homeDetailSub']['tp2Nm']; // 2차분류
      tp2Cd = homeUpdateResultList['homeDetailSub']['tp2Cd']; // 2차분류 코드
      twnNm = homeUpdateResultList['homeDetailSub']['twnNm']; // 동네명
      twnCd =
          homeUpdateResultList['homeDetailSub']['twnCd']; // 동네 코드 (10자리 동별 코드 )
      junNic = homeUpdateResultList['homeDetailSub']['junNic']; //주니 닉네임
      junPrfSeq =
          homeUpdateResultList['homeDetailSub']['junPrfSeq']; // 주니 프로필 이미지 시퀀스
      mbrGrd =
          homeUpdateResultList['homeDetailSub']['mbrGrd']; //주니 평점 일단 숫자로 해놈
      bidDlDtm = homeUpdateResultList['homeDetailSub']['bidDlDtm'];
      jobIts = homeUpdateResultList['homeDetailSub']['jobIts'];
      twnGc = homeUpdateResultList['homeDetailSub']
          ['twnGc']; // 동네구분코드 1. 동네 2. 광역 hanGnd
      hanGnd = homeUpdateResultList['homeDetailSub']
          ['hanGnd']; //하니희망 성별 0. 무관 M. 남성  F. 여성
      (twnGc == "1") ? twnGcName = '주변' : twnGcName = '광역';
      (hanGnd == "0")
          ? hanGndName = '무관'
          : (hanGnd == "M")
              ? hanGndName = '남성'
              : hanGndName = '여성';
    });
    // debugPrint('message ========= $message');
    debugPrint('jobCtn ========= $jobCtn');
    moneyController = new TextEditingController(
        text: (jobAmt == null)
            ? moneyController.text
            : '${_formatNumber(jobAmt.replaceAll(',', ''))}');
    titleController = new TextEditingController(
        text: (jobTtl == null) ? titleController.text : jobTtl);
    contentController = TextEditingController(
        text: (jobCtn == null) ? contentController.text : jobCtn);
    setState(() {
      state = state;
      token = token;
    });
    if (state) {
      try {
        String result = await registerServer.getTown(token);
        if (result == 'error') {
          return globalKey.currentState.showSnackBar(
              const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
        }
        print('loadToken result =============== $result');
        addressResult = jsonDecode(result);
        bool setRegister = addressResult['code'];
        print('setRegister =============== $setRegister');
        if (!setRegister) {
          //등록 동네 없을시 동네 등록 페이지 이동
          return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("동네가 등록 되있지 않습니다."),
                content: const Text('동네를 등록해 주세요.'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('동네 등록으로 이동'),
                    onPressed: () {
                      //동네가 등록 되있지 않을 시 동네 등록 페이지로 이동한다.
                      Navigator.pop(context, false);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyPageDetailMyTown(
                                    token: token,
                                  )));
                    },
                  ),
                ],
              );
            },
          );
        }
        // print('==========================================');
        // print(addressResult['list']);
        // print('==========================================');
        townCd1 = addressResult['list']['townCd1']; //동네 가져와서 map 으로 집어 넣는다.
        townNm1 = addressResult['list']['townNm1'];
        townCd2 = addressResult['list']['townCd2'];
        townNm2 = addressResult['list']['townNm2'];
        if (townCd1 != null) {
          if (!isDisposed)
            setState(() {
              areaItems.add({"id": townCd1, "name": townNm1});
            });
        }
        if (townCd2 != null) {
          if (!isDisposed)
            setState(() {
              areaItems.add({"id": townCd2, "name": townNm2});
            });
        }
        String tp1Result = await registerServer.getTp(); //카테고리 1 가져오기
        if (tp1Result == 'error') {
          return globalKey.currentState.showSnackBar(
              const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
        }
        if (!isDisposed) {
          setState(() {
            tp1List = jsonDecode(tp1Result);
          });
        }
        // print('tp1List ======================== $tp1List');
      } catch (e) {
        globalKey.currentState.showSnackBar(
            const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
      }
    }
  }

  sendRegister() async {
    print('등록');
    if (jobTp1 == null) {
      setState(() => jobTp1 = tp1Cd);
    }
    if (jobTp2 == null) {
      setState(() => jobTp2 = tp2Cd);
    }
    if (aucMtd == '2') {
      if (auctionTimeString == null) {
        return globalKey.currentState.showSnackBar(
            const SnackBar(content: const Text('입찰 마감시간을 선택해 주세요.')));
      }
    }
    if (moneyController.text == null) {
      return globalKey.currentState
          .showSnackBar(const SnackBar(content: const Text('금액을 입력해 주세요.')));
    }
    if (moneyController.text == '0') {
      return globalKey.currentState.showSnackBar(
          const SnackBar(content: const Text('금액은 0 원 이상이여야 합니다.')));
    }
    if (jobStDtm == null) {
      return globalKey.currentState
          .showSnackBar(const SnackBar(content: const Text('시간을 선택해 주세요.')));
    }
    if (twnGc == null) {
      setState(() => twnGc = twnGc);
    }
    if (twnCd == null) {
      return globalKey.currentState
          .showSnackBar(const SnackBar(content: const Text('동네를 선택해 주세요.')));
    }
    if (jobTtl == null) {
      return globalKey.currentState
          .showSnackBar(const SnackBar(content: const Text('제목을 입력하세요.')));
    }
    if (aucMtd == null) {
      setState(() => aucMtd = "1");
    }
    if (payMtd == null) {
      setState(() => payMtd = "1");
    }
    if (hanGnd == null) {
      setState(() => hanGnd = "0");
    }
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
    }
    jobAmt = moneyController.text;
    jobTtl = titleController.text;
    jobCtn = contentController.text;

    print('twnCd ===================== $twnCd');
    print(homeUpdateResultList['homeDetailSub']['twnCd']);
    // print('images ===================== $images');

    try {
      Uri uri = Uri.parse('$url/api/service/regiservUpt');
      http.MultipartRequest request = new http.MultipartRequest('POST', uri);

      request.fields['jobId'] = widget.jobId;
      request.fields['recieveToken'] = token;
      request.fields['jobTp1'] = jobTp1;
      request.fields['jobTp2'] = jobTp2;
      request.fields['twnCd'] = twnCd;
      request.fields['twnGc'] = twnGc;
      request.fields['jobStDtm'] = jobStDtm;
      request.fields['jobAmt'] = jobAmt;
      request.fields['reqCnt'] = '1';
      request.fields['aucMtd'] = aucMtd;
      request.fields['payMtd'] = payMtd;
      request.fields['jobTtl'] = jobTtl;
      request.fields['jobCtn'] = jobCtn;
      request.fields['hanGnd'] = hanGnd;
      if (picCnt < images.length) {
        //파일을 변경 한경우
        request.fields['picCnt'] = images.length.toString();
      } else {
        //파일을 변경하지 않은 경우
        request.fields['picCnt'] = picCnt.toString();
      }

      if (aucMtd == '2') {
        //입찰방식 입찰식 일시 서보로 보내기 위한 setting
        print('입찰 방식 입찰식');
        var now = new DateTime.now();
        var auctionTimeFromNow = now.add(new Duration(seconds: auctionTime));
        print('auctionTimeFromNow ================= $auctionTimeFromNow');
        print('start ================= $start');
        print('jobStDtm ================= $jobStDtm');
        bidDlDtm = auctionTimeFromNow.toString().substring(0, 16);
        print('bidDlDtm ================= $bidDlDtm');
        // print(start > auctionTimeFromNow);

        int compare =
            start.compareTo(auctionTimeFromNow); //날짜 비교 작업 시작날짜와 입찰 날짜 비교
        if (compare < 0) {
          print('start < auctionTimeFromNow  $start < $auctionTimeFromNow');
          return globalKey.currentState.showSnackBar(
              const SnackBar(content: const Text('입찰 마감시간보다 시작 시간이 빠릅니다.')));
        }
        request.fields['bidDlDtm'] = bidDlDtm;
        print('=======================================입찰식 업로드?');
      }
      //여러 이미지 업로드를 위한 반복문
      for (int i = 0; i < images.length; i++) {
        // ByteData byteData = await images[i].getByteData();
        ByteData byteData = await images[i].getThumbByteData(
            images[i].originalWidth, images[i].originalHeight,
            quality: 30);
        // print('byteData ==================== $byteData');
        List<int> imageData = byteData.buffer.asUint8List();
        // print('imageData ==================== $imageData');
        // print(images[i].name);
        // print(images[i].name.split('.').last);
        http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
          'image',
          imageData,
          filename: images[i].name,
          contentType: MediaType("image", images[i].name.split('.').last),
        );
        request.files.add(multipartFile);
      }
      print('===============================================================');
      print('일거리 수정 등록 전송');

      if (!isDisposed) setState(() => isHttpSend = true);
      await request.send().then((response) {
        print('=======================================response');
        print(response.statusCode);
        if (response.statusCode != 200) {
          return globalKey.currentState.showSnackBar(
              const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
        }
        if (!isDisposed) setState(() => isNextPage = true);
        Future.delayed(Duration(seconds: 1), () async {
          return Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContext context) => MyPageDetailList(
                        index: 0,
                      )),
              (route) => false);
        });
      });
    } catch (e) {
      globalKey.currentState.showSnackBar(const SnackBar(
          content: const Text('잠시후 다시 시도해 주세요.'),
          duration: Duration(seconds: 3)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return isHttpSend
        ? Scaffold(
            key: globalKey,
            body: SizedBox.expand(
              child: Container(
                  color: Colors.grey[50],
                  child: Center(
                    child: isNextPage ? AlertDialog(
                      title: Center(
                          child: Text('수정 되었습니다!', style: TextStyle(fontSize: defaultSize * 2),)),)
                        : CircularProgressIndicator(),
                  )),
            ),
          ) : state ? WillPopScope(onWillPop: onBackPressed,
                child: Scaffold(
                  key: globalKey,
                  appBar: AppBar(
                    centerTitle: true,
                    title: Text('수정하기', style: TextStyle(color: Colors.black),),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: sendRegister, textColor: Colors.black,
                          child: Text("수정 완료", style: TextStyle(fontSize: 17.0),
                          ))],
                    // actions: <Widget>[ FlatButton(onPressed: () => sendRegister(),  child: Text('수정'),),],
                  ),
         body: ListView(
           children: [
             Form(
              key: formKey,
               child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(
                    padding: EdgeInsets.fromLTRB(defaultSize * 2.5, defaultSize * 2, defaultSize, defaultSize),
                     child: Text('카테고리', style: TextStyle(fontWeight: FontWeight.bold, fontSize: defaultSize * 1.8),
                              ),
                            ),
                  SizedBox(height: 5,),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              left: defaultSize * 3, right: defaultSize),
                          height: defaultSize * 4.5,
                          width: defaultSize * 17,
                          decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(10.0),
                                        // 동그라미 모양
                              color: Colors.lightGreen),
                          child: (tp1List != null) ?
                          DropdownButton(isExpanded: false, items: tp1List.map((item) {
                            return DropdownMenuItem(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: defaultSize),
                                child: Text(item['tp1Nm'],
                                    style: TextStyle(
                                        color: Colors.white, fontSize: defaultSize * 1.7,
                                        fontWeight: FontWeight.bold)),),
                              value: item['tp1Cd']);
                          }).toList(), underline: Container(),
                            onChanged: (value) {
                              setState(() { jobTp1 = value; });
                              print('jobTp1 ======== $jobTp1');
                              getTp2();
                            },
                            hint: Text(tp1Nm ?? '', style: TextStyle(color: Colors.white, fontSize: defaultSize * 1.7)),
                            dropdownColor: Colors.lightGreen,
                            value: jobTp1,
                            iconEnabledColor: Colors.amber,
                          ) : Padding(padding: EdgeInsets.symmetric(
                              horizontal: 5.0),
                            child: SizedBox(
                              width: defaultSize,
                              height: defaultSize,
                              child: CircularProgressIndicator(),),),),
                        SizedBox(width: defaultSize * 2,),
                        Container(
                          padding: EdgeInsets.only(
                              left: defaultSize * 4, right: defaultSize),
                          height: defaultSize * 4.5,
                          width: defaultSize * 17,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            // 동그라미 모양
                            color: Colors.lightGreen,),
                          child: DropdownButton(
                            isExpanded: false,
                            items: (tp2List != null) ? tp2List.map((item) {
                              return DropdownMenuItem(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: defaultSize),
                                    child: Text(item['tp2Nm'],
                                        style: TextStyle(color: Colors.white, fontSize: defaultSize * 1.7, fontWeight: FontWeight.bold)),),
                                  value: item['tp2Cd']);
                            }).toList() : [],
                            underline: Container(),
                            onChanged: (value) {
                              setState(() { jobTp2 = value; });
                              print('jobTp2 ======== $jobTp2');
                            },
                            hint: Text(tp2Nm ?? '', style: TextStyle(color: Colors.white,
                                fontSize: defaultSize * 1.7)),
                            dropdownColor: Colors.lightGreen,
                            value: jobTp2,
                            iconEnabledColor: Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Divider(height: 15, thickness: 4,),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(),
                            Container(
                              padding: EdgeInsets.fromLTRB(defaultSize * 2.3,
                                  defaultSize , defaultSize, defaultSize),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '입찰방식',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: defaultSize * 1.8),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                           Row(
                             children: [
                               Container(
                                 child: Container(
                                   margin: EdgeInsets.only(left: 7),
                                   padding: EdgeInsets.only(left: defaultSize, right: defaultSize),
                                   height: defaultSize * 4.5,
                                   width: defaultSize * 17,
                                   // width: 100,
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(10.0),
                                     // 동그라미 모양
                                     color: Colors.lightGreen,
                                     // border: Border.all(color: Colors.grey)
                                   ),
                                   child: DropdownButton(
                                     items: registerItems.auctionMethod.map((item) {
                                       return DropdownMenuItem(
                                         child: Padding(
                                           padding: EdgeInsets.symmetric(horizontal: defaultSize),
                                           child: Text(item['name'], style: TextStyle(
                                                 fontSize: defaultSize * 1.7, color: Colors.white,)),),
                                                value: item['id'],);
                                            }).toList(),
                                            underline: Container(),
                                            onChanged: (value) { setState(() { aucMtd = value; }); print('aucMtd ======== $aucMtd'); },
                                            hint:  Text(registerItems.auctionMethod[0]["name"],style: TextStyle(fontSize: defaultSize * 1.7)),
                                            dropdownColor: Colors.lightGreen,
                                            value: aucMtd,
                                            iconEnabledColor:
                                                Colors.amber, //화살표 색
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: defaultSize * 2,),
                                      Container(padding: EdgeInsets.only(top: defaultSize * 1.3),
                                          width: defaultSize * 16.7,
                                          height: defaultSize * 4.5,
                                          decoration:BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(10.0
                                            ),
                                          ),
                                          child:
                                          Expanded(flex: 4,  child: (aucMtd == '2')
                                              ?  InkWell( child: Text(auctionTimeString
                                              ?? '터치 후 압찰시간 선택', style: TextStyle(fontSize: defaultSize * 1.7,fontWeight: FontWeight.bold,color: Colors.lightGreen[700]),textAlign: TextAlign.center,),
                                            onTap: () => setAuctionTime(), )  :  Container(),
                                          )
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Divider(),
                            Container(
                              padding: EdgeInsets.fromLTRB(defaultSize * 2.5, defaultSize * 1, defaultSize, defaultSize),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '결제',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: defaultSize * 1.8),),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: defaultSize * 1.5,),
                                      Container(
                                        width: 50,
                                        child: Text('금액',
                                          style: TextStyle(fontSize: defaultSize * 1.6),)),
                                      Container(
                                        padding: EdgeInsets.all(0),
                                        width: 150,
                                        height: defaultSize * 4.5,
                                        child: TextField(
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          controller: moneyController,
                                          decoration: InputDecoration(prefixText: _currency,
                                            border: OutlineInputBorder(borderSide: BorderSide(width: 3,)),
                                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.lightGreen[700], width: 3,),),
                                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.lime, width: 2,)),
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            WhitelistingTextInputFormatter(
                                                RegExp('[0-9]')),
                                          ],
                                          onChanged: (string) {
                                            string = '${_formatNumber(string.replaceAll(',', ''))}';
                                            moneyController.value = TextEditingValue(
                                              text: string,
                                              selection: TextSelection.collapsed(offset: string.length),);
                                            print('jobAmt ================== $string');
                                            setState(() => jobAmt = string);
                                          },
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        padding: EdgeInsets.only(left: 10),
                                        height: defaultSize * 4.5,
                                        decoration: BoxDecoration(
                                            color: Colors.lightGreen,
                                            borderRadius: BorderRadius.circular(
                                                defaultSize * 1)),
                                        child: Expanded(
                                          flex: 2,
                                          child: DropdownButton(
                                            dropdownColor: Colors.lightGreen,
                                            items: registerItems.paymentItmes
                                                .map((item) {
                                              return DropdownMenuItem(
                                                  child: Text(item['name'],
                                                      style: TextStyle(
                                                          fontSize:
                                                              defaultSize * 1.7,
                                                          color: Colors.white)),
                                                  value: item['id']);
                                            }).toList(),
                                            underline: Container(),
                                            onChanged: (value) {
                                              setState(() {
                                                payMtd = value;
                                              });
                                              print('payMtd ======== $payMtd');
                                            },
                                            hint: Text(
                                                registerItems.paymentItmes[0]
                                                    ["name"],
                                                style: TextStyle(
                                                    fontSize: defaultSize * 1.7,
                                                    color: Colors.white)),
                                            value: payMtd,
                                            iconEnabledColor:
                                                Colors.amber, //화살표 색
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Divider(),

                  Container(padding: EdgeInsets.fromLTRB(defaultSize * 2.5, defaultSize , defaultSize, defaultSize),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('날짜', style: TextStyle(fontWeight: FontWeight.bold , fontSize: defaultSize * 1.8),),
                      SizedBox(height: 10,),
                      Row(
                        children: [Padding(padding: EdgeInsets.only(left: 43)),
                          Expanded(flex: 2 ,
                            child: Text('시작일', style: TextStyle(fontSize: defaultSize * 1.6),),),
                          Expanded( flex: 6 ,
                            child: Padding( padding: EdgeInsets.only(right: defaultSize * 2),
                              child: InkWell(
                                onTap: (){
                                  FocusScopeNode currentFocus = FocusScope.of(context);
                                  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                                    currentFocus.focusedChild.unfocus();
                                  }
                                  _selectDate(context);
                                },
                                child: Container(
                                  width: 200,
                                  height: 30,
                                  margin: EdgeInsets.only(top: 0),
                                  alignment: Alignment.center,
                                  // decoration: BoxDecoration(border:Border.all(color: Colors.grey)),
                                  child: Text( selectedDate.toString().substring(0, 10) ?? '시작일을 선택하세요.',
                                    style:  TextStyle(fontSize: defaultSize * 2,),
                                    textAlign: TextAlign.right, ),
                                ),
                                // child: Text( jobStDtm ?? '시작날짜를 선택하세요.', textAlign: TextAlign.right),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                  Container(
                     // decoration: BoxDecoration(
                     //   border: Border.all(color: Colors.grey)
                     //),
                      padding: EdgeInsets.all(10.0),
                      child: Row(children: [
                        Padding(padding: EdgeInsets.only(left: 55)),
                        Text('시작 시간'),
                        InkWell(
                          onTap: () {
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                              currentFocus.focusedChild.unfocus();
                            }
                            _selectTime(context);
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 12),
                            width: defaultSize * 23.5,
                            height: 20,
                            alignment: Alignment.center,
                            child: Text(selectedTime.format(context) ?? '시작시간을 선택하세요.',
                              style: TextStyle(fontSize: defaultSize * 2),
                              textAlign: TextAlign.right,),
                          ),
                        )
                      ],
                      )),
                  SizedBox(height: 5,),
                  Divider(),
                  SizedBox(height: 10,),
                  Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(padding: EdgeInsets.fromLTRB(defaultSize,defaultSize,defaultSize,defaultSize)),
                            Container( width: 30,
                              child: Text('동네', style: TextStyle(fontWeight: FontWeight.bold , fontSize: defaultSize * 1.5),),),
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              height: 40,
                              width: defaultSize * 8.3,
                              decoration: BoxDecoration(border: Border.all(color: Colors.lightGreen),borderRadius: BorderRadius.circular(15)),
                              child: (areaItems == null) ? Padding( padding: EdgeInsets.symmetric(horizontal: 5.0), child: SizedBox( width: defaultSize, height: defaultSize, child: CircularProgressIndicator(), ),) :
                              DropdownButton(
                                items: (areaItems != null) ?
                                areaItems.map((item) {
                                  return  DropdownMenuItem(
                                      child: Text( item['name'],  style: TextStyle(fontSize: defaultSize * 1.5,) ),
                                      value: item['id']
                                  );
                                }).toList() : [],
                                underline: Container(),
                                onChanged: (value) { setState(() { twnCd = value; }); print('twnCd ======== $twnCd'); },
                                hint: Text(twnNm?? '', style: TextStyle(fontSize: defaultSize * 1.5, color: Colors.black)),
                                value:twnCd,
                                iconEnabledColor: Colors.amber, //화살표 색
                              ),
                            ),SizedBox(width:8,),
                            Container( width: 30,child: Text('범위', style: TextStyle(fontWeight: FontWeight.bold , fontSize: defaultSize * 1.5),),),
                            Container( padding: EdgeInsets.only(left: 10), height: 40,width: defaultSize * 8.1,decoration: BoxDecoration(border: Border.all(color: Colors.lightGreen),borderRadius: BorderRadius.circular(15)),

                              child: DropdownButton(
                                items: registerItems.rangeItems.map((item) {
                                  return  DropdownMenuItem(
                                      child: Text( item['name'],  style: TextStyle(fontSize: defaultSize * 1.5,) ),
                                      value: item['id']
                                  );
                                }).toList(),
                                underline: Container(),
                                onChanged: (value) { setState(() { twnGc = value; }); print('twnGc ======== $twnGc'); },
                                hint:  Text(twnGcName ?? '',style: TextStyle(fontSize: defaultSize * 1.5, color:  Colors.black)),
                                value:twnGc,
                                iconEnabledColor: Colors.amber, //화살표 색
                              ),
                            ),
                            SizedBox(width: 8,),

                            Container(width: 30, child: Text('희망성별', style: TextStyle(fontWeight: FontWeight.bold , fontSize: defaultSize * 1.5),),),
                            Container( padding: EdgeInsets.only(left: 10), height: 40,width: defaultSize * 8.3,decoration: BoxDecoration(border: Border.all(color: Colors.lightGreen),borderRadius: BorderRadius.circular(15)),
                              child:DropdownButton(
                                items: registerItems.genderItems.map((item) {
                                  return  DropdownMenuItem(
                                      child: Text( item['name'],  style: TextStyle(fontSize: defaultSize * 1.5,) ),
                                      value: item['id']
                                  );
                                }).toList(),
                                underline: Container(),
                                onTap: () {
                                  FocusScopeNode currentFocus = FocusScope.of(context);
                                  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                                    currentFocus.focusedChild.unfocus();
                                  }
                                },
                                onChanged: (value) { setState(() { hanGnd = value; }); print('hanGnd ======== $hanGnd'); },
                                hint:  Text(registerItems.genderItems[0]["name"],style: TextStyle(fontSize: defaultSize * 1.5)),
                                value:hanGnd,
                                iconEnabledColor: Colors.amber, //화살표 색
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                            SizedBox(height: 10,),
                            Divider(),
                  Container(
                    margin: EdgeInsets.only(top:defaultSize * 0.5),
                    padding: EdgeInsets.fromLTRB(defaultSize * 2.5, defaultSize , defaultSize, defaultSize * 2),
                    child:Row(
                      children: [
                        Container(
                          child: Text('일 제목', style: TextStyle(fontWeight: FontWeight.bold , fontSize: defaultSize * 1.8),),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          // width: 280,
                          width: defaultSize * 28,
                          height: defaultSize * 4.5,
                          decoration: BoxDecoration(
                            // borderRadius: BorderRadius.circular(20.0),
                            // color: Colors.grey[200],
                            // color: Colors.grey[100],
                          ),
                          child: TextFormField(
                            controller: titleController,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              // border: InputBorder.none,
                              border: OutlineInputBorder(
                                // borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide( width: 3, )
                              ),
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 15, right: 15),
                              focusedBorder: OutlineInputBorder(
                                // borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide(
                                  color: Colors.lightGreen[700],
                                  width: 3,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                // borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide(
                                    color:Colors.lime,
                                    width: 2,
                                  )
                              ),
                            ),

                            validator: (value){
                              if (value.trim().isEmpty){ return '공백은 입력할 수 없습니다.'; }
                              if (value.isEmpty) { return '제목을 입력해 주세요.'; } else  return null; },
                            onChanged: (value){
                              print('value ============ $value');
                              print('jobCtn ============ $jobCtn');
                              print(contentController.text);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(defaultSize * 2, defaultSize , defaultSize, defaultSize * 2),
                    child: Column(
                      children: [
                        Container(),
                        Container(
                          width: 80,
                          margin: EdgeInsets.only(right: 245),
                          child: Text('상세내용', style: TextStyle(fontWeight: FontWeight.bold , fontSize: defaultSize * 1.8),),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 9,top: 20,right: 16,bottom: 20),
                          // height: 300,
                          // decoration: BoxDecoration(
                          //   borderRadius: BorderRadius.circular(20.0),
                          //   color: Colors.grey[200]
                          // ),
                          child: TextFormField(
                            controller: contentController,
                            maxLines: 20,
                            minLines: 20,
                            // maxLength: (50),
                            decoration: InputDecoration(
                              // border: InputBorder.none,
                              border: OutlineInputBorder(
                                // borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide( width: 3, )
                              ),
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 15, right: 15, top: 15),
                              focusedBorder: OutlineInputBorder(
                                // borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide(
                                  color: Colors.lightGreen[700],
                                  width: 3,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                // borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide(
                                    color:Colors.lime,
                                    width: 2,
                                  )
                              ),
                            ),
                            validator: (value){
                              if (value.trim().isEmpty){ return '공백은 입력할 수 없습니다.'; }
                              if (value.isEmpty) { return '상세내용을 입력하세요.'; } else  return null;
                            },
                            onChanged: (value){ print('value =============$value'); setState(() => jobCtn = value );},
                            onSaved: (value){ jobCtn = value; },
                          ),
                        ),
                        Container(
                          width: 80,
                          margin: EdgeInsets.only(top:10,bottom: 18,right: 240),
                          child: Text('사진 첨부',style: TextStyle(fontSize: defaultSize*1.8,fontWeight: FontWeight.bold),),
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                              ],
                            ),
                            Container( height: defaultSize * 45,
                              child: (images.length > 0 && images != null) ? InkWell( onTap: loadAssets, child: buildGridView()) :
                              InkWell(
                                onTap: loadAssets,
                                child: Container( padding: EdgeInsets.only(top: 0), margin: EdgeInsets.only(left: 10,right: 15),
                                    decoration: BoxDecoration(border: Border.all(color: Colors.grey),
                                      // borderRadius: BorderRadius.circular(20.0)
                                    ),
                                    child: Center(child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('터치하여 이미지를 선택 하세요.\n\n', style: TextStyle(fontSize: defaultSize * 1.6)),
                                        Text('이미지는 3장까지 가능 합니다.', style: TextStyle(fontSize: defaultSize * 1.4)),
                                      ],
                                    ))
                                ),
                              ),
                            ),
                            SizedBox(height:  defaultSize * 3,),
                          ],
                        ),
                      ],
                    ),
                  )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Login();
  }

  changeImages() {
    //입찰 시간 선택 dailog
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(child: Text('이미지를 수정 하시겠습니까?')),
            content: Text('이미지는 3장까지 가능 합니다.'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('아니요', style: TextStyle(color: Colors.black))),
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    loadAssets();
                  },
                  child: Text('예', style: TextStyle(color: Colors.black))),
            ],
          );
        });
  }

  getTp2() async {
    //카테고리 1에 값으로 카테고리 2 가져오기
    String result = await registerServer.getTp2(jobTp1);
    if (result == 'error') {
      return globalKey.currentState
          .showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
    }
    setState(() {
      tp2List = jsonDecode(result);
    });
  }

  setAuctionTime () { //입찰 시간 선택 dailog
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: Center(child: Text('입찰 마감 시간 선택')),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RaisedButton(onPressed: () {Navigator.pop(context, false); setState(() { auctionTime = 1260; auctionTimeString ='20분';});},
                    child: Text('20분', style: TextStyle(fontSize: defaultSize * 1.6, color: Colors.lightGreen[700]),),
                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(18.0),  side: BorderSide(color: Colors.amber) ),color: Colors.white,),
                  RaisedButton(onPressed: () {Navigator.pop(context, false); setState(() { auctionTime = 1860; auctionTimeString ='30분';});},
                    child: Text('30분', style: TextStyle(fontSize: defaultSize * 1.6, color: Colors.lightGreen[700]),),
                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(18.0),  side: BorderSide(color: Colors.amber) ),color: Colors.white,),
                  RaisedButton(onPressed: () {Navigator.pop(context, false); setState(() { auctionTime = 2460; auctionTimeString ='40분';});},
                    child: Text('40분', style: TextStyle(fontSize: defaultSize * 1.6, color: Colors.lightGreen[700]),),
                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(18.0),  side: BorderSide(color: Colors.amber) ),color: Colors.white,),
                  RaisedButton(onPressed: () {Navigator.pop(context, false); setState(() { auctionTime = 3060; auctionTimeString ='50분';});},
                    child: Text('50분', style: TextStyle(fontSize: defaultSize * 1.6, color: Colors.lightGreen[700]),),
                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(18.0), side: BorderSide(color: Colors.amber) ),color: Colors.white,),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RaisedButton(onPressed: () {Navigator.pop(context, false); setState(() { auctionTime = 3660; auctionTimeString ='1시간';});},
                    child: Text('1시간', style: TextStyle(fontSize: defaultSize * 1.6, color: Colors.lightGreen[700]),),
                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(18.0),  side: BorderSide(color: Colors.amber) ),color: Colors.white,),
                  RaisedButton(onPressed: () {Navigator.pop(context, false); setState(() { auctionTime = 7260; auctionTimeString ='2시간';});},
                    child: Text('2시간', style: TextStyle(fontSize: defaultSize * 1.6, color: Colors.lightGreen[700]),),
                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(18.0),  side: BorderSide(color: Colors.amber) ),color: Colors.white,),
                  RaisedButton(onPressed: () {Navigator.pop(context, false); setState(() { auctionTime = 10860; auctionTimeString ='3시간';});},
                    child: Text('3시간', style: TextStyle(fontSize: defaultSize * 1.6, color: Colors.lightGreen[700]),),
                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(18.0),  side: BorderSide(color: Colors.amber) ),color: Colors.white,),
                  RaisedButton(onPressed: () {Navigator.pop(context, false); setState(() { auctionTime = 21660; auctionTimeString ='4시간';});},
                    child: Text('6시간', style: TextStyle(fontSize: defaultSize * 1.6, color: Colors.lightGreen[700]),),
                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(18.0),  side: BorderSide(color: Colors.amber) ),color: Colors.white,),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RaisedButton(onPressed: () {Navigator.pop(context, false); setState(() { auctionTime = 86460; auctionTimeString ='1일';});},
                    child: Text('1일', style: TextStyle(fontSize: defaultSize * 1.6, color: Colors.lightGreen[700]),),
                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(18.0),  side: BorderSide(color: Colors.amber) ),color: Colors.white,),
                  RaisedButton(onPressed: () {Navigator.pop(context, false); setState(() { auctionTime = 172860; auctionTimeString ='2일';});},
                    child: Text('2일', style: TextStyle(fontSize: defaultSize * 1.6, color: Colors.lightGreen[700]),),
                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(18.0),  side: BorderSide(color: Colors.amber) ),color: Colors.white,),
                  RaisedButton(onPressed: () {Navigator.pop(context, false); setState(() { auctionTime = 259260; auctionTimeString ='3일';});},
                    child: Text('3일', style: TextStyle(fontSize: defaultSize * 1.6, color: Colors.lightGreen[700]),),
                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(18.0),  side: BorderSide(color: Colors.amber) ),color: Colors.white,),
                  RaisedButton(onPressed: () {Navigator.pop(context, false); setState(() { auctionTime = 345660; auctionTimeString ='5일';});},
                    child: Text('5일', style: TextStyle(fontSize: defaultSize * 1.6, color: Colors.lightGreen[700]),),
                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(18.0),  side: BorderSide(color: Colors.amber) ),color: Colors.white,),
                ],
              ),
            ],
          );
        }
    );
  }

  Widget buildGridView() {
    if (images != null)
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
              itemCount: images.length,
              itemBuilder: (BuildContext context, int index) {
                Asset asset = images[index];
                return AssetThumb(
                  asset: asset,
                  width: 300,
                  height: 300,
                );
              }),
        ),
      );
    else
      return Container(color: Colors.white);
  }

  Widget buildSwiperPagination(String jobId, int picCnt) {
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
              itemBuilder: (BuildContext context, int index) {
                return Image.network(
                    '$url/api/service/homeImage?jobId=$jobId&picIndex=${index + 1}');
              }),
        ),
      );
    else
      return null;
  }

  Future<void> loadAssets() async {
    //이미지 선택 및 카메라 환경 설정
    setState(() {
      images = List<Asset>();
    });
    List<Asset> resultList;
    String error;

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 3, //최대 이미지 갯수
        enableCamera: true, //카메라 활성화
        materialOptions: MaterialOptions(
          //안드로이드 커스텀
          actionBarTitle: "Action bar",
          allViewTitle: "All view title",
          actionBarColor: "#aaaaaa",
          actionBarTitleColor: "#bbbbbb",
          lightStatusBar: false,
          statusBarColor: '#abcdef',
          startInAllView: true,
          selectCircleStrokeColor: "#000000",
          selectionLimitReachedText: "이미지는 3장만 선택 가능합니다.",
        ),
        cupertinoOptions: CupertinoOptions(
          //아이폰 커스텀
          selectionFillColor: "#ff11ab",
          selectionTextColor: "#ffffff",
          selectionCharacter: "✓",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() {
      images = resultList;
      picCnt = 0;
      if (error == null) _error = 'No Error Dectected';
    });
  }

  Future<bool> onBackPressed() {
    //뒤로가기 앱 종료
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Text("수정을 종료 하시겠습니까?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("아니오"),
                  onPressed: () => Navigator.pop(context, false),
                ),
                FlatButton(
                  child: Text("예"),
                  onPressed: () => Navigator.pop(context, true),
                )
              ],
            ));
  }
}
