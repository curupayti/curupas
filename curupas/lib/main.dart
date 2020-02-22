import 'package:curupas/models/content_html.dart';
import 'package:curupas/ui/screens/drawer/content_viewer.dart';
import 'package:curupas/ui/screens/widgets/youtube/player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notifier/notifier_provider.dart';
import 'package:curupas/ui/screens/post/post_swiper_screen.dart';
import 'package:curupas/ui/screens/group_screen.dart';
import 'package:curupas/ui/screens/main_screen.dart';
import 'package:curupas/ui/screens/sign_in_screen.dart';
import "package:curupas/ui/screens/walk_screen.dart";
import 'package:curupas/ui/screens/sign_up_screen.dart';
import 'package:curupas/ui/screens/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/post.dart';
import 'models/streaming.dart';

//Flutter awesome
//https://github.com/leisim/awesome-flutter-packages

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firestore.instance.settings();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SharedPreferences.getInstance().then((prefs) {
    runApp(
      NotifierProvider(
        child: CurupaApp(prefs: prefs),
      ),
    );
  });
}

class CurupaApp extends StatelessWidget {
  final SharedPreferences prefs;
  CurupaApp({this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Curupa',
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/walkthrough': (BuildContext context) => new WalkthroughScreen(),
        '/welcomeScreen': (BuildContext context) => new WelcomeScreen(),
        '/signin': (BuildContext context) => new SignInScreen(),
        '/signup': (BuildContext context) => new SignUpScreen(),
        '/group': (BuildContext context) => new GroupScreen(),
        '/main': (BuildContext context) => new MainScreen(),
      },
      theme: ThemeData(
        primaryColor: Colors.white,
        primarySwatch: Colors.grey,
      ),
      home: _handleCurrentScreen(),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }

  Widget _handleCurrentScreen() {
    bool seen = (prefs.getBool('seen') ?? false);
    bool registered = (prefs.getBool('registered') ?? false);
    bool group = (prefs.getBool('group') ?? false);
    if (seen) {
      if (registered) {
        if (group) {
          return new MainScreen();
        } else {
          return new GroupScreen();
        }
      } else {
        return new WelcomeScreen();
      }
    } else {
      return new WalkthroughScreen(prefs: prefs);
    }
  }
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    String set = settings.name;
    print(set);
    switch (settings.name) {
      case '/postswipe':
        if (args is Post) {
          return MaterialPageRoute(
            builder: (_) => PostSwipeScreen(
              post: settings.arguments,
            ),
          );
        }
        break;
      case '/contentviewer':
        if (args is ContentHtml) {
          return MaterialPageRoute(
            builder: (_) => ContentViewer(
              contentHtml: settings.arguments,
            ),
          );
        }
        break;
      case '/videoplayer':
        if (args is Streaming) {
          return MaterialPageRoute(
            builder: (_) =>

                //_FullScreenYoutubePlayer(
                //  streaming: settings.arguments,
                //)
                PlayerScreen(),
          );
        }
        return _errorRoute();
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
