import 'dart:async';
import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:streamify/RootPage.dart';
import 'package:streamify/HttpResponse.dart';
import 'package:streamify/SearchPage.dart';
import 'package:streamify/SizeConfig.dart';
import 'package:streamify/SongPlayer.dart';

class Destination {
  Destination(this.index, this.title, this.icon, this.color);
  final int index;
  final String title;
  final IconData icon;
  final Color color;
}

List<Destination> allDestinations = <Destination>[
  Destination(0, 'Home', Icons.home, Colors.grey),
  Destination(1, 'Search', Icons.search, Colors.grey),
  Destination(2, 'Playlist', Icons.playlist_play, Colors.grey),
];




class ViewNavigatorObserver extends NavigatorObserver {
  ViewNavigatorObserver(this.onNavigation);

  final VoidCallback onNavigation;

  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    onNavigation();
  }
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    onNavigation();
  }
}

class DestinationView extends StatefulWidget {
  const DestinationView({ Key key, this.destination, this.onNavigation }) : super(key: key);

  final Destination destination;
  final VoidCallback onNavigation;

  @override
  _DestinationViewState createState() => _DestinationViewState();
}

class _DestinationViewState extends State<DestinationView> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      observers: <NavigatorObserver>[
        ViewNavigatorObserver(widget.onNavigation),
      ],
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            if(widget.destination.index==0) {
              switch (settings.name) {
                case '/':
                  return RootPage(destination: widget.destination);
                default:
                  return RootPage(destination: widget.destination);
              }
            }
            else if(widget.destination.index==1){
              switch(settings.name) {
                case '/':
                  return SearchPage();
                default:
                  return SearchPage();
              }
            }
            else{
              switch(settings.name) {
                case '/':
                  return RootPage(destination: widget.destination);
                default:
                  return RootPage(destination: widget.destination);
              }
            }
          },
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin<HomePage> {


  List<Key> _destinationKeys;
  List<AnimationController> _faders;
  AnimationController _hide,playerScale,rectController,playerPage,rect_1_cont,songText,songText_1,_hidePlayer;
  int _currentIndex = 0;
  Animation<double> scalePlayer;

  RelativeRectTween relativeRectTween,rect_1;

  @override
  void initState() {
    super.initState();

    _faders = allDestinations.map<AnimationController>((Destination destination) {
      return AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    }).toList();
    _faders[_currentIndex].value = 1.0;
    _destinationKeys = List<Key>.generate(allDestinations.length, (int index) => GlobalKey()).toList();
    _hide = AnimationController(vsync: this, duration: Duration(seconds: 0),);
    _hidePlayer=AnimationController(vsync: this,duration: Duration(milliseconds: 200));
    playerScale=AnimationController(vsync: this,duration: Duration(seconds: 0));
    scalePlayer=Tween<double>(begin: 0.0, end: 1.0).animate(playerScale);
    playerPage=AnimationController(
      vsync: this,
      duration: const Duration(seconds: 0),
    );

    rectController=AnimationController(
      vsync: this,
      duration: const Duration(seconds: 0),
    );
    rect_1_cont=AnimationController(
      vsync: this,
      duration: const Duration(seconds: 0),
    );

    songText=AnimationController(
      vsync: this,
      duration: const Duration(seconds: 0),
    );
    songText_1=AnimationController(
      vsync: this,
      duration: const Duration(seconds: 0),
    );

    songText.value=1.0;
    _hidePlayer.value=0.0;
  }

  @override
  void dispose() {
    for (AnimationController controller in _faders)
      controller.dispose();
    _hide.dispose();
    AudioManager.instance.stop();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
//    if (notification.depth == 0) {
//      if (notification is UserScrollNotification) {
//        final UserScrollNotification userScroll = notification;
//        switch (userScroll.direction) {
//          case ScrollDirection.forward:
//            _hide.forward();
//            break;
//          case ScrollDirection.reverse:
//            _hide.reverse();
//            break;
//          case ScrollDirection.idle:
//            break;
//        }
//      }
//    }
    return false;
  }

  bool showPlayer=false;
  double h=60,lastDrag=60;
  double reqH=0.0,screenH=0.0,screenW=0.0,initial=0.0;




  @override
  Widget build(BuildContext context) {
    //reqH=MediaQuery.of(context).size.height-kBottomNavigationBarHeight;
    screenH=MediaQuery.of(context).size.height;
    SizeConfig.screenHeight=screenH;
    reqH=screenH;
    screenW=MediaQuery.of(context).size.width;
    SizeConfig.screenWidth=screenW;
    if(initial==0.0){
      relativeRectTween = RelativeRectTween(
        begin: RelativeRect.fromLTRB(0, 0, screenW-60, 0),
        end: RelativeRect.fromLTRB(screenW*0.05, screenH*0.15, screenW*0.05, screenH*0.4),
      );

      initial=60/screenH;
      playerPage.value=initial;

      relativeRectTween = RelativeRectTween(
        begin: RelativeRect.fromLTRB(0, 0, screenW-60, 0),
        end: RelativeRect.fromLTRB(screenW*0.05, screenH*0.15, screenW*0.05, screenH*0.4),
      );
      rect_1= RelativeRectTween(
        begin: RelativeRect.fromLTRB(0, screenH-58-60, 0,0),
        end: RelativeRect.fromLTRB(0, 0, 0, 0),
      );
    }


//    return NotificationListener<ScrollNotification>(
//      onNotification: _handleScrollNotification,
//      child:
      return Scaffold(
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              margin: EdgeInsets.only(bottom: marginBottom),
              child: Stack(
                fit: StackFit.expand,
                children: allDestinations.map((Destination destination) {
                  final Widget view = FadeTransition(
                    opacity: _faders[destination.index].drive(CurveTween(curve: Curves.fastOutSlowIn)),
                    child: KeyedSubtree(
                      key: _destinationKeys[destination.index],
                      child: DestinationView(
                        destination: destination,
                        onNavigation: () {
                          _hide.forward();
                        },
                      ),
                    ),
                  );
                  if (destination.index == _currentIndex) {
                    _faders[destination.index].forward();
                    return view;
                  } else {
                    _faders[destination.index].reverse();
                    if (_faders[destination.index].isAnimating) {
                      return IgnorePointer(child: view);
                    }
                    return Offstage(child: view);
                  }
                }).toList(),
              ),
            ),
            PositionedTransition(
              rect: rect_1.animate(rect_1_cont),
              child: FadeTransition(
                opacity: _hidePlayer,
                child: ScaleTransition(
                  scale: _hidePlayer,
                  child: GestureDetector(
                      onTapUp:(tap)async{

                        print('CLicked---');

                        if(playerPage.value==initial){
                          while(h<screenH){
                            await Future.delayed(Duration(microseconds: 1));
                            if(h+4<screenH)
                              h+=4;
                            else h=screenH;
                            playerPage.value=h/screenH;
                            if(h>61) {
                              double v=(h-60)/(screenH-60);
                              rectController.value = v;
                              _hide.value = 1 - v;
                              rect_1_cont.value=v;
                            }
                            if(playerPage.value<=0.5){
                              songText.value=1-(2*playerPage.value);
                              songText_1.value=0.0;
                            }
                            else{
                              songText.value=0.0;
                              songText_1.value=2*(playerPage.value-0.5);
                            }
                          }
                          songText.value=0.0;
                          songText_1.value=1.0;
                        }

                      },
                    onVerticalDragUpdate: (drag){
                      // print(drag.primaryDelta);
                      h=playerPage.value*screenH;
                      if(h>=60 && h-drag.primaryDelta>=60 && h-drag.primaryDelta<=reqH){
                        h-=drag.primaryDelta;
                        playerPage.value=h/screenH;
                        if(h>61) {
                          double v=(h-60)/(screenH-60);
                          rectController.value = v;
                          _hide.value = 1 - v;
                        }

                        if(playerPage.value<=0.5){
                          songText.value=1-(2*playerPage.value);
                          songText_1.value=0.0;
                        }
                        else{
                          songText.value=0.0;
                          songText_1.value=2*(playerPage.value-0.5);
                        }
//
                      }

                      if(lastDrag<h){
                        lastDrag=h;
                        showPlayer=true;
                      }
                      else{
                        lastDrag=h;
                        showPlayer=false;
                      }

                      rect_1_cont.value=rectController.value;

                      print('value==${playerPage.value}');

                    },
                    onVerticalDragEnd: (drag)async{
                      //print('tapped up=====123==========$showPlayer');
                      if(showPlayer){
                        while(h<screenH){
                          await Future.delayed(Duration(microseconds: 1));
                          h+=4;
                          playerPage.value=h/screenH;
                          if(h>61) {
                            double v=(h-60)/(screenH-60);
                            rectController.value = v;
                            _hide.value = 1 - v;
                            rect_1_cont.value=v;
                          }
                          if(playerPage.value<=0.5){
                            songText.value=1-(2*playerPage.value);
                            songText_1.value=0.0;
                          }
                          else{
                            songText.value=0.0;
                            songText_1.value=2*(playerPage.value-0.5);
                          }
                        }
                        songText.value=0.0;
                        songText_1.value=1.0;
                      }
                      else{
                        while(h>60){
                          await Future.delayed(Duration(microseconds: 1));
                          if(h-4>=60)
                            h-=4;
                          else h=60;
                          playerPage.value=h/screenH;
                          if(h>61) {
                            double v=(h-60)/(screenH-60);
                            rectController.value = v;
                            _hide.value = 1 - v;
                            rect_1_cont.value=v;

                          }
                          if(playerPage.value<=0.5){
                            songText.value=1-(2*playerPage.value);
                            songText_1.value=0.0;
                          }
                          else{
                            songText.value=0.0;
                            songText_1.value=2*(playerPage.value-0.5);
                          }
                        }
                        songText.value=1.0;
                        songText_1.value=0.0;
                      }
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                            ),
                            alignment: Alignment.topLeft,
                            // height: screenH,
                            width: MediaQuery.of(context).size.width,
                            child: ManagePlayerLayout(),
                          ),
                        ),
                        Container(
                          height: 2,
                          width: screenW,
                          color: Colors.black,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
        bottomNavigationBar: ClipRect(
          child: SizeTransition(
            sizeFactor: _hide,
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (int index) {
                setState(() {
                  print('line==404');
                  _currentIndex = index;
                });
              },
              backgroundColor: Colors.grey[900],
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
              items: allDestinations.map((Destination destination) {
                return BottomNavigationBarItem(
                    icon: Icon(destination.icon),
                    backgroundColor: Colors.grey[900],
                    title: Text(destination.title)
                );
              }).toList(),
            ),
          ),
        ),
      );
    //);
  }

  Color playerColor=Colors.grey[900];

  double transX=0,transY=0,imageH=0.0,imageW=0.0,showPlayerText=0.0,songPlayerValue=0;
  int songDuration=0;

  bool showPlayButton=true;


  List<String> songPlayed=['0','00'];


  String maxTimeOfSong='0:00';

  double marginBottom=0;


  String songLink='http://192.168.43.61:3000/songs/Attention.mp3';
  String songImage=HttpResponse.BASE_URL+'images/songicon.png',songTitle='NA',songArtist='NA';

  GlobalKey<SongPlayerState> songPlayerStateGlobal=GlobalKey();


  Widget ManagePlayerLayout(){

    return Container(
      margin: EdgeInsets.only(top: 1),
      color: Colors.grey[900],
      width: screenW,
      child: Stack(
        children: [
          Positioned(
            left: 70,
            right: 0,
            top: 0,
            child: FadeTransition(
              opacity: songText,
              child: Container(
                //margin: EdgeInsets.only(left: 70),
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 5,
                      child: InkWell(

                        child: Container(
                          width: double.infinity,
                          height: 60,
                          alignment: Alignment.centerLeft,
                          child: Text('$songTitle',style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,),
                        ),
                      ),
                    ),
                    //Flexible(flex: 5,child: ScrollingText(text: 'Dragon ball super',textStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 16),)),
                    Flexible(
                      flex: 1,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: ()async{

                          print('CLicked---');

                          await AudioManager.instance.playOrPause();
                          bool playing=AudioManager.instance.isPlaying;
                          setState(() {
                            showPlayButton=!playing;
                            print('line===640');
                          });
                          songPlayerStateGlobal.currentState.UpdatePlayButton(showPlayButton);
                        },
                        child: Card(
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)
                          ),
                          elevation: 0,
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 200),
                            child: showPlayButton?
                            Icon(Icons.play_arrow,color: Colors.white,size: 30,):
                            Icon(Icons.pause,color: Colors.white,size: 30,),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          PositionedTransition(
            rect: relativeRectTween.animate(rectController),
            child: FittedBox(
              child: Card(
                elevation: 40,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network('$songImage',fit: BoxFit.cover,
                      height: screenW,
                      width: screenW,
                    )),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: SizeTransition(
              sizeFactor: rectController,
              child: ScaleTransition(
                scale: rectController,
                child: SongPlayer(
                  playOrPause: (value){
                    print('Update==PlayOrPause==$value');
                    setState(() {
                      showPlayButton=value;
                      print('line==561');
                    });
                  },
                  key: songPlayerStateGlobal,
                  updateImage: (value){
                    if(_hidePlayer.value==0.0){
                      marginBottom=60;
                      _hidePlayer.forward();
                    }
                    print('UpDateImage===$value');
                    List<String> s=value.split(',');
                    setState(() {
                      songImage=s[0];
                      songTitle=s[1];
                      print('line==575');
                    });
                  },
                ),
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ScaleTransition(
              scale: songText_1,
              child: FadeTransition(
                opacity: songText_1,
                child: SizedBox(
                  height: 60,
                  width: screenW,
                  child: Container(
                    margin: EdgeInsets.only(top:23,right: 10),
                    color: Colors.transparent,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                            onTap: ()async{
                              showPlayer=false;
                              while(h>60){
                                await Future.delayed(Duration(microseconds: 1));
                                if(h-4>=60)
                                  h-=4;
                                else h=60;
                                playerPage.value=h/screenH;
                                if(h>61) {
                                  double v=(h-60)/(screenH-60);
                                  rectController.value = v;
                                  _hide.value = 1 - v;
                                  rect_1_cont.value=v;
                                }
                                if(playerPage.value<=0.5){
                                  songText.value=1-(2*playerPage.value);
                                  songText_1.value=0.0;
                                }
                                else{
                                  songText.value=0.0;
                                  songText_1.value=2*(playerPage.value-0.5);
                                }
                              }
                              songText.value=1.0;
                              songText_1.value=0.0;
                            },
                            child: Icon(Icons.keyboard_arrow_down,color: Colors.white,size: 40,)),
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.only(right: screenW*0.1,top: 5),
                            alignment: Alignment.center,
                            child:Text('Spotify',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void ManagePlayerColor(double value){
    setState(() {
      print('line==660');
      if(value>0.9){
        playerColor=Colors.grey[500];
      }
      else if(value>0.8){
        playerColor=Colors.grey[500];
      }
      else if(value>0.7){
        playerColor=Colors.grey[500];
      }
      else if(value>0.6){
        playerColor=Colors.grey[500];
      }
      else if(value>0.5){
        playerColor=Colors.grey[600];
      }
      else if(value>0.4){
        playerColor=Colors.grey[700];
      }
      else if(value>0.3){
        playerColor=Colors.grey[800];
      }
      else if(value>0.2){
        playerColor=Colors.grey[900];
      }
      else playerColor=Colors.grey[900];
    });
  }

}

void main() {
  runApp(MaterialApp(home: HomePage(),debugShowCheckedModeBanner: false,theme: ThemeData(
    primaryColor: Colors.black
  ),));
 // runApp(HomePage());
}

