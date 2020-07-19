import 'dart:async';
import 'dart:convert';
import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:streamify/GenreSongs.dart';
import 'package:streamify/HttpResponse.dart';
import 'package:streamify/main.dart';


class RootPage extends StatefulWidget{

  final Destination destination;

  const RootPage({ Key key, this.destination }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return RootPageState();
  }

}

class RootPageState extends State<RootPage> {


  List<dynamic> songsList=List<dynamic>(),top10Punjabi=List<dynamic>(),top10Hindi=List<dynamic>(),top10English=List<dynamic>();
  bool showList=false;
  double screenW=0.0,screenH=0.0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSongList();
  }

  @override
  Widget build(BuildContext context) {
    screenW=MediaQuery.of(context).size.width;
    screenH=MediaQuery.of(context).size.height;

    return Scaffold(
//      appBar: AppBar(
//        title: Text(widget.destination.title,style: TextStyle(color: Colors.white),),
//        backgroundColor: Colors.black87,
//      ),
      backgroundColor: Colors.black87,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        //padding: EdgeInsets.only(top: 10),
        child: showList ? SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 56,),
              Container(alignment: Alignment.center,child: Text('Welcome user',style: TextStyle(fontSize: screenW*0.06,color: Colors.white),textAlign: TextAlign.center,)),
              SizedBox(height: 30,),
              Container(margin: EdgeInsets.only(left: 5),child: Text('Genre',style: TextStyle(fontSize: screenW*0.05,color: Colors.white,fontWeight: FontWeight.w600))),
              SizedBox(
                height: 10,
              ),
              Container(
                //height: screenW*0.3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: (){
                              Navigator.push(context, CupertinoPageRoute(
                                builder: (c)=>GenreSongs(title: 'Punjabi albums',type: 'punjabi_album',)
                              ));
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 5),
                              //width: screenW*0.5,
                              //height: screenW*0.3,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors:[
                                        Colors.red[200],
                                        Colors.red[400],
                                        Colors.red[600]
                                      ]
                                  ),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              padding: EdgeInsets.all(8),
                              alignment: Alignment.center,
                              child: Text('Punjabi Songs',maxLines: 2,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: screenW*0.04,color: Colors.white,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: (){
                              Navigator.push(context, CupertinoPageRoute(
                                  builder: (c)=>GenreSongs(title: 'English albums',type: 'english_album',)
                              ));
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 10),
                              //width: screenW*0.3,
                             // height: screenW*0.3,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors:[
                                        Colors.purple[200],
                                        Colors.purple[400],
                                        Colors.purple[600]
                                      ]
                                  ),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              padding: EdgeInsets.all(8),
                              alignment: Alignment.center,
                              child: Text('English Songs',maxLines: 2,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: screenW*0.04,color: Colors.white,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: (){
                              Navigator.push(context, CupertinoPageRoute(
                                  builder: (c)=>GenreSongs(title: 'Hindi albums',type: 'hindi_album',)
                              ));
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 5),
                              width: screenW*0.5,
                             // height: screenW*0.3,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors:[
                                        Colors.green[200],
                                        Colors.green[400],
                                        Colors.green[600]
                                      ]
                                  ),
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              padding: EdgeInsets.all(8),
                              alignment: Alignment.center,
                              child: Text('Hindi Songs',maxLines: 2,overflow: TextOverflow.ellipsis,style: TextStyle(fontSize: screenW*0.04,color: Colors.white,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(color: Colors.transparent,),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 25,
              ),
              getTop10Punjabi(),
              SizedBox(height: 15,),
              getTop10English(),
              SizedBox(height: 15,),
              getTop10Hindi(),
            ],
          ),
        ):Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  void getSongList() async{

//    setState(() {
//      showList=false;
//    });
    var response = await HttpResponse.getResponse(service: 'top_10?genre=punjabi');

    print("SongsList==$response");

    Map<String, dynamic> map = json.decode(response.toString());

    top10Punjabi = map['songs'] as List;

    response = await HttpResponse.getResponse(service: 'top_10?genre=english');

    print("SongsList==$response");

    map = json.decode(response.toString());

    top10English = map['songs'] as List;

    response = await HttpResponse.getResponse(service: 'top_10?genre=hindi');

    print("SongsList==$response");

    map = json.decode(response.toString());

    top10Hindi = map['songs'] as List;

    setState(() {
      showList = true;
    });

  }

  Widget getTop10Punjabi() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(margin: EdgeInsets.only(left: 5),child: Text('Top 10 Punjabi Songs',style: TextStyle(fontSize: screenW*0.04,color: Colors.white,fontWeight: FontWeight.w600),)),
        SizedBox(height: 15,),
        SizedBox(
          width: screenW,
          height: screenW*0.45,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: top10Punjabi.length,
              itemBuilder: (c,i){
                return Container(
                  width:screenW*0.3 ,
                  height: screenW*0.5,
                  padding: EdgeInsets.only(left: 5,right: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: (){
                          AudioManager.instance.stop();
                          AudioManager.instance.audioList.clear();
                          AudioManager.instance.audioList=[AudioInfo(HttpResponse.SongPath+top10Punjabi[i]['name']+'.mp3',title:top10Punjabi[i]['name'],desc: top10Punjabi[i]['artist_name'],coverUrl:HttpResponse.ImagePath+top10Punjabi[i]['name']+'.png')];
                          AudioManager.instance.play(auto:true);
                        },
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(HttpResponse.ImagePath+top10Punjabi[i]['name']+'.png',height: screenW*0.3,width: screenW*0.3,fit: BoxFit.cover,),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Flexible(
                        child: Text(
                          top10Punjabi[i]['name'].toString(),style: TextStyle(fontSize: screenW*0.03,color:Colors.white ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                );
              }),
        ),
      ],
    );

  }

  Widget getTop10English() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(margin: EdgeInsets.only(left: 5),child: Text('Top 10 English Songs',style: TextStyle(fontSize: screenW*0.04,color: Colors.white,fontWeight: FontWeight.w600),)),
        SizedBox(height: 15,),
        SizedBox(
          width: screenW,
          height: screenW*0.45,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: top10English.length,
              itemBuilder: (c,i){
                return Container(
                  width:screenW*0.3 ,
                  height: screenH*0.5,
                  padding: EdgeInsets.only(left: 5,right: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: (){
                          AudioManager.instance.stop();
                          AudioManager.instance.audioList.clear();
                          AudioManager.instance.audioList=[AudioInfo(HttpResponse.SongPath+top10English[i]['name']+'.mp3',title:top10English[i]['name'],desc: top10English[i]['artist_name'],coverUrl:HttpResponse.ImagePath+top10English[i]['name']+'.png')];
                          AudioManager.instance.play(auto:true);
                        },
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(HttpResponse.ImagePath+top10English[i]['name']+'.png',height: screenW*0.3,width: screenW*0.3,fit: BoxFit.cover,),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Flexible(
                        child: Text(
                          top10English[i]['name'].toString(),style: TextStyle(fontSize: screenW*0.03,color:Colors.white ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                );
              }),
        ),
      ],
    );

  }

  Widget getTop10Hindi() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(margin: EdgeInsets.only(left: 5),child: Text('Top 10 Hindi Songs',style: TextStyle(fontSize: screenW*0.04,color: Colors.white,fontWeight: FontWeight.w600),)),
        SizedBox(height: 15,),
        SizedBox(
          width: screenW,
          height: screenW*0.45,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: top10Hindi.length,
              itemBuilder: (c,i){
                return Container(
                  width:screenW*0.3 ,
                  height: screenH*0.5,
                  padding: EdgeInsets.only(left: 5,right: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: (){
                          AudioManager.instance.stop();
                          AudioManager.instance.audioList.clear();
                          AudioManager.instance.audioList=[AudioInfo(HttpResponse.SongPath+top10Hindi[i]['name']+'.mp3',title:top10Hindi[i]['name'],desc: top10Hindi[i]['artist_name'],coverUrl:HttpResponse.ImagePath+top10Hindi[i]['name']+'.png')];
                          AudioManager.instance.play(auto:true);
                        },
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(HttpResponse.ImagePath+top10Hindi[i]['name']+'.png',height: screenW*0.3,width: screenW*0.3,fit: BoxFit.cover,),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Flexible(
                        child: Text(
                          top10Hindi[i]['name'].toString(),style: TextStyle(fontSize: screenW*0.03,color:Colors.white ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                );
              }),
        ),
      ],
    );

  }
}