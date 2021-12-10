import 'dart:convert';

import 'package:any_rent/settings/url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import '../../../settings/size_config.dart';
import '../mypage_detail_appbar.dart';
import 'package:android_intent/android_intent.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import '../../mypage_server.dart';
import '../../../permission/gps_permission.dart';

const mapUrl = UrlConfig.url+'/api/mypage/kakaoMap';

class MyPageDetailMyTown extends StatefulWidget {
  MyPageDetailMyTown({Key key, this.token}) : super(key: key);
  final String token;
  @override
  _MyPageDetailMyTownState createState() => _MyPageDetailMyTownState();
}

class _MyPageDetailMyTownState extends State<MyPageDetailMyTown> {
  double defaultSize = SizeConfig.defaultSize;
  String latitude, longitude, token, addressLine, subLocality, thoroughfare, insertYn, cert1, cert2, substringCert1, substringCert2, kakaoMapUrl;
  int townCnt1, townCnt2;
  String reCert11 = '양재동';
  String reCert12 = '1';
  bool permission = false;
  Map <String, dynamic> address, certification;
  final globalKey = GlobalKey<ScaffoldState>();
  bool isDisposed = false;


  @override
  void initState() {
    super.initState();
    getGpsPermission();
    token = widget.token;
    getAddress();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  getAddress() async {
    String result = await myPageServer.getAddress(token);
    print('result =================== $result');
    if(result == 'error') { return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.'))); }
    address = jsonDecode(result);
    if(!isDisposed) {
      setState(() {
        cert1 = address['reCert1'];
        cert2 = address['reCert2'];
        if(cert1 != null){ substringCert1 = cert1.substring(10); }
        if(cert2 != null){ substringCert2 = cert2.substring(10); }
        townCnt1 = address['townCnt1'];
        townCnt2 = address['townCnt2'];
      });
    }
    // print('substringCert1 =============== $substringCert1');
    // print('substringCert2 =============== $substringCert2');
    // print('townCnt1 =============== $townCnt1');
    // print('townCnt2 =============== $townCnt2');
    print('=======22222=====$cert1');
    print('=======22222=====$cert2');
  }


  getGpsPermission() async{
    permission = await gpsPermission.requestLocationPermission(context);
    setState(() => permission);
    if(permission) {
      gpsService();
    }
  }

  Future gpsService() async {
    if(!await Geolocator().isLocationServiceEnabled()) {
      print('gps off');
      checkGps();
    } else {
      print('gps on');
      var position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      final coordinates = new Coordinates(position.latitude, position.longitude);
      var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;
      if(!isDisposed) {
        setState(() {
          latitude = position.latitude.toString();
          longitude = position.longitude.toString();
          addressLine = first.addressLine;
          subLocality = first.subLocality;
          thoroughfare = first.thoroughfare;
        });
      }
      print('latitude =============== $latitude');
      print('longitude =============== $longitude');

      setState(() {
        kakaoMapUrl = mapUrl+'?latitude=$latitude&longitude=$longitude';
      });
    }
  }

  Future checkGps() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
              ),
              title: Text("GPS 가 활성화 되있지 않습니다."),
              content:const Text('GPS 를 활성화 시켜주세요.'),
              actions: <Widget>[
                FlatButton(child: Text('Ok',style: TextStyle(color: Colors.lightGreen[800],fontSize: defaultSize * 2),),
                  onPressed: () {
                    final AndroidIntent intent = AndroidIntent( action: 'android.settings.LOCATION_SOURCE_SETTINGS');
                    intent.launch();
                    Navigator.of(context, rootNavigator: true).pop();
                    Future.delayed(Duration(seconds: 3), () async{
                      if(!await Geolocator().isLocationServiceEnabled()) gpsService();
                    });
                  },
                ),
              ],
            );
          },
        );
      }}}

  _sendAddress() async{
    debugPrint('등록');
    if( addressLine == null){ return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.'))); }
    String result =  await myPageServer.sendAddress(token, latitude, longitude);
    // String result =  await myPageServer.sendAddress(token, "37.4890847", "127.0933093");
    if(result == 'error') { return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.'))); }
    address = jsonDecode(result);
    insertYn = address['insertYn'];
    print('address =============== $address');
    print('insertYn =============== $insertYn');
    if( insertYn == 'SAME') { return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('이미 등록된 장소입니다.'))); }
    if( insertYn == 'FALSE') { return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('동네인증은 2곳만 가능합니다.'))); }
    address = jsonDecode(result);
    if(!isDisposed) {
      setState(() {
        cert1 = address['twnCdNm1'];
        cert2 = address['twnCdNm2'];
        if(cert1 != null){ substringCert1 = cert1.substring(10); }
        if(cert2 != null){ substringCert2 = cert2.substring(10); }
        townCnt1 = address['townCnt1'];
        townCnt2 = address['townCnt2'];
      });
    }
    print('_sendAddress reCert1 =============== $cert1');
    print('_sendAddress reCert2 =============== $cert2');
    print('_sendAddress townCnt1 =============== $townCnt1');
    print('_sendAddress townCnt2 =============== $townCnt2');
  }


  Widget reCertText2(String cert, int cnt, String reCert, bool type){
    return (cert == null) ? Container() :
      Container(
        // decoration: BoxDecoration(
        //   color: Colors.lightBlueAccent.withOpacity(0.1)
        // ),
        margin: EdgeInsets.only(left: defaultSize),
        // color: Colors.red.withOpacity(0.3),
          padding: EdgeInsets.only(left:defaultSize *2 ,right: defaultSize *2),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    // padding: EdgeInsets.all(defaultSize * 2),
                    child: Row(
                      children: [
                        // Container(
                        //   // decoration: BoxDecoration(
                        //   //     color: Colors.red.withOpacity(0.1)
                        //   // ),
                        // child:
                        // Text('동네 : ', style: TextStyle( fontSize:  defaultSize * 1.8),)
                        // ),
                        Container(
                          margin: EdgeInsets.only(right: defaultSize * 5.4),
                          padding: EdgeInsets.only(top: defaultSize * 1.6,),
                        height: defaultSize * 4,
                        //     decoration: BoxDecoration(
                        //     color: Colors.red.withOpacity(0.1)
                        // ),
                        child: Text(cert ?? '' , style: TextStyle( fontSize:  defaultSize * 1.8),)),
                        Container(
                          height: defaultSize * 4,
                              width: defaultSize * 4,
                              padding: EdgeInsets.only(top: defaultSize * 1.7),
                          //     decoration: BoxDecoration(
                          //     color: Colors.red.withOpacity(0.1)
                          // ),
                          child:
                              // Text('인증횟수 : ' , style: TextStyle( fontSize:  defaultSize * 1.8),),
                              // SizedBox(width: defaultSize * 1,),
                              Container(child: (cnt != null) ?  Text('$cnt', style: TextStyle( fontSize:  defaultSize * 1.8,color: Colors.lightGreen[700],fontWeight: FontWeight.bold),textAlign: TextAlign.center,) : Text('0', style: TextStyle( color: Colors.lightGreen[700],fontSize:  defaultSize * 1.8,fontWeight: FontWeight.bold),textAlign: TextAlign.center)),

                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: defaultSize * 6.3,),
                  Container(
                    margin: EdgeInsets.only(top: defaultSize * 0.8),
                    height: defaultSize * 4,
                      width: defaultSize * 8.5,
                      decoration: BoxDecoration(color: Colors.pink,borderRadius: BorderRadius.circular(15)),
                      child: FlatButton(child: Text('삭제',style: TextStyle(fontSize: defaultSize * 2,color: Colors.white),),onPressed: ()=> removeAddressDialog(reCert, type),))
                  // IconButton(icon: Icon(Icons.clear, color: Colors.amber,), onPressed: ()=> removeAddressDialog(reCert, type)),
                ],
              ),
            ],
          )
      );
  }

  Widget getMap(String latitude, String longitude){
    return WebviewScaffold(
      url: kakaoMapUrl,
      ignoreSSLErrors: true, // https 이나 인증서가 정상적이지 않는 경우 하얀 화면이 뜨는데 그것을 없애 주는 것
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppBar(centerTitle:true,title: Text("내 동네"),
      // actions: [FlatButton(onPressed: ()=> certificationAddress(), child: Text("동네인증"))]
        ),

      body: Column(
        children: [
          Container(
            child: Container(
              // decoration: BoxDecoration(
              //     color: Colors.red.withOpacity(0.1)
              // ),
              margin: EdgeInsets.all(20.0),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: defaultSize * 1,),
                    Row(
                      children: [
                        Expanded( flex: 4, child: Text( (thoroughfare != null) ? '현재위치) $thoroughfare' : '', style: TextStyle( fontSize: defaultSize * 2, ), ) ),
                        Expanded( flex: 2,
                          child: Container(
                            height: defaultSize * 4.5,
                            width: defaultSize * 12,
                            decoration: BoxDecoration(
                              color: Colors.lightGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child:permission ?
                            FlatButton( child: Text( '등 록',  style: TextStyle( color: Colors.white,fontWeight: FontWeight.bold ), ), onPressed: () => _sendAddress(),) :
                              FlatButton( child: Text( '새로고침',  style: TextStyle( color: Colors.white, fontWeight: FontWeight.bold), ), onPressed: () => getGpsPermission() ,),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(),
                        Container(
                          padding: EdgeInsets.only(top: defaultSize * 1),
                          child: Text( (thoroughfare == null) ? '죄송합니다. 현재 위치정보를 가져올 수 없습니다. 다시 시도해 주세요.' : '' , style: TextStyle( fontSize: defaultSize * 1.5,color: Colors.pink ),),
                          width: defaultSize * 22.7,
                          height: defaultSize * 5,
                          // decoration: BoxDecoration(
                          //   color: Colors.red.withOpacity(0.3)
                          // ),
                        ),
                        Container(
                          width: defaultSize * 12,
                          height: defaultSize * 5,
                          // decoration: BoxDecoration(
                          // color: Colors.red.withOpacity(0.1)
                          // ),
                            padding: EdgeInsets.only(top: 12),
                            child: TextButton.icon(onPressed: () {setState(() {latitude = null;});
                            getGpsPermission();
                            }, icon: Icon(Icons.gps_fixed,size: 18,color: Colors.lightGreen[800],), label: Text("현재위치",style: TextStyle(color: Colors.lightGreen[800])))),
                      ],
                    ),



                    Container(
                      margin: EdgeInsets.only(top:defaultSize * 1),
                      height: defaultSize * 22,
                      width: defaultSize * 40,
                        child:  (latitude != null)  ?
                        getMap(latitude, longitude)
                            : Padding( padding: EdgeInsets.symmetric(horizontal: 5.0), child: SizedBox( width: defaultSize, height: defaultSize, child: CircularProgressIndicator(), ),),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
              width: defaultSize * 35,
              height: defaultSize * 20,
              // decoration: BoxDecoration(
              //   color: Colors.blue.withOpacity(0.1)
              // ),
            child: Column(
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Container( width: defaultSize * 10,
                              padding: EdgeInsets.only(top: defaultSize * 0.8,left: defaultSize * 3.5),
                              height: defaultSize * 3,
                              // decoration: BoxDecoration(
                              //     color: Colors.green.withOpacity(0.1)
                              // ),
                              child: Text('동 네',style: TextStyle(fontWeight: FontWeight.bold),),
                            ),
                            Container(
                              // margin: EdgeInsets.only(left: defaultSize * 2),
                              padding: EdgeInsets.only(top: defaultSize * 0.8,left: defaultSize * 2.3),
                              width: defaultSize * 10,
                              height: defaultSize * 3,
                              // decoration: BoxDecoration(
                              //     color: Colors.green.withOpacity(0.1)
                              // ),
                              child: Text('인증횟수',style: TextStyle(fontWeight: FontWeight.bold),),
                            ),
                          ],
                        ),
                        width: defaultSize * 35,
                      height: defaultSize * 3,
                        // decoration: BoxDecoration(
                        //     color: Colors.green.withOpacity(0.1)
                        // ),
                      ),
                      Container(
                        // decoration: BoxDecoration(
                        //   color: Colors.red.withOpacity(0.1)
                        // ),
                          child: (substringCert1 == null) ? Container() : reCertText2(substringCert1, townCnt1, cert1, true)),
                      SizedBox(height: defaultSize * 1.5,),
                      Container(
                          // decoration: BoxDecoration(
                          //     color: Colors.red.withOpacity(0.1)
                          // ),
                          child: (substringCert2 == null) ? Container() : reCertText2(substringCert2, townCnt2, cert2, false)),
                    ],
                  ),
          ),
          Container(
            child: Container(
              child: Center(
                child:  Container(
                  width: defaultSize * 12,
                  height: defaultSize * 4.5,
                  decoration: BoxDecoration(
                      color: Colors.lightGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FlatButton(
                    child: Text( '동네 인증',  style: TextStyle( color: Colors.white,fontWeight: FontWeight.bold ), ),
                    onPressed: ()=> certificationAddress(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future removeAddressDialog(String reCert, bool type) async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
              ),
              title: Text("동네를 삭제하시겠습니까?"),
              content:const Text('동네를 삭제하시면 \n인증횟수가 초기화 됩니다.'),
              actions: <Widget>[
                FlatButton(child: Text('예',style: TextStyle(color: Colors.lightGreen[800]),),
                  onPressed: ()=> removeAddress(reCert, type),
                ),
                FlatButton(child: Text('아니요',style: TextStyle(color: Colors.lightGreen[800])),
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                ),
              ],
            );
          },
        );
      }

  //동네 삭제
  Future removeAddress(String reCert, bool type) async {
    String twnCd = reCert.substring(0,10);
    setState(() { type ? substringCert1 = null : substringCert2 = null ; });
    String result = await myPageServer.removeAddress(token, twnCd);
    print('removeAddress result ==================== $result');
    if(result == 'error') {
      Navigator.of(context, rootNavigator: true).pop();
      return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
    }
    Navigator.of(context, rootNavigator: true).pop();
    return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('삭제되었습니다.')));
  }

  //동네 인증
  Future certificationAddress() async {
    String result =  await myPageServer.certificationAddress(token, latitude, longitude);
    // String result =  await myPageServer.certificationAddress(token, "37.4890847", "127.0933093");
    // String result =  await myPageServer.certificationAddress(token, "37.4710847", "127.0673093");
    print('certificationAddress result ==================== $result');
    if(result == 'error') { return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.'))); }
    certification = jsonDecode(result);
    print('certificationAddress certification ==================== $certification');
    print(certification['message']);
    String message = certification['message'];
    print('certificationAddress message ==================== $message');
    if(message == '03') { return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('인증 되지 않은 동네입니다. \n 동네인증 후 사용해 주세요.')));  }
    if(message == '05') { return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('동네인증은 하루에 한번 가능합니다.')));  }
    if(message == '01') { setState(() { townCnt1 = certification['townCnt1']; });}
    if(message == '02') { setState(() { townCnt2 = certification['townCnt2']; });}
    globalKey.currentState.showSnackBar(const SnackBar(content: const Text('인증 되었습니다.')));
    Future.delayed(Duration(seconds: 1), () async{
      Navigator.of(context, rootNavigator: true).pop();
    });
  }
}