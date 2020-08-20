import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewer extends StatefulWidget {
  final String photoUrl;

  PhotoViewer({Key key, @required this.photoUrl}) : super(key: key);
  @override
  _PhotoViewerState createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Photo"),
      ),
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(widget.photoUrl),
        ),
      ),
    );
  }
}
