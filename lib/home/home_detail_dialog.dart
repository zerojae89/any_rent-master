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
                height: defaultSize * 43,
                width: MediaQuery.of(context).size.width * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox( height: 20, ),
                    Text( "프로필", style: TextStyle( fontSize: defaultSize * 2.5,  fontWeight: FontWeight.bold, ), ),
                    SizedBox( height: defaultSize * 3, ),
                    Container(decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellow.withOpacity(0.7),width: defaultSize*0.3),
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
                    SizedBox( height: defaultSize * 2, ),
                    Text( junNic, style: TextStyle( fontSize: defaultSize * 2.5, color: Colors.lightGreen, fontWeight: FontWeight.bold, ), ),
                    SizedBox( height: defaultSize * 2, ),
                    Text( "평점 : $mbrGrd", style: TextStyle( fontSize: defaultSize * 2.0,  fontWeight: FontWeight.bold, ), ),
                    SizedBox(height: 0.3,),
                    Padding(
                      padding: EdgeInsets.all(defaultSize * 1),
                      child:  Center(child: FlatButton(onPressed: ()=> Navigator.pop(context), child: Text("닫기",style: TextStyle(color: Colors.lightGreen[800],fontWeight: FontWeight.bold,fontSize: defaultSize * 2),),)),
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
                // border: Border.all(
                //   color: Colors.lightGreen[700],
                //   width: 5
                // ),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              padding: EdgeInsets.only(left: 10,top: 10,right: 10),
              height: defaultSize * 36,
              width: MediaQuery.of(context).size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox( height: 25, ),
                  Text( "예약 확인", style: TextStyle( fontSize: defaultSize * 2.3,  fontWeight: FontWeight.bold, ), ),
                  SizedBox( height: defaultSize * 2, ),
                  Container(
                    padding: EdgeInsets.only(left: 10,right: 10,top: 5),
                      // decoration: BoxDecoration(
                      //   border: Border.all(color: Colors.grey)
                      // ),
                      width: defaultSize * 23,
                      height: defaultSize * 5,
                      child: Text( jobTtl,  style: TextStyle( fontSize: defaultSize *1.7, fontWeight: FontWeight.bold,color: Colors.lightGreen[800]),textAlign: TextAlign.center, )),
                  SizedBox( height: defaultSize * 1, ),
                  Container(height: defaultSize * 7,width: defaultSize * 20,
                      // decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: Text( jobCtn,  style: TextStyle( fontSize: defaultSize * 1.5, fontWeight: FontWeight.bold, ), )),
                  SizedBox( height: defaultSize * 1, ),
                  Text( "작업 시작시간 :  \n $jobStDtm",  style: TextStyle( fontSize: defaultSize * 1.5, fontWeight: FontWeight.bold, ), ),
                  SizedBox( height: defaultSize * 0.5, ),
                  Padding(
                    padding: EdgeInsets.all(defaultSize * 1.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FlatButton(onPressed: ()=> reservation(context, token, jobId), child: Text('예', style: TextStyle(fontSize:defaultSize*1.7,color: Colors.lightGreen[800],fontWeight: FontWeight.bold),),),
                        SizedBox(width: defaultSize*1,),
                        FlatButton(onPressed: ()=> Navigator.pop(context), child: Text("아니오",style: TextStyle(fontSize: defaultSize*1.7,color: Colors.lightGreen[800],fontWeight: FontWeight.bold), ),)
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))
          ),
          title: Text("게시물을 삭제 하시겠습니까?"),
          actions: <Widget>[
            FlatButton(
              child: Text("아니오",style: TextStyle(color: Colors.lightGreen[800])),
              onPressed: () => Navigator.pop(context, false),
            ),
            FlatButton(
              child: Text("예",style: TextStyle(color: Colors.lightGreen[800])),
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))
          ),
          title: Text("게시물을 수정 하시겠습니까?"),
          actions: <Widget>[
            FlatButton(
              child: Text("아니오",style: TextStyle(color: Colors.lightGreen[800])),
              onPressed: () => Navigator.pop(context, false),
            ),
            FlatButton(
              child: Text("예",style: TextStyle(color: Colors.lightGreen[800])),
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
