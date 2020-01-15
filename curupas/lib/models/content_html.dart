import 'package:cloud_firestore/cloud_firestore.dart';

class ContentHtml {

  final String documentID;
  final String html;
  final String name;
  final String database_ref;


  ContentHtml({this.documentID, this.html, this.name, this.database_ref});

  Map<String, Object> toJson() {
    return {'documentID': documentID, 'html': html, 'name': name, 'database_ref': database_ref};
  }

  factory ContentHtml.fromJson(Map<String, Object> doc) {
    ContentHtml content_html = new ContentHtml(
      html: doc['html'],
      documentID: doc['documentID'],
      name: doc['name'],
      database_ref: doc['database_ref'],
    );
    return content_html;
  }

  factory ContentHtml.fromDocument(DocumentSnapshot doc) {
    return ContentHtml.fromJson(doc.data);
  }
}