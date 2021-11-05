import 'package:any_rent/home/home_server.dart';
import 'package:any_rent/mypage/detail/list/mypage_list.dart';
import 'package:any_rent/settings/url.dart';
import 'package:flutter/material.dart';

import '../main_home.dart';
import 'home_update.dart';

// const url = 'http://211.253.20.112'; //개발서버
// const url = "http://192.168.1.3:4001"; //재승 내부 ip
const url = UrlConfig.url;

class HomeDetailDialog {

  showDialogProfile(context, defaultSize, junNic, junPrfSeq, mbrGrd){ //주니 프로필 보여주기
    return showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(15),
                height: defaultSize * 48,
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox( height: 20, ),
                    Text( "프로필", style: TextStyle( fontSize: defaultSize * 2.5,  fontWeight: FontWeight.bold, ), ),
                    SizedBox( height: defaultSize * 3, ),
                    Container(decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: (junPrfSeq == null)
                                ? AssetImage('assets/noimage.jpg')
                                : NetworkImage(
                                '$url/api/mypage/images?recieveToken=$junPrfSeq')), //.
                        // border: Border.all(
                        //     color: Colors.yellow.withOpacity(0.8),
                        //     width: 5)
                    ),
                        width: defaultSize * 12,
                        height: defaultSize * 15),
                    SizedBox( height: defaultSize * 3, ),
                    Text( junNic, style: TextStyle( fontSize: defaultSize * 2.5, color: Colors.lightGreen, fontWeight: FontWeight.bold, ), ),
                    SizedBox( height: defaultSize * 2, ),
                    Text( "평점 : $mbrGrd", style: TextStyle( fontSize: defaultSize * 2.0,  fontWeight: FontWeight.bold, ), ),
                    Padding(
                      padding: EdgeInsets.all(defaultSize * 2),
                      child:  Center(child: RaisedButton(onPressed: ()=> Navigator.pop(context), child: Text("닫기"),)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  showDialogFunc(context, defaultSize, jobTtl, jobCtn, jobStDtm, token, jobId) { //예약하기
    return showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(15),
              height: defaultSize * 40,
              width: MediaQuery.of(context).size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox( height: 10, ),
                  Text( "예약 확인", style: TextStyle( fontSize: defaultSize * 2.3,  fontWeight: FontWeight.bold, ), ),
                  SizedBox( height: defaultSize * 3, ),
                  Text( jobTtl,  style: TextStyle( fontSize: defaultSize *1.7, fontWeight: FontWeight.bold, ), ),
                  SizedBox( height: defaultSize * 3, ),
                  Text( jobCtn,  style: TextStyle( fontSize: defaultSize * 1.5, fontWeight: FontWeight.bold, ), ),
                  SizedBox( height: defaultSize * 3, ),
                  Text( "작업 시작시간 :  \n $jobStDtm",  style: TextStyle( fontSize: defaultSize * 1.2, fontWeight: FontWeight.bold, ), ),
                  SizedBox( height: defaultSize * 3, ),
                  Padding(
                    padding: EdgeInsets.all(defaultSize * 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FlatButton(color: Colors.purple, onPressed: ()=> reservation(context, token, jobId), child: Text('예', style: TextStyle(color: Colors.amber),),),
                        FlatButton(color: Colors.purple, onPressed: ()=> Navigator.pop(context), child: Text("아니오",style: TextStyle(color: Colors.amber), ),)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  onDeletePressed(context, jobId, token){ //삭제하기
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text("게시물을 삭제 하시겠습니까?"),
          actions: <Widget>[
            FlatButton(
              child: Text("아니오"),
              onPressed: () => Navigator.pop(context, false),
            ),
            FlatButton(
              child: Text("예"),
              onPressed: () {
                homeServer.deleteService(token, jobId);
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MyHomePage(index: 0,)), (route) => false);
              }
            )
          ],
        )
    );
  }

  onUpdatePressed(context, jobId){ //수정하기
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text("게시물을 수정 하시겠습니까?"),
          actions: <Widget>[
            FlatButton(
              child: Text("아니오"),
              onPressed: () => Navigator.pop(context, false),
            ),
            FlatButton(
              child: Text("예"),
              onPressed: () {
                Navigator.pop(context, true);
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomeUpdate(jobId: jobId,)));
              }
            )
          ],
        )
    );
  }

  reservation(context, token, jobId) async{
    print('예약 하기 서버 받는거 하면됨 \n 그리고 페이지 이동?');
    print(token);
    print(jobId);
    try{
      String result = await homeServer.reservationService(token, jobId);
      print('result ================= $result');
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => MyPageDetailList(index: 1,)), (route) => false);
    } catch(e){
    Scaffold.of(context).showSnackBar( SnackBar(content: Text("잠시후 다시 시도해 주세요.",), duration: Duration(seconds: 3),) );
    }
  }
}

HomeDetailDialog homeDetailDialog = HomeDetailDialog();
