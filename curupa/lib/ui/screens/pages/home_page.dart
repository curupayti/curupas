import "package:flutter/material.dart";
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:onboarding_flow/globals.dart' as _globals;
import 'package:onboarding_flow/models/group.dart';
import 'package:onboarding_flow/ui/draw/line.dart';
import 'package:onboarding_flow/ui/screens/feed/feed_card.dart';
import 'dart:ui' as ui;

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FeedDetailsPage(),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

class FeedDetailsPage extends StatefulWidget {
  @override
  _FeedDetailsPageState createState() => _FeedDetailsPageState();
}

class _FeedDetailsPageState extends State<FeedDetailsPage> {
  Group group;
  String year;

  @override
  void initState() {
    group = _globals.group;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 110.0),
            child:
                Image.asset(_globals.dataFeed.backdropPhoto, fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 110.0),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: _buildContent(),
              ),
            ),
          ),
          CustomPaint(
            painter: CurvePainter(0, null),
          ),
          CustomPaint(
            painter: CurvePainter(null, 110),
          ),
        ],
      ),
      floatingActionButton: buildSpeedDial(),
    );
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      marginRight: 25,
      marginBottom: 30,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      visible: true,
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      tooltip: 'Menu',
      heroTag: 'speed-dial-hero-tag',
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 8.0,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
            child: Icon(Icons.poll, color: Colors.white),
            backgroundColor: Color.fromRGBO(0, 29, 126, 1),
            label: 'Encuesta',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => print('FIRST CHILD')),
        /*SpeedDialChild(
          child: Icon(Icons.video_label, color: Colors.white),
          backgroundColor: Color.fromRGBO(0, 29, 126, 1),
          label: 'Subir Video',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => print('SECOND CHILD'),
        ),
        SpeedDialChild(
          child: Icon(Icons.calendar_today),
          backgroundColor: Colors.white,
          label: 'Proponer juntada',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => print('THIRD CHILD'),
        ),*/
      ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildAvatar(),
          _buildInfo(),
          _buildFeedScroller(),
          //_buildGroupButton(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
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
        child: Image.asset(_globals.dataFeed.avatar),
      ),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _globals.dataFeed.name,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
            ),
          ),
          Text(
            _globals.dataFeed.location,
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
            _globals.dataFeed.biography,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedScroller() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: SizedBox.fromSize(
        size: Size.fromHeight(245.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          itemCount: _globals.dataFeed.feeds.length,
          itemBuilder: (BuildContext context, int index) {
            var feed = _globals.dataFeed.feeds[index];
            return FeedCard(feed);
          },
        ),
      ),
    );
  }
}
