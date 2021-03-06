import 'dart:async';
import 'dart:io';

import 'package:curupas/business/auth.dart';
import 'package:curupas/business/cache.dart';
import 'package:curupas/globals.dart' as _globals;
import 'package:curupas/models/HTML.dart';
import 'package:curupas/models/curupa_user.dart';
import 'package:curupas/models/message.dart';
import 'package:curupas/ui/pages/calendar_page.dart';
import 'package:curupas/ui/pages/group_page.dart';
import 'package:curupas/ui/pages/home_page.dart';
import 'package:curupas/ui/pages/profile_page.dart';
import 'package:curupas/ui/pages/streaming_page.dart';
import 'package:curupas/ui/screens/friend_screen.dart';
import 'package:curupas/ui/widgets/alert_sms_dialog.dart';
import 'package:device_info/device_info.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

//https://pub.dev/packages/flutter_staggered_grid_view#-example-tab-

class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);

  _MainScreenState createState() => _MainScreenState();
}

class PopChoice {
  const PopChoice({this.title, this.icon, this.id}); //, this.tabId});
  final String title;
  final IconData icon;
  final int id;
  //final int tabId;
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int selectedPos = 0;
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
  List<PopChoice> currentChoice;

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

  PopChoice _selectedChoice;

  HomePage one;
  CalendarPage two;
  StreamingPage three;
  GroupPage four;
  ProfilePage five;

  // ignore: deprecated_member_use
  List<List<PopChoice>> pop_choices = new List<List<PopChoice>>();

  final List<PopChoice> choice_home = <PopChoice>[
    PopChoice(title: 'Ayuda', icon: Icons.help, id: 0),
  ];

  final List<PopChoice> choice_calendar = <PopChoice>[
    PopChoice(title: 'Ayuda', icon: Icons.help, id: 0),
  ];

  final List<PopChoice> choice_videos = <PopChoice>[
    PopChoice(title: 'Ayuda', icon: Icons.help, id: 0),
  ];

  final List<PopChoice> choice_group = <PopChoice>[
    PopChoice(title: 'Ayuda', icon: Icons.help, id: 0),
  ];

  final List<PopChoice> choice_profile = <PopChoice>[
    PopChoice(title: 'Configuración', icon: Icons.settings, id: 0),
    PopChoice(title: 'Editar Perfil', icon: Icons.edit, id: 1),
    PopChoice(title: 'Salir', icon: Icons.all_out, id: 2),
  ];

  void _select(PopChoice choice) {
    setState(() {
      // Causes the app to rebuild with the new _selectedChoice.
      _selectedChoice = choice;
    });
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Define a top-level named handler which background/terminated messages will
  /// call.
  ///
  /// To verify things are working, check out the native platform logs.
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();
    print("Handling a background message ${message.messageId}");
  }

  /// Create a [AndroidNotificationChannel] for heads up notifications
  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
    enableVibration: true,
    playSound: true,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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

    _selectedChoice = choice_profile[0];

