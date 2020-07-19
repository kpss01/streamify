

import 'dart:convert';

import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:streamify/HttpResponse.dart';
import 'package:streamify/SizeConfig.dart';

class SearchPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SearchPageState();
  }

}

class SearchPageState extends State<SearchPage> with TickerProviderStateMixin{

  AnimationController searchAnimation,appBarAnimation;

  List<dynamic> searchList=List<dynamic>(),list=List<dynamic>();

  bool showList=false,showSearchList=true;
  TextEditingController textEditingController=TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchAnimation=AnimationController(vsync: this,duration: Duration(microseconds: 100));
    appBarAnimation=AnimationController(vsync: this,duration: Duration(milliseconds: 100));

    appBarAnimation.value=0.0;
    searchAnimation.value=1.0;

    getListData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: SizeConfig.screenWidth,
        height: double.infinity,
        child:showList ? Stack(
          children: [
            FadeTransition(
              opacity: searchAnimation,
              child: Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.only(top: SizeConfig.screenHeight*0.13),
                width: SizeConfig.screenWidth,
                height: double.infinity,
                child: Text('Search',style: TextStyle(fontSize: SizeConfig.screenWidth*0.13,color: Colors.white),),
              ),
            ),
            FadeTransition(
              opacity: searchAnimation,
              child: NestedScrollView(
                physics: ClampingScrollPhysics(),
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
                      Container(
                        height: 30,
                        width: double.infinity,
                      ),
                      Flexible(
                        child: Container(
                          width: SizeConfig.screenWidth,
                          color: Colors.black,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              InkWell(
                                onTap: (){
                                  print('Clicked===');
                                  searchList=list;
                                  searchAnimation.reverse();
                                  appBarAnimation.forward();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white
                                  ),
                                  margin: EdgeInsets.only(left: 5,right: 5,bottom: 10),
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search),
                                      SizedBox(width: 5,),
                                      Text('Search songs...',style: TextStyle(fontSize: 16),),
                                    ],
                                  ),
                                ),
                              ),
                              Flexible(child: getListView()),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            FadeTransition(
              opacity: appBarAnimation,
              child: ScaleTransition(
                scale: appBarAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 26,
                    ),
                    Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[700]
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 5,
                          ),
                          InkWell(
                            onTap:(){
                              appBarAnimation.reverse();
                              searchAnimation.forward();
                            },
                            borderRadius: BorderRadius.circular(30),
                            child: Icon(Icons.arrow_back,color: Colors.white60,),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Flexible(
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                contentPadding: EdgeInsets.all(0),
                                hintText: 'Search...',
                                hintStyle: TextStyle(
                                    color: Colors.white
                                ),
                              ),
                              controller: textEditingController,
                              style: TextStyle(
                                color: Colors.white
                              ),
                              onChanged: (text){
                                getSearchData(data: text);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: (){
                              if(textEditingController.text.length>0) {
                                textEditingController.text = '';
                                getSearchData(data: '');
                              }
                            },
                            child: Icon(Icons.clear,color: Colors.white60,),
                          ),
                          SizedBox(
                            width: 5,
                          )
                        ],
                      ),
                    ),
                    showSearchList ? Flexible(child: getSearchListView()) : Flexible(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ):Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  void getListData()async {

    setState(() {
      showList=false;
    });

    var response=await HttpResponse.getResponse(service:'search?keyword=');

    print('list==$response');

    Map<String,dynamic> map=json.decode(response.toString());

    list=map['search'] as List;
    searchList=list;

    setState(() {
      showList=true;
    });

  }

 Widget getListView(){

    return ListView.builder(
      padding: EdgeInsets.only(top: 10),
      itemCount: list.length,
        shrinkWrap: true,
        itemBuilder: (c,i){
      return ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(HttpResponse.ImagePath+list[i]['name']+'.png'),
        ),
        title: Text(list[i]['name'],style: TextStyle(color: Colors.white),),
        subtitle: Text(list[i]['artist_name'],style: TextStyle(color: Colors.white54),),
        onTap: (){
          AudioManager.instance.audioList.clear();
          AudioManager.instance.audioList=[AudioInfo(HttpResponse.SongPath+list[i]['name']+'.mp3',title:list[i]['name'],desc: list[i]['artist_name'],coverUrl:HttpResponse.ImagePath+list[i]['name']+'.png')];
          AudioManager.instance.play(auto:true);
        },
      );
    });

  }

  void getSearchData({String data})async{

    setState(() {
      showSearchList=false;
    });

    var response=await HttpResponse.getResponse(service:'search?keyword=$data');

    print('SearchList==$response');

    Map<String,dynamic> map=json.decode(response.toString());

    searchList=map['search'] as List;

    setState(() {
      showSearchList=true;
    });

  }

  Widget getSearchListView(){
    if(searchList.length==0){
      return Center(
        child: Text('No result found',style: TextStyle(color: Colors.white70,fontSize: 16),),
      );
    }
    return ListView.builder(
        padding: EdgeInsets.only(top: 10),
        itemCount: searchList.length,
        shrinkWrap: true,
        itemBuilder: (c,i){
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(HttpResponse.ImagePath+searchList[i]['name']+'.png'),
            ),
            title: Text(searchList[i]['name'],style: TextStyle(color: Colors.white),),
            subtitle: Text(searchList[i]['artist_name'],style: TextStyle(color: Colors.white54),),
            onTap: (){
              AudioManager.instance.audioList.clear();
              AudioManager.instance.audioList=[AudioInfo(HttpResponse.SongPath+searchList[i]['name']+'.mp3',title:searchList[i]['name'],desc: searchList[i]['artist_name'],coverUrl:HttpResponse.ImagePath+searchList[i]['name']+'.png')];
              AudioManager.instance.play(auto:true);
            },
          );
        });
  }

}