import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:any_rent/settings/url.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:any_rent/mypage/detail/mytown/mypage_mytown.dart';
import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';
import '../main_home.dart';
import 'register_items.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:any_rent/settings/size_config.dart';
import '../login/login.dart';
import 'register_server.dart';
import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:date_format/src/locale/locale.dart';

// const url = 'http://211.253.20.112'; //개발서버
// const url = "http://192.168.1.3:4001"; //재승 내부 ip
const url = UrlConfig.url;


class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}


class _RegisterState extends State<Register> {
  double _height;
  double _width;
  String _setTime, _setDate, _hour,_minute,_time;
  String dateTime;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00,);
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  Future<Null>_selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        // locale: Locale('kr'),
        // locale: ,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2021),
        lastDate: DateTime(2100));
    if(picked != null)
      setState(() {
        selectedDate = picked;
        print("selectedDate ============");
        print(selectedDate.toString());
        print("selectedDate ============");

        _dateController.text =
            DateFormat.yMd('ko_KR').format(selectedDate);
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

        String asd = selectedTime.toString().substring(10,15);
        print(asd);
        print("selectedTime ============");

        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        _timeController.text = _time;


        print("_time =========== $_time");

        _timeController.text = formatDate(
            DateTime(2019, 08, 1, selectedTime.hour, selectedTime.minute),
            [hh, ':', nn, " ", am]).toString();
      });
  }

  @override
  void initState(){
    _dateController.text = DateFormat.yMd().format(DateTime.now());

    _timeController.text = formatDate(
        DateTime(2019, 08, 1, DateTime.now().hour, DateTime.now().minute),
        [hh, ':', nn, " ", am]).toString();
    super.initState();
    loadToken();
  }


  String token, jobTp1, jobTp2, twnCd, twnGc, jobStDtm, bidDlDtm, jobAmt, aucMtd, payMtd, jobTtl, jobCtn, hanGnd, townCd1, townCd2, townNm1, townNm2, auctionTimeString;
  int auctionTime = 600;
  String people = "1";
  bool state = true;
  List<Map> areaItems = [];
  Map <String, dynamic> addressResult;
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

  final _controller = TextEditingController();
  AnimationController controller;
  static const _locale = 'ko';
  String _formatNumber(String s) => NumberFormat.decimalPattern(_locale).format(int.parse(s));
  String get _currency => NumberFormat.compactSimpleCurrency(locale: _locale).currencySymbol;
  final navigatorKey = GlobalKey<NavigatorState>();


  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
  }

  loadToken() async{ //동네등록 확인여부 및 동네 리스트 가져오기
    token = await customSharedPreferences.getString('token');
    state = await customSharedPreferences.getBool('state');
    setState(() { state = state; token = token;});
    if(state){
      try{
        String result = await registerServer.getTown(token);
        if(result == 'error')  { return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.'))); }
        print('loadToken result =============== $result');
        addressResult = jsonDecode(result);
        bool setRegister = addressResult['code'];
        // print('setRegister =============== $setRegister');
        if(!setRegister){ //등록 동네 없을시 동네 등록 페이지 이동
          return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("동네가 등록 되있지 않습니다."),
                content:const Text('동네를 등록해 주세요.'),
                actions: <Widget>[
                  FlatButton(child: Text('동네 등록으로 이동'),
                    onPressed: () { //동네가 등록 되있지 않을 시 동네 등록 페이지로 이동한다.
                      Navigator.pop(context, false);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyPageDetailMyTown(token: token,)));
                    },
                  ),
                ],
              );
            },
          );
        }
        townCd1 = addressResult['list']['townCd1']; //동네 가져와서 map 으로 집어 넣는다.
        townNm1 = addressResult['list']['townNm1'];
        townCd2 = addressResult['list']['townCd2'];
        townNm2 = addressResult['list']['townNm2'];
        if(townCd1 != null){ if(!isDisposed)  setState(() { areaItems.add({"id": townCd1, "name" : townNm1}); }); }
        if(townCd2 != null){ if(!isDisposed)  setState(() { areaItems.add({"id": townCd2, "name" : townNm2}); }); }
        String tp1Result  = await registerServer.getTp(); //카테고리 1 가져오기
        if(tp1Result == 'error')  { return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.'))); }
        if(!isDisposed)  {setState(() { tp1List =  jsonDecode(tp1Result); });}
        // print('tp1List ======================== $tp1List');
      } catch(e){
        globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
      }
    }
  }

  sendRegister () async{
    print('등록');
    if(jobTp1 == null) { return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('카테고리 1을 선택해 주세요.'))); }
    if(jobTp2 == null) { return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('카테고리 2을 선택해 주세요.'))); }
    if(aucMtd == '2') { if(auctionTimeString == null) { return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('입찰 마감시간을 선택해 주세요.'))); } }
    if(jobAmt == null){return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('금액을 입력해 주세요.'))); }
    if(jobAmt == '0'){return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('금액은 0 원 이상이여야 합니다.'))); }
    if(jobStDtm == null) { return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('시간을 선택해 주세요.'))); }
    if(twnCd == null) { return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('동네를 선택해 주세요.'))); }
    if(jobTtl == null) {return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('제목을 입력하세요.'))); }
    if(jobCtn == null) {return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('상세내용을 입력하세요.'))); }
    if(twnGc == null) { setState(()=> twnGc = "1"); }
    if(aucMtd == null) { setState(()=> aucMtd = "1"); }
    if(payMtd == null) { setState(()=> payMtd = "1"); }
    if(hanGnd == null) { setState(()=> hanGnd = "0"); }

    final form = formKey.currentState;
    if(form.validate()){
      form.save();
    }


    print('jobTp1 ===================== $jobTp1');
    print('jobTp2 ===================== $jobTp2');
    print('aucMtd ===================== $aucMtd');
    print('payMtd ===================== $payMtd');
    print('people ===================== $people');
    print('twnCd ===================== $twnCd');
    print('twnGc ===================== $twnGc');
    print('jobStDtm ===================== $jobStDtm');
    print('jobAmt ===================== $jobAmt');
    print('jobTtl ===================== $jobTtl');
    print('jobCtn ===================== $jobCtn');
    print('images ===================== $images');
    print('hanGnd ===================== $hanGnd');
    print(images.length);
    print('=======================================');


    try{

      Uri uri = Uri.parse('$url/api/service/regiService');
      http.MultipartRequest request = new http.MultipartRequest('POST', uri);

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
      request.fields['picCnt'] = images.length.toString();

      if(aucMtd == '2') { //입찰방식 입찰식 일시 서보로 보내기 위한 setting
        print('입찰 방식 입찰식');
        var now = new DateTime.now();
        var auctionTimeFromNow = now.add(new Duration(seconds: auctionTime));
        print('auctionTimeFromNow ================= $auctionTimeFromNow');
        print('start ================= $start');
        print('jobStDtm ================= $jobStDtm');
        bidDlDtm = auctionTimeFromNow.toString().substring(0,16);
        print('bidDlDtm ================= $bidDlDtm');
        // print(start > auctionTimeFromNow);

        int compare = start.compareTo(auctionTimeFromNow); //날짜 비교 작업 시작날짜와 입찰 날짜 비교
        if (compare < 0 ){
          print('start < auctionTimeFromNow  $start < $auctionTimeFromNow');
          return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('입찰 마감시간보다 시작 시간이 빠릅니다.')));
        }
        request.fields['bidDlDtm'] = bidDlDtm;
        print('=======================================입찰식 업로드?');
      }
      //여러 이미지 업로드를 위한 반복문
      for (int i = 0; i < images.length; i++) {
        // ByteData byteData = await images[i].getByteData();
        print('images ===============================================================');
        print(images[i].originalHeight);
        print(images[i].originalWidth);
        ByteData byteData = await images[i].getThumbByteData(images[i].originalWidth, images[i].originalHeight, quality: 30);
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

      print('일거리 등록 전송');
      if(!isDisposed)  setState(() => isHttpSend = true );
      await request.send().then((response) {
        print('=======================================response');
        print(response.statusCode);
        if(response.statusCode != 200 ) { return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.'))); }
        if(!isDisposed)  setState(() => isNextPage = true );
        Future.delayed(Duration(seconds: 1), () async{
          return Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MyHomePage(index: 0,)), (route) => false);
        });
      });

    } catch(e){
      globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    CircularProgressIndicator();
    // return Scaffold( body: Center(child: Container( width: defaultSize * 10, height: defaultSize * 10, color: Colors.white, child: CircularProgressIndicator())) );
    return isHttpSend ?  Scaffold( key: globalKey, body: SizedBox.expand( child: Container( color: Colors.grey[50],  child: Center(child:
    isNextPage ?
      AlertDialog(
        title: Center(child: Text('정상 등록 되었습니다!', style: TextStyle(fontSize: defaultSize * 2),)),
      ) : CircularProgressIndicator(),
    ) ), ), ):
     state ? Scaffold(
      key: globalKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('등록하기', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
        actions: <Widget>[
          FlatButton(onPressed: sendRegister,
              textColor: Colors.black,
              child: Text("소일등록",style: TextStyle(fontSize: 17.0),),)
        ],
      ),
      body: ListView(
        children: [
          Form(
            key: formKey,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CircularProgressIndicator(),
                  Container(
                    padding: EdgeInsets.fromLTRB(defaultSize * 2.5, defaultSize * 2, defaultSize, defaultSize),
                    child: Text('카테고리', style: TextStyle(fontWeight: FontWeight.bold , fontSize: defaultSize * 1.8),),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: defaultSize, right: defaultSize),
                          height: 40,
                          width: 130,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0), // 동그라미 모양
                              color: Colors.lightGreen
                          ),
                          child: (tp1List != null) ?
                          DropdownButton(
                            isExpanded: false,
                            items: tp1List.map((item) {
                              return  DropdownMenuItem(
                                  child: Padding( padding: EdgeInsets.symmetric(horizontal: defaultSize), child: Text( item['tp1Nm'], style: TextStyle(color: Colors.white,fontSize: defaultSize * 1.6,fontWeight: FontWeight.bold)), ),
                                  value: item['tp1Cd']
                              );
                            }).toList(),
                            underline: Container(),
                            onChanged: (value) {
                              setState(() { jobTp1 = value; });
                              print('jobTp1 ======== $jobTp1');
                              getTp2();
                            },
                            hint:  Text(('카테고리1'),style: TextStyle(color: Colors.lightGreen[100],fontSize: 17)),
                            dropdownColor: Colors.lightGreen,
                            value:jobTp1,
                            iconEnabledColor: Colors.amber,
                          ) : Padding( padding: EdgeInsets.symmetric(horizontal: 5.0), child: SizedBox( width: defaultSize, height: defaultSize, child: CircularProgressIndicator(), ),),
                        ),
                        SizedBox( width: defaultSize * 2, ),
                        Container(
                          padding: EdgeInsets.only(left: defaultSize, right: defaultSize),
                          height: 40,
                          width: 130,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0), // 동그라미 모양
                              color: Colors.lightGreen,
                          ),
                          child: DropdownButton(
                            isExpanded: false,
                            items: (tp2List != null) ?
                            tp2List.map((item) {
                              return  DropdownMenuItem(
                                  child: Padding( padding: EdgeInsets.symmetric(horizontal: defaultSize),  child: Text( item['tp2Nm'],  style: TextStyle(color: Colors.white,fontSize: defaultSize * 1.6,fontWeight: FontWeight.bold) ), ),
                                  value: item['tp2Cd']
                              );
                            }).toList() : [],
                            underline: Container(),
                            onChanged: (value) {
                              setState(() { jobTp2 = value; });
                              print('jobTp2 ======== $jobTp2');
                            },
                            hint:  Text(('카테고리2'),style: TextStyle(color: Colors.lightGreen[100],fontSize: defaultSize * 1.7)),
                            dropdownColor: Colors.lightGreen,
                            value:jobTp2,
                            iconEnabledColor: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Divider(),
                  Container(
                    padding: EdgeInsets.fromLTRB(defaultSize * 2.5, defaultSize , defaultSize, defaultSize),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('입찰방식', style: TextStyle(fontWeight: FontWeight.bold , fontSize: defaultSize * 1.8),),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Expanded(
                              flex: 0,
                                child:Container(
                                  margin: EdgeInsets.only(left: 27),
                                  padding: EdgeInsets.only(left: defaultSize, right: defaultSize),
                                  height: 40,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0), // 동그라미 모양
                                      color: Colors.lightGreen,
                                  ),
                                  child:    DropdownButton(
                                    items: registerItems.auctionMethod.map((item) {
                                      return  DropdownMenuItem(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: defaultSize),
                                          child: Text( item['name'],  style: TextStyle(fontSize: defaultSize * 1.7,color: Colors.white,) ), ),
                                        value: item['id'],
                                      );
                                    }).toList(),
                                    underline: Container(),
                                    onChanged: (value) { setState(() { aucMtd = value; }); print('aucMtd ======== $aucMtd'); },
                                    hint:  Text(registerItems.auctionMethod[0]["name"],style: TextStyle(fontSize: defaultSize * 1.7,color: Colors.white)),
                                    dropdownColor: Colors.lightGreen,
                                    value:aucMtd,
                                    iconEnabledColor: Colors.amber, //화살표 색
                                  ),
                                ),
                            ),SizedBox(width: 50,),
                            Container(padding: EdgeInsets.only(left: defaultSize,top: defaultSize),
                                width: 160,
                                height: 40,
                                child:
                            Expanded(flex: 4,  child: (aucMtd == '2')
                                ?  InkWell( child: Text(auctionTimeString
                                ?? '터치 후 압찰시간 선택', style: TextStyle(fontSize: defaultSize * 1.7,fontWeight: FontWeight.bold,color: Colors.lightGreen[700])),
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
                    padding: EdgeInsets.fromLTRB(defaultSize * 2.5, defaultSize * 1, defaultSize, defaultSize ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('결제', style: TextStyle(fontWeight: FontWeight.bold , fontSize: defaultSize * 1.8),),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text('결제', style: TextStyle(fontSize: defaultSize * 1.6),),
                            ),
                            Expanded( flex: 4,
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(prefixText: _currency),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (string) {
                                  string = '${_formatNumber(string.replaceAll(',', ''))}';
                                  _controller.value = TextEditingValue(
                                    text: string,
                                    selection: TextSelection.collapsed(offset: string.length), );
                                  print('jobAmt ================== $string');
                                  setState(()=> jobAmt = string);
                                },
                              ),
                            ),
                            Expanded( flex: 2,
                              child:DropdownButton(
                                items: registerItems.paymentItmes.map((item) {
                                  return  DropdownMenuItem(
                                      child: Text( item['name'],  style: TextStyle(fontSize: defaultSize * 1.7,) ),
                                      value: item['id']
                                  );
                                }).toList(),
                                underline: Container(),
                                onChanged: (value) { setState(() { payMtd = value; }); print('payMtd ======== $payMtd'); },
                                hint:  Text(registerItems.paymentItmes[0]["name"],style: TextStyle(fontSize: defaultSize * 1.7)),
                                value:payMtd,
                                iconEnabledColor: Colors.amber, //화살표 색
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                    padding: EdgeInsets.fromLTRB(defaultSize * 2.5, defaultSize , defaultSize, defaultSize),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('날짜', style: TextStyle(fontWeight: FontWeight.bold , fontSize: defaultSize * 1.8),),
                        SizedBox(height: 10,),
                        Padding(padding: EdgeInsets.only(top: 10)),
                        Row(
                          children: [
                            Expanded(flex: 2 ,child: Text('시작일', style: TextStyle(fontSize: defaultSize * 1.6),),),
                            Expanded( flex: 6 ,
                              child: Padding( padding: EdgeInsets.only(right: defaultSize * 2),
                                child: InkWell(
                                  onTap: (){
                                    _selectDate(context);
                                    },
                                  child: Container(
                                  width: 200,
                                  height: 30,
                                  margin: EdgeInsets.only(top: 0),
                                  alignment: Alignment.center,
                                  // decoration: BoxDecoration(border:Border.all(color: Colors.grey)),
                                  child: TextFormField(
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                    enabled: false,
                                    keyboardType: TextInputType.text,
                                    controller: _dateController,
                                    onSaved: (String val) {
                                      _setDate = val;
                                    },
                                    decoration: InputDecoration(
                                        disabledBorder:
                                        UnderlineInputBorder(borderSide: BorderSide.none),
                                        // labelText: 'Time',
                                        contentPadding: EdgeInsets.only(top: 0.0)),
                                  ),
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
                    padding: EdgeInsets.all(20.0),
                    child:Row(
                      children: [
                        Text('시작 시간'),
                        InkWell(
                          onTap: () {
                            _selectTime(context);
                          },
                          child:
                          Container(
                            margin: EdgeInsets.only(left:45),
                            width: _width / 1.7,
                            height: 20,
                            alignment: Alignment.center,
                            child: Text( selectedTime.format(context) ?? '시작시간을 선택하세요.',
                              style:  TextStyle(fontSize: 20),
                              textAlign: TextAlign.right, ),
                          ),
                        )
                      ],
                    )
                  ),
                  Divider(),
                  Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(padding: EdgeInsets.fromLTRB(defaultSize*2.5,defaultSize,defaultSize,defaultSize)),
                            Expanded(flex: 1, child: Text('동네', style: TextStyle(fontWeight: FontWeight.bold , fontSize: defaultSize * 1.8),),),
                            Expanded( flex: 2,
                              child: (areaItems == null) ? Padding( padding: EdgeInsets.symmetric(horizontal: 5.0), child: SizedBox( width: defaultSize, height: defaultSize, child: CircularProgressIndicator(), ),) :
                              DropdownButton(
                                items: (areaItems != null) ?
                                areaItems.map((item) {
                                  return  DropdownMenuItem(
                                      child: Text( item['name'],  style: TextStyle(fontSize: defaultSize * 1.7,) ),
                                      value: item['id']
                                  );
                                }).toList() : [],
                                underline: Container(),
                                onChanged: (value) { setState(() { twnCd = value; }); print('twnCd ======== $twnCd'); },
                                hint: Text('동네', style: TextStyle(fontSize: defaultSize * 1.7)),
                                value:twnCd,
                                iconEnabledColor: Colors.amber, //화살표 색
                              ),
                            ),
                            Expanded(flex: 2, child: Text('범위', style: TextStyle(fontWeight: FontWeight.bold , fontSize: defaultSize * 1.8),),),
                            Expanded( flex: 2,
                              child:DropdownButton(
                                items: registerItems.rangeItems.map((item) {
                                  return  DropdownMenuItem(
                                      child: Text( item['name'],  style: TextStyle(fontSize: defaultSize * 1.7,) ),
                                      value: item['id']
                                  );
                                }).toList(),
                                underline: Container(),
                                onChanged: (value) { setState(() { twnGc = value; }); print('twnGc ======== $twnGc'); },
                                hint:  Text(registerItems.rangeItems[0]["name"],style: TextStyle(fontSize: defaultSize * 1.7)),
                                value:twnGc,
                                iconEnabledColor: Colors.amber, //화살표 색
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(padding: EdgeInsets.fromLTRB(defaultSize*2.5,defaultSize,defaultSize,defaultSize)),
                            Expanded(flex: 1, child: Text('희망성별', style: TextStyle(fontWeight: FontWeight.bold , fontSize: defaultSize * 1.8),),),
                            Expanded( flex: 2,
                              child:DropdownButton(
                                items: registerItems.genderItems.map((item) {
                                  return  DropdownMenuItem(
                                      child: Text( item['name'],  style: TextStyle(fontSize: defaultSize * 1.7,) ),
                                      value: item['id']
                                  );
                                }).toList(),
                                underline: Container(),
                                onChanged: (value) { setState(() { hanGnd = value; }); print('hanGnd ======== $hanGnd'); },
                                hint:  Text(registerItems.genderItems[0]["name"],style: TextStyle(fontSize: defaultSize * 1.7)),
                                value:hanGnd,
                                iconEnabledColor: Colors.amber, //화살표 색
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                    padding: EdgeInsets.fromLTRB(defaultSize * 2.5, defaultSize * 3, defaultSize, defaultSize * 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('일내용', style: TextStyle(fontWeight: FontWeight.bold , fontSize: defaultSize * 1.8),),
                        Padding(
                          padding: EdgeInsets.all(defaultSize * 1.3),
                          child: TextFormField(
                            decoration: InputDecoration(labelText: '제목을 입력하세요.'),
                            validator: (value){
                              if (value.trim().isEmpty){ return '공백은 입력할 수 없습니다.'; }
                              if (value.isEmpty) { return '제목을 입력해 주세요.'; } else  return null; },
                            onChanged: (value){ print('value =============$value'); setState(() => jobTtl = value );},
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(defaultSize * 1.3),
                          child: TextFormField(
                            decoration: InputDecoration(labelText: '상세내용을 입력하세요.'),
                            maxLines: 6,
                            validator: (value){
                              if (value.trim().isEmpty){ return '공백은 입력할 수 없습니다.'; }
                              if (value.isEmpty) { return '상세내용을 입력하세요.'; } else  return null; },
                            onChanged: (value){ print('value =============$value'); setState(() => jobCtn = value );},
                            onSaved: (value){ jobCtn = value; },
                          ),
                        ),
                        Column(
                          children: [
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: [
                            //
                            //   ],
                            // ),
                            SizedBox( height: defaultSize * 45,  child: (images.length > 0) ? InkWell( onTap: loadAssets, child: buildGridView()) :
                              InkWell(
                                onTap: loadAssets,
                                child: Container( padding: EdgeInsets.only(top: defaultSize * 2),
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
                            // Container(
                            //   width: defaultSize * 20, height: defaultSize * 8,
                            //   decoration: BoxDecoration(
                            //   color: Colors.blueAccent[700],
                            //     boxShadow: [
                            //       BoxShadow(
                            //         color: Colors.amber[100],
                            //         blurRadius: 5.0,
                            //         spreadRadius: 3.0
                            //       )
                            //     ],
                            //     borderRadius: BorderRadius.circular(30.0), ),
                            //   child: FlatButton(
                            //     child: Text('소일 등록 !', style: TextStyle(fontSize: defaultSize * 2.5,color: Colors.white)),
                            //     onPressed: sendRegister,
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ): Login();
  }

  getTp2() async { //카테고리 1에 값으로 카테고리 2 가져오기
    String result = await registerServer.getTp2(jobTp1);
    if(result == 'error')  { return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.'))); }
    setState(() { tp2List = jsonDecode(result); });
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
              pagination: SwiperPagination( alignment: Alignment.bottomRight, ),
              itemCount: images.length,
              itemBuilder: (BuildContext context, int index){
                Asset asset = images[index];
                return AssetThumb(
                  asset: asset,
                  width: images[index].originalWidth,
                  height: images[index].originalHeight,
                );
              }
          ),
        ),
      );
    else
      return Container(color: Colors.white);
  }

  Future<void> loadAssets() async { //이미지 선택 및 카메라 환경 설정
    setState(() { images = List<Asset>(); });
    List<Asset> resultList;
    String error;

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 3, //최대 이미지 갯수
        enableCamera: true, //카메라 활성화
        materialOptions: MaterialOptions( //안드로이드 커스텀
          // actionBarTitle: "Action bar",
          allViewTitle: "등록 사진고르기",
          actionBarColor: "#aaaaaa",
          actionBarTitleColor: "#bbbbbb",
          lightStatusBar: false,
          statusBarColor: '#abcdef',
          startInAllView: true,
          selectCircleStrokeColor: "#000000",
          selectionLimitReachedText: "이미지는 3장만 선택 가능합니다.",
        ),
        cupertinoOptions: CupertinoOptions( //아이폰 커스텀
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
      if (error == null) _error = 'No Error Dectected';
    });
  }

}