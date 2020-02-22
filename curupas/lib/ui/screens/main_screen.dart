import 'dart:async';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:curupas/models/content_html.dart';
import 'package:curupas/models/drawer_content.dart';
import 'package:curupas/models/museum.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:curupas/business/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:curupas/business/messaging.dart';
import 'package:curupas/models/description.dart';
import 'package:curupas/models/post.dart';
import 'package:curupas/models/streaming.dart';
import 'package:curupas/models/user.dart';
import 'package:curupas/ui/screens/pages/calendar_page.dart';
import 'package:curupas/ui/screens/pages/group_page.dart';
import 'package:curupas/ui/screens/pages/home_page.dart';
import 'package:curupas/ui/screens/pages/profile_page.dart';
import 'package:curupas/ui/screens/pages/streaming_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curupas/globals.dart' as _globals;
import 'package:youtube_api/youtube_api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';

//https://pub.dev/packages/flutter_staggered_grid_view#-example-tab-

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
  final Key keyFive = PageStorageKey('pageFive');

  int currentTab = 0;

  List<Widget> pages;
  Widget currentPage;

  _MainScreenState me;

  final PageStorageBucket bucket = PageStorageBucket();

  bool _loadingInProgress = true;


  SharedPreferences prefs;

  static String key = "AIzaSyCapBh4kR9X8U82KyU7bAlyg7_jgteR4RE";
  static String channelId = "UCeLNPJoPAio9rT2GAdXDVmw";

  YoutubeAPI ytApi = new YoutubeAPI(key);

  TapGestureRecognizer _flutterTapRecognizer;

  TextStyle linkStyle = const TextStyle(
    color: Colors.blue,
    decoration: TextDecoration.underline,
    fontSize: 25.0,
  );

  String curupasUrl = 'https://curupas.com.ar/';

  @override
  void initState() {

    //_globals.queryDevice();

    isRegistered().then((result) {
      if (result) {
        new MessagingWidget();
        _globals.setFilePickerGlobal();
        String userId = prefs.getString('userId');
        _globals.getUserData(userId).then((user) {
          if (!user.smsChecked) {
            if (!user.accepted) {
              showDialog(
                context: context,
                builder: (BuildContext context) =>
                    _buildNotAcceptedDialog(context),
              );
            } else {
              loadContent();
            }
          } else {
            loadContent();
          }
        });
      }
    });

    _flutterTapRecognizer = new TapGestureRecognizer()
      ..onTap = () => _openUrl(curupasUrl);

    super.initState();
  }

  Future<void> loadContent() async {
    getDescription();
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
      int _length = _globals.drawerContent.contents.length;
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
          child:
            ListView.separated(
                itemCount: _length,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _createHeader();
                  } else {
                    ContentHtml contentHtml = _globals.drawerContent.contents[index];
                    int icon = int.parse(contentHtml.icon);
                    return _createDrawerItem(
                        contentHtml : contentHtml,
                        index: index,
                        icon: getIconFromInt(icon),
                        text: contentHtml.name,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/contentviewer',
                            arguments: contentHtml,
                          );
                          print(contentHtml.name);
                        }
                     );
                  }
                },
                separatorBuilder: (context, index) {
                  return Padding(
                      padding: EdgeInsets.only(top: 0.0),
                      child:
                        Divider(),
                  );
                },

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

  IconData getIconFromInt(int id) {
    return IconData(id, fontFamily: 'MaterialIcons');
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
              top: 15.0,
              right: 15.0,
              child: Text("Versión ${_globals.description.version}",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0))),
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
      {ContentHtml contentHtml, int index, IconData icon, String text, GestureTapCallback onTap}) {
    return ListTile(
      title:
        Row(
          children: <Widget>[            Icon(icon),
            Padding(
              padding: EdgeInsets.only(left: 8.0, top: 8.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.grey,
                ),
              ),
            ),
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
    await Auth.getPostSnapshots().then((templist) {
      Auth.getPost(templist).then((posts) {
        getMuseums(description, posts);
      });
    });
  }

  void getMuseums(String desc, List<Post> posts) async {
    await Auth.getMuseumSnapshots().then((templist) {
      Auth.getMuseum(templist).then((museums) {
        getDrawers(desc, posts, museums);
      });
    });
  }

  void getDrawers(String desc, List<Post> posts, List<Museum> museums) async {
    await Auth.getHtmlContentByType("drawer").then((_drawer) {
      _globals.drawerContent = _drawer;
      _globals.drawerContent.contents.sort((a, b) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      getNewsletters(desc, posts, museums);
    });
  }

  void getNewsletters(String desc, List<Post> posts, List<Museum> museums) async {
    await Auth.getHtmlContentByType("newsletter").then((_newsletterContent) {
      _globals.newsletterContent = _newsletterContent;
      _globals.setData(desc, posts, museums, _newsletterContent.contents);
      _globals.newsletterContent.contents.sort((a, b) {
        return a.last_update.compareTo(b.last_update);
      });
      getAnecdotes();
    });
  }

  void getAnecdotes() async {
    await Auth.getHtmlContentByTypeAndGroup("anecdote", _globals.group.yearRef).then((_anecdote) {
      _globals.anecdoteContent = _anecdote;
      _globals.anecdoteContent.contents.sort((a, b) {
        return a.last_update.compareTo(b.last_update);
      });
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
    pageTitles = ["Home", "Calendario", "Streaming", _group, "Perfil"];
    pageTitle = pageTitles[0];
    tabItems = List.of([
      new TabData(iconData: Icons.home, title: pageTitles[0]),
      new TabData(iconData: Icons.calendar_today, title: pageTitles[1]),
      new TabData(iconData: Icons.videocam, title: pageTitles[2]),
      new TabData(iconData: Icons.group_work, title: pageTitles[3]),
      new TabData(iconData: Icons.account_circle, title: pageTitles[4]),
    ]);

    HomePage one = new HomePage(
      key: keyOne,
    );

    CalendarPage two = new CalendarPage(
      key: keyTwo,
    );

    StreamingPage three = new StreamingPage(
      key: keyThree,
    );

    GroupPage four = new GroupPage(
      key: keyFour,
    );

    ProfilePage five = new ProfilePage(
      key: keyFive,
    );

    setState(() {
      pages = [one, two, three, four, five];
      currentPage = one;
      _loadingInProgress = false;
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

  Widget _buildNotAcceptedDialog(BuildContext context) {
    return new AlertDialog(
      title: Text('Aprobación pendiente',
          style: TextStyle(
              color: Colors.blue, fontSize: ScreenUtil().setSp(40.0))),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildAboutText(),
          SizedBox(
            height: 16.0,
          ),
          _buildLogoAttribution(),
        ],
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 5.0, right: 15.0, left: 15.0),
          child: new FlatButton(
            onPressed: () {
              exit(0);
            },
            textColor: Colors.white,
            child: Text(
              'CERRAR APLICACIÓN',
              style: TextStyle(
                  color: Colors.blue, fontSize: ScreenUtil().setSp(40.0)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutText() {
    String message =
        "Falta que tu referente de la camada ${_globals.group.year} apruebe tu ingreso. Te va a llegar un mensaje de texto SMS cuando lo haga.";
    return new RichText(
      text: new TextSpan(
        text: "${message}\n\n",
        style: TextStyle(
            color: Colors.black87, fontSize: ScreenUtil().setSp(30.0)),
        children: <TextSpan>[
          new TextSpan(
              text:
                  'Mientras tanto, podes ver mas información del proyecto en ',
              style: TextStyle(
                  color: Colors.black87, fontSize: ScreenUtil().setSp(30.0))),
          new TextSpan(
            text: 'Curupas',
            recognizer: _flutterTapRecognizer,
            style: linkStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoAttribution() {
    return new Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: new Row(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: new Image.asset(
              "assets/images/escudo.png",
              width: 50.0,
            ),
          ),
          const Expanded(
            child: const Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: const Text(
                'El regreso virtual es crecimiento',
                style: const TextStyle(fontSize: 20.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openUrl(String url) async {
    /*if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }*/
  }
}
