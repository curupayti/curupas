import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String year;
  final String documentID;
  final CollectionReference media;

  Group({this.year, this.documentID, this.media});

  Map<String, Object> toJson() {
    return {
      'year': year,
      'documentID': documentID,
      'media': media,
    };
  }

  factory Group.fromJson(Map<String, Object> doc) {
    Group group = new Group(
      year: doc['year'],
      documentID: doc['documentID'],
      media: doc['media'],
    );
    return group;
  }

  factory Group.fromDocument(DocumentSnapshot doc) {
    return Group.fromJson(doc.data);
  }
}
