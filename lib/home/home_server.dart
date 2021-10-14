import 'package:any_rent/settings/url.dart';
import 'package:http/http.dart' as http;

// const url = 'http://211.253.20.112'; //개발서버
// const url = "http://192.168.1.3:4001"; //재승 내부 ip

const url = UrlConfig.url;

class HomeServer{
  Future<String> getHomeList(Map <String, String> map) async{ //홈리스트 받아오기
    print("getHomeList====================================================Start");
    http.Response response = await http.post( '$url/api/service/homeServ',  body: map );
    if (response.statusCode == 200) {
      print("getHomeList====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  Future<String> getHomeDetail(Map <String, String> map) async{ //일 상세 받아 오기
    print("getHomeDetail====================================================Start");
    http.Response response = await http.post( '$url/api/service/homeDetail',  body: map );
    if (response.statusCode == 200) {
      print("getHomeDetail====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  Future<String> sendAttention(String token, String  jobId) async{ //관심 목록 추가 하기
    print("sendAttention====================================================Start");
    http.Response response = await http.post( '$url/api/service/hanItsInsert',
        body: {
          "recieveToken" : token,
          "jobId" : jobId
        }
    );
    if (response.statusCode == 200) {
      print("sendAttention====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  Future<String> sendAttentionDelete(String token, String  jobId) async{ //관심 목록 추가 하기
    print("sendAttentionDelet====================================================Start");
    http.Response response = await http.post( '$url/api/service/hanItsDelete',
        body: {
          "recieveToken" : token,
          "jobId" : jobId,
          "uyn" : "N"
        }
    );
    if (response.statusCode == 200) {
      print("sendAttentionDelet====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  Future<String> deleteService(String token, String  jobId) async {  // 일거리 삭제하기
    print("deleteRegiService====================================================Start");
    http.Response response = await http.post( '$url/api/service/regiservDel',
        body: {
          "recieveToken" : token,
          "jobId" : jobId,
        }
    );
    if (response.statusCode == 200) {
      print("deleteRegiService====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  Future<String> reservationService(String token, String  jobId) async { // 일거리 삭제하기
    print("reservationService====================================================Start");
    http.Response response = await http.post( '$url/api/service/bookingServ',
        body: {
          "recieveToken" : token,
          "jobId" : jobId,
        }
    );
    if (response.statusCode == 200) {
      print("reservationService====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  Future<String> reservationBidAmt(String token, String bidAmt, String  jobId, String junId) async { // 일거리 삭제하기
    print("reservationBidAmt====================================================Start");
    http.Response response = await http.post( '$url/api/service/registBidAmt',
        body: {
          "recieveToken" : token,
          "bidAmt" : bidAmt,
          "jobId" : jobId,
          "junId" : junId
        }
    );
    if (response.statusCode == 200) {
      print("reservationBidAmt====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }
}

HomeServer homeServer = HomeServer();