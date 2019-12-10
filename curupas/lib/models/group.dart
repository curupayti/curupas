import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String year;
  final String documentID;
  final DocumentReference yearRef;

  Group({this.year, this.documentID, this.yearRef});

  Map<String, Object> toJson() {
    return {'year': year, 'documentID': documentID, 'yearRef': yearRef};
  }

  factory Group.fromJson(Map<String, Object> doc) {
    Group group = new Group(
      year: doc['year'],
      documentID: doc['documentID'],
      yearRef: doc['yearRef'],
    );
    return group;
  }

  factory Group.fromDocument(DocumentSnapshot doc) {
    return Group.fromJson(doc.data);
  }
}
