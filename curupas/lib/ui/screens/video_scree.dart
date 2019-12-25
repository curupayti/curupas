import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:curupas/models/streaming.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';

class VideoPlayerScreen extends StatefulWidget {
  Streaming streaming;
  VideoPlayerScreen({this.streaming});
  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayerScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  YoutubePlayerController _controller;
  TextEditingController _idController;
  TextEditingController _seekToController;

  PlayerState _playerState;
  YoutubeMetaData _videoMetaData;
  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;

  final List<String> _ids = [
    'gQDByCdjUXw',
    'iLnmTe5Q2Qw',
    '_WoCV4c6XOE',
    'KmzdUe0RSJo',
    '6jZDSSZZxjQ',
    'p2lYr3vM_1w',
    '7QUtEmBT_-w',
    '34_PXCzGw1M',
  ];
  int count = 0;

  String _videoId;

  /*void listener() {
    if (_controller.value.playerState == PlayerState.ENDED) {
      _showThankYouDialog();
    }
    if (mounted) {
      setState(() {
        _playerStatus = _controller.value.playerState.toString();
        _errorCode = _controller.value.errorCode.toString();
      });
    }
  }*/

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: 'QFlRzcZoNoA',
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHideAnnotation: true,
      ),
    )..addListener(listener);
    _idController = TextEditingController();
    _seekToController = TextEditingController();
    _videoMetaData = YoutubeMetaData();
    _playerState = PlayerState.unknown;
    _videoId = widget.streaming.id;
    print(_videoId);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      //DeviceOrientation.landscapeRight,
      //DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.streaming.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.blueAccent,
              topActions: <Widget>[
                SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    _controller.metadata.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 25.0,
                  ),
                  onPressed: () {
                    _showSnackBar('Settings Tapped!');
                  },
                ),
              ],
              onReady: () {
                _isPlayerReady = true;
              },
              onEnded: (id) {
                _controller.load(_ids[count++]);
                _showSnackBar('Next Video Started!');
              },
            ),
            /*SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    controller: _idController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Enter youtube \<video id\> or \<link\>"),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _videoId = _idController.text;
                        print(_videoId);
                        // If text is link then converting to corresponding id.
                        if (_videoId.contains("http"))
                          _videoId = YoutubePlayer.convertUrlToId(_videoId);
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 16.0,
                      ),
                      color: Color(0xFFFF0000),
                      child: Text(
                        "PLAY",
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.play_arrow
                              : Icons.pause,
                        ),
                        onPressed: () {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
                        onPressed: () {
                          _muted ? _controller.unMute() : _controller.mute();
                          setState(() {
                            _muted = !_muted;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.fullscreen),
                        onPressed: () => _controller.enterFullScreen(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextField(
                    controller: _seekToController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Seek to seconds",
                      suffixIcon: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: OutlineButton(
                          child: Text("Seek"),
                          onPressed: () => _controller.seekTo(
                            Duration(
                              seconds: int.parse(_seekToController.text),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "Volume",
                        style: TextStyle(fontWeight: FontWeight.w300),
                      ),
                      Expanded(
                        child: Slider(
                          inactiveColor: Colors.transparent,
                          value: _volume,
                          min: 0.0,
                          max: 100.0,
                          divisions: 10,
                          label: '${(_volume).round()}',
                          onChanged: (value) {
                            setState(() {
                              _volume = value;
                            });
                            _controller.setVolume(_volume.round());
                          },
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Status: $_playerStatus",
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Error Code: $_errorCode",
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }

  void _showThankYouDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Video Ended"),
          content: Text("Thank you for trying the plugin!"),
        );
      },
    );
  }
}
