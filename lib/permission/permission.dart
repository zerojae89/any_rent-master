import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:any_rent/main_home.dart';
import 'package:any_rent/settings/size_config.dart';
import 'premission_menu_item.dart';

class Permission extends StatefulWidget {
  @override
  _PermissionState createState() => _PermissionState();
}

class _PermissionState extends State<Permission> {
  SharedPreferences _prefs;

  Future<void> permissionState(BuildContext context) async{
    _prefs = await SharedPreferences.getInstance(); // SharedPreferences의 인스턴스를 필드에 저장;
    setState(() { _prefs.setBool('permission', true); }); // SharedPreferences에 permission으로 저장된 값을 읽어 필드에 저장. 없을 경우 false
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MyHomePage(index: 0,)), (route) => false);
  }
  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return AlertDialog(
      title: Container(
          margin:EdgeInsets.only(top:100),child: Text( 'AnyRent 앱 접근 권한 안내',  textAlign: TextAlign.center,  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.lightGreen[700]), )),
      content:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(margin: EdgeInsets.only(left: 20), child: Text( '필수 접근 권한    ',  style: TextStyle( fontWeight: FontWeight.bold,  fontSize: defaultSize * 2.0, ), )),
          SizedBox(height: 20,),
          Text( '없음',  style: TextStyle( fontSize: defaultSize * 1.8, ), ),
          Divider(height: 50,thickness: 2,),
          SizedBox(height: 0,),
          Text( '선택적 접근 권한',  textAlign: TextAlign.left,  style: TextStyle( fontWeight: FontWeight.bold,  fontSize: defaultSize * 2.3, ), ),
          SizedBox(height: 40,),
          PermissionMenuItem( icon: Icon(Icons.camera_alt),   title: ' 카메라     :   ',  content: '사진 촬영을 위해 사용', ),
          SizedBox(height: 20,),
          PermissionMenuItem( icon: Icon(Icons.storage),      title: ' 저장소   :   ',    content: '파일첨부, 저장을 위해 사용', ),
          SizedBox(height: 20,),
          PermissionMenuItem( icon: Icon(Icons.location_on),  title: ' 위치정보 :   ',    content: '지역 정보 제공을 위해사용', ),
          SizedBox(height: 20,),
          PermissionMenuItem( icon: Icon(Icons.call),         title: ' 전화번호 :   ',    content: '사용자 식별을 위해 사용', ),
          SizedBox(height: 50,),
          FlatButton( onPressed: ()=> permissionState(context),
              child: Text( '확인',  style: TextStyle( fontWeight: FontWeight.bold,  fontSize: defaultSize * 1.8,  color: Colors.white ),  textAlign: TextAlign.center, ),
            color: Colors.lightGreen,
          )
        ],
      ),
    );
  }
}

