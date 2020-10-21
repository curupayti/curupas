import 'package:cloud_firestore/cloud_firestore.dart';

import 'group_media.dart';

class Group {
  final String year;
  final String documentID;
  List<GroupMedia> medias;
  final DocumentReference yearRef;

  Group({this.year, this.documentID, this.yearRef});

  Map<String, Object> toJson() {
    return {'year': year, 'documentID': documentID, 'yearRef': yearRef};
  }

  factory Group.fromJson(Map<String, Object> doc, String documentID, DocumentReference yearRef) {
    Group group = new Group(
      year: doc['year'],
      //documentID: doc['documentID'],
      documentID: documentID,
      //yearRef: doc['yearRef'],
      yearRef: yearRef,
    );
    return group;
  }

  factory Group.fromDocument(DocumentSnapshot doc) {
    String documentID = doc.documentID;
    DocumentReference yearRef = doc.reference;
    return Group.fromJson(doc.data(), documentID, yearRef);
  }
}
