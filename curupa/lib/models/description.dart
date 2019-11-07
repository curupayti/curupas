import 'package:cloud_firestore/cloud_firestore.dart';

class Description {
  final String title;
  final String description;
  final String documentID;

  Description({
    this.title,
    this.description,
    this.documentID,
  });

  Map<String, Object> toJson() {
    return {
      'title': title,
      'description': description,
      'documentID': documentID,
    };
  }

  factory Description.fromJson(Map<String, Object> doc, String documentID) {
    Description description = new Description(
      title: doc['title'],
      description: doc['description'],
      documentID: documentID,
    );
    return description;
  }

  factory Description.fromDocument(DocumentSnapshot doc) {
    return Description.fromJson(doc.data, doc.documentID);
  }
}
