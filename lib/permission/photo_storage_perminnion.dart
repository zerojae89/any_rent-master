import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoStoragePermission {
  final PermissionHandler permissionHandler = PermissionHandler();
  Map<PermissionGroup, PermissionStatus> permissions;

  Future<bool> _requestPermission(PermissionGroup permission) async {
    final PermissionHandler _permissionHandler = PermissionHandler();
    var result = await _permissionHandler.requestPermissions([permission]);
    if (result[permission] == PermissionStatus.granted) { return true; }
    return false;
  }

  //권한 확인 storage = 저장소 camera = 카메라 false 일시 openAppSettings 으로 권한 확인 받게 이동
  Future<bool> requestLocationPermission(BuildContext context,{Function onPermissionDenied}) async {
    var storage = await _requestPermission(PermissionGroup.storage);
    var camera = await _requestPermission(PermissionGroup.camera);
    if (storage!=true) openAppSettingDialog(context);
    if (camera!=true) openAppSettingDialog(context);
    bool granted = (storage && camera);
    debugPrint('requestContactsPermission  storage $storage');
    debugPrint('requestContactsPermission  camera $camera');
    return granted;
  }

  Future openAppSettingDialog(BuildContext context) async{
    showDialog( context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(child: Text("권한 설정거부")),
            content:const Text('권한을 활성화 시켜주세요.'),
            actions: <Widget>[
              FlatButton(child: Text('설정으로 이동'),
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
PhotoStoragePermission photoStoragePermission = PhotoStoragePermission();