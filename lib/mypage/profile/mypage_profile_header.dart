import 'dart:convert';
import 'dart:typed_data';

import 'package:any_rent/mypage/mypage_server.dart';
import 'package:any_rent/settings/url.dart';
import 'package:flutter/material.dart';
import 'package:any_rent/settings/size_config.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:any_rent/settings/custom_shared_preferences.dart';
import 'package:any_rent/permission/photo_storage_perminnion.dart';

// const url = 'http://211.253.20.112'; //개발서버
// const url = "http://192.168.1.3:4001"; //재승 내부 ip
const url = UrlConfig.url;

class MyPageProfileHeader extends StatefulWidget{
  @override
  _MyPageProfileHeaderState createState() => _MyPageProfileHeaderState();
}

class _MyPageProfileHeaderState extends State<MyPageProfileHeader> {
  List<Asset> images = List<Asset>();
  String _error;
  double defaultSize = SizeConfig.defaultSize;
  String token;
  int prfSeq;
  final globalKey = GlobalKey<ScaffoldState>();
  bool isDisposed = false;

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  loadToken() async{
    token = await customSharedPreferences.getString('token');
    // print('MyPageHeader token == $token');
    // print('Mypage state == $state');
    String result = await myPageServer.getProfile(token);
    Map<String, dynamic> profile = jsonDecode(result);
    // print('Mypage responeJson == $result');
    if(!isDisposed) { setState(() { prfSeq = profile['prfSeq']; }); }
    // print('MyPageHeader prfSeq == $prfSeq');
  }

  Widget buildGridView() {
    if (images != null){
      return Center(
        child: GridView.count(
          crossAxisCount: 1,
          children: List.generate(images.length, (index) {
            Asset asset = images[index];
            return AssetThumb(
              asset: asset,
              width: 300,
              height: 300,
            );
          }),
        ),
      );
    } else{
      return (prfSeq == null) ?  Icon(Icons.account_box_rounded, size: defaultSize * 8,) :  Image.network('$url/api/mypage/images?recieveToken=$prfSeq');//이미지 널 체크 여부
    }
  }

  Future<void> loadAssets() async {
    bool result = await photoStoragePermission.requestLocationPermission(context);
    if(! result) {return photoStoragePermission.openAppSettingDialog(context); }
    setState(() { images = List<Asset>(); });

    List<Asset> resultList;
    String error;

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 1, //최대 이미지 갯수
        enableCamera: true, //카메라 활성화
        materialOptions: MaterialOptions( //안드로이드 커스텀
          actionBarTitle: "Action bar",
          allViewTitle: "All view title",
          actionBarColor: "#aaaaaa",
          actionBarTitleColor: "#bbbbbb",
          lightStatusBar: false,
          statusBarColor: '#abcdef',
          startInAllView: true,
          selectCircleStrokeColor: "#000000",
          selectionLimitReachedText: "사진은 1장만 선택이 가능합니다.",
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

    images = (resultList == null) ? [] : resultList;
    if(images.length > 0){
      Uri uri = Uri.parse('$url/api/mypage/profilUpt');
      http.MultipartRequest request = new http.MultipartRequest('POST', uri);
      print('token ================ $token');
      print(images.length);
      print(resultList.length);
      request.fields['recieveToken'] = token;
      for (int i = 0; i < images.length; i++) {
        ByteData byteData = await images[i].getThumbByteData(300, 400, quality: 50);
        // ByteData byteData = await images[i].getByteData();
        // print('byteData ==================== $byteData');
        List<int> imageData = byteData.buffer.asUint8List();
        // print('imageData ==================== $imageData');
        print(images[i].name);
        print(images[i].name.split('.').last);
        http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
          'image',
          imageData,
          filename: images[i].name,
          contentType: MediaType("image", images[i].name.split('.').last),
        );
        request.files.add(multipartFile);
      }
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if(response.statusCode != 200 ) { return globalKey.currentState.showSnackBar(const SnackBar(content: const Text('잠시후 다시 시도해 주세요.'))); }
    }
    setState(() {
      images = resultList;
      if (error == null) _error = 'No Error Dectected';
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: globalKey,
      onTap: () => profileDialog(),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(
            color: Colors.lightGreen,
            blurRadius: 5.0,
            spreadRadius: 3.0
          )]
        ),
        padding: EdgeInsets.symmetric(vertical: 25, horizontal: 30),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: defaultSize * 15,
                    height: defaultSize * 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.fill,
                          image: (prfSeq == null)
                            ? AssetImage('assets/noimage.jpg')
                              : NetworkImage('$url/api/mypage/images?recieveToken=$prfSeq')
                      ),
                      border: Border.all(
                        color: Colors.amberAccent.withOpacity(0.8),
                        width: 5
                      )
                      )
                    ),
                    // child: (images.length > 0) ?
                    SizedBox( height: defaultSize * 5)
                    // : (prfSeq == null) ?  Icon(Icons.circle, size: defaultSize * 8,) :  Image.network('$url/api/mypage/images?recieveToken=$prfSeq'),//이미지 널 체크 여부
            // ),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.only(top: defaultSize )),
          ],
        ),
      ),
    );
  }

  void profileDialog(){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
            ),
            title: Center(child: Text('프로필 이미지 변경')),
            content: Text('\n이미지를 변경 하시겠습니까?\n'),
            actions: <Widget>[
              FlatButton(onPressed: ()=> Navigator.pop(context, false), child: Text('취소',style: TextStyle(color: Colors.lightGreen[800]),)),
              (prfSeq != null) ? FlatButton(onPressed: ()=> removeProfileDialog(), child: Text('삭제',style: TextStyle(color: Colors.lightGreen[800]))) : null,
              FlatButton(onPressed: (){
                loadAssets();
                Navigator.pop(context, false);
                }, child: Text('변경',style: TextStyle(color: Colors.lightGreen[800]))),
            ],
          );
        }
    );
  }
  void removeProfileDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
            ),
            title: Center(child: Text('프로필 이미지 삭제')),
            content: Text('\n이미지를 삭제 하시겠습니까?\n'),
            actions: <Widget>[
              FlatButton(onPressed: ()=> Navigator.pop(context, false), child: Text('아니오',style: TextStyle(color: Colors.lightGreen[800]))),
              FlatButton(onPressed: (){
                removeProfileImg();
                Navigator.pop(context, false);
              }, child: Text('예',style: TextStyle(color: Colors.lightGreen[800]))),
            ],
          );
        }
    );
  }

  removeProfileImg() async{
    String result = await myPageServer.removeProfile(token);
    print('removeProfileImg result ====================+$result');
    if(result == 'error') { return Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );}
    setState(() => prfSeq = null);
    Navigator.pop(context, false);
    // DELETE COMPLETE
    return Scaffold.of(context).showSnackBar( SnackBar(content: Text("삭제되었습니다.",), duration: Duration(seconds: 3),) );
  }
}