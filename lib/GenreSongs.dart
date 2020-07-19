import 'dart:convert';

import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:streamify/HttpResponse.dart';
import 'package:streamify/SizeConfig.dart';

class GenreSongs extends StatefulWidget{

  final String title,type;
  GenreSongs({this.title,this.type});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return GenreSongsState();
  }

}

class GenreSongsState extends State<GenreSongs> with TickerProviderStateMixin{

  List<dynamic> albumList=List<dynamic>();

  AnimationController titleAnimation,appBarAnimation;
  ScrollController scrollController=ScrollController();
  int value=0;

  bool showList=false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    titleAnimation=AnimationController(vsync: this,duration: Duration(seconds: 0));
    appBarAnimation=AnimationController(vsync: this,duration: Duration(seconds: 0));

    scrollController.addListener(() {
      double v=1-((scrollController.position.pixels).toInt())/value;
      titleAnimation.value=v;
      appBarAnimation.value=1-titleAnimation.value;
    });

    titleAnimation.value=1.0;
    appBarAnimation.value=0.0;

    getAlbumList();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    value=(SizeConfig.screenHeight*0.2).toInt();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: ScaleTransition(scale: appBarAnimation,child: FadeTransition(opacity: appBarAnimation,child: Text(widget.title,style: TextStyle(color: Colors.white),))),
        backgroundColor: Colors.transparent,
      ),
      body: showList ? Container(
        width: SizeConfig.screenWidth,
        height: double.infinity,
        child: Stack(
          children: [
            Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.only(top: SizeConfig.screenHeight*0.065),
              width: SizeConfig.screenWidth,
              height: double.infinity,
              child: ScaleTransition(scale: titleAnimation,child: FadeTransition(opacity:titleAnimation,child: Text(widget.title,style: TextStyle(fontSize: SizeConfig.screenWidth*0.13,color: Colors.white),))),
            ),
            NestedScrollView(
              physics: ClampingScrollPhysics(),
              controller: scrollController,
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverToBoxAdapter(
                    child: Container(
                      color: Colors.transparent,
                      height: SizeConfig.screenHeight*0.2,
                    ),
                  )
                ];
              },
              body: Container(
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
//                    Container(
//                      height: 30,
//                      width: double.infinity,
//                    ),
                    Flexible(
                      child: Container(
                        width: SizeConfig.screenWidth,
                        color: Colors.black,
                        child: ListView.builder(
                          physics: ClampingScrollPhysics(),
                          itemCount: albumList.length,
                            itemBuilder: (c,i){
                          return ListTile(
                            title: Text(albumList[i]['name'],style: TextStyle(color: Colors.white),),
                            subtitle: Text(albumList[i]['count'].toString()+' songs',style: TextStyle(color: Colors.white54),),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(HttpResponse.AlbumPath+albumList[i]['name']+'.png'),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios,color: Colors.white,),
                            onTap: (){
                              Navigator.push(context, CupertinoPageRoute(
                                builder: (c)=>AlbumSongs(title: albumList[i]['name'],type: '',)
                              ));
                            },
                          );
                        })
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ):Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void getAlbumList()async {

    setState(() {
      showList=false;
    });

    var response=await HttpResponse.getResponse(service: 'genre/${widget.type}');

    print('Album==$response');

    Map<String,dynamic> map=json.decode(response.toString());

    albumList=map['album'] as List;

    setState(() {
      showList=true;
    });

  }

}

class AlbumSongs extends StatefulWidget{

  final String title,type;
  AlbumSongs({this.title,this.type});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AlbumSongsState();
  }

}

class AlbumSongsState extends State<AlbumSongs> with TickerProviderStateMixin{

  List<dynamic> albumList=List<dynamic>();

  AnimationController titleAnimation,appBarAnimation;
  ScrollController scrollController=ScrollController();
  int value=0;

  bool showList=false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    titleAnimation=AnimationController(vsync: this,duration: Duration(seconds: 0));
    appBarAnimation=AnimationController(vsync: this,duration: Duration(seconds: 0));

