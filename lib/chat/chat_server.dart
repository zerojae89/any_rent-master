import 'package:any_rent/settings/url.dart';
import 'package:http/http.dart' as http;

// const url = 'http://211.253.20.112'; //개발서버
// const url = "http://192.168.1.3:4001"; //재승 내부 ip
// const url = "http://192.168.1.2:4000"; // 내 로컬 ip

const url = UrlConfig.url;

class ChatServer{

  Future<String> getChatList(String token ) async{ //채팅 목록 조회하기
    print("getChatList====================================================Start");
    http.Response response = await http.post( '$url/api/chat/chatList',
        body: {
          "recieveToken" : token,
        }
    );
    if (response.statusCode == 200) {
      print("getChatList====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  Future<String> getChatCnt(String jobId, String junId, String hanId ) async{ //채팅방 유저 프로필 가져오기
    print("getChatProfile====================================================Start");
    http.Response response = await http.post( '$url/api/chat/chatCnt',
        body: {
          "jobId" : jobId,
          "junId" : junId,
          "hanId" : hanId,
        }
    );
    if (response.statusCode == 200) {
      print("getChatProfile====================================================end");
      print(response.body);
      String jsonString = response.body;
      return jsonString;
    } else {
      throw Exception('error');
      // print('error!!!!!!!!!!');
      // return "error";
    }
  }

  Future<String> getProfile(String mbrId, String userId ) async{ //채팅방 유저 프로필 가져오기
    print("getProfile====================================================Start");
    http.Response response = await http.post( '$url/api/chat/getProfile',
        body: { "mbrId" : mbrId,  "userId" : userId, }
    );
    if (response.statusCode == 200) {
      print("getProfile====================================================end");
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

ChatServer chatServer = ChatServer();