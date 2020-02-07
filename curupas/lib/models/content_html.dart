import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ContentHtml {

  final String documentID;
  final String html;
  final String name;
  final String database_ref;
  final DocumentReference group_ref;
  final String icon;
  final DateTime last_update;

  ContentHtml({
    this.documentID,
    this.html,
    this.name,
    this.database_ref,
    this.group_ref,
    this.icon,
    this.last_update,
  });

  Map<String, Object> toJson() {
    return {
      'documentID': documentID,
      'html': html,
      'name': name,
      'database_ref': database_ref,
      'group_ref': group_ref,
      'icon': icon,
      'last_update' : last_update
    };
  }

  factory ContentHtml.fromJson(Map<String, Object> doc) {

    Timestamp timestamp = doc["last_update"] as Timestamp;
    var format = new DateFormat('d MMM, hh:mm a');
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);

    ContentHtml content_html = new ContentHtml(
      html: doc['html'],
      documentID: doc['documentID'],
      name: doc['name'],
      database_ref: doc['database_ref'],
      group_ref: doc['group_ref'],
      icon: doc['icon'],
      last_update: date,
    );
    return content_html;
  }

  factory ContentHtml.fromDocument(DocumentSnapshot doc) {
    return ContentHtml.fromJson(doc.data);
  }
}