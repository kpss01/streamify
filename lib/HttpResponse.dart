
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';


class HttpResponse{

  static String BASE_URL='http://192.168.43.61:3000/';
  static String ImagePath='http://192.168.43.61:3000/images/';
  static String AlbumPath='http://192.168.43.61:3000/album_images/';
  static String SongPath='http://192.168.43.61:3000/songs/';

  static Future<String> postResponse({String service,Map body}){
    String url="http://192.168.43.61:3000/api/"+service;
    print('Url==$url');
    return http.post(url,body: body).then((http.Response response){
      if(response.statusCode<200 || response.statusCode>400 || json==null){
        print('HttpResponse=='+response.body.toString());
        throw new Exception("Error while fetching============================");
      }
      return response.body.toString();
    });
  }

  static Future<String> getResponse({String service}) async{
    String url = "http://192.168.43.61:3000/api/" + service;
    print('Url==$url');
    http.Response response= await http.get(url);
    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      print("Error occur===============================");
      print('HttpResponse=='+response.body.toString());

      return throw new Exception("Error while fetching============================");
    }
    else
      return response.body.toString();
  }

}