    scrollController.addListener(() {
      double v=1-((scrollController.position.pixels).toInt())/value;
      titleAnimation.value=v;
      appBarAnimation.value=1-titleAnimation.value;
    });

    titleAnimation.value=1.0;
    appBarAnimation.value=0.0;

    getAlbumList();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    value=(SizeConfig.screenHeight*0.2).toInt();
    return Scaffold(
      backgroundColor: Colors.black,
//      appBar: AppBar(
//        title: ScaleTransition(scale: appBarAnimation,child: FadeTransition(opacity: appBarAnimation,child: Text(widget.title,style: TextStyle(color: Colors.white),))),
//        backgroundColor: Colors.transparent,
//      ),
      body: showList ? Container(
        width: SizeConfig.screenWidth,
        height: double.infinity,
        child: Stack(
          children: [
//            Container(
//              alignment: Alignment.topCenter,
//              //margin: EdgeInsets.only(top: SizeConfig.screenHeight*0.065),
//              width: SizeConfig.screenWidth,
//              height: double.infinity,
//              child: ScaleTransition(scale: titleAnimation,child: FadeTransition(opacity:titleAnimation,child: Image.network(HttpResponse.AlbumPath+widget.title+'.png',fit: BoxFit.cover,height:SizeConfig.screenHeight*0.2,width: SizeConfig.screenWidth*0.7,))),
//            ),
            NestedScrollView(
              physics: ClampingScrollPhysics(),
              controller: scrollController,
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
//                  SliverToBoxAdapter(
//                    child: Container(
//                      color: Colors.transparent,
//                      height: SizeConfig.screenHeight*0.2,
//                    ),
//                  )
                  SliverAppBar(
                    expandedHeight: 200.0,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: Text(widget.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              //backgroundColor: Colors.black26
                            ),
                        ),
                        background: Image.network(
                          HttpResponse.AlbumPath+widget.title+'.png',
                          fit: BoxFit.cover,
                        )),
                  ),
                ];
              },
              body: Container(
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
//                    Container(
//                      height: 30,
//                      width: double.infinity,
//                    ),
                    Flexible(
                      child: Container(
                          width: SizeConfig.screenWidth,
                          color: Colors.black,
                          child: ListView.builder(
                              physics: ClampingScrollPhysics(),
                              itemCount: albumList.length,
                              itemBuilder: (c,i){
                                return ListTile(
                                  title: Text(albumList[i]['name'],style: TextStyle(color: Colors.white),),
                                  subtitle: Text(albumList[i]['artist_name'].toString(),style: TextStyle(color: Colors.white54),),
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(HttpResponse.ImagePath+albumList[i]['name']+'.png'),
                                  ),
                                  trailing: PopupMenuButton<int>(
                                    color: Colors.white,
                                    icon: Icon(Icons.more_vert,color: Colors.white,),
                                    onSelected: (int result) { print('Selected==$result'); },
                                    itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                                      PopupMenuItem<int>(
                                        value: 2,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.favorite_border),
                                            SizedBox(width: 5,),
                                            Text('Like'),
                                          ],
                                        ),
                                      ),
                                       PopupMenuItem<int>(
                                        value: 0,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.queue_music),
                                            SizedBox(width: 5,),
                                            Text('Add to Queue'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<int>(
                                        value: 1,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.playlist_add),
                                            SizedBox(width: 5,),
                                            Text('Add to Playlist'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: (){
                                    AudioManager.instance.audioList.clear();
                                    AudioManager.instance.audioList=[AudioInfo(HttpResponse.SongPath+albumList[i]['name']+'.mp3',title:albumList[i]['name'],desc: albumList[i]['artist_name'],coverUrl:HttpResponse.ImagePath+albumList[i]['name']+'.png')];
                                    AudioManager.instance.play(auto:true);
                                  },
                                );
                              })
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ):Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void getAlbumList()async {

    setState(() {
      showList=false;
    });

    var response=await HttpResponse.getResponse(service: 'songs/${widget.title}');

    print('Album==$response');

    Map<String,dynamic> map=json.decode(response.toString());

    albumList=map['songs'] as List;

    setState(() {
      showList=true;
    });

  }

}