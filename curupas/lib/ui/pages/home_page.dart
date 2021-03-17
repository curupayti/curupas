import 'dart:async';
import 'dart:ui' as ui;

import 'package:curupas/business/cache.dart';
import 'package:curupas/globals.dart' as _globals;
import 'package:curupas/ui/screens/post/post_card.dart';
import 'package:curupas/ui/widgets/museum.dart';
import 'package:curupas/ui/widgets/newsletter/newsletter_widget.dart';
import 'package:curupas/ui/widgets/pumas/pumas_widget.dart';
import 'package:curupas/ui/widgets/valores/valores_widget.dart';
import "package:flutter/material.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  //bool data_loaded = false;
  int _counting = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeStream(_loading),
      floatingActionButton: buildSpeedDial(),
    );
  }

  @override
  void initState() {
    super.initState();
    initDynamicLinks(context);

    if (_globals.home_data_loaded == false) {
      loadHomeData();
      _globals.eventBus.on().listen((event) {
        String _event = event.toString();
        if (_event.contains("home")) {
          _counting = _counting + 1;
          if (_counting == 6) {
            _counting = 0;
            if (mounted) {
              loaded();
            } else {
              Timer.periodic(Duration(seconds: 5), (timer) {
                if (mounted) {
                  loaded();
                  timer.cancel();
                }
                print("Home timer 5 seconds call mounted");
              });
            }
          }
          print("Counting : ${_counting}");
        }
      });
    } else {
      loaded();
    }
  }

  void loaded() {
    _globals.home_data_loaded = true;
    setState(() {
      _loading = false;
    });
  }

  void loadHomeData() async {
    setState(() {
      _loading = true;
    });
    _globals.getDescription();
    _globals.getPosts();
    _globals.getNewsletters();
    _globals.getValores();
    _globals.getMuseums();
    _globals.getPumas();
  }
}

void _openUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

void initDynamicLinks(BuildContext context) async {
  /*final PendingDynamicLinkData data =
    await FirebaseDynamicLinks.instance.getInitialLink();

    final Uri deepLink = data?.link;

    if (deepLink != null) {
      Navigator.pushNamed(context, deepLink.path);
    }

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          final Uri deepLink = dynamicLink?.link;

          if (deepLink != null) {
            Navigator.pushNamed(context, deepLink.path);
          }
        }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });*/
}

//https://github.com/flutter/flutter/tree/e10df3c1a65f9d7db3fc5340cffef966f7bd40a6/packages/flutter/lib/src/material/animated_icons/data

SpeedDial buildSpeedDial() {
  return SpeedDial(
    marginRight: 25,
    marginBottom: 18,
    animatedIcon: AnimatedIcons.add_event,
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
      /*SpeedDialChild(
            child: Icon(Icons.calendar_today, color: Colors.white),
            backgroundColor: Color.fromRGBO(0, 29, 126, 1),
            label: 'Calendario',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => print('FIRST CHILD')),*/
      SpeedDialChild(
          child: Icon(Icons.poll, color: Colors.white),
          backgroundColor: Color.fromRGBO(0, 29, 126, 1),
          label: 'Newsletter',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => print('FIRST CHILD')),
    ],
  );
}

class HomeStream extends StatefulWidget {
  final bool loading;

  HomeStream(this.loading);

  @override
  _HomeStreamState createState() => new _HomeStreamState();
}

class _HomeStreamState extends State<HomeStream> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double _statusBarHeight = MediaQuery.of(context).padding.top;
    double _height = height - (80 /* navbar */ + _statusBarHeight);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: _height,
              child: HomeBackground(
                widget.loading,
              ),
            )
          ],
        ),
      ),
    );
  }

/*@override
    void initState() {

    }*/

}

class HomeBackground extends StatelessWidget {
  final bool loading;

  HomeBackground(this.loading);

  @override
  Widget build(BuildContext context) {
    double _statusBarHeight = MediaQuery.of(context).padding.top;
    double bottomPadding = _statusBarHeight + ScreenUtil().setHeight(30.0);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child:
                Image.asset(Cache.appData.home_background, fit: BoxFit.cover),
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
              //painter: CurvePainter(0, null, 10),
              ),
          CustomPaint(
              //painter: CurvePainter(null, bottomPadding, 5),
              ),
        ],
      ),
      //floatingActionButton: buildSpeedDial(),
    );
  }

  Widget _buildContent() {
    if (loading) {
      return SpinKitFadingCircle(
        itemBuilder: (BuildContext context, int index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: index.isEven ? Colors.red : Colors.green,
            ),
          );
        },
      );
    } else {
      return SingleChildScrollView(
        child: Cache.appData != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildHeader(),
                  _buildPostScroller(),
                  _buildNewsletterTimeline(),
                  _buildValoresTimeline(),
                  _buildMuseumTimeline(),
                  _buildPumasTimeline(),
                ],
              )
            : Container(),
      );
    }
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
            Cache.appData.name != null ? Cache.appData.name : "",
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
            Cache.appData.location != null ? Cache.appData.location : "",
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
          Cache.appData.biography != null ? Cache.appData.biography : "",
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
      child: Image.asset(Cache.appData.avatar),
    );
  }

  Widget _buildPostScroller() {
    return Cache.appData != null &&
            Cache.appData.posts != null &&
            Cache.appData.posts.length > 0
        ? Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SizedBox.fromSize(
              size: Size.fromHeight(245.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemCount: Cache.appData.posts.length,
                itemBuilder: (BuildContext context, int index) {
                  var post = Cache.appData.posts[index];
                  return PostCard(post);
                },
              ),
            ),
          )
        : Container();
  }

  Widget _buildNewsletterTimeline() {
    return Cache.appData.newsletterContent.contents != null &&
            Cache.appData.newsletterContent.contents.length > 0
        ? Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SizedBox.fromSize(
              size: Size.fromHeight(200.0),
              child: new NewsletterWidget(
                  newsletters: Cache.appData.newsletterContent.contents),
            ),
          )
        : Container();
  }

  Widget _buildMuseumTimeline() {
    return Cache.appData.museums != null && Cache.appData.museums.length > 0
        ? Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SizedBox.fromSize(
              size: Size.fromHeight(170.0),
              child: new MuseumWidget(museums: Cache.appData.museums),
            ),
          )
        : Container();
  }

  Widget _buildPumasTimeline() {
    return Cache.appData.pumasContent.contents != null &&
            Cache.appData.pumasContent.contents.length > 0
        ? Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SizedBox.fromSize(
              size: Size.fromHeight(170.0),
              child:
                  new PumasWidget(pumas: Cache.appData.pumasContent.contents),
            ),
          )
        : new Container();
  }

  Widget _buildValoresTimeline() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: SizedBox.fromSize(
        size: Size.fromHeight(170.0),
        child: new ValoresWidget(pumas: Cache.appData.valoresContent.contents),
      ),
    );
  }
}
