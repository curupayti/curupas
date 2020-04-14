import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'group_media.dart';

class NotificationCloud {
  final String documentID;
  final String title;
  final String imageURL;
  final String thumbnailImageURL;
  final String notification;
  final DateTime last_update;

  NotificationCloud({
    this.documentID,
    this.title,
    this.imageURL,
    this.thumbnailImageURL,
    this.notification,
    this.last_update
  });

  Map<String, Object> toJson() {
    return {
      'documentID': documentID,
      'title': title,
      'title': imageURL,
      'title': thumbnailImageURL,
      'title': notification
    };
  }

  factory NotificationCloud.fromJson(Map<String, Object> doc, String documentID) {

    Timestamp timestamp = doc["last_update"] as Timestamp;
    //var format = new DateFormat('d MMM, hh:mm a');
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);

    NotificationCloud noti = new NotificationCloud(
      documentID: documentID,
      title: doc['title'],
      imageURL: doc['imageURL'],
      thumbnailImageURL: doc['thumbnailImageURL'],
      notification: doc['notification'],
      last_update: date,
    );
    return noti;
  }

  factory NotificationCloud.fromDocument(DocumentSnapshot doc) {
    String documentID = doc.documentID;
    return NotificationCloud.fromJson(doc.data, documentID);
  }
}
