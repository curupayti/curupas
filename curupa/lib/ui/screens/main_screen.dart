import 'dart:async';
import 'dart:io';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onboarding_flow/business/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onboarding_flow/business/messaging.dart';
import 'package:onboarding_flow/models/description.dart';
import 'package:onboarding_flow/models/feeds.dart';
import 'package:onboarding_flow/models/streaming.dart';
import 'package:onboarding_flow/models/user.dart';
import 'package:onboarding_flow/ui/screens/pages/group_page.dart';
import 'package:onboarding_flow/ui/screens/pages/home_page.dart';
import 'package:onboarding_flow/ui/screens/pages/profile_page.dart';
import 'package:onboarding_flow/ui/screens/pages/streaming_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onboarding_flow/globals.dart' as _globals;
import 'package:youtube_api/youtube_api.dart';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key, this.title, FirebaseUser firebaseUser})
      : super(key: key);
  final String title;
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int selectedPos = 0;
  //double bottomNavBarHeight = 80;
  GlobalKey bottomNavigationKey = GlobalKey();
  List<TabData> tabItems;

  String _group;

  List<String> pageTitles = [];
  String pageTitle;

  final Key keyOne = PageStorageKey('pageOne');
  final Key keyTwo = PageStorageKey('pageTwo');
  final Key keyThree = PageStorageKey('pageThree');
  final Key keyFour = PageStorageKey('pageFour');

  int currentTab = 0;

  List<Widget> pages;
  Widget currentPage;

  _MainScreenState me;

  final PageStorageBucket bucket = PageStorageBucket();

  bool _loadingInProgress = true;
  bool _loaded = false;

  SharedPreferences prefs;

  static String key = "AIzaSyCapBh4kR9X8U82KyU7bAlyg7_jgteR4RE";
  static String channelId = "UCeLNPJoPAio9rT2GAdXDVmw";

  YoutubeAPI ytApi = new YoutubeAPI(key);

  @override
  void initState() {
    isRegistered().then((result) {
      if (result) {
        _globals.setFilePickerGlobal();
        String userId = prefs.getString('userId');
        String year = prefs.getString('year');
        String name = prefs.getString('name');
        _globals.getUserData(userId, year, name);
        getDescription();
      }
    });

    new MessagingWidget();

    super.initState();
  }

  Future<bool> isRegistered() async {
    bool registered = await getRegistered();
    if (registered != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> getRegistered() async {
    prefs = await SharedPreferences.getInstance();
    bool registered = prefs.getBool('registered');
    return registered;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance =
        ScreenUtil(width: 640, height: 1136, allowFontScaling: true)
          ..init(context);
    if (_loadingInProgress) {
      return Stack(children: <Widget>[
        new Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: new Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: ScreenUtil().setHeight(30.0),
                      bottom: ScreenUtil().setWidth(50.0),
                      left: ScreenUtil().setWidth(30.0),
                      right: ScreenUtil().setWidth(30.0)),
                  child: new Image.asset("assets/images/pelota_small.png",
                      height: ScreenUtil().setHeight(350.0),
                      fit: BoxFit.fitHeight),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: ScreenUtil().setHeight(50.0)),
                child: new Text(
                  "Cargando datos",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.none,
                    fontSize: ScreenUtil().setSp(50.0),
                    fontWeight: FontWeight.w300,
                    fontFamily: "OpenSans",
                  ),
                ),
              ),
              new Container(
                width: 60,
                height: 60,
                child: new CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: ScreenUtil().setHeight(50.0)),
                child: new Text(
                  "Un momento por favor",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.none,
                    fontSize: ScreenUtil().setSp(35.0),
                    fontWeight: FontWeight.w300,
                    fontFamily: "OpenSans",
                  ),
                ),
              ),
            ],
          ),
        ),
      ]);
    } else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          elevation: 0.5,
          leading: new IconButton(
              icon: new Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState.openDrawer()),
          title: Text(pageTitle),
          centerTitle: true,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              /*DrawerHeader(
                child: Text('Drawer Header'),
              ),*/
              _createHeader(),
              _createDrawerItem(icon: Icons.info_outline, text: 'Acerca de'),
              Divider(),
              _createDrawerItem(
                  icon: Icons.highlight, text: 'Como mejorar la app'),
              Divider(),
              _createDrawerItem(
                  icon: Icons.bug_report, text: 'Reportar un bug'),
              Divider(),
              _createDrawerItem(
                icon: Icons.exit_to_app,
                text: 'Salir',
                onTap: () {
                  _logOut();
                  _scaffoldKey.currentState.openEndDrawer();
                },
              ),
              ListTile(
                title: Text('0.0.1'),
                onTap: () {},
              ),
            ],
          ),
        ),
        body: Stack(
          children: <Widget>[
            Padding(
              child: PageStorage(
                child: currentPage,
                bucket: bucket,
              ),
              padding: EdgeInsets.only(bottom: 0.0),
            ),
          ],
        ),
        bottomNavigationBar: FancyBottomNavigation(
          tabs: tabItems,
          circleColor: Color.fromRGBO(223, 0, 9, 1),
          inactiveIconColor: Color(0xFF0bf0411),
          initialSelection: 0,
          key: bottomNavigationKey,
          onTabChangedListener: (index) {
            setState(() {
              pageTitle = pageTitles[index];
              currentPage = pages[index];
            });
          },
        ),
      );
    }
  }

  Widget _createHeader() {
    return DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: new BoxDecoration(
          color: Color.fromRGBO(191, 4, 17, 1),
          gradient: new LinearGradient(colors: [
            Color.fromRGBO(0, 29, 126, 1),
            Color.fromRGBO(191, 4, 17, 1)
          ], begin: Alignment.centerRight, end: new Alignment(-1.0, -1.0)),
        ),
        child: Stack(children: <Widget>[
          Positioned(
              bottom: 12.0,
              left: 16.0,
              child: Text("Comunidad",
                  style: TextStyle(
                      color: Color.fromRGBO(215, 203, 13, 1),
                      fontSize: 30.0,
                      fontWeight: FontWeight.w500))),
        ]));
  }

  Widget _createDrawerItem(
      {IconData icon, String text, GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.grey,
              ),
            ),
          )
        ],
      ),
      onTap: onTap,
    );
  }

  void getDescription() async {
    Stream<Description> descStream = Auth.getDescription();
    descStream.listen((Description _desc) async {
      _globals.description = _desc;
      getPosts(_desc.title, _desc.description);
    });
  }

  void getPosts(String title, String description) async {
    await Auth.getPosts().then((listFeed) {
      List<Feed> newFeed = listFeed;
      _globals.setDataPosts(description, newFeed);
      getStreamingData();
    });
  }

  void getStreamingData() async {
    List<YT_API> ytResult = [];
    List<Streaming> streamingList = [];
    try {
      ytResult = await ytApi.channel(channelId);
    } on Exception catch (exception) {
      print(exception.toString());
    } catch (error) {
      print(error.toString());
    }
    if (ytResult.length > 0) {
      print(ytResult.toString());
      _globals.streamingReachable = true;
      _globals.setYoutubeApi(ytResult);

      //String nameString = jsonEncode(ytResult);
      //print("________");
      //print(nameString);
      //print("________");

      for (var i = 0; i < ytResult.length; i++) {
        Streaming streaming = new Streaming();
        YT_API ytapi = ytResult[i];
        //writeYoutubeLog(i, ytapi.toString());
        streaming.id = ytapi.id;
        streaming.title = ytapi.title;
        streaming.kind = ytapi.kind;
        Map _default = ytapi.thumbnail['high'];
        String thubnailUrl = _default['url'];
        streaming.thumnailUrl = thubnailUrl;
        streaming.videoUrl = ytapi.url;
        String kind = ytapi.kind;
        if (kind == "live") {
          streaming.isLive = true;
          _globals.streammer.setIsLiveStreaming(true);
        } else {
          streaming.isLive = false;
        }
        streamingList.add(streaming);
      }
      _globals.streammer.serStreamings(streamingList);
    }
    updeteWidget();
  }

  Future<File> writeYoutubeLog(int counter, String content) async {
    final file = await _localFile;

    // Write the file.
    return file.writeAsString('$content');
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/log_youtube.txt');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  void updeteWidget() {
    _group = _globals.group.year;
    pageTitles = ["Home", "Streaming", _group, "Perfil"];
    pageTitle = pageTitles[0];
    tabItems = List.of([
      new TabData(iconData: Icons.home, title: pageTitles[0]),
      new TabData(iconData: Icons.videocam, title: pageTitles[1]),
      new TabData(iconData: Icons.group_work, title: pageTitles[2]),
      new TabData(iconData: Icons.account_circle, title: pageTitles[3]),
    ]);

    HomePage one = new HomePage(
      key: keyOne,
    );
    StreamingPage two = new StreamingPage(
      key: keyTwo,
    );

    GroupPage three = new GroupPage(
      key: keyThree,
    );

    ProfilePage four = new ProfilePage(
      key: keyFour,
    );

    setState(() {
      pages = [one, two, three, four];
      currentPage = one;
      _loadingInProgress = false;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    //_navigationController.dispose();
  }

  void _logOut() async {
    prefs.setBool('registered', false);
    prefs.setBool('group', false);
    prefs.setString('userId', null);
    Auth.signOut();
    Navigator.of(context).pushNamed("/signin");
  }
}
