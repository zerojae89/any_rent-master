import 'dart:convert';
import 'dart:math';

import 'package:any_rent/mypage/detail/mytown/mypage_mytown.dart';
import 'package:any_rent/register/register_server.dart';
import 'package:any_rent/settings/size_config.dart';
import 'package:flutter/material.dart';
import 'package:any_rent/home/home_item.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:android_intent/android_intent.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:any_rent/main_home.dart';
import '../permission/gps_permission.dart';
import 'package:any_rent/settings/custom_shared_preferences.dart';

import 'home_drop_itmes.dart';
import 'home_server.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String token, townCd1, townCd2, townNm1, townNm2, auctionTimeString, twnCd, latitude, longitude, thoroughfare, sortId;
  String jobId, jobTtl, aucMtd, jobStDtm, bidDlDtm, payMtd, jobIts, twnNm;
  int jobAmt, prfSeq;
  bool permission = true;
  bool isDisposed = false;
  bool gpsPermissionBool = true;
  Map <String, dynamic> addressResult, homeResultList;
  List<Map> areaItems = [];
  List<dynamic> homeItems = [];
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  final globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    loadPermission();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  loadPermission() async { //권한 여부 확인
    permission = await customSharedPreferences.getBool('permission');
    if(!isDisposed) { setState(() => permission); }  // SharedPreferences에 permission으로 저장된 값을 읽어 필드에 저장. 없을 경우 false
    //permisssion false 일경우 처음으로 돌아 간다.
    print('Home permission =============== $permission');
    if(permission) getGpsPermission();
  }

  getGpsPermission() async{
    gpsPermissionBool = await gpsPermission.requestLocationPermission(context);
    // print('gpsPermissionBool ===================== $gpsPermissionBool');
    if(!isDisposed) { setState(() => gpsPermissionBool); }
    if(gpsPermissionBool) gpsService();
  }

  Future gpsService() async {
    if(!await Geolocator().isLocationServiceEnabled()) {
      // print('gps off');
      checkGps();
    } else {
      // print('gps on');
      var position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      final coordinates = new Coordinates(position.latitude, position.longitude);
      var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;
      if(!isDisposed) {
        setState(() {
          latitude = position.latitude.toString();
          longitude = position.longitude.toString();
          thoroughfare = first.thoroughfare;
        });
      }
      //동네등록 확인여부 및 동네 리스트 가져오기
      token = await customSharedPreferences.getString('token');
      if(!isDisposed) { setState(() => token); }
      if(token != null){  //회원 일시 동네 등록 여부 확인
        String result = await registerServer.getTown(token);
        // print('loadToken result =============== $result');
        addressResult = jsonDecode(result);
        bool setRegister = addressResult['code'];
        // print('setRegister =============== $setRegister');
        if(!setRegister){ townDialog(); } //등록 동네 없을시 동네 등록 페이지 이동
        setState(() => setRegister = true);
        townCd1 = addressResult['list']['townCd1']; //동네 가져와서 map 으로 집어 넣는다.
        townNm1 = addressResult['list']['townNm1'];
        townCd2 = addressResult['list']['townCd2'];
        townNm2 = addressResult['list']['townNm2'];
        if(townCd1 != null){ if(!isDisposed) setState(() { areaItems.add({"id": townCd1, "name" : townNm1}); }); }
        if(townCd2 != null){ if(!isDisposed) setState(() { areaItems.add({"id": townCd2, "name" : townNm2}); }); }
      }
      try{
        if(areaItems.length != 0 ){ //동네 목록 유 무 로 현위치 또는 동네 코드로 넘겨준다.
          twnCd = areaItems[0]['id'];
          var homeList = { "recieveToken" : token, "twnCd" : twnCd,  "twnGc" : '2',};
          String homeResult = await homeServer.getHomeList(homeList);
          print('homeResult ================ $homeResult');
          if(homeResult == 'error')  {
            // true / false 넣어서  CircularProgressIndicator() 넣자
            return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
          }
          // print(jsonDecode(homeResult)['homeList']);
          // homeResultList = jsonDecode(homeResult)['homeList'];
          // print('homeResultList ================ $homeResultList');
          if(!isDisposed){setState(() => homeItems = jsonDecode(homeResult)['homeList'] );}
          // homeItems.add(jsonDecode(homeResult)['homeList']);
          // print('homeItems ================ $homeItems');
          } else {
          print('등록된 동네가 없다 위에서 확인 했지만 취소 했을 경우 현재 위치를 띄워 준다.');
          print(' token=== $token');
          var homeList;
          if(token != null){ homeList = { "recieveToken" : token, "gps_x" : longitude,  "gps_y": latitude,"twnGc" : '2',}; }
          if(token == null){ homeList = { "gps_x" : longitude,  "gps_y": latitude,"twnGc" : '2',}; }
          print('homeList =============================== $homeList');
          String homeResult = await homeServer.getHomeList(homeList);
          print('homeResult ================ $homeResult');
          if(!isDisposed){setState(() => homeItems = jsonDecode(homeResult)['homeList'] );}
          print('homeItems ================ $homeItems');

        }
      } catch(e){
        globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
      }
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

  //async wait 을 쓰기 위해서는 Future 타입을 이용함
  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 0)); //thread sleep 같은 역할을 함.
    //새로운 정보를 그려내는 곳
    //동네등록 확인여부 및 동네 리스트 가져오기
    try{
      if(areaItems.length != 0 ){ //동네 목록 유 무 로 현위치 또는 동네 코드로 넘겨준다.
        twnCd = areaItems[0]['id'];
        var homeList = { "recieveToken" : token, "twnCd" : twnCd,  "twnGc" : '1',};
        String homeResult = await homeServer.getHomeList(homeList);
        print('homeResult ================ $homeResult');
        if(homeResult == 'error')  {
          // true / false 넣어서  CircularProgressIndicator() 넣자
          return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
        }
        // print(jsonDecode(homeResult)['homeList']);
        // homeResultList = jsonDecode(homeResult)['homeList'];
        // print('homeResultList ================ $homeResultList');
        if(!isDisposed){setState(() => homeItems = jsonDecode(homeResult)['homeList'] );}
        // homeItems.add(jsonDecode(homeResult)['homeList']);
        // print('homeItems ================ $homeItems');
      } else {
        print('등록된 동네가 없다 위에서 확인 했지만 취소 했을 경우 현재 위치를 띄워 준다.');
        print(' token=== $token');
        var homeList;
        if(token != null){ homeList = { "recieveToken" : token, "gps_x" : longitude,  "gps_y": latitude,"twnGc" : '1',}; }
        if(token == null){ homeList = { "gps_x" : longitude,  "gps_y": latitude,"twnGc" : '1',}; }
        print('homeList =============================== $homeList');
        String homeResult = await homeServer.getHomeList(homeList);
        print('homeResult ================ $homeResult');
        if(!isDisposed){setState(() => homeItems = jsonDecode(homeResult)['homeList'] );}
        print('homeItems ================ $homeItems');

      }
    } catch(e){
      globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        elevation: 0,
        title: Theme(
          data: Theme.of(context).copyWith(
              canvasColor: Theme.of(context).primaryColor
          ),
          child: DropdownButton(
            // dropdownColor: Colors.white,
            items: (areaItems != null) ?
            areaItems.map((item) {
              return  DropdownMenuItem(
                  child: Text( item['name'],  style: TextStyle(fontSize: defaultSize * 1.7, color:  Colors.black) ),
                  value: item['id']
              );
            }).toList() : [],
            underline: Container(),
            onChanged: (value) {
              print('value ======================= $value');
              setState(() { twnCd = value; });
              print('twnCd ======== $twnCd');
              selectTwList(value.toString());
            },
            hint: (areaItems.length == 0) ? Text(thoroughfare ??'동네', style: TextStyle(fontSize: defaultSize * 1.7, color:  Colors.black)) : Text(areaItems[0]["name"],style: TextStyle(fontSize: defaultSize * 1.7, color:  Colors.white)),
            value:twnCd,
            iconEnabledColor: Colors.amber, //화살표 색
          ),
        ),
        actions: [
          Container(
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.circular(20.0),
            //   color: Colors.lightGreen
            // ),
            padding: EdgeInsets.only(top: 5,left: 20),
            child: DropdownButton(
              dropdownColor: Colors.white,
              items: homeSortItems.sortItems.map((item) {
                return  DropdownMenuItem(
                    child: Text( item['name'],  style: TextStyle(fontSize: defaultSize * 1.7,color:  Colors.black) ),
                    value: item['id']
                );
              }).toList(),
              underline: Container(),
              onChanged: (value) {
                print('value ======== $value');
                setState(() { sortId = value; });
                if(value == "1"){ refreshList(); }
                if(value == "2"){
                  print('낮은 금액순!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
                  List selected = homeItems.where((element) => element['jobAmt'] > 1).toList()..sort(( a, b) => b['jobAmt'].compareTo(a['jobAmt']));
                  homeItems.clear();
                  if(!isDisposed){ setState(() => homeItems = selected); }
                }
                if(value == "3"){
                  print('높은 금액순!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
                  List selected = homeItems.where((element) => element['jobAmt'] > 1).toList()..sort(( a, b) => a['jobAmt'].compareTo(b['jobAmt']));
                  homeItems.clear();
                  if(!isDisposed){ setState(() => homeItems = selected); }
                }
                if(value == "4"){
                  print('지역보기 !!!!!!!!!!!!!!!!!!!!!!!!!!!!');
                  selectTwGcList("1");
                }
                if(value == "5"){
                  selectTwGcList("2");
                  print('광역보기 !!!!!!!!!!!!!!!!!!!!!!!!!!!!');
                }

              },
              hint:  Text(homeSortItems.sortItems[0]["name"],style: TextStyle(fontSize: defaultSize * 1.7,  color:  Colors.black)),
              value: sortId,
              iconEnabledColor: Colors.amber, //화살표 색
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: refreshList,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.lightGreen[50],
                      borderRadius: BorderRadius.only(
                        // topLeft: Radius.circular(32),
                        // topRight: Radius.circular(32),
                      )),
                  padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Column(
                    children: [
                      Expanded(
                          flex: 10,
                          child: Column(
                            children: [
                              Expanded(
                                flex: 15,
                                child:
                                (homeItems.length == 0 ) ?
                                Center(child:  roadHomeList(homeItems)) :
                                ListView.builder(
                                  itemCount: homeItems.length,
                                  itemBuilder: (context, index) {
                                    jobId = homeItems[homeItems.length - index -1]['jobId'];
                                    jobTtl = homeItems[homeItems.length - index -1]['jobTtl'];
                                    aucMtd = homeItems[homeItems.length - index -1]['aucMtd'];
                                    jobStDtm = homeItems[homeItems.length - index -1]['jobStDtm'];
                                    jobStDtm = homeItems[homeItems.length - index -1]['jobStDtm'];
                                    bidDlDtm = homeItems[homeItems.length - index -1]['bidDlDtm'];
                                    jobAmt = homeItems[homeItems.length - index -1]['jobAmt'];
                                    payMtd = homeItems[homeItems.length - index -1]['payMtd'];
                                    jobIts = homeItems[homeItems.length - index -1]['jobIts'];
                                    twnNm = homeItems[homeItems.length - index -1]['twnNm'];
                                    prfSeq = homeItems[homeItems.length - index -1]['prfSeq'];
                                    return HomeItem(token, jobId, jobTtl, aucMtd, jobStDtm, bidDlDtm, jobAmt, index, payMtd, jobIts, twnNm, prfSeq );
                                  },
                                ),
                              )
                            ],
                          )
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget roadHomeList (List<dynamic> homeItems){
    if(homeItems.length == 0){
      return Text('현재 동네에 등록된 일이 없습니다.');
    } else {
      Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
      return CircularProgressIndicator();
    }
  }

  void townDialog () { //동네 등록 다이얼 로그
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("동네가 등록 되있지 않습니다."),
          content:const Text('동네를 등록해 주세요.'),
          actions: <Widget>[
            FlatButton(child: Text('동네 등록으로 이동'),
              onPressed: () { //동네가 등록 되있지 않을 시 동네 등록 페이지로 이동한다.
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyPageDetailMyTown(token: token,)));
              },
            ),
            FlatButton(onPressed: ()=> Navigator.pop(context), child: Text('현위치로 보기'))
          ],
        );
      },
    );
  }

  selectTwList(String twnCd) async{
      try{
        var homeList = { "recieveToken" : token, "twnCd" : twnCd,  "twnGc" : '1',};
        String homeResult = await homeServer.getHomeList(homeList);
        // print('homeResult ================ $homeResult');
        if(homeResult == 'error')  {
          return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
        }
        // // print(jsonDecode(homeResult)['homeList']);
        // homeResultList = jsonDecode(homeResult)['homeList'];
        // print('homeResultList ================ $homeResultList');
        homeItems.clear();
        if(!isDisposed){setState(() => homeItems = jsonDecode(homeResult)['homeList'] );}
      } catch(e){
        globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
    }
  }

  selectTwGcList(String twnGc) async{
    try{
      var homeList;
      homeItems.clear();
      if(areaItems.length == 0 ){
        if(token != null){ homeList = { "recieveToken" : token, "gps_x" : longitude,  "gps_y": latitude,"twnGc" : '2',}; }
        if(token == null){ homeList = { "gps_x" : longitude,  "gps_y": latitude,"twnGc" : '2',}; }
        String homeResult = await homeServer.getHomeList(homeList);
        if(homeResult == 'error')  { return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.'))); }
        if(!isDisposed){setState(() => homeItems = jsonDecode(homeResult)['homeList'] );}
      } else {
        homeList = { "recieveToken" : token, "twnCd" : twnCd,  "twnGc" : twnGc,};
        String homeResult = await homeServer.getHomeList(homeList);
        if(homeResult == 'error')  { return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.'))); }
        if(!isDisposed){setState(() => homeItems = jsonDecode(homeResult)['homeList'] );}
      }
    } catch(e){
      globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.')));
    }
  }
}