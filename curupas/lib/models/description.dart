import 'package:cloud_firestore/cloud_firestore.dart';

class Description {

  final String title;
  final String description;
  final String documentID;
  final String version;

  Description({
    this.title,
    this.description,
    this.documentID,
    this.version,
  });

  Map<String, Object> toJson() {
    return {
      'title': title,
      'description': description,
      'documentID': documentID,
      'version': version,
    };
  }

  factory Description.fromJson(Map<String, Object> doc, String documentID) {
    Description description = new Description(
      title: doc['title'],
      description: doc['description'],
      documentID: documentID,
      version: doc['version'],
    );
    return description;
  }

  factory Description.fromDocument(DocumentSnapshot doc) {
    return Description.fromJson(doc.data, doc.documentID);
  }

}
