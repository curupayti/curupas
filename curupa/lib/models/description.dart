import 'package:cloud_firestore/cloud_firestore.dart';

class Description {
  final String desc;
  final String documentID;

  Description({
    this.desc,
    this.documentID,
  });

  Map<String, Object> toJson() {
    return {
      'desc': desc,
      'documentID': documentID,
    };
  }

  factory Description.fromJson(Map<String, Object> doc, String documentID) {
    Description title = new Description(
      desc: doc['desc'],
      documentID: documentID,
    );
    return title;
  }

  factory Description.fromDocument(DocumentSnapshot doc) {
    return Description.fromJson(doc.data, doc.documentID);
  }
}
