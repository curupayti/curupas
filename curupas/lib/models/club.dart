import 'package:cloud_firestore/cloud_firestore.dart';

class Club {

  final String id;
  final String name;
  //final String site;
  //final String address;
  //final String documentID;

  Club({this.id, this.name});

  factory Club.fromJson(Map<String, Object> doc, String documentId) {
    Club club = new Club(name:documentId);
    return club;
  }

  //doc['name']

  factory Club.fromDocument(DocumentSnapshot doc) {
    String documentId = doc.id;
    return Club.fromJson(doc.data(), documentId);
  }
}
