import "package:flutter/material.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:onboarding_flow/globals.dart' as _globals;
import 'package:onboarding_flow/models/streaming.dart';
import 'package:onboarding_flow/ui/draw/line.dart';
import 'dart:ui' as ui;

import 'package:onboarding_flow/ui/screens/feed/feed_card.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeStream(),
      floatingActionButton: buildSpeedDial(),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

SpeedDial buildSpeedDial() {
  return SpeedDial(
    marginRight: 25,
    marginBottom: 18,
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
          child: Icon(Icons.calendar_today, color: Colors.white),
          backgroundColor: Color.fromRGBO(0, 29, 126, 1),
          label: 'Calendario',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => print('FIRST CHILD')),
      SpeedDialChild(
          child: Icon(Icons.poll, color: Colors.white),
          backgroundColor: Color.fromRGBO(0, 29, 126, 1),
          label: 'Encuesta',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => print('FIRST CHILD')),
    ],
  );
}

class HomeStream extends StatefulWidget {
  @override
  _HomeStreamState createState() => new _HomeStreamState();
}

class _HomeStreamState extends State<HomeStream> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double _height = height - (80 /* navbar */ + ScreenUtil.statusBarHeight);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(height: _height, child: HomeBackground())
          ],
        ),
      ),
    );
  }
}

class HomeBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double bottomPadding =
        ScreenUtil.statusBarHeight + ScreenUtil().setHeight(30.0);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child:
                Image.asset(_globals.dataFeed.backdropPhoto, fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: _buildContent(),
              ),
            ),
          ),
          CustomPaint(
            painter: CurvePainter(0, null, 10),
          ),
          CustomPaint(
            painter: CurvePainter(null, bottomPadding, 5),
          ),
        ],
      ),
      //floatingActionButton: buildSpeedDial(),
    );
  }
}

Widget _buildContent() {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildHeader(),
        _buildFeedScroller(),
      ],
    ),
  );
}

Widget _buildHeader() {
  return new Row(
    children: [
      new Expanded(
        child: Padding(
          padding: EdgeInsets.only(
            top: ScreenUtil().setHeight(40.0),
          ),
          child: _buildHeaderText(),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(right: ScreenUtil().setWidth(16.0)),
        child: _buildAvatar(),
      ),
    ],
  );
}

Widget _buildHeaderText() {
  return new Column(
    children: <Widget>[
      Padding(
        padding: EdgeInsets.only(left: ScreenUtil().setHeight(10.0)),
        child: Text(
          _globals.dataFeed.name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: ScreenUtil().setSp(80.0),
            //backgroundColor: Colors.green,
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(top: ScreenUtil().setHeight(16.0)),
        child: Text(
          _globals.dataFeed.location,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Container(
        color: Colors.white.withOpacity(0.85),
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        width: ScreenUtil().setWidth(350.0),
        height: 1.0,
      ),
      Text(
        _globals.dataFeed.biography,
        style: TextStyle(
          color: Colors.white.withOpacity(0.85),
          fontSize: ScreenUtil().setSp(30.0),
        ),
      ),
    ],
  );
}

Widget _buildAvatar() {
  return Container(
    width: ScreenUtil().setWidth(250.0),
    height: ScreenUtil().setHeight(250.0),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white30),
    ),
    margin: EdgeInsets.only(
        top: ScreenUtil().setWidth(20.0), left: ScreenUtil().setWidth(25.0)),
    padding: EdgeInsets.only(
      top: ScreenUtil().setWidth(20.0),
      left: ScreenUtil().setWidth(20.0),
      right: ScreenUtil().setWidth(20.0),
      bottom: ScreenUtil().setWidth(20.0),
    ),
    child: Image.asset(_globals.dataFeed.avatar),
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
