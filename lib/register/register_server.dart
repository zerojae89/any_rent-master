import 'package:http/http.dart' as http;
import 'package:any_rent/settings/url.dart';

// const url = 'http://211.253.20.112'; //개발서버
// const url = "http://192.168.1.3:4001"; //재승 내부 ip

const url = UrlConfig.url;

class RegisterServer{

  //일 유형 1차 정보 가져오기
  Future<String> getTp() async{
    print("getTp1====================================================Start");
    http.Response response = await http.get( '$url/api/service/sendTp' );
    if (response.statusCode == 200) {
      print("getTp1====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  //일 유형 1차 정보로 2차유형 정보 알아오기
  Future<String> getTp2(String tp1Cd) async{
    print("getTp2====================================================Start");
    http.Response response = await http.post( '$url/api/service/sendTp2',
      body: {
        "tp1Cd" : tp1Cd,
      }
    );
    if (response.statusCode == 200) {
      print("getTp2====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  //동네 인증여부 및 등록 동네 불러오기
  Future<String> getTown(String token) async{
    print("getTown====================================================Start");
    http.Response response = await http.post( '$url/api/service/regiCall',
        body: {
          "recieveToken" : token,
        }
    );
    if (response.statusCode == 200) {
      print("getTown====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  //일거리 등록 이미지 없고 선착 순인 경우
  Future<String> sendRegister(dynamic list) async{
    print("sendRegister====================================================Start");
    http.Response response = await http.post( '$url/api/service/register',
        body: list );
    if (response.statusCode == 200) {
      print("sendRegister====================================================end");
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

RegisterServer registerServer = RegisterServer();