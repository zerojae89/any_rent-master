import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent/android_intent.dart';
import 'package:geolocator/geolocator.dart';


import 'dart:async';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AnyRent',
        theme: ThemeData( primarySwatch: Colors.lightGreen, ), // 앱에 매인 테마 색을 정한다.
        // home: MyHomePage(index: 0),
        home: AskForPermission()
    );
  }
}

class AskForPermission extends StatefulWidget {
  @override
  _AskForPermissionState createState() => _AskForPermissionState();
}
class _AskForPermissionState extends State<AskForPermission> {
  String latitude, longitude;
  bool serviceEnabled = true;
  final PermissionHandler permissionHandler = PermissionHandler();
  Map<PermissionGroup, PermissionStatus> permissions;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    _gpsService();
  }

  Future<bool> _requestPermission(PermissionGroup permission) async {
    final PermissionHandler _permissionHandler = PermissionHandler();
    var result = await _permissionHandler.requestPermissions([permission]);
    if (result[permission] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }
/*Checking if your App has been Given Permission*/
  Future<bool> requestLocationPermission({Function onPermissionDenied}) async {
    var granted = await _requestPermission(PermissionGroup.location);
    if (granted!=true) {
      requestLocationPermission();
    }
    debugPrint('requestContactsPermission $granted');
    return granted;
  }
/*Show dialog if GPS not enabled and open settings location*/
  Future _checkGps() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Can't get gurrent location"),
              content:const Text('Please make sure you enable GPS and try again'),
              actions: <Widget>[
                FlatButton(child: Text('Ok'),
                  onPressed: () {
                    final AndroidIntent intent = AndroidIntent(
                        action: 'android.settings.LOCATION_SOURCE_SETTINGS');
                    intent.launch();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ],
            );
          },
        );
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Can't get gurrent location"),
            content:const Text('Please make sure you enable GPS and try again'),
            actions: <Widget>[
              FlatButton(child: Text('Ok'),
                onPressed: () {
                  final AndroidIntent intent = AndroidIntent(
                      action: 'android.settings.LOCATION_SOURCE_SETTINGS');
                  intent.launch();
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          );
        },
      );
    }}
/*Check if gps service is enabled or not*/
  Future _gpsService() async {
    // serviceEnabled = await Geolocator().isLocationServiceEnabled();
    // print('serviceEnabled =================== $serviceEnabled');
    if(!await Geolocator().isLocationServiceEnabled()) {
      print('gps gogo');
      _checkGps();
      return null;
    } else {
      print('gps nono');
      var currentPosition = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      var lastPosition = await Geolocator()
          .getLastKnownPosition(desiredAccuracy: LocationAccuracy.low);
      print(currentPosition);
      print(lastPosition);
      print(lastPosition.latitude);
      print(lastPosition.longitude);
      // setState(() {
      //   latitude = lastPosition.latitude.toString();
      //   longitude = lastPosition.longitude.toString();
      // });
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Ask for permisions'),
          backgroundColor: Colors.red,
        ),
        body: Center(
            child: Column(
              children: <Widget>[
                Text("All Permission Granted"),
              ],
            ))
    );
  }
}
