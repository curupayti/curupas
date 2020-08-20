import 'package:curupas/models/notification.dart';
import 'package:flutter/material.dart';

class NotificationDetails extends StatefulWidget {
  final NotificationCloud notification;

  NotificationDetails({Key key, @required this.notification}) : super(key: key);

  @override
  _NotificationDetailsState createState() => _NotificationDetailsState();
}

class _NotificationDetailsState extends State<NotificationDetails> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Center(
              child: Container(
                height: 120,
                width: 120,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.notification.imageURL),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              widget.notification.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              widget.notification.notification,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
