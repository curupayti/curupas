import 'package:flutter/material.dart';
import 'package:notifier/notifier_provider.dart';
import 'package:onboarding_flow/ui/screens/feed/feed_swiper_screen.dart';
import 'package:onboarding_flow/ui/screens/group_screen.dart';
import 'package:onboarding_flow/ui/screens/main_screen.dart';
import 'package:onboarding_flow/ui/screens/sign_in_screen.dart';
import "package:onboarding_flow/ui/screens/walk_screen.dart";
import 'package:onboarding_flow/ui/screens/root_screen.dart';
import 'package:onboarding_flow/ui/screens/sign_up_screen.dart';
import 'package:onboarding_flow/ui/screens/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/feeds.dart';

void main() {
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true);
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
        '/root': (BuildContext context) => new RootScreen(),
        '/signin': (BuildContext context) => new SignInScreen(),
        '/signup': (BuildContext context) => new SignUpScreen(),
        '/group': (BuildContext context) => new GroupScreen(),
        '/main': (BuildContext context) => new MainScreen(),
        //'/feedswipe': (BuildContext context) => new FeedSwipeScreen(),
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
          return new RootScreen();
        } else {
          return new GroupScreen();
        }
      } else {
        return new RootScreen();
      }
    } else {
      return new WalkthroughScreen(prefs: prefs);
    }
  }
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/feedswipe':
        if (args is Feed) {
          return MaterialPageRoute(
            builder: (_) => FeedSwipeScreen(
              feed: args,
            ),
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
