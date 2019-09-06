import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:onboarding_flow/globals.dart' as _globals;
import 'package:onboarding_flow/models/group.dart';

class VideoDetailsPage extends StatefulWidget {
  @override
  _VideoDetailsPageState createState() => _VideoDetailsPageState();
}

class _VideoDetailsPageState extends State<VideoDetailsPage> {
  Group group;
  String year;

  @override
  void initState() {
    group = _globals.group;
    //year = group.year;

    //print(group.year);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(_globals.dataFeed.backdropPhoto, fit: BoxFit.cover),
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Container(), //_buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  /*Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildAvatar(),
          _buildInfo(),
          _buildVideoScroller(),
          _buildGroupButton(),
        ],
      ),
    );
  }*/

  /*Widget _buildAvatar() {
    return Container(
      width: 110.0,
      height: 110.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white30),
      ),
      margin: const EdgeInsets.only(top: 32.0, left: 16.0),
      padding: const EdgeInsets.all(3.0),
      child: ClipOval(
        child: Image.asset(_globals.data.avatar),
      ),
    );
  }*/

  /*Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _globals.data.name,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
            ),
          ),
          Text(
            _globals.data.location,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.85),
            margin: const EdgeInsets.symmetric(vertical: 16.0),
            width: 225.0,
            height: 1.0,
          ),
          Text(
            _globals.data.biography,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }*/

  /*Widget _buildVideoScroller() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: SizedBox.fromSize(
        size: Size.fromHeight(245.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          itemCount: _globals.dataFeed.feeds.length,
          itemBuilder: (BuildContext context, int index) {
            var video = _globals.dataFeed.feeds[index];
            return VideoCard(video);
          },
        ),
      ),
    );
  }*/

  Widget _buildGroupButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 50.0, right: 50.0),
      child: Center(
        child: FlatButton(
          child: Text(
            _globals.group.year,
            style: new TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
          onPressed: () {},
          color: Color.fromRGBO(0, 29, 126, 1),
          colorBrightness: Brightness.dark,
          disabledColor: Colors.blueGrey,
          highlightColor: Colors.red,
          padding: EdgeInsets.symmetric(
              horizontal: 8.0, vertical: 5.0), // gives padding to the button
        ),
      ),
    );
  }
}
