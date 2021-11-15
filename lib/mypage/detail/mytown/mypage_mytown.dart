import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../settings/size_config.dart';
import '../mypage_detail_appbar.dart';
import 'package:android_intent/android_intent.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import '../../mypage_server.dart';
import '../../../permission/gps_permission.dart';

class MyPageDetailMyTown extends StatefulWidget {
  MyPageDetailMyTown({Key key, this.token}) : super(key: key);
  final String token;
  @override
  _MyPageDetailMyTownState createState() => _MyPageDetailMyTownState();
}

class _MyPageDetailMyTownState extends State<MyPageDetailMyTown> {
  double defaultSize = SizeConfig.defaultSize;
  String latitude, longitude, token, addressLine, subLocality, thoroughfare, insertYn, cert1, cert2, substringCert1, substringCert2;
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
              title: Text("GPS 가 활성화 되있지 않습니다."),
              content:const Text('GPS 를 활성화 시켜주세요.'),
              actions: <Widget>[
                FlatButton(child: Text('Ok'),
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
          padding: EdgeInsets.all(defaultSize * 2),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(defaultSize * 2),
                    child: Column(
                      children: [
                        Text('동네', style: TextStyle( fontSize:  defaultSize * 1.8),),
                        Text(cert ?? '' , style: TextStyle( fontSize:  defaultSize * 1.4),),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(defaultSize * 2),
                    child: Column(
                      children: [
                        Text('인증횟수' , style: TextStyle( fontSize:  defaultSize * 1.8),),
                        (cnt != null) ?  Text('$cnt', style: TextStyle( fontSize:  defaultSize * 1.4),) : Text('0', style: TextStyle( fontSize:  defaultSize * 1.4),),
                      ],
                    ),
                  ),
                  IconButton(icon: Icon(Icons.clear, color: Colors.amber,), onPressed: ()=> removeAddressDialog(reCert, type)),
                ],
              ),
            ],
          )
      );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      body: Column(
        children: [
          MyPageDetailAppbar( title: '내 동네',),
          Expanded( flex: 2,
            child: Container(
              margin: EdgeInsets.all(20.0),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( '현재위치\n',  style: TextStyle( fontSize: defaultSize * 2.6,  fontWeight: FontWeight.bold ), ),
                    Text( (thoroughfare == null) ? '죄송합니다. 현재 위치정보를 가져올 수 없습니다. 다시 시도해 주세요.' : '' , style: TextStyle( fontSize: defaultSize * 1.9, ),),
                    Divider(),
                    Row(
                      children: [
                        Expanded( flex: 4, child: Text( (thoroughfare != null) ? '현재위치) $thoroughfare' : '', style: TextStyle( fontSize: defaultSize * 2, ), ) ),
                        Expanded( flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.lightGreen[400],
                              borderRadius: BorderRadius.circular(35),
                            ),
                            child:permission ?
                            FlatButton( child: Text( '등록',  style: TextStyle( color: Colors.white, ), ), onPressed: () => _sendAddress(),) :
                              FlatButton( child: Text( '새로고침',  style: TextStyle( color: Colors.white, ), ), onPressed: () => getGpsPermission() ,),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 200,left: 20),
              child: Column(
                children: [
                  (substringCert1 == null) ? Container() : reCertText2(substringCert1, townCnt1, cert1, true),
                  (substringCert2 == null) ? Container() : reCertText2(substringCert2, townCnt2, cert2, false),
                ],
              ),
          ),
          Expanded( flex: 1,
            child: Container(
              child: Center(
                child:  Container(
                  width: defaultSize * 27,
                  decoration: BoxDecoration(
                      color: Colors.lightGreen[400],
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: FlatButton(
                    child: Text( '인증',  style: TextStyle( color: Colors.white, ), ),
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
              title: Text("동네를 삭제하시겠습니까?."),
              content:const Text('동네를 삭제하시면 \n인증횟수가 초기화 됩니다.'),
              actions: <Widget>[
                FlatButton(child: Text('예'),
                  onPressed: ()=> removeAddress(reCert, type),
                ),
                FlatButton(child: Text('아니요'),
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