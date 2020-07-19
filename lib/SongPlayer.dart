import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:streamify/HttpResponse.dart';


typedef  PlayOrPause= void Function(bool);
typedef UpdateImage=void Function(String);

class SongPlayer extends StatefulWidget {

  PlayOrPause playOrPause;
  UpdateImage updateImage;


  SongPlayer({
    Key key,
    this.playOrPause,
    this.updateImage
  }) : super(key: key);
  @override
  SongPlayerState createState() => SongPlayerState();
}

class SongPlayerState extends State<SongPlayer> {
  String _platformVersion = 'Unknown';
  bool isPlaying = false;
  Duration _duration;
  Duration _position;
  double _slider;
  double _sliderVolume;
  String _error;
  num curIndex = 0;
  PlayMode playMode = AudioManager.instance.playMode;

  String songImage=HttpResponse.BASE_URL+'images/songicon.png',songTitle='NA',songArtist='NA';


  @override
  void initState() {
    super.initState();

    initPlatformState();
    setupAudio();
    // loadFile();
  }

  @override
  void dispose() {
    // 释放所有资源
    AudioManager.instance.stop();
    super.dispose();
  }
  void setupAudio() {

//    AudioManager.instance.audioList = _list;
//    AudioManager.instance.intercepter = true;
//    AudioManager.instance.play(auto: false);

    AudioManager.instance.onEvents((events, args) {
      print("$events, $args");
      switch (events) {
        case AudioManagerEvents.start:
          print("start load data callback, curIndex is ${AudioManager.instance.curIndex}");
          _position = AudioManager.instance.position;
          _duration = AudioManager.instance.duration;
          _slider = 0;
          songTitle=AudioManager.instance.audioList[AudioManager.instance.curIndex].title;
          String value=AudioManager.instance.audioList[AudioManager.instance.curIndex].coverUrl+','+songTitle;
          widget.updateImage(value);
          showPlayButton =false;
          widget.playOrPause(false);
          AudioManager.instance.intercepter=true;
          songArtist=AudioManager.instance.audioList[AudioManager.instance.curIndex].desc;
          setState(() {});
          break;
        case AudioManagerEvents.ready:
          print("ready to play");
          _error = null;
          _sliderVolume = AudioManager.instance.volume;
          _position = AudioManager.instance.position;
          _duration = AudioManager.instance.duration;

          setState(() {});
          // if you need to seek times, must after AudioManagerEvents.ready event invoked
          // AudioManager.instance.seekTo(Duration(seconds: 10));
          break;
        case AudioManagerEvents.seekComplete:
          _position = AudioManager.instance.position;
          _slider = _position.inMilliseconds / _duration.inMilliseconds;
          setState(() {});
          print("seek event is completed. position is [$args]/ms");
          break;
        case AudioManagerEvents.buffering:
          print("buffering $args");
          break;
        case AudioManagerEvents.playstatus:
          showPlayButton =!AudioManager.instance.isPlaying;
          widget.playOrPause(showPlayButton);
          setState(() {});
          break;
        case AudioManagerEvents.timeupdate:
          _position = AudioManager.instance.position;
          _slider = _position.inMilliseconds / _duration.inMilliseconds;
          setState(() {});
          AudioManager.instance.updateLrc('${_formatDuration(_position)} / ${_formatDuration(_duration)}');
          break;
        case AudioManagerEvents.error:
          _error = args;
          setState(() {});
          break;
        case AudioManagerEvents.ended:
          AudioManager.instance.next();
          break;
        case AudioManagerEvents.volumeChange:
          _sliderVolume = AudioManager.instance.volume;
          setState(() {});
          break;
        default:
          break;
      }
    });
  }


  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await AudioManager.instance.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  double screenH=0.0,screenW=0.0;

  bool showPlayButton=true;

