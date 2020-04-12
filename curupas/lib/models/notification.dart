import 'package:cloud_firestore/cloud_firestore.dart';

import 'group_media.dart';

class Notification {
  final String documentID;
  final String title;
  final String imageURL;
  final String thumbnailImageURL;
  final String notification;

  Notification({
    this.documentID,
    this.title,
    this.imageURL,
    this.thumbnailImageURL,
    this.notification});

  Map<String, Object> toJson() {
    return {
      'documentID': documentID,
      'title': title,
      'title': imageURL,
      'title': thumbnailImageURL,
      'title': notification
    };
  }

  factory Notification.fromJson(Map<String, Object> doc, String documentID) {
    Notification group = new Notification(
      documentID: documentID,
      title: doc['title'],
      imageURL: doc['imageURL'],
      thumbnailImageURL: doc['thumbnailImageURL'],
      notification: doc['notification'],
    );
    return group;
  }

  factory Notification.fromDocument(DocumentSnapshot doc) {
    String documentID = doc.documentID;
    return Notification.fromJson(doc.data, documentID);
  }
}
