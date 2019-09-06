import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String year;
  final String documentID;

  Group({
    this.year,
    this.documentID,
  });

  Map<String, Object> toJson() {
    return {
      'year': year,
      'documentID': documentID,
    };
  }

  factory Group.fromJson(Map<String, Object> doc) {
    Group group = new Group(
      year: doc['year'],
      documentID: doc['documentID'],
    );
    return group;
  }

  factory Group.fromDocument(DocumentSnapshot doc) {
    return Group.fromJson(doc.data);
  }
}
