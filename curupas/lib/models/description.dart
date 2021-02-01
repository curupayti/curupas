import 'package:cloud_firestore/cloud_firestore.dart';

class Description {

  final String title;
  final String description;
  final String documentID;
  String version;
  String appName;
  String packageName;
  String buildNumber;

  Description({
    this.title,
    this.description,
    this.documentID,
    this.version,
    this.appName,
    this.packageName,
    this.buildNumber,
  });

  Map<String, Object> toJson() {
    return {
      'title': title,
      'description': description,
      'documentID': documentID,
      'version': version,
      'appName': appName,
      'packageName': packageName,
      'buildNumber': buildNumber,
    };
  }

  factory Description.fromJson(Map<String, Object> doc, String documentID) {
    Description description = new Description(
      title: doc['title'],
      description: doc['description'],
      documentID: documentID,
      version: doc['version'],
      appName: doc['appName'],
      packageName: doc['packageName'],
      buildNumber: doc['buildNumber'],
    );
    return description;
  }

  factory Description.fromDocument(DocumentSnapshot doc) {
    return Description.fromJson(doc.data(), doc.id);
  }

}