    initPlatformState().then((device) {
      if (device["isPhysicalDevice"]) {
        isPhysicalDevice = device["isPhysicalDevice"];
      }

      isRegistered().then((result) async {
        if (result) {
          _globals.setFilePickerGlobal();
          String userId = prefs.getString('userId');
          await _globals.getUserData(userId).then((CurupaUser user) async {
            if (Cache.appData.curupaGuest.isGuest) {
              Cache.appData.curupaGuest.user = user;
              Cache.appData.curupaGuest.phone = user.phone;
            } else {
              Cache.appData.curupaGuest.isGuest = false;
            }

            await _firebaseMessaging.getToken().then((token) async {
              Map<String, dynamic> data = new Map<String, dynamic>();
              if (isPhysicalDevice) {
                data['token'] = token;
              }
              data['device'] = device;
              await Auth.updateUser(userId, data).then((CurupaUser user) async {
                Cache.appData.user.token = token;
              });
            });

            Cache.appData.user = user;
            _globals.getDrawers();

            if (user.smsChecked == null) {
              showDialog(
                context: context,
                builder: (BuildContext context) => new SMSDialog(
                    userId: user.userID, phone: Cache.appData.curupaGuest.phone),
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
    bool guest = (prefs.getBool('guest') ?? false);
    Cache.appData.curupaGuest.isGuest = guest;
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
        "Falta que tu referente de la camada ${Cache.appData.group.year} apruebe tu ingreso. Te va a llegar un mensaje de texto SMS cuando lo haga.";
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
      /*ScreenUtil.instance =
      ScreenUtil(width: 640, height: 1136, allowFontScaling: true)
        ..init(context);*/

      return ScreenUtilInit(
        designSize: Size(640, 1136),
        allowFontScaling: false,
        child: Stack(
          children: <Widget>[
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
                    padding:
                        EdgeInsets.only(bottom: ScreenUtil().setHeight(50.0)),
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
          ],
        ),
      );
    } else {
      int _length = Cache.appData.drawerContent.contents.length;
      return Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          elevation: 0.5,
          leading: new IconButton(
              icon: new Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState.openDrawer()),
          title: Text(pageTitle),
          centerTitle: true,
          actions: <Widget>[
            currentIconButton,
            Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: PopupMenuButton<PopChoice>(
                onSelected: _select,
                itemBuilder: (BuildContext context) {
                  return currentChoice.map((PopChoice choice) {
                    return PopupMenuItem<PopChoice>(
                      value: choice,
                      child: new GestureDetector(
                          onTap: () {
                            print("Clicked choice : ${choice.id}");
                            _runPopChoice(choice);
                          },
                          child: Row(children: <Widget>[
                            Icon(choice.icon),
                            VerticalDivider(color: Colors.white, width: 10),
                            Text(choice.title),
                          ])),
                    );
                  }).toList();
                },
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView.separated(
            itemCount: _length,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _createHeader();
              } else {
                HTML contentHtml = Cache.appData.drawerContent.contents[index];
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
              currentTab = index;
              pageTitle = pageTitles[index];
              currentPage = pages[index];
              currentIconButton = navBarIcons[index];
              currentChoice = pop_choices[index];
            });
          },
        ),
      );
    }
  }

  void _runPopChoice(PopChoice choice) {
    if (currentPage == one) {
    } else if (currentPage == two) {
    } else if (currentPage == three) {
    } else if (currentPage == four) {
    } else if (currentPage == five) {
      if (choice.id == 2) {
        //Logout
        // TODO: 41.1 "Salir" is working though should quit the main screen and go back to the sign_up.dat
        _showLogoutDialog(context);
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancelar"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Salir"),
      onPressed: () {
        _logOut();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Consulta"),
      content: Text("¿Queres salir de la aplicación?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
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
              child: Text("Versión ${Cache.appData.description.version}",
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

  void listenNotifications() async {
    if (Platform.isIOS) iOS_Permission();

    _firebaseMessaging.requestPermission();

    // Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        Navigator.pushNamed(context, '/message',
            arguments: MessageArguments(message, true));
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                // TODO: add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: 'launch_background',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      Navigator.pushNamed(context, '/message',
          arguments: MessageArguments(message, true));
    });

    /*_firebaseMessaging.configure(
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
    );*/
  }

  void iOS_Permission() {
    _firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);
    /*_firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });*/
  }

  void updeteWidget() {
    group = Cache.appData.group.year;

    if (Cache.appData.curupaGuest.isGuest) {
      pageTitles = ["Home", "Calendario", "Streaming", "Perfil"];
    } else {
      pageTitles = ["Home", "Calendario", "Streaming", group, "Perfil"];
    }

    pageTitle = pageTitles[0];

    TabData home = new TabData(iconData: Icons.home, title: pageTitles[0]);
    TabData calendar_today =
        new TabData(iconData: Icons.calendar_today, title: pageTitles[1]);
    TabData videoCam =
        new TabData(iconData: Icons.videocam, title: pageTitles[2]);
    TabData group_work, account_circle;

    if (Cache.appData.curupaGuest.isGuest) {
      account_circle =
          new TabData(iconData: Icons.account_circle, title: pageTitles[3]);
    } else {
      group_work =
          new TabData(iconData: Icons.group_work, title: pageTitles[3]);
      account_circle =
          new TabData(iconData: Icons.account_circle, title: pageTitles[4]);
    }

    List<TabData> tabs;

    if (Cache.appData.curupaGuest.isGuest) {
      tabs = [home, calendar_today, videoCam, account_circle];
    } else {
      tabs = [home, calendar_today, videoCam, group_work, account_circle];
    }

    tabItems = List.of(tabs);

    int length = tabItems.length;

    one = new HomePage(
      key: keyOne,
    );

    two = new CalendarPage(
      key: keyTwo,
    );

    three = new StreamingPage(
      key: keyThree,
    );

    four = new GroupPage(
      key: keyFour,
    );

    five = new ProfilePage(
      key: keyFive,
    );

    if (Cache.appData.curupaGuest.isGuest) {
      navBarIcons = [_home, _calendar, _videos, _profile];
    } else {
      navBarIcons = [_home, _calendar, _videos, _group, _profile];
    }

    if (Cache.appData.curupaGuest.isGuest) {
      pop_choices = [
        choice_home,
        choice_calendar,
        choice_videos,
        choice_profile
      ];
    } else {
      pop_choices = [
        choice_home,
        choice_calendar,
        choice_videos,
        choice_group,
        choice_profile
      ];
    }

    setState(() {
      if (Cache.appData.curupaGuest.isGuest) {
        pages = [one, two, three, five];
      } else {
        pages = [one, two, three, four, five];
      }
      currentPage = one;
      currentChoice = choice_home;
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
    prefs.setBool('guest', false);
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