  @override
  Widget build(BuildContext context) {

    screenH=MediaQuery.of(context).size.height;
    screenW=MediaQuery.of(context).size.width;
    return Container(
      alignment: Alignment.bottomCenter,
      height: screenH*0.3,
      color: Colors.transparent,
      width: screenW,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 20),
            child: Text('$songTitle',style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500
            ),),
          ),
          Container(
            margin: EdgeInsets.only(left: 20,top: 5),
            child: Text('$songArtist',style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w500
            ),),
          ),
          SizedBox(height: 10,),
          SliderTheme(
            data: SliderThemeData(
                trackHeight: 3
            ),
            child: Slider.adaptive(
              activeColor: Colors.white,
              value: _slider ?? 0,
              onChanged: (value) {
                setState(() {
                  _slider = value;
                });
              },
              onChangeEnd: (value) {
                if (_duration != null) {
                  Duration msec = Duration(
                      milliseconds:
                      (_duration.inMilliseconds * value).round());
                  AudioManager.instance.seekTo(msec);
                }
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 20,right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedContainer(
                  duration: Duration(seconds: 0),
                  transform: Matrix4.translationValues(0, -10, 0),
                  child: Text(_formatDuration(_position),style: TextStyle(
                      color: Colors.white,
                      fontSize: 12
                  ),),
                ),

                AnimatedContainer(
                  duration: Duration(seconds: 0),
                  transform: Matrix4.translationValues(0, -10, 0),
                  child: Text(_formatDuration(_duration),style: TextStyle(
                      color: Colors.white,
                      fontSize: 12
                  ),),
                ),
              ],
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RotatedBox(quarterTurns:2,child: Icon(Icons.skip_next,color: Colors.white,size: screenH*0.05,)),
                SizedBox(
                  width: 15,
                ),
                Container(
                  width: screenH*0.1,
                  height: screenH*0.1,
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(screenH*0.1)
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(screenH*0.1),
                    onTap: ()async{

                      //getDuration();

                      bool playing = await AudioManager.instance.playOrPause();
                      setState(() {
                        showPlayButton=!playing;
                      });
                      widget.playOrPause(showPlayButton);
                    },
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenH*0.1)
                      ),
                      elevation: 0,
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        child: showPlayButton?Icon(Icons.play_arrow,color: Colors.black87,size: screenH*0.05,):Icon(Icons.pause,color: Colors.black87,size: screenH*0.05,),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                InkWell(
                    onTap: (){

                    },
                    child: RotatedBox(quarterTurns:0,child: Icon(Icons.skip_next,color: Colors.white,size: screenH*0.05,))),

              ],
            ),
          )
        ],
      ),
    );
  }

  void UpdatePlayButton(bool playOrPause){
    setState(() {
      showPlayButton=playOrPause;
    });
  }

  Widget bottomPanel() {
    return Column(children: <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: songProgress(context),
      ),
      Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                icon: getPlayModeIcon(playMode),
                onPressed: () {
                  playMode = AudioManager.instance.nextMode();
                  setState(() {});
                }),
            IconButton(
                iconSize: 36,
                icon: Icon(
                  Icons.skip_previous,
                  color: Colors.black,
                ),
                onPressed: () => AudioManager.instance.previous()),
            IconButton(
              onPressed: () async {
                bool playing = await AudioManager.instance.playOrPause();
                print("await -- $playing");
              },
              padding: const EdgeInsets.all(0.0),
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 48.0,
                color: Colors.black,
              ),
            ),
            IconButton(
                iconSize: 36,
                icon: Icon(
                  Icons.skip_next,
                  color: Colors.black,
                ),
                onPressed: () => AudioManager.instance.next()),
            IconButton(
                icon: Icon(
                  Icons.stop,
                  color: Colors.black,
                ),
                onPressed: () => AudioManager.instance.stop()),
          ],
        ),
      ),
    ]);
  }

  Widget getPlayModeIcon(PlayMode playMode) {
    switch (playMode) {
      case PlayMode.sequence:
        return Icon(
          Icons.repeat,
          color: Colors.black,
        );
      case PlayMode.shuffle:
        return Icon(
          Icons.shuffle,
          color: Colors.black,
        );
      case PlayMode.single:
        return Icon(
          Icons.repeat_one,
          color: Colors.black,
        );
    }
    return Container();
  }

  Widget songProgress(BuildContext context) {
    var style = TextStyle(color: Colors.black);
    return Row(
      children: <Widget>[
        Text(
          _formatDuration(_position),
          style: style,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbColor: Colors.blueAccent,
                  overlayColor: Colors.blue,
                  thumbShape: RoundSliderThumbShape(
                    disabledThumbRadius: 5,
                    enabledThumbRadius: 5,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: 10,
                  ),
                  activeTrackColor: Colors.blueAccent,
                  inactiveTrackColor: Colors.grey,
                ),
                child: Slider(
                  value: _slider ?? 0,
                  onChanged: (value) {
                    setState(() {
                      _slider = value;
                    });
                  },
                  onChangeEnd: (value) {
                    if (_duration != null) {
                      Duration msec = Duration(
                          milliseconds:
                          (_duration.inMilliseconds * value).round());
                      AudioManager.instance.seekTo(msec);
                    }
                  },
                )),
          ),
        ),
        Text(
          _formatDuration(_duration),
          style: style,
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    if (d == null) return "--:--";
    int minute = d.inMinutes;
    int second = (d.inSeconds > 60) ? (d.inSeconds % 60) : d.inSeconds;
    String format = ((minute < 10) ? "0$minute" : "$minute") +
        ":" +
        ((second < 10) ? "0$second" : "$second");
    return format;
  }

  Widget volumeFrame() {
    return Row(children: <Widget>[
      IconButton(
          padding: EdgeInsets.all(0),
          icon: Icon(
            Icons.audiotrack,
            color: Colors.black,
          ),
          onPressed: () {
            AudioManager.instance.setVolume(0);
          }),
      Expanded(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Slider(
                value: _sliderVolume ?? 0,
                onChanged: (value) {
                  setState(() {
                    _sliderVolume = value;
                    AudioManager.instance.setVolume(value, showVolume: true);
                  });
                },
              )))
    ]);
  }
}

