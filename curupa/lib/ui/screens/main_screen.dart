import 'dart:async';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:onboarding_flow/business/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onboarding_flow/models/description.dart';
import 'package:onboarding_flow/models/feeds.dart';
import 'package:onboarding_flow/models/streaming.dart';
import 'package:onboarding_flow/ui/screens/pages/group_page.dart';
import 'package:onboarding_flow/ui/screens/pages/home_page.dart';
import 'package:onboarding_flow/ui/screens/pages/profile_page.dart';
import 'package:onboarding_flow/ui/screens/pages/streaming_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onboarding_flow/globals.dart' as _globals;
import 'package:youtube_api/youtube_api.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key, this.title, FirebaseUser firebaseUser})
      : super(key: key);
  final String title;
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int selectedPos = 0;
  double bottomNavBarHeight = 80;
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
        bool group = prefs.getBool('group');
        if (group == null) {
          group = false;
        }
        _globals.getUserData(userId, group);
        getDescription();
      }
    });
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
                  padding: const EdgeInsets.only(top: 50.0, bottom: 50.0),
                  child: new Image.asset("assets/images/escudo.png",
                      height: 100.0, width: 100.0, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: new Text(
                  "Cargando datos",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.none,
                    fontSize: 15.0,
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
                padding: const EdgeInsets.only(top: 50.0),
                child: new Text(
                  "Un momento por favor",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.none,
                    fontSize: 15.0,
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
              DrawerHeader(
                child: Text('Drawer Header'),
              ),
              ListTile(
                title: Text('Log Out'),
                onTap: () {
                  _logOut();
                  _scaffoldKey.currentState.openEndDrawer();
                },
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
              padding: EdgeInsets.only(
                  bottom:
                      0.0), //bottomNavBarHeight), //Modificar esto o sacar padding.
            ),
          ],
        ),
        bottomNavigationBar: FancyBottomNavigation(
          tabs: tabItems,
          circleColor: Color.fromRGBO(223, 0, 9, 1), //,Color(0xFF0bf0411),
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

  void getDescription() async {
    Stream<Description> descStream = Auth.getDescription();
    descStream.listen((Description _desc) async {
      _globals.description = _desc;
      getFeed(_desc.desc);
    });
  }

  void getFeed(String description) async {
    await Auth.getFeed().then((listFeed) {
      List<Feed> newFeed = listFeed;
      _globals.setDataFeed(description, newFeed);
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
      _globals.setYoutubeApi(ytResult);
      for (var i = 0; i < ytResult.length; i++) {
        Streaming streaming = new Streaming();
        YT_API ytapi = ytResult[i];
        streaming.id = ytapi.id;
        streaming.title = ytapi.title;
        streaming.kind = ytapi.kind;
        Map _default = ytapi.thumbnail['high'];
        String thubnailUrl = _default['url'];
        streaming.thumnailUrl = thubnailUrl;
        streaming.videoUrl = ytapi.url;
        if (ytapi.kind == "live") {
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
    Auth.signOut();
  }
}
