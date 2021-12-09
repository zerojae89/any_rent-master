import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class GpsPermission {
  String latitude, longitude;
  final PermissionHandler permissionHandler = PermissionHandler();
  Map<PermissionGroup, PermissionStatus> permissions;

  Future<bool> _requestPermission(PermissionGroup permission) async {
    final PermissionHandler _permissionHandler = PermissionHandler();
    var result = await _permissionHandler.requestPermissions([permission]);
    if (result[permission] == PermissionStatus.granted) { return true; }
    return false;
  }
  //권한 확인 location = 위치 else 일시 openAppSettings 으로 권한 확인 받게 이동
  Future<bool> requestLocationPermission(BuildContext context,{Function onPermissionDenied}) async {
    var granted = await _requestPermission(PermissionGroup.location);
    if (granted!=true)  openAppSettingDialog(context);
    return granted;
  }

  Future openAppSettingDialog(BuildContext context) async{
    showDialog( context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
          ),
          title: Center(child: Text("권한 설정거부")),
          content:const Text('권한을 활성화 시켜주세요.'),
          actions: <Widget>[
            FlatButton(child: Text('설정으로 이동',style: TextStyle(color: Colors.lightGreen[800]),),
              onPressed: () => openSetting(context),
            ),
          ],
        );
      }
    );
  }
  openSetting(BuildContext context) async {
    Navigator.of(context, rootNavigator: true).pop();
    await PermissionHandler().openAppSettings();
  }
}

GpsPermission gpsPermission = GpsPermission();