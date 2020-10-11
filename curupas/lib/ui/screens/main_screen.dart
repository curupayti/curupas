import 'dart:async';
import 'dart:io';
import 'package:curupas/models/HTML.dart';
import 'package:curupas/models/user.dart';
import 'package:curupas/ui/pages/calendar_page.dart';
import 'package:curupas/ui/pages/group_page.dart';
import 'package:curupas/ui/pages/home_page.dart';
import 'package:curupas/ui/pages/profile_page.dart';
import 'package:curupas/ui/pages/streaming_page.dart';
import 'package:curupas/ui/screens/friend_screen.dart';
import 'package:curupas/ui/widgets/alert_sms_dialog.dart';
import 'package:device_info/device_info.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:curupas/business/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:curupas/globals.dart' as _globals;

//https://pub.dev/packages/flutter_staggered_grid_view#-example-tab-

class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);

  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int selectedPos = 0;

  //double bottomNavBarHeight = 80;
  GlobalKey bottomNavigationKey = GlobalKey();
  List<TabData> tabItems;

  String group;

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

  bool _loading = true;

  SharedPreferences prefs;

  String curupasUrl = 'https://curupas.com.ar/';

  List<IconButton> navBarIcons = new List<IconButton>();
  IconButton currentIconButton;
  IconButton _home;
  IconButton _calendar;
  IconButton _videos;
  IconButton _group;
  IconButton _profile;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  TapGestureRecognizer _flutterTapRecognizer;

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  var isPhysicalDevice = false;

  TextStyle linkStyle = const TextStyle(
    color: Colors.blue,
    decoration: TextDecoration.underline,
    fontSize: 25.0,
  );

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Future<Map<String, dynamic>> initPlatformState() async {

    Map<String, dynamic> deviceData;

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    return deviceData;
  }

  @override
  void initState() {
    super.initState();

    initPlatformState().then((device) {

      if (device["isPhysicalDevice"]) {
        isPhysicalDevice = device["isPhysicalDevice"];
      }

      isRegistered().then((result) async {
        if (result) {
          _globals.setFilePickerGlobal();
          String userId = prefs.getString('userId');
          await _globals.getUserData(userId).then((user) async {

            await _firebaseMessaging.getToken().then((token) async {
              Map<String, dynamic> data = new Map<String, dynamic>();
              if (isPhysicalDevice) {
                data['token'] = token;
              }
              data['device'] = device;
              await Auth.updateUser(userId, data).then((User user) async {
                _globals.user.token = token;
              });
            });

            _globals.user = user;
            _globals.initData();
            _globals.getDrawers();

            if (!user.smsChecked) {
              showDialog(
                context: context,
                builder: (BuildContext context) =>
                new SMSDialog(userId: user.userID),
              );
            } else if (!user.accepted) {
              showDialog(
                context: context,
                builder: (BuildContext context) =>
                    _buildNotAcceptedDialog(context),
              );
            }
          });
        }
     });

    });

    _home = IconButton(
      icon: Icon(
        Icons.help,
        color: Colors.grey,
      ),
      onPressed: () {
        // do something
      },
    );

    _calendar = IconButton(
      icon: Icon(
        Icons.update,
        color: Colors.grey,
      ),
      onPressed: () {
        // do something
      },
    );

    _videos = IconButton(
      icon: Icon(
        Icons.visibility,
        color: Colors.grey,
      ),
      onPressed: () {
        // do something
      },
    );

    _group = IconButton(
      icon: Icon(
        Icons.group,
        color: Colors.grey,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FriendsListPage(),
          ),
        );
      },
    );

    _profile = IconButton(
      icon: Icon(
        Icons.settings,
        color: Colors.grey,
      ),
      onPressed: () {
        // do something
      },
    );

    listenNotifications();

    _globals.eventBus.on().listen((event) {
      String _event = event.toString();
      if (_event.contains("main")) {
        setState(() {
          updeteWidget();
        });
      }
    });
  }

  void handleClick(String value) {
    switch (value) {
      case 'Update':

        break;
    }
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      ScreenUtil.instance =
      ScreenUtil(width: 640, height: 1136, allowFontScaling: true)
        ..init(context);

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
          actions: <Widget>[currentIconButton],
        ),
        drawer: Drawer(
          child: ListView.separated(
            itemCount: _length,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _createHeader();
              } else {
                HTML contentHtml = _globals.drawerContent.contents[index];
                int icon = int.parse(contentHtml.icon);
                return _createDrawerItem(
                    contentHtml: contentHtml,
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
                    });
              }
            },
            separatorBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(top: 0.0),
                child: Divider(),
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
              currentIconButton = navBarIcons[index];
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
                  style: TextStyle(color: Colors.white, fontSize: 20.0))),
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
      {HTML contentHtml,
        int index,
        IconData icon,
        String text,
        GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
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

  void listenNotifications() {
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        //_showItemDialog(message);
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        //_navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        //_navigateToItemDetail(message);
      },
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  void updeteWidget() {
    group = _globals.group.year;
    pageTitles = ["Home", "Calendario", "Streaming", group, "Perfil"];
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

    navBarIcons = [_home, _calendar, _videos, _group, _profile];

    setState(() {
      pages = [one, two, three, four, five];
      currentPage = one;
      currentIconButton = _home;
      _loading = false;
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

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    // Or do other work.
  }
}
