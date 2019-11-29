import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingWidget extends StatefulWidget {
  MessagingWidget({Key key}) : super(key: key);
  _MessagingWidgetState createState() => _MessagingWidgetState();
}

class _MessagingWidgetState extends State<MessagingWidget> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      _firebaseMessaging
          .requestNotificationPermissions(const IosNotificationSettings(
        badge: true,
        sound: true,
        alert: true,
      ));
      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });
    }
    _firebaseMessaging.configure(onLaunch: (Map<String, dynamic> message) {
      print('On Launch: ' + message.toString());
    }, onMessage: (Map<String, dynamic> message) {
      print('On Message: ' + message.toString());
    }, onResume: (Map<String, dynamic> message) {
      print('On Resume: ' + message.toString());
    });
    _firebaseMessaging.getToken().then((token) {
      print(token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox
        .shrink(); //I return this because builder can't return a null object
  }
}
