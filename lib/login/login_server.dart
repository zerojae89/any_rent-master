import 'package:any_rent/settings/url.dart';
import 'package:http/http.dart' as http;

// const url = 'http://211.253.20.112'; //개발서버
// const url = "http://192.168.1.3:4001"; //재승 내부 ip

const url = UrlConfig.url;

class LoginServer{

  //회원 가입시 macAdr 전송
  Future<String> sendDeviceToken(String mbrId, String macAdr) async{
    print("sendDeviceToken====================================================Start");
    http.Response response = await http.post( Uri.encodeFull("$url/api/auth/getMac"),
        body: {
          "mbrId" : mbrId,
          "macAdr" : macAdr
        }
    );
    if (response.statusCode == 200) {
      print("sendDeviceToken====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  //앱 기동시 토큰 확인
  Future<String> sendToken(String token,) async{
    print("sendToken====================================================Start");
    http.Response response = await http.post( Uri.encodeFull("$url/api/auth/checkToken"),
        body: { "recieveToken" : token, }
    );
    if (response.statusCode == 200) {
      print("sendToken====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  //로그아웃
  Future<String> logout(String token,) async{
    print("logout====================================================Start");
    http.Response response = await http.post( Uri.encodeFull("$url/api/auth/logout"),
        body: { "recieveToken" : token, }
    );
    if (response.statusCode == 200) {
      print("logout====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  //회원탈퇴
  Future<String> unjoin(String token,) async{
    print("unjoin====================================================Start");
    http.Response response = await http.post( Uri.encodeFull("$url/api/auth/unjoin"),
        body: { "recieveToken" : token, }
    );
    if (response.statusCode == 200) {
      print("unjoin====================================================end");
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

LoginServer loginServer = LoginServer();
