import 'package:any_rent/settings/url.dart';
import 'package:http/http.dart' as http;

// const url = 'http://211.253.20.112'; //개발서버
// const url = "http://192.168.1.3:4001"; //재승 내부 ip

const url = UrlConfig.url;

class MyPageServer {

  //유저 정보 가져오기
  Future<String> getProfile(String token) async {
    print(
        "getProfile====================================================Start");
    http.Response response = await http.post('$url/api/mypage/getToken',
        body: {
          "recieveToken": token,
        }
    );
    if (response.statusCode == 200) {
      print(
          "getProfile====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  //낙내임 변경
  Future<String> changrNic(String token, String nicNm) async {
    print("changrNic====================================================Start");
    http.Response response = await http.post('$url/api/mypage/uptNicnm',
        body: {
          "recieveToken": token,
          "recieveNicNm": nicNm
        }
    );
    if (response.statusCode == 200) {
      print("changrNic====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  //동네 가져오기
  Future<String> getAddress(String token) async {
    print(
        "getAddress====================================================Start");
    http.Response response = await http.post(
        '$url/api/mypage/userTown', body: { "recieveToken": token,});
    if (response.statusCode == 200) {
      print(
          "getAddress====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  //동네 등록 하기
  Future<String> sendAddress(String token, String latitude,
      String longitude) async {
    print(
        "sendAddress====================================================Start");
    http.Response response = await http.post('$url/api/mypage/registerTown',
        body: {
          "recieveToken": token,
          "gps_y": latitude,
          "gps_x": longitude,
        }
    );
    if (response.statusCode == 200) {
      print(
          "sendAddress====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  //동네 삭제하기
  Future<String> removeAddress(String token, String twnCd) async {
    print(
        "removeAddress====================================================Start");
    http.Response response = await http.post('$url/api/mypage/deleteTown',
        body: { "recieveToken": token, "twnCd": twnCd});
    if (response.statusCode == 200) {
      print(
          "removeAddress====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  //동네 인증하기
  Future<String> certificationAddress(String token, String latitude,
      String longitude) async {
    print(
        "certificationAddress====================================================Start");
    http.Response response = await http.post('$url/api/mypage/increaseCert',
        body: {
          "recieveToken": token,
          "gps_y": latitude,
          "gps_x": longitude,
        });
    if (response.statusCode == 200) {
      print(
          "certificationAddress====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  //이미지 삭제하기
  Future<String> removeProfile(String token) async {
    print(
        "removeProfile====================================================Start");
    http.Response response = await http.post('$url/api/mypage/profliDel',
        body: {
          "recieveToken": token,
        }
    );
    if (response.statusCode == 200) {
      print(
          "removeProfile====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  //준일 목록 불러오기
  Future<String> getjunWorkList(String token) async {
    print(
        "junWorkList====================================================Start");
    http.Response response = await http.post('$url/api/mypage/junWork',
        body: {
          "recieveToken": token,
        }
    );
    if (response.statusCode == 200) {
      print(
          "junWorkList====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  Future<String> getAttentionList(String token) async {
    //관삼목록 목록 불러오기
    print(
        "getAttentionList====================================================Start");
    http.Response response = await http.post('$url/api/service/hanItsSelect',
        body: {
          "recieveToken": token,
        }
    );
    if (response.statusCode == 200) {
      print(
          "getAttentionList====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  Future<String> getHanWorkList(String token) async {
    //한일 목록 불러오기
    print(
        "getAttentionList====================================================Start");
    http.Response response = await http.post('$url/api/service/hanilSelect',
        body: {
          "recieveToken": token,
        }
    );
    if (response.statusCode == 200) {
      print(
          "getAttentionList====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  Future<String> sendServiceComplete(String token, String jobId) async {
    //소일 완료 하기
    print(
        "sendServiceComplete====================================================Start");
    http.Response response = await http.post('$url/api/service/completeServ',
        body: {
          "recieveToken": token,
          "jobId": jobId
        }
    );
    if (response.statusCode == 200) {
      print(
          "sendServiceComplete====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  Future<String> getHanId(String token,) async {
    //하니 아이디 가져오기
    print("getHanId====================================================Start");
    http.Response response = await http.post('$url/api/service/getHanId',
        body: {
          "recieveToken": token,
        }
    );
    if (response.statusCode == 200) {
      print("getHanId====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  Future<String> getReviewWiretList(String token) async {
    //리뷰 작성 가져오기
    print("getHanId====================================================Start");
    http.Response response = await http.post('$url/api/chat/getReviewWiretList',
        body: {
          "recieveToken": token,
        }
    );
    if (response.statusCode == 200) {
      print("getHanId====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  Future<String> sendReview(String token, String opId, String jobId,
      String junHan, String revCtn, String grd, String kind) async {
    //후기 작성 및 수정 하기
    print(
        "sendReview====================================================Start");
    http.Response response = await http.post("$url/api/chat/sendReview",
        body: {
          "recieveToken": token,
          "opId": opId,
          "jobId": jobId,
          "junHan": junHan,
          "revCtn": revCtn,
          "grd": grd,
          "kind": kind
        }
    );
    if (response.statusCode == 200) {
      print(
          "sendReview====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  Future<String> deleteReview(String token, String jobId,) async {
    //후기 삭제 하기
    print(
        "deleteReview====================================================Start");
    http.Response response = await http.post("$url/api/chat/deleteReview",
        body: {
          "recieveToken": token,
          "jobId": jobId,
        }
    );
    if (response.statusCode == 200) {
      print(
          "deleteReview====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  Future<String> getReviewReadList(String token) async {
    //리뷰 작성 가져오기
    print("getHanId====================================================Start");
    http.Response response = await http.post('$url/api/chat/getReviewReadList',
        body: {
          "recieveToken": token,
        }
    );
    if (response.statusCode == 200) {
      print("getHanId====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  Future<String> getBidderList(String token) async {
    //리뷰 작성 가져오기
    print(
        "getBidderList====================================================Start");
    http.Response response = await http.post(
        '$url/api/mypage/bidder', body: { "recieveToken": token});
    if (response.statusCode == 200) {
      print(
          "getBidderList====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  Future<String> getBidderDetail(String jobId) async {
    //리뷰 작성 가져오기
    print("getBidderDetail==========================================Start");
    http.Response response = await http.post(
        '$url/api/mypage/bidderDetail', body: { "jobId": jobId});
    if (response.statusCode == 200) {
      print(
          "getBidderDetail====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  Future<String> keyWordRegi(String token, String keyWord) async {
    print("keyWord=============================Start");
    print("token=====================3333$token");
    print("keyword=====================3333$keyWord");

    http.Response response = await http.post(
        '$url/api/mypage/keyWordRegi',
        body: { "recieveToken": token,
                "keyWord" : keyWord }
        );
    if (response.statusCode == 200) {
      print(

          "keyWord====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
    }
  }

  Future<String> bidderSuccess(String token, String jobId, String hanId, int bidAmt) async {
    print(
        "bidderSuccess====================================================start");
    print("token=====================3333$token");
    print("jobId=====================3333$jobId");
    print("hanId=====================3333$hanId");
    print("bidAmt=====================3333$bidAmt");
    http.Response response = await http.post(
        '$url/api/mypage/bidderSuccess',
        body: {
          "recieveToken": token,
          "jobId" : jobId,
          "hanId" : hanId,
          "bidAmt": '$bidAmt'
        }
    );
    if (response.statusCode == 200) {
      print(
          "bidderSuccess====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
    }
  }


}

MyPageServer myPageServer = MyPageServer();