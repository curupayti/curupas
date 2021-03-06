import 'package:chewie/chewie.dart';
import 'package:curupas/models/group_media.dart';
import 'package:curupas/ui/pages/photo_viewer.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class GroupMediaDetails extends StatefulWidget {
  final GroupMedia media;

  GroupMediaDetails({Key key, @required this.media}) : super(key: key);

  @override
  _GroupMediaDetailsState createState() => _GroupMediaDetailsState();
}

class _GroupMediaDetailsState extends State<GroupMediaDetails> {
//  final MethodChannel platform = const MethodChannel('curupa');

  VideoPlayerController _controller;
  ChewieController _chewieController;
  int videoSec = 0;

  final Widget loader = Container(
    height: 150,
    alignment: Alignment.center,
    child: CircularProgressIndicator(
      valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
    ),
  );

  Widget _topView() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (widget.media.type != 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoViewer(
                        photoUrl: widget.media.imageUrl,
                      ),
                    ),
                  );
                }
              },
              child: new Image.network(widget.media.thumbnailUrl),
            ),
            Visibility(
              visible: widget.media.type == 1 ? true : false,
              child: new Container(
                child: _chewieController != null
                    ? Chewie(
                        controller: _chewieController,
                      )
                    : loader,
              ),
            ),
          ],
        ),
      ),
    );
  }

//  IconButton(
//  onPressed: () async {
////                  if (Platform.isAndroid) {
////                    await platform.invokeMethod(
////                      'videoPlayer',
////                      {"url": "${widget.media.videoUrl}"},
////                    );
////                  } else if (Platform.isIOS) {
////                    platform.invokeMethod(
////                      'videoPlayer',
////                      [widget.media.videoUrl],
////                    );
////                  }
//
//  Navigator.push(
//  context,
//  MaterialPageRoute(
//  builder: (context) => VideoApp(
//  videoUrl: widget.media.videoUrl,
//  ),
//  ),
//  );
//},
//icon: Icon(
//Icons.play_circle_outline,
//size: 60.0,
//color: Colors.white,
//),
//),

  Widget _titleMedia() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        widget.media.title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _descriptionMedia() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        widget.media.description,
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.media.type == 1) {
      _controller = VideoPlayerController.network(widget.media.videoUrl)
        ..initialize().then((_) {
          setState(() {
            _chewieController = ChewieController(
              videoPlayerController: _controller,
              aspectRatio: _controller.value.aspectRatio,
              looping: false,
              allowFullScreen: true,
              allowMuting: true,
              startAt: Duration(seconds: 0),
              errorBuilder: (context, error) {
                return Center(
                  child: Text(error),
                );
              },
            );
          });
        });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_chewieController != null) _chewieController.dispose();
    if (_controller != null) _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _topView(),
            SizedBox(
              height: 20,
            ),
            _titleMedia(),
            SizedBox(
              height: 20,
            ),
            _descriptionMedia()
          ],
        ),
      ),
    );
  }
}
